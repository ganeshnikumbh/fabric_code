#!/usr/bin/env python
# coding: utf-8

# ## nb_gold_dim_product_salesforce
#
# New notebook

# In[ ]:


# The command is not a standard IPython magic command. It is designed for use within Fabric notebooks only.
# %%configure
# {
#     "defaultLakehouse": {
#         "name":        { "variableName": "$(/**/vl_lakehouse_config/lh_silver_name)" },
#         "id":          { "variableName": "$(/**/vl_lakehouse_config/lh_silver_id)" },
#         "workspaceId": { "variableName": "$(/**/vl_lakehouse_config/lh_workspace_id)" }
#     }
# }


# In[ ]:


# The command is not a standard IPython magic command. It is designed for use within Fabric notebooks only.
# %run nb_utils.py


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 1 — Parameters
# Cell tag: parameters — Fabric Pipeline injects values at runtime.
# ══════════════════════════════════════════════════════════════════════════════

p_ingestion_date      = "2026-09-08"    # REQUIRED — e.g. "2025-04-09"
p_ingestion_timestamp = "2026-09-08T01:00:00Z"    # REQUIRED — e.g. "2025-04-09T01:00:00Z"
p_src_busn_asst       = "elic"    # REQUIRED — e.g. "elic"
p_ingestion_run_id    = "00000000-0000-0000-0000-000000000000"


# In[ ]:


# Notebook: nb_gold_dim_product_salesforce
# Layer:    Gold
# Purpose:  Top up gold.dim_product with the product names that appear only in
#           the Salesforce extract (task.product_c, event.product_c,
#           campaign.product_c).
#
# Mapping:  docs/salesforce/sf3/gold_mapping_document.md  section 3.5
# Build order: 5 of 10.
#
# ─────────────────────────────────────────────────────────────────────────────
# DESIGN NOTE — read before running
#
# Mapping section 3.5 says: "There is no product master in the extract -
# replace this with the real product master when one exists."  One DOES exist:
# gold.dim_product is already loaded from EQ_Warehouse by nb_gold_dim_product,
# and it already carries product_name and product_key.
#
# So this notebook does NOT build a second, competing product dimension.  It
# writes into the SAME conformed gold.dim_product, insert-only, and inserts a
# row only when the Salesforce product name is not already present.  That keeps
# `LEFT JOIN dim_product ON product_name` (used by dim_campaign, fact_activity
# and fact_campaign_performance) single-valued — a duplicate product_name would
# fan those joins out.
#
# If the team would rather keep the two masters apart, change _target_table
# below and repoint the product_key joins in the four notebooks that use it.
# ─────────────────────────────────────────────────────────────────────────────
#
# Write pattern: INSERT-ONLY (SCD Type 1), anti-joined on product_name.
#
# Pre-requisites:
#   - Attach lh_gold as the default lakehouse before running.
#   - lh_silver must be added to the notebook session.
#   - nb_gold_dim_product (EQ_Warehouse master) should run first.

import time

from pyspark.sql import SparkSession
from pyspark.sql import functions as F

spark = SparkSession.builder.appName("nb_gold_dim_product_salesforce").getOrCreate()

_notebook_start = time.time()

_target_table      = "lh_gold.gold.dim_product"
_is_scd2           = False
_surrogate_key_col = "product_key"
_hash_col          = "md5_hash"
_business_key_cols = ["product_name", "product_line", "product_family", "is_unknown_member"]

print("=" * 65)
print("  nb_gold_dim_product_salesforce — START")
print("=" * 65)
print(f"  target          : {_target_table}")
print(f"  ingestion_date  : {p_ingestion_date}")
print(f"  src_busn_asst   : {p_src_busn_asst}")
print("=" * 65)


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 2 — Distinct product names across the three Salesforce sources
# ══════════════════════════════════════════════════════════════════════════════
# 'NOT_PROVIDED' is the silver NULL sentinel; 'N/A' is a real source value that
# means the same thing.  Neither belongs in a dimension.

print(f"\n[1/4] Reading distinct product names from task, event and campaign")

product_df = spark.sql(f"""
WITH names AS (
    SELECT DISTINCT TRIM(t.product_c) AS product_name
    FROM   lh_silver.silver_s2.task t
    WHERE  t.ingestion_date = '{p_ingestion_date}'

    UNION

    SELECT DISTINCT TRIM(e.product_c) AS product_name
    FROM   lh_silver.silver_s2.event e
    WHERE  e.ingestion_date = '{p_ingestion_date}'

    UNION

    SELECT DISTINCT TRIM(c.product_c) AS product_name
    FROM   lh_silver.silver_s2.campaign c
    WHERE  c.ingestion_date = '{p_ingestion_date}'
)
SELECT
    product_name,

    -- Product line.  Confirm this rule with the product team — it is inferred
    -- from the brand names present in the extract, not from a source column.
    CASE
        WHEN product_name RLIKE '(?i)(Market|Certainty|Confidence|WealthMax|Bridge)'
             THEN 'Annuity'
        ELSE 'Unclassified'
    END                                                                 AS product_line,

    -- Family = the brand prefix, e.g. 'MarketSeven Index' -> 'Market'.
    CASE
        WHEN product_name LIKE 'Market%'     THEN 'Market'
        WHEN product_name LIKE 'Certainty%'  THEN 'Certainty'
        WHEN product_name LIKE 'Confidence%' THEN 'Confidence'
        WHEN product_name LIKE 'WealthMax%'  THEN 'WealthMax'
        WHEN product_name LIKE 'Bridge%'     THEN 'Bridge'
        ELSE SPLIT(product_name, ' ')[0]
    END                                                                 AS product_family,

    CAST(0 AS TINYINT)                                                  AS is_unknown_member

FROM names
WHERE product_name IS NOT NULL
  AND product_name <> 'NOT_PROVIDED'
  AND product_name <> 'N/A'
  AND product_name <> ''
""")

