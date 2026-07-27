# Notebook: nb_maintenance_backup_to_temp
# Layer:    Bronze (lh_bronze) + Silver (lh_silver)
# Purpose:  One-time pre-deployment backup. For each target schema it DEEP CLONEs
#           every table into a sibling "<schema>_temp" schema (same lakehouse),
#           verifies row counts, then — only once every clone is verified —
#           empties the originals by dropping their tables, leaving the target
#           schema present but empty so the updated pipeline recreates the tables
#           fresh with the new structure.
#
#           Target schemas (default):
#             lh_bronze : bronze_eqwarehouse, bronze_hubspot, bronze_webex
#             lh_silver : silver_s1, silver_s2
#
#           silver_s2 contains Materialized Lake Views (MLVs), not plain tables.
#           MLVs are derived from silver_s1 and are recreated by the pipeline
#           (ensure_mlv_and_refresh), so for MLV schemas the notebook snapshots
#           the materialized data with CTAS and drops the originals with
#           DROP MATERIALIZED LAKE VIEW. List such schemas in p_view_schemas.
#
# Safety model:
#   - p_dry_run = True             → report the plan only; nothing is written.
#   - Clone + verify ALWAYS run before any drop.
#   - Originals are dropped ONLY when p_drop_originals = True AND every clone in
#     the run verified (row counts matched). A single clone/verify failure
#     cancels the entire drop phase — nothing is dropped.
#   - Re-runnable: clones use CREATE OR REPLACE; a source that is already gone
#     (backed up on a prior run) is skipped, not treated as an error.
#
# Recommended rollout (three passes):
#   1. p_dry_run=True                                  → review the plan.
#   2. p_dry_run=False, p_drop_originals=False         → back up + verify only.
#      Inspect the *_temp schemas / counts.
#   3. p_dry_run=False, p_drop_originals=True          → drop the originals.
#   Keep the *_temp schemas until the test load is validated — they are the
#   rollback. Drop them with a separate cleanup only after sign-off.
#
# Pre-requisites:
#   - Attach BOTH lh_bronze and lh_silver to this notebook session
#     (Notebook settings -> Lakehouses -> Add) so SHOW SCHEMAS sees every
#     target schema. Schema names are unique across the two lakehouses, so each
#     is matched by its schema (last) name and cloned within its own lakehouse.

import time
from pyspark.sql import SparkSession

spark = SparkSession.builder.appName("nb_maintenance_backup_to_temp").getOrCreate()
# Backups may read parquet written by older engines — keep reads permissive.
spark.conf.set("spark.sql.parquet.datetimeRebaseModeInRead", "LEGACY")
spark.conf.set("spark.sql.parquet.int96RebaseModeInRead",    "LEGACY")

_notebook_start = time.time()

# ══════════════════════════════════════════════════════════════════════════════
# SECTION 1 — Parameters
# Cell tag: parameters — Fabric Pipeline injects values at runtime.
# ══════════════════════════════════════════════════════════════════════════════

p_target_schemas  = "bronze_eqwarehouse,bronze_hubspot,bronze_webex,silver_s1,silver_s2"
p_view_schemas    = "silver_s2"   # schemas whose objects are MLVs (special handling)
p_temp_suffix     = "_temp"       # backup schema suffix
p_dry_run         = True          # True = report plan only, no writes
p_drop_originals  = False         # True = drop originals AFTER all clones verified

print("=" * 74)
print("  nb_maintenance_backup_to_temp — START")
print("=" * 74)
print(f"  target schemas   : {p_target_schemas}")
print(f"  view (MLV) schemas: {p_view_schemas or '(none)'}")
print(f"  temp suffix      : {p_temp_suffix}")
print(f"  dry run          : {p_dry_run}")
print(f"  drop originals   : {p_drop_originals}")
print("=" * 74)

# ══════════════════════════════════════════════════════════════════════════════
# SECTION 2 — Discover target schemas and their tables
#
# SHOW SCHEMAS returns a "namespace" column with three-part values
# (workspace.lakehouse.schema). Each part must be backtick-quoted individually.
# ══════════════════════════════════════════════════════════════════════════════

def _quote_ns(namespace: str) -> str:
    """Backtick-quote each part of a dot-separated namespace for Spark SQL."""
    return ".".join(f"`{p}`" for p in namespace.split("."))

def _temp_namespace(namespace: str) -> str:
    """Return the sibling backup namespace: <ws>.<lh>.<schema><suffix>."""
    parts = namespace.split(".")
    parts[-1] = parts[-1] + p_temp_suffix
    return ".".join(parts)

