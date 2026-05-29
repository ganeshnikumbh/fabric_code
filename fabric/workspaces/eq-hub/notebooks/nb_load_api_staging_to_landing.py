#!/usr/bin/env python
# coding: utf-8

# ## nb_load_api_staging_to_landing
# 
# New notebook

# In[1]:


# The command is not a standard IPython magic command. It is designed for use within Fabric notebooks only.
# %%configure -f
# {
#     "defaultLakehouse": {
#         "name": {
#             "variableName": "$(/**/vl_lakehouse_config/lh_landing_name)"
#         },
#         "id": {
#             "variableName": "$(/**/vl_lakehouse_config/lh_landing_id)"
#         },
#         "workspaceId": {
#             "variableName": "$(/**/vl_lakehouse_config/lh_workspace_id)"
#         }
#     }
# }


# In[2]:


# The command is not a standard IPython magic command. It is designed for use within Fabric notebooks only.
# %run nb_utils.py


# In[3]:


# ── Parameters ─────────────────────────────────────────────────────────────────
p_table_name     = "crm_contacts"
p_ingestion_date = "2026-05-26"
p_target_schema  = "hubspot"      # target schema / subfolder name (e.g. "hubspot", "webex")


# In[4]:


import json
from pyspark.sql.functions import col, decode, regexp_extract

_lakehouse_id = spark.conf.get("trident.lakehouse.id")
_workspace_id = spark.conf.get("trident.workspace.id")

_STAGING_PATH = (
    f"abfss://{_workspace_id}@onelake.dfs.fabric.microsoft.com"
    f"/{_lakehouse_id}/Files/{p_target_schema}/staging/{p_table_name}_{p_ingestion_date}"
)
_FULL_TABLE = f"lh_landing.{p_target_schema}.{p_table_name}"

# Read each file as a single row using binaryFile format — immune to newlines/formatting.
# wholetext on the text format is unreliable on Fabric ABFSS paths when the JSON spans
# multiple lines (e.g. Copy Activity writes paginated responses as a JSON array).
_df = (
    spark.read
         .format("binaryFile")
         .load(_STAGING_PATH)
         .select(
             regexp_extract(col("path"), r"(/Files/.+)$", 1).alias("file_name"),
             decode(col("content"), "UTF-8").alias("raw_json"),
         )
)


# In[5]:


# Overwrite landing table
(
    _df.write
       .format("delta")
       .mode("overwrite")
       .option("overwriteSchema", "true")
       .saveAsTable(_FULL_TABLE)
)

print(f"Written {_df.count()} rows to {_FULL_TABLE}")

# In[ ]:

mssparkutils.notebook.exit(json.dumps({  # noqa: F821
    "target_table": _FULL_TABLE,
}))

