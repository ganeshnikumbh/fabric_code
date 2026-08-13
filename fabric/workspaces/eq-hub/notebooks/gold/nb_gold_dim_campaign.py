#!/usr/bin/env python
# coding: utf-8

# ## nb_gold_dim_campaign
# 
# New notebook

# In[1]:


# The command is not a standard IPython magic command. It is designed for use within Fabric notebooks only.
# %%configure
# {
#     "defaultLakehouse": {
#         "name":        { "variableName": "$(/**/vl_lakehouse_config/lh_silver_name)" },
#         "id":          { "variableName": "$(/**/vl_lakehouse_config/lh_silver_id)" },
#         "workspaceId": { "variableName": "$(/**/vl_lakehouse_config/lh_workspace_id)" }
#     }
# }


# In[2]:


# The command is not a standard IPython magic command. It is designed for use within Fabric notebooks only.
# %run nb_utils.py


# In[10]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 1 — Parameters
# Cell tag: parameters — Fabric Pipeline injects values at runtime.
# ══════════════════════════════════════════════════════════════════════════════

p_ingestion_date      = "2026-07-28"    # REQUIRED — e.g. "2025-04-09"
p_ingestion_timestamp = "2026-07-28T01:00:00Z"    # REQUIRED — e.g. "2025-04-09T01:00:00Z"
p_src_busn_asst       = "elic"    # REQUIRED — e.g. "elic"
p_ingestion_run_id = "040b71a5-97a3-4f91-8912-e4d9b802b109"


# In[11]:


# Notebook: nb_gold_dim_campaign
# Layer:    Gold
# Purpose:  Full-refresh load of gold.dim_campaign from
#           lh_silver.dbo.agent_base_current (SCD2 _current view).
#
#           agency_name is NOT available in agent_base; the column is written
#           as NULL until the source join path is confirmed (see open item #3 in
#           docs/gold_mapping_agent_training_star_schema.md).
#
# Write pattern: full OVERWRITE on every run.  Because the source is the
#                _current view (active records only), reloading the full table
#                is the safest way to keep the gold dim in sync.
#
# Pre-requisites:
#   - Attach lh_gold as the default lakehouse before running.
#   - lh_silver must be added to the notebook session
#     (Notebook settings → Lakehouses → Add).

import time

from pyspark.sql import SparkSession
from pyspark.sql import functions as F

spark = SparkSession.builder.appName("nb_gold_dim_campaign").getOrCreate()

_notebook_start = time.time()



_target_table = "lh_gold.gold.dim_campaign"
_business_key_cols = ['source_campaign_id','campaign_name','campaign_utm']   # list
_is_scd2           = True
_surrogate_key_col = "campaign_key"
_hash_col          = "md5_hash"

print("=" * 65)
print("  nb_gold_dim_campaign — START")
print("=" * 65)
print(f"  ingestion_date  : {p_ingestion_date}")
print(f"  src_busn_asst   : {p_src_busn_asst}")
print("=" * 65)


# In[12]:


compaign_dim_df = spark.sql(f'''select distinct
campaign_id as source_campaign_id,
campaign_name,
campaign_utm
from lh_silver.silver_s2.marketing_emails where campaign_id is not null
and ingestion_date = '{p_ingestion_date}'
''')


# In[13]:


display(compaign_dim_df.limit(2))


# In[14]:


compaign_dim_df = (
    compaign_dim_df
    # ── Surrogate key ──────────────────────────────────────────────────────
    # Input: all agent business columns (excludes audit + SCD2 metadata cols)
    .withColumn(_surrogate_key_col, make_surrogate_key(*[F.col(c) for c in _business_key_cols]))
    .select(
        _surrogate_key_col,
        "campaign_name",
        "campaign_utm",
        "source_campaign_id"
    )
)


# In[15]:


display(compaign_dim_df.limit(2))

#  ['agent_number','agent_name','agent_type','national_producer_number','nasd_finra_number','status'] 


# In[ ]:


# ── Load ──────────────────────────────────────────────────────────────────────

print(f"\n[2/4] Instantiating GoldLoader")

loader = GoldLoader(spark)  # noqa: F821  # type: ignore[name-defined]
print(f"  GoldLoader ready  : {len(loader._function_registry)} functions in registry")

print(f"  [load] Writing to '{_target_table}' (is_scd2={_is_scd2}) ...")

_load_start = time.time()
loader.load(
    df                = compaign_dim_df,
    target_table      = _target_table,
    is_scd2           = _is_scd2,
    business_key_cols = _business_key_cols,
    surrogate_key_col = _surrogate_key_col,
    hash_col          = _hash_col,
    ingestion_date = p_ingestion_date,
    data_timestamp = p_ingestion_timestamp,
    source_system = "HubSpot",
    ingestion_run_id = p_ingestion_run_id,
    ingestion_timestamp = p_ingestion_timestamp,
    src_busn_asst = p_src_busn_asst
)
print(f"  [load]  Complete  ({round(time.time() - _load_start, 2)}s)")


# In[ ]:


from delta.tables import DeltaTable  # noqa: F821  # type: ignore[import]

_unknown_df = spark.range(1).select(
    F.lit(-1)           .cast("long")      .alias("campaign_key"),
    F.lit("Unknown")                       .alias("campaign_name"),
    F.lit("Unknown")                       .alias("campaign_utm"),
    F.lit("Unknown")                       .alias("source_campaign_id"),
    F.lit(None)         .cast("timestamp") .alias("effective_timestamp"),
    F.lit(None)         .cast("timestamp") .alias("expiration_timestamp"),
    F.lit(1)            .cast("int")       .alias("is_current"),
    F.lit(None)         .cast("string")    .alias("md5_hash"),
    F.lit(None)         .cast("date")      .alias("ingestion_date"),
    F.lit(None)         .cast("timestamp") .alias("data_timestamp"),
    F.lit("EQ_Warehouse")                       .alias("source_system"),
    F.lit(None)         .cast("string")    .alias("ingestion_run_id"),
    F.lit(None)         .cast("timestamp") .alias("ingestion_timestamp"),
    F.lit("elic")                       .alias("src_busn_asst"),
)

(
    DeltaTable.forName(spark, _target_table).alias("tgt")
    .merge(_unknown_df.alias("src"), "tgt.campaign_key = src.campaign_key")
    .whenNotMatchedInsertAll()
    .execute()
)
print(f"  Unknown row (campaign_key=-1) ensured in '{_target_table}'")