_targets = {s.strip().lower() for s in p_target_schemas.split(",") if s.strip()}
_views   = {s.strip().lower() for s in p_view_schemas.split(",") if s.strip()}

if not _targets:
    raise ValueError("p_target_schemas is empty — nothing to back up.")

# Namespaces whose schema (last part) is a requested target, excluding any that
# are themselves *_temp (so re-runs never back up a backup).
all_namespaces = [
    row["namespace"]
    for row in spark.sql("SHOW SCHEMAS").collect()
    if row["namespace"].split(".")[-1].lower() in _targets
    and not row["namespace"].split(".")[-1].lower().endswith(p_temp_suffix.lower())
]

_found = {ns.split(".")[-1].lower() for ns in all_namespaces}
_missing = _targets - _found
if _missing:
    # A requested schema not visible in the session is almost always a missing
    # lakehouse attachment — fail loudly rather than silently skipping a backup.
    raise ValueError(
        f"Target schema(s) not found in this session: {sorted(_missing)}. "
        f"Attach the owning lakehouse(s) (lh_bronze and lh_silver) and re-run."
    )

print(f"Schemas to back up : {len(all_namespaces)}")

# (source_ns, temp_ns, schema_label, table, is_view)
work = []
for ns in sorted(all_namespaces):
    label   = ns.split(".")[-1]
    is_view = label.lower() in _views
    rows    = spark.sql(f"SHOW TABLES IN {_quote_ns(ns)}").collect()
    objs    = [r["tableName"] for r in rows if not r["isTemporary"]]
    print(f"  {label}: {len(objs)} object(s){'  [MLV schema]' if is_view else ''}")
    for t in objs:
        work.append((ns, _temp_namespace(ns), label, t, is_view))

print(f"\nTotal objects to back up: {len(work)}\n")

# ══════════════════════════════════════════════════════════════════════════════
# SECTION 3 — Phase 1: clone every object into its *_temp schema and verify
# ══════════════════════════════════════════════════════════════════════════════

cloned      = []   # (display, method, rows)
verify_fail = []   # (display, detail)
clone_error = []   # (display, message)
skipped_src = []   # source already gone (prior-run backup)

# Ensure each *_temp schema exists once (skipped on dry run).
_temp_ns_set = sorted({tn for _, tn, _, _, _ in work})
if not p_dry_run:
    for tn in _temp_ns_set:
        spark.sql(f"CREATE SCHEMA IF NOT EXISTS {_quote_ns(tn)}")
        print(f"  ensured schema  {tn}")
    print("")

for src_ns, temp_ns, label, table, is_view in work:
    src     = f"{_quote_ns(src_ns)}.`{table}`"
    dst     = f"{_quote_ns(temp_ns)}.`{table}`"
    display = f"{label}.{table}"
    t0 = time.time()

    if not spark.catalog.tableExists(f"{src_ns}.{table}"):
        skipped_src.append(display)
        print(f"  SKIP SRC GONE {display:<52} — source absent (already backed up?)")
        continue

    try:
        rows_src = spark.table(src).count()
    except Exception as e:
        clone_error.append((display, f"read source failed: {e}"))
        print(f"  ERROR         {display}: {e}")
        continue

    if p_dry_run:
        _how = "CTAS (MLV)" if is_view else "DEEP CLONE"
        print(f"  WOULD BACKUP  {display:<52} — {rows_src:,} rows via {_how} -> {temp_ns}")
        cloned.append((display, _how, rows_src))
        continue

    # MLV schemas: DEEP CLONE does not apply to views — snapshot with CTAS.
    # Table schemas: prefer DEEP CLONE (preserves Delta history); fall back to
    # CTAS if the engine refuses (e.g. the object is a view).
    method = None
    try:
        if is_view:
            spark.sql(f"CREATE OR REPLACE TABLE {dst} AS SELECT * FROM {src}")
            method = "CTAS (MLV)"
        else:
            spark.sql(f"CREATE OR REPLACE TABLE {dst} DEEP CLONE {src}")
            method = "DEEP CLONE"
    except Exception as e_clone:
        try:
            spark.sql(f"CREATE OR REPLACE TABLE {dst} AS SELECT * FROM {src}")
            method = "CTAS (fallback)"
            print(f"  NOTE          {display}: DEEP CLONE failed, used CTAS ({e_clone})")
        except Exception as e_ctas:
            clone_error.append((display, f"clone failed: {e_ctas}"))
            print(f"  ERROR         {display}: {e_ctas}")
            continue

    # Verify row counts match.
    try:
        rows_dst = spark.table(dst).count()
    except Exception as e:
        clone_error.append((display, f"read backup failed: {e}"))
        print(f"  ERROR         {display}: {e}")
        continue

    if rows_dst != rows_src:
        verify_fail.append((display, f"src={rows_src:,} dst={rows_dst:,}"))
        print(f"  VERIFY FAIL   {display:<52} — src={rows_src:,} dst={rows_dst:,}")
        continue

    cloned.append((display, method, rows_dst))
    print(f"  BACKED UP     {display:<52} — {rows_dst:,} rows via {method} ({time.time()-t0:.1f}s)")

