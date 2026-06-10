#!/usr/bin/env python
# coding: utf-8

# ## nb_gold_dim_policy
# 
# New notebook

# In[41]:


# The command is not a standard IPython magic command. It is designed for use within Fabric notebooks only.
# %run nb_utils.py


# In[1]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 1 — Parameters
# Cell tag: parameters — Fabric Pipeline injects values at runtime.
# ══════════════════════════════════════════════════════════════════════════════

p_ingestion_date      = "2026-04-22"    # REQUIRED — e.g. "2025-04-09"
p_ingestion_timestamp = "2026-04-22T01:00:00Z"    # REQUIRED — e.g. "2025-04-09T01:00:00Z"
p_src_busn_asst       = "elic"    # REQUIRED — e.g. "elic"


# In[43]:


# Notebook: nb_gold_dim_policy
# Layer:    Gold
# Purpose:  Full-refresh load of gold.dim_policy from
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
import re

spark = SparkSession.builder.appName("nb_gold_dim_policy").getOrCreate()

_notebook_start = time.time()


_target_table = "lh_gold.gold.dim_policy"
_business_key_cols = ['policy_number','policy_status_code']   # list
_is_scd2           = True
_surrogate_key_col = "policy_key"
_hash_col          = "md5_hash"

print("=" * 65)
print("  nb_gold_dim_policy — START")
print("=" * 65)
print(f"  ingestion_date  : {p_ingestion_date}")
print(f"  src_busn_asst   : {p_src_busn_asst}")
print("=" * 65)


# In[44]:


policy_dim_df = spark.sql('''
select 
c.contract_number as policy_number,
--c.product_id as source_product_id,
--c.owner_client_id as source_owner_client_id,
--c.owner_2_client_id as source_owner_2_client_id,
--c.annuitant_insured_client_id as source_annuitant_insured_client_id,
--c.annuitant_insured_2_client_id as source_annuitant_insured_2_client_id,
c.application_received_timestamp,
c.application_signed_timestamp,
c.issue_timestamp,
c.issue_state_code,
c.issue_age,
c.attained_age,
c.contract_status_code as policy_status_code,
--c.cost_basis,
--c.recovered_cost_basis,
c.qual_ind,
c.qual_type,
c.contract_option as policy_option,
c.certain_period,
c.mec_status_code,
c.related_contract_number as related_policy_number,
c.class_code,
c.underwriting_class,
c.underwriting_timestamp,
--c.funding_company_id as source_funding_company_id,
--c.source_key,
--c.contract_id as source_policy_id,
--c.surrender_id as source_surrender_id,
c.surrender_id,
-- all flags
CAST(is_spousal_continuation as INT) AS is_spousal_continuation,
CAST(is_supplemental_contract as INT) AS is_supplemental_contract,
CAST(is_qdro as INT) AS is_qdro,
CAST(is_rider_claim as INT) AS is_rider_claim,
CAST(is_roth_conversion as INT) AS is_roth_conversion,
CAST(is_internal_replacement as INT) AS is_internal_replacement,
CAST(is_partial_tax_conversion as INT) AS is_partial_tax_conversion,
CAST(is_waiver_in_effect as INT) AS is_waiver_in_effect,
CAST(is_e_delivery as INT) AS is_e_delivery,
case when c.start_timestamp < c.effective_timestamp then c.start_timestamp
else c.effective_timestamp end as effective_timestamp,
case when c.end_timestamp < c.expiration_timestamp then c.end_timestamp
else c.expiration_timestamp end as expiration_timestamp,
c.is_current  
from silver_s2.contract_base_current c''')


# In[45]:


display(policy_dim_df.limit(2))


# In[2]:


surrender_df = spark.sql(f'''select surrender_id,surrender_fund_number,surrender_state_code,
surrender_gender,surrender_risk_class,surrender_rule_start_date,surrender_rule_end_date
from (
select s.surrender_id,s.fund_number as surrender_fund_number,
s.state_code as surrender_state_code,
s.gender as surrender_gender,
s.risk_class as surrender_risk_class,
s.rule_start_date as surrender_rule_start_date,
s.rule_end_date as surrender_rule_end_date,
row_number() over(partition by s.surrender_id order by s.ingestion_date desc) as rnk
from silver_s2.surrender_base s
where ingestion_date <= '{p_ingestion_date}'
)
where rnk=1
''')


# In[47]:


