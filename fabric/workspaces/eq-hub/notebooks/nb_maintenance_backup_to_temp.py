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
#     (Notebook settings -> Lakehouses -> Add). SHOW SCHEMAS only lists the
#     DEFAULT lakehouse's schemas, so this notebook does NOT rely on it — it
#     takes an explicit lakehouse->schemas map (p_schema_map) and enumerates
#     each lakehouse by name. Each schema is cloned within its own lakehouse.

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

# lakehouse -> schemas, as "lh:schemaA,schemaB;lh2:schemaC". Each schema is
# enumerated inside its named lakehouse (SHOW SCHEMAS is default-lakehouse only).
p_schema_map      = "lh_bronze:bronze_eqwarehouse,bronze_hubspot,bronze_webex;lh_silver:silver_s1,silver_s2"
p_view_schemas    = "silver_s2"   # schemas whose objects are MLVs (special handling)
p_temp_suffix     = "_temp"       # backup schema suffix
p_dry_run         = True          # True = report plan only, no writes
p_drop_originals  = False         # True = drop originals AFTER all clones verified

print("=" * 74)
print("  nb_maintenance_backup_to_temp — START")
print("=" * 74)
print(f"  schema map       : {p_schema_map}")
print(f"  view (MLV) schemas: {p_view_schemas or '(none)'}")
print(f"  temp suffix      : {p_temp_suffix}")
print(f"  dry run          : {p_dry_run}")
print(f"  drop originals   : {p_drop_originals}")
print("=" * 74)

# ══════════════════════════════════════════════════════════════════════════════
# SECTION 2 — Resolve each lakehouse.schema and list its tables
#
# Fabric table names are multi-part (workspace.lakehouse.schema.table) and each
# part must be backtick-quoted individually. SHOW SCHEMAS only returns the
# DEFAULT lakehouse's schemas, so for a non-default lakehouse we address it by
# name. We resolve the working namespace form per (lakehouse, schema) by trying
# the workspace-qualified form first, then shorter forms, using SHOW TABLES as
# the probe.
# ══════════════════════════════════════════════════════════════════════════════

def _quote(parts: list) -> str:
    """Backtick-quote each element of a namespace part list for Spark SQL."""
    return ".".join(f"`{p}`" for p in parts)

# Detect the workspace prefix from the default lakehouse's namespaces (if any
# are three-part: workspace.lakehouse.schema). May stay None on some versions.
_workspace = None
try:
    for _r in spark.sql("SHOW SCHEMAS").collect():
        _p = _r["namespace"].split(".")
        if len(_p) >= 3:
            _workspace = _p[0]
            break
except Exception:
    pass
print(f"  workspace prefix : {_workspace or '(not detected)'}\n")

def _resolve(lakehouse: str, schema: str):
    """Return the namespace part-list that Spark accepts for this
    lakehouse.schema, plus its table rows. Tries longest form first."""
    candidates = []
    if _workspace:
        candidates.append([_workspace, lakehouse, schema])
    candidates.append([lakehouse, schema])
    candidates.append([schema])   # only valid when lakehouse is the default
    last_err = None
    for parts in candidates:
        try:
            rows = spark.sql(f"SHOW TABLES IN {_quote(parts)}").collect()
            return parts, rows
        except Exception as e:
            last_err = e
    raise ValueError(
        f"Could not resolve '{lakehouse}.{schema}'. Is '{lakehouse}' attached to "
        f"this session? Tried {candidates}. Last error: {last_err}"
    )

def _obj_exists(parts: list, table: str) -> bool:
    """True if `table` currently exists under namespace `parts`."""
    return len(spark.sql(f"SHOW TABLES IN {_quote(parts)} LIKE '{table}'").collect()) > 0

# Parse the lakehouse -> schemas map.
_pairs = []
for chunk in [c for c in p_schema_map.split(";") if c.strip()]:
    lh, _, schemas = chunk.partition(":")
    lh = lh.strip()
    for sch in [s.strip() for s in schemas.split(",") if s.strip()]:
        if sch.lower().endswith(p_temp_suffix.lower()):
            continue  # never back up a backup
        _pairs.append((lh, sch))
if not _pairs:
    raise ValueError("p_schema_map is empty or malformed — nothing to back up.")

_views = {s.strip().lower() for s in p_view_schemas.split(",") if s.strip()}

# (src_parts, temp_parts, schema_label, table, is_view)
work = []
for lh, sch in _pairs:
    src_parts, rows = _resolve(lh, sch)
    temp_parts      = src_parts[:-1] + [src_parts[-1] + p_temp_suffix]
    is_view         = sch.lower() in _views
    objs            = [r["tableName"] for r in rows if not r["isTemporary"]]
    print(f"  {lh}.{sch}: {len(objs)} object(s){'  [MLV schema]' if is_view else ''}")
    for t in objs:
        work.append((src_parts, temp_parts, sch, t, is_view))

print(f"\nTotal objects to back up: {len(work)}\n")

# ══════════════════════════════════════════════════════════════════════════════
# SECTION 3 — Phase 1: clone every object into its *_temp schema and verify
# ══════════════════════════════════════════════════════════════════════════════

cloned      = []   # (display, method, rows)
verify_fail = []   # (display, detail)
clone_error = []   # (display, message)
skipped_src = []   # source already gone (prior-run backup)

# Ensure each *_temp schema exists once (skipped on dry run).
_temp_ns_set = {tuple(tp) for _, tp, _, _, _ in work}
if not p_dry_run:
    for tp in sorted(_temp_ns_set):
        spark.sql(f"CREATE SCHEMA IF NOT EXISTS {_quote(list(tp))}")
        print(f"  ensured schema  {'.'.join(tp)}")
    print("")

for src_parts, temp_parts, label, table, is_view in work:
    src     = f"{_quote(src_parts)}.`{table}`"
    dst     = f"{_quote(temp_parts)}.`{table}`"
    display = f"{label}.{table}"
    t0 = time.time()

    if not _obj_exists(src_parts, table):
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
        print(f"  WOULD BACKUP  {display:<52} — {rows_src:,} rows via {_how} -> {'.'.join(temp_parts)}")
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
    for src_parts, temp_parts, label, table, is_view in work:
        src     = f"{_quote(src_parts)}.`{table}`"
        display = f"{label}.{table}"
        if not _obj_exists(src_parts, table):
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

            if _obj_exists(src_parts, table):
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