_clone_ok      = len(clone_error) == 0 and len(verify_fail) == 0
_have_failures = not _clone_ok

# ══════════════════════════════════════════════════════════════════════════════
# SECTION 4 — Phase 2: empty the originals (guarded)
# Runs ONLY when: not dry run, p_drop_originals, and every clone verified.
# ══════════════════════════════════════════════════════════════════════════════

dropped     = []
drop_error  = []
drop_ran    = False

if p_dry_run:
    if p_drop_originals:
        print(f"\n[DRY RUN] Would drop {len(work)} original object(s) after verified backup.")
elif not p_drop_originals:
    print("\nDrop phase skipped — p_drop_originals is False (backup-only run).")
elif _have_failures:
    print("\nDROP PHASE CANCELLED — one or more clones failed/could not be verified. "
          "No originals dropped. Resolve the failures above and re-run.")
else:
    drop_ran = True
    print(f"\nDropping {len(work)} original object(s) — every clone verified.")
    for src_ns, temp_ns, label, table, is_view in work:
        src     = f"{_quote_ns(src_ns)}.`{table}`"
        display = f"{label}.{table}"
        if not spark.catalog.tableExists(f"{src_ns}.{table}"):
            continue  # already gone
        try:
            # MLV schemas need DROP MATERIALIZED LAKE VIEW; plain schemas DROP TABLE.
            if is_view:
                try:
                    spark.sql(f"DROP MATERIALIZED LAKE VIEW IF EXISTS {src}")
                except Exception:
                    spark.sql(f"DROP TABLE IF EXISTS {src}")
            else:
                spark.sql(f"DROP TABLE IF EXISTS {src}")

            if spark.catalog.tableExists(f"{src_ns}.{table}"):
                raise RuntimeError("object still present after drop")
            dropped.append(display)
            print(f"  DROPPED       {display}")
        except Exception as e:
            drop_error.append((display, str(e)))
            print(f"  ERROR         {display}: {e}")

# ══════════════════════════════════════════════════════════════════════════════
# SECTION 5 — Summary
# ══════════════════════════════════════════════════════════════════════════════

_elapsed = round(time.time() - _notebook_start, 1)
print("\n" + "=" * 74)
print("  nb_maintenance_backup_to_temp — COMPLETE")
print(f"  Mode                  : {'DRY RUN' if p_dry_run else 'EXECUTE'}")
print(f"  Objects considered    : {len(work)}")
print(f"  {'Would back up' if p_dry_run else 'Backed up'}         : {len(cloned)}")
print(f"  Source already gone   : {len(skipped_src)}")
print(f"  Verify failures       : {len(verify_fail)}")
print(f"  Clone errors          : {len(clone_error)}")
if drop_ran or (p_dry_run and p_drop_originals):
    print(f"  Originals dropped     : {len(dropped)}")
    print(f"  Drop errors           : {len(drop_error)}")
if verify_fail:
    print("\n  Verify failures (row-count mismatch — NOT safe to drop):")
    for d, det in verify_fail:
        print(f"    {d}: {det}")
if clone_error:
    print("\n  Clone errors:")
    for d, m in clone_error:
        print(f"    {d}: {m}")
if drop_error:
    print("\n  Drop errors:")
    for d, m in drop_error:
        print(f"    {d}: {m}")
print("=" * 74)

# Fail the notebook if anything went wrong, so the pipeline stops before the
# destructive deploy proceeds on an incomplete/unverified backup.
_problems = len(verify_fail) + len(clone_error) + len(drop_error)
if _problems:
    raise RuntimeError(
        f"{_problems} problem(s) during backup/prep — see summary above. "
        f"Originals were {'partially dropped' if drop_error else 'NOT dropped'}."
    )