policy_dim_df = policy_dim_df.join(surrender_df, on=["surrender_id"], how="left")


# In[48]:


display(policy_dim_df.limit(2))


# In[49]:


# ── 1. Slim contract to just what you need for the pivot ──────────
contract_slim = spark.table("silver_s2.contract_base_current") \
    .select(F.col("contract_number").alias("policy_number"), 
            "rider_group_key")

rider_df = spark.table("silver_s2.rider_group_base_current")   # rider_group_key, rider_code

# ── 2. Join slim contract to riders ───────────────────────────────
joined = contract_slim.join(rider_df, on="rider_group_key", how="left")

# ── 3. Discover distinct rider codes dynamically ──────────────────
rider_codes = sorted([
    row["rider_code"]
    for row in rider_df.select("rider_code").distinct().collect()
    if row["rider_code"] is not None
])

def safe_col_name(code):
    return "has_" + re.sub(r"[^a-zA-Z0-9]", "_", code)

# ── 4. Build flag columns ─────────────────────────────────────────
flag_cols = [
    F.max(F.when(F.col("rider_code") == code, 1).otherwise(0))
     .alias(safe_col_name(code))
    for code in rider_codes
]

# ── 5. Pivot — only 2 group keys needed ───────────────────────────
rider_flags = (
    joined
    .groupBy("policy_number")
    .agg(
        *flag_cols,
        F.count("rider_code").alias("total_riders")
    )
)

policy_dim_df = policy_dim_df.join(rider_flags, on=["policy_number"], how="left")


# In[50]:


display(policy_dim_df.limit(2))


# In[51]:


policy_dim_df = (
    policy_dim_df
    .withColumn(_surrogate_key_col, make_surrogate_key(*[F.col(c) for c in _business_key_cols]))
    .select(
        _surrogate_key_col,
        "policy_number",
        "application_received_timestamp",
        "application_signed_timestamp",
        "issue_timestamp",
        "issue_state_code",
        "issue_age",
        "attained_age",
        "policy_status_code",
        "qual_ind",
        "qual_type",
        "policy_option",
        "certain_period",
        "mec_status_code",
        "related_policy_number",
        "class_code",
        "underwriting_class",
        "underwriting_timestamp",
        "surrender_fund_number",
        "surrender_state_code",
        "surrender_gender",
        "surrender_risk_class",
        "surrender_rule_start_date",
        "surrender_rule_end_date",
        "is_spousal_continuation",
        "is_supplemental_contract",
        "is_qdro",
        "is_rider_claim",
        "is_roth_conversion",
        "is_internal_replacement",
        "is_partial_tax_conversion",
        "is_waiver_in_effect",
        "is_e_delivery",
        "has_ABR",
        "has_ABR_TI",
        "has_AVGuarRider",
        "has_IBR",
        "has_IBR_SD",
        "has_IBR_ST",
        "has_InflationRider",
        "has_LIQ",
        "has_LTCRider",
        "has_LongevityRider",
        "has_MVA",
        "has_NFRider",
        "has_NursingHomeWaiver",
        "has_OP",
        "has_ROP",
        "has_SR",
        "has_TIR",
        "has_WSC",
        "has_WellnessRider",
        "effective_timestamp",
        "expiration_timestamp",
        "is_current"        
    )
)


# In[52]:


display(policy_dim_df.limit(2))

#  ['agent_number','agent_name','agent_type','national_producer_number','nasd_finra_number','status'] 


# In[53]:


# ── Load ──────────────────────────────────────────────────────────────────────

print(f"\n[2/4] Instantiating GoldLoader")

loader = GoldLoader(spark)  # noqa: F821  # type: ignore[name-defined]
print(f"  GoldLoader ready  : {len(loader._function_registry)} functions in registry")

print(f"  [load] Writing to '{_target_table}' (is_scd2={_is_scd2}) ...")

_load_start = time.time()
loader.load(
    df                = policy_dim_df,
    target_table      = _target_table,
    is_scd2           = _is_scd2,
    business_key_cols = _business_key_cols,
    surrogate_key_col = _surrogate_key_col,
    hash_col          = _hash_col,
)
print(f"  [load]  Complete  ({round(time.time() - _load_start, 2)}s)")


# In[ ]:


# ── Unknown / default row (policy_key = -1) ───────────────────────────────────
from delta.tables import DeltaTable  # noqa: F821  # type: ignore[import]

