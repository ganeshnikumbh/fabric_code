-- ============================================================
-- Gold Layer DDL — AgentTraining Star Schema
-- Lakehouse : lh_gold
-- Schema    : gold
-- Tables    : dim_date, dim_agent, dim_product_training,
--             fact_agent_training_event
-- ============================================================
--
-- Surrogate key convention (all _key columns):
--   CAST(conv(substr(md5(concat_ws('|', <business_cols>)), 1, 15), 16, 10) AS BIGINT)
--   Takes the first 15 hex characters of the MD5 digest (60 bits),
--   converts hex→decimal, then casts as BIGINT.  Fits within BIGINT range
--   and is deterministic for the same set of input values.
--
--   Exclude from SK input:  ingestion_date, data_timestamp, source_system,
--                           ingestion_run_id, ingestion_timestamp, src_busn_asst,
--                           md5_hash, effective_timestamp, expiration_timestamp,
--                           is_current
--
-- Source views (silver_s2 materialized lake views in lh_silver.dbo):
--   dim_date                ← date_base              (not SCD2 — single view)
--   dim_agent               ← agent_base_current     (SCD2 — _current only)
--   dim_product_training    ← training_course_base_current           (driving)
--                              JOIN training_product_group_base_current
--                              JOIN training_state_group_base_current
--                              JOIN product_base_current  (for product_name)
--                              JOIN state_base_current    (for state_name)
--   fact_agent_training_event ← agent_training_base_current          (driving)
-- ============================================================


-- ── dim_date ─────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS gold.dim_date (

    -- Surrogate key
    date_key                BIGINT      NOT NULL,   -- SK: conv(md5(all business cols), 1, 15) → BIGINT

    -- Business / natural key
    calendar_date           DATE        NOT NULL,   -- BK: CAST(calendar_timestamp AS DATE)

    -- Day attributes
    day_of_month            INT,                    -- CAST(day_of_month AS INT)
    day_of_week             INT,                    -- CAST(day_of_week AS INT)
    day_name                STRING,
    week_of_year            INT,                    -- CAST(week_of_year AS INT)

    -- Month / quarter / year attributes
    month                   INT,                    -- CAST(month AS INT)
    month_name              STRING,
    quarter                 INT,                    -- CAST(quarter AS INT)
    year                    INT,                    -- CAST(year AS INT)

    -- Fiscal calendar (derived — assumes fiscal year starts 1-Jul)
    fiscal_year             INT,                    -- CASE WHEN month >= 7 THEN year + 1 ELSE year END
    fiscal_quarter          INT,                    -- derived from month within fiscal year

    -- Boolean flags
    is_weekday              BOOLEAN,
    is_holiday              BOOLEAN,
    is_month_end            BOOLEAN,                -- mapped from silver is_last_day_of_month
    is_quarter_end          BOOLEAN,                -- derived: calendar_date = last_day_of_quarter

    -- Pipeline audit
    src_busn_asst           STRING,
    ingestion_date          DATE,
    ingestion_timestamp     TIMESTAMP
)
USING DELTA
TBLPROPERTIES ('delta.enableChangeDataFeed' = 'true')
COMMENT 'Gold dimension: calendar date attributes. Not SCD2. Source: lh_silver.dbo.date_base.';

-- ── dim_agent ────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS gold.dim_agent (

    -- Surrogate key
    agent_key               BIGINT      NOT NULL,   -- SK: conv(md5(all business cols), 1, 15) → BIGINT

    -- Agent identifiers
    agent_number            STRING,                 -- direct from silver agent_number
    agent_name              STRING,                 -- mapped from silver display_name
    agent_type              STRING,
    national_producer_number STRING,
    nasd_finra_number       STRING,

    -- Status and dates
    status                  STRING,
    hire_date               DATE,                   -- CAST(hire_date AS DATE)
    termination_date        DATE,                   -- CAST(termination_date AS DATE)

    -- Agency context
    agency_name             STRING,                 -- ⚠ NOT IN agent_base — requires join to company/hierarchy; NULL until sourced

    -- FK to future dim_client
    agent_client_key        BIGINT,                 -- FK: conv(md5(CAST(client_id AS STRING))) → BIGINT

    -- SCD2 tracking (carried from silver_s1 SCD2 columns)
    effective_timestamp     TIMESTAMP,
    expiration_timestamp    TIMESTAMP,
    is_current              BOOLEAN,

    -- Pipeline audit
    src_busn_asst           STRING,
    ingestion_date          DATE,
    ingestion_timestamp     TIMESTAMP
)
USING DELTA
TBLPROPERTIES ('delta.enableChangeDataFeed' = 'true')
COMMENT 'Gold dimension: agent/producer profile. SCD2. Source: lh_silver.dbo.agent_base_current.';

-- ── dim_product_training ─────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS gold.dim_product_training (

    -- Surrogate key
    product_training_key    BIGINT      NOT NULL,   -- SK: conv(md5(all business cols), 1, 15) → BIGINT

    -- Business / natural key
    training_code           STRING,                 -- BK: from training_course_base.training_code

    -- Training course attributes (from training_course_base_current)
    training_name           STRING,                 -- training_course_base.training_name
    context                 STRING,                 -- training_course_base.context (or course_type)
    description             STRING,                 -- training_course_base.description

    -- Product association (from training_product_group_base_current + product_base)
    product_key             BIGINT,                 -- FK: conv(md5(CAST(product_id AS STRING))) → BIGINT
    product_name            STRING,                 -- joined from product_base

    -- State association (from training_state_group_base_current + state_base)
    state_code              STRING,                 -- FK: from training_state_group_base.state_code
    state_name              STRING,                 -- joined from state_base

    -- Pipeline audit
    src_busn_asst           STRING,
    ingestion_date          DATE,
    ingestion_timestamp     TIMESTAMP
)
USING DELTA
TBLPROPERTIES ('delta.enableChangeDataFeed' = 'true')
COMMENT 'Gold dimension: training course × product × state grain. Sources: training_course_base_current, training_product_group_base_current, training_state_group_base_current, product_base_current, state_base_current.';

-- ── fact_agent_training_event ─────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS gold.fact_agent_training_event (

    -- Surrogate key (degenerate — uniquely identifies the event row)
    agent_training_event_key BIGINT     NOT NULL,   -- SK: conv(md5(all business cols), 1, 15) → BIGINT

    -- Foreign keys to dimensions
    agent_key               BIGINT      NOT NULL,   -- FK → gold.dim_agent.agent_key
    product_training_key    BIGINT      NOT NULL,   -- FK → gold.dim_product_training.product_training_key
    completion_date_key     BIGINT      NOT NULL,   -- FK → gold.dim_date.date_key  (role: completion date)
    expiration_date_key     BIGINT,                 -- FK → gold.dim_date.date_key  (role: expiration date; NULL if no expiry)

    -- Pipeline audit
    src_busn_asst           STRING,
    ingestion_date          DATE,
    ingestion_timestamp     TIMESTAMP
)
USING DELTA
TBLPROPERTIES ('delta.enableChangeDataFeed' = 'true')
COMMENT 'Gold fact: one row per agent training completion event. Grain: agent × training course × completion date. Source: lh_silver.dbo.agent_training_base_current.';