source_count = product_df.count()
print(f"  Distinct Salesforce product names : {source_count:,}")
display(product_df.limit(20))


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 3 — Keep only names the conformed dimension does not already hold
# ══════════════════════════════════════════════════════════════════════════════
# Anti-join on product_name (not on the surrogate key): the EQ_Warehouse rows
# derive their key from ten columns, so a name match would never show up as a
# key match, and we would insert a duplicate name.

if spark.catalog.tableExists(_target_table):
    _existing_names = spark.table(_target_table).select("product_name").distinct()
    product_df = product_df.join(_existing_names, on="product_name", how="left_anti")
    print(f"\n[2/4] Existing dim_product found — keeping only unseen product names")
else:
    print(f"\n[2/4] dim_product does not exist yet — first load")

gold_count = product_df.count()
print(f"  New product names to insert : {gold_count:,}")
display(product_df.limit(20))


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 4 — Load via GoldLoader (insert-only)
# ══════════════════════════════════════════════════════════════════════════════

print(f"\n[3/4] Instantiating GoldLoader")

loader = GoldLoader(spark)  # noqa: F821  # type: ignore[name-defined]
print(f"  GoldLoader ready  : {len(loader._function_registry)} functions in registry")

print(f"  [load] Writing to '{_target_table}' (is_scd2={_is_scd2}) ...")

_load_start = time.time()
loader.load(
    df                  = product_df,
    target_table        = _target_table,
    is_scd2             = _is_scd2,
    business_key_cols   = _business_key_cols,
    surrogate_key_col   = _surrogate_key_col,
    hash_col            = _hash_col,
    ingestion_date      = p_ingestion_date,
    data_timestamp      = p_ingestion_timestamp,
    source_system       = "Salesforce",
    ingestion_run_id    = p_ingestion_run_id,
    ingestion_timestamp = p_ingestion_timestamp,
    src_busn_asst       = p_src_busn_asst,
)
print(f"  [load]  Complete  ({round(time.time() - _load_start, 2)}s)")


# In[ ]:


# ── Unknown / default row (product_key = -1) ──────────────────────────────────
# nb_gold_dim_product already writes this row; here we only make sure it exists
# and that is_unknown_member is flagged on it (that column is new to the table).
from delta.tables import DeltaTable  # noqa: F821  # type: ignore[import]

_unknown_df = spark.range(1).select(
    F.lit(-1)        .cast("long")   .alias("product_key"),
    F.lit("Unknown")                 .alias("product_name"),
    F.lit("Unknown")                 .alias("product_line"),
    F.lit("Unknown")                 .alias("product_family"),
    F.lit(1)         .cast("tinyint").alias("is_unknown_member"),
)

(
    DeltaTable.forName(spark, _target_table).alias("tgt")
    .merge(_unknown_df.alias("src"), "tgt.product_key = src.product_key")
    .whenMatchedUpdate(set={"is_unknown_member": F.lit(1).cast("tinyint")})
    .whenNotMatchedInsertAll()
    .execute()
)
print(f"  Unknown row (product_key=-1) ensured in '{_target_table}'")


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 5 — Data quality
# ══════════════════════════════════════════════════════════════════════════════
# Duplicate product_name is the check that matters here: three downstream
# notebooks join this dimension by name, so a duplicate silently fans them out.

_dq = spark.sql(f"""
SELECT
    (SELECT COUNT(*) FROM (
        SELECT product_name FROM {_target_table}
        GROUP BY product_name HAVING COUNT(*) > 1
     ))                                                        AS dup_product_names,
    (SELECT COUNT(*) FROM {_target_table}
      WHERE product_name IN ('NOT_PROVIDED', 'N/A'))            AS sentinel_leak_rows
""").collect()[0]

print(f"\n[4/4] Data quality")
print(f"  duplicate product names : {_dq['dup_product_names']}")
print(f"  sentinel leak rows      : {_dq['sentinel_leak_rows']}")

if _dq["dup_product_names"] or _dq["sentinel_leak_rows"]:
    raise ValueError(
        f"[nb_gold_dim_product_salesforce] Hard data quality check failed: {_dq}"
    )


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 6 — Summary
# ══════════════════════════════════════════════════════════════════════════════

_elapsed = round(time.time() - _notebook_start, 2)

print("\n" + "=" * 65)
print("  nb_gold_dim_product_salesforce — COMPLETE")
print(f"  Salesforce product names : {source_count:,}")
print(f"  Newly inserted           : {gold_count:,}")
print(f"  Elapsed                  : {_elapsed}s")
print("=" * 65)

mssparkutils.notebook.exit("OK")  # noqa: F821  # type: ignore[name-defined]