_unknown_df = spark.range(1).select(
    F.lit(-1)       .cast("long")      .alias("policy_key"),
    F.lit("Unknown")                   .alias("policy_number"),
    F.lit(None)     .cast("timestamp") .alias("application_received_timestamp"),
    F.lit(None)     .cast("timestamp") .alias("application_signed_timestamp"),
    F.lit(None)     .cast("timestamp") .alias("issue_timestamp"),
    F.lit("Unknown")                   .alias("issue_state_code"),
    F.lit(0)        .cast("int")       .alias("issue_age"),
    F.lit(0)        .cast("int")       .alias("attained_age"),
    F.lit("Unknown")                   .alias("policy_status_code"),
    F.lit("Unknown")                   .alias("qual_ind"),
    F.lit("Unknown")                   .alias("qual_type"),
    F.lit("Unknown")                   .alias("policy_option"),
    F.lit(0)        .cast("int")       .alias("certain_period"),
    F.lit("Unknown")                   .alias("mec_status_code"),
    F.lit("Unknown")                   .alias("related_policy_number"),
    F.lit("Unknown")                   .alias("class_code"),
    F.lit("Unknown")                   .alias("underwriting_class"),
    F.lit(None)     .cast("timestamp") .alias("underwriting_timestamp"),
    F.lit("Unknown")                   .alias("surrender_fund_number"),
    F.lit("Unknown")                   .alias("surrender_state_code"),
    F.lit("Unknown")                   .alias("surrender_gender"),
    F.lit("Unknown")                   .alias("surrender_risk_class"),
    F.lit(None)     .cast("date")      .alias("surrender_rule_start_date"),
    F.lit(None)     .cast("date")      .alias("surrender_rule_end_date"),
    F.lit(0)        .cast("int")       .alias("is_spousal_continuation"),
    F.lit(0)        .cast("int")       .alias("is_supplemental_contract"),
    F.lit(0)        .cast("int")       .alias("is_qdro"),
    F.lit(0)        .cast("int")       .alias("is_rider_claim"),
    F.lit(0)        .cast("int")       .alias("is_roth_conversion"),
    F.lit(0)        .cast("int")       .alias("is_internal_replacement"),
    F.lit(0)        .cast("int")       .alias("is_partial_tax_conversion"),
    F.lit(0)        .cast("int")       .alias("is_waiver_in_effect"),
    F.lit(0)        .cast("int")       .alias("is_e_delivery"),
    F.lit(0)        .cast("int")       .alias("has_ABR"),
    F.lit(0)        .cast("int")       .alias("has_ABR_TI"),
    F.lit(0)        .cast("int")       .alias("has_AVGuarRider"),
    F.lit(0)        .cast("int")       .alias("has_IBR"),
    F.lit(0)        .cast("int")       .alias("has_IBR_SD"),
    F.lit(0)        .cast("int")       .alias("has_IBR_ST"),
    F.lit(0)        .cast("int")       .alias("has_InflationRider"),
    F.lit(0)        .cast("int")       .alias("has_LIQ"),
    F.lit(0)        .cast("int")       .alias("has_LTCRider"),
    F.lit(0)        .cast("int")       .alias("has_LongevityRider"),
    F.lit(0)        .cast("int")       .alias("has_MVA"),
    F.lit(0)        .cast("int")       .alias("has_NFRider"),
    F.lit(0)        .cast("int")       .alias("has_NursingHomeWaiver"),
    F.lit(0)        .cast("int")       .alias("has_OP"),
    F.lit(0)        .cast("int")       .alias("has_ROP"),
    F.lit(0)        .cast("int")       .alias("has_SR"),
    F.lit(0)        .cast("int")       .alias("has_TIR"),
    F.lit(0)        .cast("int")       .alias("has_WSC"),
    F.lit(0)        .cast("int")       .alias("has_WellnessRider"),
    F.lit(None)     .cast("timestamp") .alias("effective_timestamp"),
    F.lit(None)     .cast("timestamp") .alias("expiration_timestamp"),
    F.lit(1)        .cast("int")       .alias("is_current"),
    F.lit(None)     .cast("string")    .alias("md5_hash"),
)

(
    DeltaTable.forName(spark, _target_table).alias("tgt")
    .merge(_unknown_df.alias("src"), "tgt.policy_key = src.policy_key")
    .whenNotMatchedInsertAll()
    .execute()
)
print(f"  Unknown row (policy_key=-1) ensured in '{_target_table}'")

