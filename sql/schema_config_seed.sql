-- ============================================================
-- schema_config — DDL + seed data
-- ============================================================

IF OBJECT_ID('dbo.schema_config', 'U') IS NOT NULL
    DROP TABLE dbo.schema_config;
GO

CREATE TABLE dbo.schema_config (
    id                  INT             NOT NULL    IDENTITY(1,1),
    source_name         NVARCHAR(100)   NOT NULL,
    source_table_name   NVARCHAR(200)   NOT NULL,
    target_table_name   NVARCHAR(200)   NOT NULL,
    source_column_name  NVARCHAR(200)   NOT NULL,
    target_column_name  NVARCHAR(200)   NOT NULL,
    target_data_type    NVARCHAR(100)   NOT NULL,
    ordinal_position    INT             NOT NULL,
    include_in_md5hash  BIT             NOT NULL    CONSTRAINT df_schema_config_hash     DEFAULT (1),
    is_primary_key      BIT             NOT NULL    CONSTRAINT df_schema_config_pk       DEFAULT (0),
    is_active           BIT             NOT NULL    CONSTRAINT df_schema_config_active   DEFAULT (1),
    created_at          DATETIME2       NOT NULL    CONSTRAINT df_schema_config_created  DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT pk_schema_config PRIMARY KEY (id)
);
GO
CREATE INDEX ix_schema_config_source_name  ON dbo.schema_config (source_name);
GO
CREATE INDEX ix_schema_config_table_name   ON dbo.schema_config (source_table_name);
GO

-- ── Existing seed rows (EQ_Warehouse, EQ_ODS, HubSpot) — explicit IDs ─────
SET IDENTITY_INSERT dbo.schema_config ON;
GO


-- [01] Territory (4 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  (   1, 'EQ_Warehouse', 'Territory'                                 , 'territory_base', 'TerritoryPK'                               , 'territory_id'                              , 'INT'                 ,   1, 1, 1, 1, GETUTCDATE()),
  (   2, 'EQ_Warehouse', 'Territory'                                 , 'territory_base', 'TerritoryName'                             , 'territory_name'                            , 'STRING'              ,   2, 1, 0, 1, GETUTCDATE()),
  (   3, 'EQ_Warehouse', 'Territory'                                 , 'territory_base', 'ClientFK'                                  , 'client_id'                                 , 'INT'                 ,   3, 1, 0, 1, GETUTCDATE()),
  (   4, 'EQ_Warehouse', 'Territory'                                 , 'territory_base', 'TerritoryActive'                           , 'is_territory_active'                       , 'BOOLEAN'             ,   4, 1, 0, 1, GETUTCDATE());

-- [02] HierarchyTerritory (8 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  (   8, 'EQ_Warehouse', 'HierarchyTerritory'                        , 'hierarchy_territory_base', 'HierarchyTerritoryPK'                      , 'hierarchy_territory_id'                    , 'INT'                 ,   1, 1, 1, 1, GETUTCDATE()),
  (   9, 'EQ_Warehouse', 'HierarchyTerritory'                        , 'hierarchy_territory_base', 'HierarchySetKey'                           , 'hierarchy_set_key'                         , 'INT'                 ,   2, 1, 0, 1, GETUTCDATE()),
  (  10, 'EQ_Warehouse', 'HierarchyTerritory'                        , 'hierarchy_territory_base', 'TerritoryFK'                               , 'territory_id'                              , 'INT'                 ,   3, 1, 0, 1, GETUTCDATE());

-- [03] Hierarchy_SuperHierarchy (10 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  (  16, 'EQ_Warehouse', 'Hierarchy_SuperHierarchy'                  , 'hierarchy_super_hierarchy_base', 'SuperHierarchyPK'                          , 'super_hierarchy_id'                        , 'INT'                 ,   1, 1, 1, 1, GETUTCDATE()),
  (  17, 'EQ_Warehouse', 'Hierarchy_SuperHierarchy'                  , 'hierarchy_super_hierarchy_base', 'AgentContractFK'                           , 'agent_contract_id'                         , 'INT'                 ,   2, 1, 0, 1, GETUTCDATE()),
  (  18, 'EQ_Warehouse', 'Hierarchy_SuperHierarchy'                  , 'hierarchy_super_hierarchy_base', 'HierarchySetKey'                           , 'hierarchy_set_key'                         , 'INT'                 ,   3, 1, 0, 1, GETUTCDATE()),
  (  19, 'EQ_Warehouse', 'Hierarchy_SuperHierarchy'                  , 'hierarchy_super_hierarchy_base', 'ReverseLevel'                              , 'reverse_level'                             , 'DECIMAL(18,4)'       ,   4, 1, 0, 1, GETUTCDATE()),
  (  20, 'EQ_Warehouse', 'Hierarchy_SuperHierarchy'                  , 'hierarchy_super_hierarchy_base', 'DisplayName'                               , 'display_name'                              , 'STRING'              ,   5, 1, 0, 1, GETUTCDATE());

-- [04] Hierarchy_Option (9 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  (  26, 'EQ_Warehouse', 'Hierarchy_Option'                          , 'hierarchy_option_base', 'HierarchyOptionPK'                         , 'hierarchy_option_id'                       , 'INT'                 ,   1, 1, 1, 1, GETUTCDATE()),
  (  27, 'EQ_Warehouse', 'Hierarchy_Option'                          , 'hierarchy_option_base', 'HierarchyBridgeFK'                         , 'hierarchy_bridge_id'                       , 'INT'                 ,   2, 1, 0, 1, GETUTCDATE()),
  (  28, 'EQ_Warehouse', 'Hierarchy_Option'                          , 'hierarchy_option_base', 'AgentContractFK'                           , 'agent_contract_id'                         , 'INT'                 ,   3, 1, 0, 1, GETUTCDATE()),
  (  29, 'EQ_Warehouse', 'Hierarchy_Option'                          , 'hierarchy_option_base', 'AccessRemovedInd'                          , 'is_access_removed'                         , 'BOOLEAN'             ,   4, 1, 0, 1, GETUTCDATE());

-- [05] Hierarchy_Bridge (15 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  (  35, 'EQ_Warehouse', 'Hierarchy_Bridge'                          , 'hierarchy_bridge_base', 'HierarchyBridgePK'                         , 'hierarchy_bridge_id'                       , 'INT'                 ,   1, 1, 1, 1, GETUTCDATE()),
  (  36, 'EQ_Warehouse', 'Hierarchy_Bridge'                          , 'hierarchy_bridge_base', 'HierarchyGroupKey'                         , 'hierarchy_group_key'                       , 'INT'                 ,   2, 1, 0, 1, GETUTCDATE()),
  (  37, 'EQ_Warehouse', 'Hierarchy_Bridge'                          , 'hierarchy_bridge_base', 'HierarchySetKey'                           , 'hierarchy_set_key'                         , 'INT'                 ,   3, 1, 0, 1, GETUTCDATE()),
  (  38, 'EQ_Warehouse', 'Hierarchy_Bridge'                          , 'hierarchy_bridge_base', 'SplitPercent'                              , 'split_percent'                             , 'DECIMAL(18,4)'       ,   4, 1, 0, 1, GETUTCDATE()),
  (  39, 'EQ_Warehouse', 'Hierarchy_Bridge'                          , 'hierarchy_bridge_base', 'ServicingAgentIndicator'                   , 'servicing_agent_indicator'                 , 'STRING'              ,   5, 1, 0, 1, GETUTCDATE()),
  (  40, 'EQ_Warehouse', 'Hierarchy_Bridge'                          , 'hierarchy_bridge_base', 'CommissionOnlyIndicator'                   , 'commission_only_indicator'                 , 'STRING'              ,   6, 1, 0, 1, GETUTCDATE()),
  (  41, 'EQ_Warehouse', 'Hierarchy_Bridge'                          , 'hierarchy_bridge_base', 'CommissionOption'                          , 'commission_option'                         , 'STRING'              ,   7, 1, 0, 1, GETUTCDATE()),
  (  42, 'EQ_Warehouse', 'Hierarchy_Bridge'                          , 'hierarchy_bridge_base', 'HierarchyOrder'                            , 'hierarchy_order'                           , 'INT'                 ,   8, 1, 0, 1, GETUTCDATE()),
  (  43, 'EQ_Warehouse', 'Hierarchy_Bridge'                          , 'hierarchy_bridge_base', 'StartDate'                                 , 'start_timestamp'                           , 'TIMESTAMP'           ,   9, 1, 0, 1, GETUTCDATE()),
  (  44, 'EQ_Warehouse', 'Hierarchy_Bridge'                          , 'hierarchy_bridge_base', 'StopDate'                                  , 'stop_timestamp'                            , 'TIMESTAMP'           ,  10, 1, 0, 1, GETUTCDATE());

-- [06] Hierarchy (5 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  (  51, 'EQ_Warehouse', 'Hierarchy'                                 , 'hierarchy_base', 'HierarchyPK'                               , 'hierarchy_id'                              , 'INT'                 ,   1, 1, 1, 1, GETUTCDATE()),
  (  52, 'EQ_Warehouse', 'Hierarchy'                                 , 'hierarchy_base', 'HierarchySetKey'                           , 'hierarchy_set_key'                         , 'INT'                 ,   2, 1, 0, 1, GETUTCDATE()),
  (  53, 'EQ_Warehouse', 'Hierarchy'                                 , 'hierarchy_base', 'AgentContractFK'                           , 'agent_contract_id'                         , 'INT'                 ,   3, 1, 0, 1, GETUTCDATE()),
  (  54, 'EQ_Warehouse', 'Hierarchy'                                 , 'hierarchy_base', 'Level'                                     , 'level'                                     , 'INT'                 ,   4, 1, 0, 1, GETUTCDATE()),
  (  55, 'EQ_Warehouse', 'Hierarchy'                                 , 'hierarchy_base', 'ReverseLevel'                              , 'reverse_level'                             , 'INT'                 ,   5, 1, 0, 1, GETUTCDATE());

-- [07] CommissionLevelRank (8 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  (  60, 'EQ_Warehouse', 'CommissionLevelRank'                       , 'commission_level_rank_base', 'CommissionLevelRankPK'                     , 'commission_level_rank_id'                  , 'INT'                 ,   1, 1, 1, 1, GETUTCDATE()),
  (  61, 'EQ_Warehouse', 'CommissionLevelRank'                       , 'commission_level_rank_base', 'CommissionLevel'                           , 'commission_level'                          , 'STRING'              ,   2, 1, 0, 1, GETUTCDATE()),
  (  62, 'EQ_Warehouse', 'CommissionLevelRank'                       , 'commission_level_rank_base', 'Rank'                                      , 'rank'                                      , 'INT'                 ,   3, 1, 0, 1, GETUTCDATE());

-- [08] AgentContract (16 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  (  68, 'EQ_Warehouse', 'AgentContract'                             , 'agent_contract_base', 'AgentContractPK'                           , 'agent_contract_id'                         , 'INT'                 ,   1, 1, 1, 1, GETUTCDATE()),
  (  69, 'EQ_Warehouse', 'AgentContract'                             , 'agent_contract_base', 'AgentNumber'                               , 'agent_number'                              , 'STRING'              ,   2, 1, 0, 1, GETUTCDATE()),
  (  70, 'EQ_Warehouse', 'AgentContract'                             , 'agent_contract_base', 'AgentFK'                                   , 'agent_id'                                  , 'INT'                 ,   3, 1, 0, 1, GETUTCDATE()),
  (  71, 'EQ_Warehouse', 'AgentContract'                             , 'agent_contract_base', 'Context'                                   , 'context'                                   , 'STRING'              ,   4, 1, 0, 1, GETUTCDATE()),
  (  72, 'EQ_Warehouse', 'AgentContract'                             , 'agent_contract_base', 'Status'                                    , 'status'                                    , 'STRING'              ,   5, 1, 0, 1, GETUTCDATE()),
  (  73, 'EQ_Warehouse', 'AgentContract'                             , 'agent_contract_base', 'CommissionLevel'                           , 'commission_level'                          , 'STRING'              ,   6, 1, 0, 1, GETUTCDATE()),
  (  74, 'EQ_Warehouse', 'AgentContract'                             , 'agent_contract_base', 'SituationCode'                             , 'situation_code'                            , 'STRING'              ,   7, 1, 0, 1, GETUTCDATE()),
  (  75, 'EQ_Warehouse', 'AgentContract'                             , 'agent_contract_base', 'ContractEffectiveDate'                     , 'contract_effective_timestamp'              , 'TIMESTAMP'           ,   8, 1, 0, 1, GETUTCDATE()),
  (  76, 'EQ_Warehouse', 'AgentContract'                             , 'agent_contract_base', 'ContractTerminationDate'                   , 'contract_termination_timestamp'            , 'TIMESTAMP'           ,   9, 1, 0, 1, GETUTCDATE()),
  (  77, 'EQ_Warehouse', 'AgentContract'                             , 'agent_contract_base', 'CurrentRecord'                             , 'is_current_record'                         , 'STRING'              ,  10, 1, 0, 1, GETUTCDATE()),
  (  78, 'EQ_Warehouse', 'AgentContract'                             , 'agent_contract_base', 'SetToCurrentDate'                          , 'set_to_current_timestamp'                  , 'TIMESTAMP'           ,  11, 1, 0, 1, GETUTCDATE());

-- [09] TrainingState_Group (10 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  (  84, 'EQ_Warehouse', 'TrainingState_Group'                       , 'training_state_group_base', 'TrainingStateGroupPK'                      , 'training_state_group_id'                   , 'INT'                 ,   1, 1, 1, 1, GETUTCDATE()),
  (  85, 'EQ_Warehouse', 'TrainingState_Group'                       , 'training_state_group_base', 'TrainingStateGroupKey'                     , 'training_state_group_key'                  , 'INT'                 ,   2, 1, 0, 1, GETUTCDATE()),
  (  86, 'EQ_Warehouse', 'TrainingState_Group'                       , 'training_state_group_base', 'State'                                     , 'state_code'                                , 'STRING'              ,   3, 1, 0, 1, GETUTCDATE()),
  (  87, 'EQ_Warehouse', 'TrainingState_Group'                       , 'training_state_group_base', 'Required'                                  , 'is_required'                               , 'BOOLEAN'             ,   4, 1, 0, 1, GETUTCDATE()),
  (  88, 'EQ_Warehouse', 'TrainingState_Group'                       , 'training_state_group_base', 'EffectiveDate'                             , 'effective_timestamp'                       , 'TIMESTAMP'           ,   5, 1, 0, 1, GETUTCDATE());

-- [10] TrainingProduct_Group (9 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  (  94, 'EQ_Warehouse', 'TrainingProduct_Group'                     , 'training_product_group_base', 'TrainingProductGroupPK'                    , 'training_product_group_id'                 , 'INT'                 ,   1, 1, 1, 1, GETUTCDATE()),
  (  95, 'EQ_Warehouse', 'TrainingProduct_Group'                     , 'training_product_group_base', 'TrainingProductGroupKey'                   , 'training_product_group_key'                , 'INT'                 ,   2, 1, 0, 1, GETUTCDATE()),
  (  96, 'EQ_Warehouse', 'TrainingProduct_Group'                     , 'training_product_group_base', 'ProductFK'                                 , 'product_id'                                , 'INT'                 ,   3, 1, 0, 1, GETUTCDATE()),
  (  97, 'EQ_Warehouse', 'TrainingProduct_Group'                     , 'training_product_group_base', 'Required'                                  , 'is_required'                               , 'BOOLEAN'             ,   4, 1, 0, 1, GETUTCDATE());

-- [11] Rider_Group (20 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  ( 103, 'EQ_Warehouse', 'Rider_Group'                               , 'rider_group_base', 'RiderGroupPK'                              , 'rider_group_id'                            , 'INT'                 ,   1, 1, 1, 1, GETUTCDATE()),
  ( 104, 'EQ_Warehouse', 'Rider_Group'                               , 'rider_group_base', 'RiderGroupKey'                             , 'rider_group_key'                           , 'INT'                 ,   2, 1, 0, 1, GETUTCDATE()),
  ( 105, 'EQ_Warehouse', 'Rider_Group'                               , 'rider_group_base', 'Code'                                      , 'rider_code'                                , 'STRING'              ,   3, 1, 0, 1, GETUTCDATE()),
  ( 106, 'EQ_Warehouse', 'Rider_Group'                               , 'rider_group_base', 'Description'                               , 'description'                               , 'STRING'              ,   4, 1, 0, 1, GETUTCDATE()),
  ( 107, 'EQ_Warehouse', 'Rider_Group'                               , 'rider_group_base', 'BaseValue'                                 , 'base_value'                                , 'DECIMAL(18,4)'       ,   5, 1, 0, 1, GETUTCDATE()),
  ( 108, 'EQ_Warehouse', 'Rider_Group'                               , 'rider_group_base', 'EligibilityDate'                           , 'eligibility_timestamp'                     , 'TIMESTAMP'           ,   6, 1, 0, 1, GETUTCDATE()),
  ( 109, 'EQ_Warehouse', 'Rider_Group'                               , 'rider_group_base', 'FeePercent'                                , 'fee_percent'                               , 'DECIMAL(18,4)'       ,   7, 1, 0, 1, GETUTCDATE()),
  ( 110, 'EQ_Warehouse', 'Rider_Group'                               , 'rider_group_base', 'Lives'                                     , 'lives'                                     , 'STRING'              ,   8, 1, 0, 1, GETUTCDATE()),
  ( 111, 'EQ_Warehouse', 'Rider_Group'                               , 'rider_group_base', 'PayValue'                                  , 'pay_value'                                 , 'DECIMAL(18,4)'       ,   9, 1, 0, 1, GETUTCDATE()),
  ( 112, 'EQ_Warehouse', 'Rider_Group'                               , 'rider_group_base', 'Frequency'                                 , 'frequency'                                 , 'STRING'              ,  10, 1, 0, 1, GETUTCDATE()),
  ( 113, 'EQ_Warehouse', 'Rider_Group'                               , 'rider_group_base', 'WellnessEnrollment'                        , 'is_wellness_enrollment'                    , 'BOOLEAN'             ,  11, 1, 0, 1, GETUTCDATE()),
  ( 114, 'EQ_Warehouse', 'Rider_Group'                               , 'rider_group_base', 'WellnessCredits'                           , 'wellness_credits'                          , 'DECIMAL(18,4)'       ,  12, 1, 0, 1, GETUTCDATE()),
  ( 115, 'EQ_Warehouse', 'Rider_Group'                               , 'rider_group_base', 'StartAge'                                  , 'start_age'                                 , 'INT'                 ,  13, 1, 0, 1, GETUTCDATE()),
  ( 116, 'EQ_Warehouse', 'Rider_Group'                               , 'rider_group_base', 'StartDate'                                 , 'start_timestamp'                           , 'TIMESTAMP'           ,  14, 1, 0, 1, GETUTCDATE()),
  ( 117, 'EQ_Warehouse', 'Rider_Group'                               , 'rider_group_base', 'StopDate'                                  , 'stop_timestamp'                            , 'TIMESTAMP'           ,  15, 1, 0, 1, GETUTCDATE());

-- [12] Requirement_Group (14 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  ( 123, 'EQ_Warehouse', 'Requirement_Group'                         , 'requirement_group_base', 'RequirementGroupPK'                        , 'requirement_group_id'                      , 'INT'                 ,   1, 1, 1, 1, GETUTCDATE()),
  ( 124, 'EQ_Warehouse', 'Requirement_Group'                         , 'requirement_group_base', 'RequirementGroupKey'                       , 'requirement_group_key'                     , 'INT'                 ,   2, 1, 0, 1, GETUTCDATE()),
  ( 125, 'EQ_Warehouse', 'Requirement_Group'                         , 'requirement_group_base', 'Code'                                      , 'requirement_code'                          , 'STRING'              ,   3, 1, 0, 1, GETUTCDATE()),
  ( 126, 'EQ_Warehouse', 'Requirement_Group'                         , 'requirement_group_base', 'Description'                               , 'description'                               , 'STRING'              ,   4, 1, 0, 1, GETUTCDATE()),
  ( 127, 'EQ_Warehouse', 'Requirement_Group'                         , 'requirement_group_base', 'Status'                                    , 'status'                                    , 'STRING'              ,   5, 1, 0, 1, GETUTCDATE()),
  ( 128, 'EQ_Warehouse', 'Requirement_Group'                         , 'requirement_group_base', 'EffectiveDate'                             , 'effective_timestamp'                       , 'TIMESTAMP'           ,   6, 1, 0, 1, GETUTCDATE()),
  ( 129, 'EQ_Warehouse', 'Requirement_Group'                         , 'requirement_group_base', 'FollowUpDate'                              , 'follow_up_timestamp'                       , 'TIMESTAMP'           ,   7, 1, 0, 1, GETUTCDATE()),
  ( 130, 'EQ_Warehouse', 'Requirement_Group'                         , 'requirement_group_base', 'ReceivedDate'                              , 'received_timestamp'                        , 'TIMESTAMP'           ,   8, 1, 0, 1, GETUTCDATE()),
  ( 131, 'EQ_Warehouse', 'Requirement_Group'                         , 'requirement_group_base', 'ExecutedDate'                              , 'executed_timestamp'                        , 'TIMESTAMP'           ,   9, 1, 0, 1, GETUTCDATE());

-- [13] RenewalRate_Group (11 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  ( 137, 'EQ_Warehouse', 'RenewalRate_Group'                         , 'renewal_rate_group_base', 'RenewalRateGroupPK'                        , 'renewal_rate_group_id'                     , 'INT'                 ,   1, 1, 1, 1, GETUTCDATE()),
  ( 138, 'EQ_Warehouse', 'RenewalRate_Group'                         , 'renewal_rate_group_base', 'RenewalRateGroupKey'                       , 'renewal_rate_group_key'                    , 'INT'                 ,   2, 1, 0, 1, GETUTCDATE()),
  ( 139, 'EQ_Warehouse', 'RenewalRate_Group'                         , 'renewal_rate_group_base', 'EffectiveDate'                             , 'effective_timestamp'                       , 'TIMESTAMP'           ,   3, 1, 0, 1, GETUTCDATE()),
  ( 140, 'EQ_Warehouse', 'RenewalRate_Group'                         , 'renewal_rate_group_base', 'Year'                                      , 'year'                                      , 'INT'                 ,   4, 1, 0, 1, GETUTCDATE()),
  ( 141, 'EQ_Warehouse', 'RenewalRate_Group'                         , 'renewal_rate_group_base', 'YearDisplay'                               , 'year_display'                              , 'STRING'              ,   5, 1, 0, 1, GETUTCDATE()),
  ( 142, 'EQ_Warehouse', 'RenewalRate_Group'                         , 'renewal_rate_group_base', 'Rate'                                      , 'rate'                                      , 'DECIMAL(18,4)'       ,   6, 1, 0, 1, GETUTCDATE());

-- [14] Reinsurance_Group (9 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  ( 148, 'EQ_Warehouse', 'Reinsurance_Group'                         , 'reinsurance_group_base', 'ReinsuranceGroupPK'                        , 'reinsurance_group_id'                      , 'INT'                 ,   1, 1, 1, 1, GETUTCDATE()),
  ( 149, 'EQ_Warehouse', 'Reinsurance_Group'                         , 'reinsurance_group_base', 'ReinsuranceGroupKey'                       , 'reinsurance_group_key'                     , 'INT'                 ,   2, 1, 0, 1, GETUTCDATE()),
  ( 150, 'EQ_Warehouse', 'Reinsurance_Group'                         , 'reinsurance_group_base', 'TreatyCode'                                , 'treaty_code'                               , 'STRING'              ,   3, 1, 0, 1, GETUTCDATE()),
  ( 151, 'EQ_Warehouse', 'Reinsurance_Group'                         , 'reinsurance_group_base', 'CoinsurancePercentage'                     , 'coinsurance_percentage'                    , 'DECIMAL(18,4)'       ,   4, 1, 0, 1, GETUTCDATE());

-- [15] RecurringPayment_Group (21 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  ( 157, 'EQ_Warehouse', 'RecurringPayment_Group'                    , 'recurring_payment_group_base', 'RecurringPaymentGroupPK'                   , 'recurring_payment_group_id'                , 'INT'                 ,   1, 1, 1, 1, GETUTCDATE()),
  ( 158, 'EQ_Warehouse', 'RecurringPayment_Group'                    , 'recurring_payment_group_base', 'RecurringPaymentGroupKey'                  , 'recurring_payment_group_key'               , 'INT'                 ,   2, 1, 0, 1, GETUTCDATE()),
  ( 159, 'EQ_Warehouse', 'RecurringPayment_Group'                    , 'recurring_payment_group_base', 'ActivityTypeFK'                            , 'activity_type_id'                          , 'INT'                 ,   3, 1, 0, 1, GETUTCDATE()),
  ( 160, 'EQ_Warehouse', 'RecurringPayment_Group'                    , 'recurring_payment_group_base', 'PayeeFK'                                   , 'payee_id'                                  , 'INT'                 ,   4, 1, 0, 1, GETUTCDATE()),
  ( 161, 'EQ_Warehouse', 'RecurringPayment_Group'                    , 'recurring_payment_group_base', 'NextEffectiveDate'                         , 'next_effective_timestamp'                  , 'TIMESTAMP'           ,   5, 1, 0, 1, GETUTCDATE()),
  ( 162, 'EQ_Warehouse', 'RecurringPayment_Group'                    , 'recurring_payment_group_base', 'PausedInd'                                 , 'is_paused'                                 , 'BOOLEAN'             ,   6, 1, 0, 1, GETUTCDATE()),
  ( 163, 'EQ_Warehouse', 'RecurringPayment_Group'                    , 'recurring_payment_group_base', 'DistributionType'                          , 'distribution_type'                         , 'STRING'              ,   7, 1, 0, 1, GETUTCDATE()),
  ( 164, 'EQ_Warehouse', 'RecurringPayment_Group'                    , 'recurring_payment_group_base', 'Lives'                                     , 'lives'                                     , 'STRING'              ,   8, 1, 0, 1, GETUTCDATE()),
  ( 165, 'EQ_Warehouse', 'RecurringPayment_Group'                    , 'recurring_payment_group_base', 'Frequency'                                 , 'frequency'                                 , 'STRING'              ,   9, 1, 0, 1, GETUTCDATE()),
  ( 166, 'EQ_Warehouse', 'RecurringPayment_Group'                    , 'recurring_payment_group_base', 'WithdrawalType'                            , 'withdrawal_type'                           , 'STRING'              ,  10, 1, 0, 1, GETUTCDATE()),
  ( 167, 'EQ_Warehouse', 'RecurringPayment_Group'                    , 'recurring_payment_group_base', 'FirstDate'                                 , 'first_timestamp'                           , 'TIMESTAMP'           ,  11, 1, 0, 1, GETUTCDATE()),
  ( 168, 'EQ_Warehouse', 'RecurringPayment_Group'                    , 'recurring_payment_group_base', 'PriorDate'                                 , 'prior_timestamp'                           , 'TIMESTAMP'           ,  12, 1, 0, 1, GETUTCDATE()),
  ( 169, 'EQ_Warehouse', 'RecurringPayment_Group'                    , 'recurring_payment_group_base', 'PriorActivityFK'                           , 'prior_activity_id'                         , 'INT'                 ,  13, 1, 0, 1, GETUTCDATE()),
  ( 170, 'EQ_Warehouse', 'RecurringPayment_Group'                    , 'recurring_payment_group_base', 'EligibleRMDDate'                           , 'eligible_rmd_timestamp'                    , 'TIMESTAMP'           ,  14, 1, 0, 1, GETUTCDATE()),
  ( 171, 'EQ_Warehouse', 'RecurringPayment_Group'                    , 'recurring_payment_group_base', 'CalculatedAmount'                          , 'calculated_amount'                         , 'DECIMAL(18,4)'       ,  15, 1, 0, 1, GETUTCDATE()),
  ( 172, 'EQ_Warehouse', 'RecurringPayment_Group'                    , 'recurring_payment_group_base', 'GrossNet'                                  , 'gross_net'                                 , 'STRING'              ,  16, 1, 0, 1, GETUTCDATE());

-- [16] Note_Group (21 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  ( 178, 'EQ_Warehouse', 'Note_Group'                                , 'note_group_base', 'NoteGroupPK'                               , 'note_group_id'                             , 'INT'                 ,   1, 1, 1, 1, GETUTCDATE()),
  ( 179, 'EQ_Warehouse', 'Note_Group'                                , 'note_group_base', 'SourceKey'                                 , 'source_key'                                , 'BIGINT'              ,   2, 1, 0, 1, GETUTCDATE()),
  ( 180, 'EQ_Warehouse', 'Note_Group'                                , 'note_group_base', 'NoteGroupKey'                              , 'note_group_key'                            , 'INT'                 ,   3, 1, 0, 1, GETUTCDATE()),
  ( 181, 'EQ_Warehouse', 'Note_Group'                                , 'note_group_base', 'Order'                                     , 'sort_order'                                , 'INT'                 ,   4, 1, 0, 1, GETUTCDATE()),
  ( 182, 'EQ_Warehouse', 'Note_Group'                                , 'note_group_base', 'Text'                                      , 'note_text'                                 , 'STRING'              ,   5, 1, 0, 1, GETUTCDATE()),
  ( 183, 'EQ_Warehouse', 'Note_Group'                                , 'note_group_base', 'Type'                                      , 'note_type'                                 , 'STRING'              ,   6, 1, 0, 1, GETUTCDATE()),
  ( 184, 'EQ_Warehouse', 'Note_Group'                                , 'note_group_base', 'Role'                                      , 'role'                                      , 'STRING'              ,   7, 1, 0, 1, GETUTCDATE()),
  ( 185, 'EQ_Warehouse', 'Note_Group'                                , 'note_group_base', 'MaintDate'                                 , 'maint_timestamp'                           , 'TIMESTAMP'           ,   8, 1, 0, 1, GETUTCDATE()),
  ( 186, 'EQ_Warehouse', 'Note_Group'                                , 'note_group_base', 'MaintBy'                                   , 'maint_by'                                  , 'STRING'              ,   9, 1, 0, 1, GETUTCDATE()),
  ( 187, 'EQ_Warehouse', 'Note_Group'                                , 'note_group_base', 'Call_ID'                                   , 'call_id'                                   , 'INT'                 ,  10, 1, 0, 1, GETUTCDATE()),
  ( 188, 'EQ_Warehouse', 'Note_Group'                                , 'note_group_base', 'Call_Length'                               , 'call_length'                               , 'INT'                 ,  11, 1, 0, 1, GETUTCDATE()),
  ( 189, 'EQ_Warehouse', 'Note_Group'                                , 'note_group_base', 'Call_StartDate'                            , 'call_start_timestamp'                      , 'TIMESTAMP'           ,  12, 1, 0, 1, GETUTCDATE()),
  ( 190, 'EQ_Warehouse', 'Note_Group'                                , 'note_group_base', 'Call_InOut'                                , 'call_direction'                            , 'STRING'              ,  13, 1, 0, 1, GETUTCDATE()),
  ( 191, 'EQ_Warehouse', 'Note_Group'                                , 'note_group_base', 'Call_Operators'                            , 'call_operators'                            , 'STRING'              ,  14, 1, 0, 1, GETUTCDATE()),
  ( 192, 'EQ_Warehouse', 'Note_Group'                                , 'note_group_base', 'Call_FilePath'                             , 'call_file_path'                            , 'STRING'              ,  15, 1, 0, 1, GETUTCDATE()),
  ( 193, 'EQ_Warehouse', 'Note_Group'                                , 'note_group_base', 'Call_EncryptKey'                           , 'call_encrypt_key'                          , 'STRING'              ,  16, 1, 0, 1, GETUTCDATE());

-- [17] IndexValue_Group (12 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  ( 199, 'EQ_Warehouse', 'IndexValue_Group'                          , 'index_value_group_base', 'IndexValueGroupPK'                         , 'index_value_group_id'                      , 'INT'                 ,   1, 1, 1, 1, GETUTCDATE()),
  ( 200, 'EQ_Warehouse', 'IndexValue_Group'                          , 'index_value_group_base', 'IndexValueGroupKey'                        , 'index_value_group_key'                     , 'INT'                 ,   2, 1, 0, 1, GETUTCDATE()),
  ( 201, 'EQ_Warehouse', 'IndexValue_Group'                          , 'index_value_group_base', 'Ticker'                                    , 'ticker'                                    , 'STRING'              ,   3, 1, 0, 1, GETUTCDATE()),
  ( 202, 'EQ_Warehouse', 'IndexValue_Group'                          , 'index_value_group_base', 'IndexName'                                 , 'index_name'                                , 'STRING'              ,   4, 1, 0, 1, GETUTCDATE()),
  ( 203, 'EQ_Warehouse', 'IndexValue_Group'                          , 'index_value_group_base', 'EffectiveDate'                             , 'effective_timestamp'                       , 'TIMESTAMP'           ,   5, 1, 0, 1, GETUTCDATE()),
  ( 204, 'EQ_Warehouse', 'IndexValue_Group'                          , 'index_value_group_base', 'IndexValue'                                , 'index_value'                               , 'DECIMAL(18,4)'       ,   6, 1, 0, 1, GETUTCDATE()),
  ( 205, 'EQ_Warehouse', 'IndexValue_Group'                          , 'index_value_group_base', 'Change'                                    , 'change_amount'                             , 'DECIMAL(18,4)'       ,   7, 1, 0, 1, GETUTCDATE());

-- [18] ExternalAccount_Group (12 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  ( 211, 'EQ_Warehouse', 'ExternalAccount_Group'                     , 'external_account_group_base', 'ExternalAccountGroupPK'                    , 'external_account_group_id'                 , 'INT'                 ,   1, 1, 1, 1, GETUTCDATE()),
  ( 212, 'EQ_Warehouse', 'ExternalAccount_Group'                     , 'external_account_group_base', 'ExternalAccountGroupKey'                   , 'external_account_group_key'                , 'INT'                 ,   2, 1, 0, 1, GETUTCDATE()),
  ( 213, 'EQ_Warehouse', 'ExternalAccount_Group'                     , 'external_account_group_base', 'ExternalAccountType'                       , 'external_account_type'                     , 'STRING'              ,   3, 1, 0, 1, GETUTCDATE()),
  ( 214, 'EQ_Warehouse', 'ExternalAccount_Group'                     , 'external_account_group_base', 'Company'                                   , 'company_name'                              , 'STRING'              ,   4, 1, 0, 1, GETUTCDATE()),
  ( 215, 'EQ_Warehouse', 'ExternalAccount_Group'                     , 'external_account_group_base', 'RoutingNumber'                             , 'routing_number'                            , 'STRING'              ,   5, 1, 0, 1, GETUTCDATE()),
  ( 216, 'EQ_Warehouse', 'ExternalAccount_Group'                     , 'external_account_group_base', 'AccountNumber'                             , 'account_number'                            , 'STRING'              ,   6, 1, 0, 1, GETUTCDATE()),
  ( 217, 'EQ_Warehouse', 'ExternalAccount_Group'                     , 'external_account_group_base', 'VerificationCode'                          , 'verification_code'                         , 'STRING'              ,   7, 1, 0, 1, GETUTCDATE()),
  ( 218, 'EQ_Warehouse', 'ExternalAccount_Group'                     , 'external_account_group_base', 'VerificationResponse'                      , 'verification_response'                     , 'STRING'              ,   8, 1, 0, 1, GETUTCDATE()),
  ( 219, 'EQ_Warehouse', 'ExternalAccount_Group'                     , 'external_account_group_base', 'VerificationDate'                          , 'verification_timestamp'                    , 'TIMESTAMP'           ,   9, 1, 0, 1, GETUTCDATE()),
  ( 220, 'EQ_Warehouse', 'ExternalAccount_Group'                     , 'external_account_group_base', 'Active'                                    , 'is_active'                                 , 'BOOLEAN'             ,  10, 1, 0, 1, GETUTCDATE()),
  ( 221, 'EQ_Warehouse', 'ExternalAccount_Group'                     , 'external_account_group_base', 'StartDate'                                 , 'start_timestamp'                           , 'TIMESTAMP'           ,  11, 1, 0, 1, GETUTCDATE()),
  ( 222, 'EQ_Warehouse', 'ExternalAccount_Group'                     , 'external_account_group_base', 'EndDate'                                   , 'end_timestamp'                             , 'TIMESTAMP'           ,  12, 1, 0, 1, GETUTCDATE());

-- [19] ContractValue_Group (13 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  ( 225, 'EQ_Warehouse', 'ContractValue_Group'                       , 'contract_value_group_base', 'ContractValueGroupPK'                      , 'contract_value_group_id'                   , 'INT'                 ,   1, 1, 1, 1, GETUTCDATE()),
  ( 226, 'EQ_Warehouse', 'ContractValue_Group'                       , 'contract_value_group_base', 'ContractValueGroupKey'                     , 'contract_value_group_key'                  , 'INT'                 ,   2, 1, 0, 1, GETUTCDATE()),
  ( 227, 'EQ_Warehouse', 'ContractValue_Group'                       , 'contract_value_group_base', 'ValueType'                                 , 'value_type'                                , 'STRING'              ,   3, 1, 0, 1, GETUTCDATE()),
  ( 228, 'EQ_Warehouse', 'ContractValue_Group'                       , 'contract_value_group_base', 'ValueDate'                                 , 'value_timestamp'                           , 'TIMESTAMP'           ,   4, 1, 0, 1, GETUTCDATE()),
  ( 229, 'EQ_Warehouse', 'ContractValue_Group'                       , 'contract_value_group_base', 'Value'                                     , 'value'                                     , 'DECIMAL(18,4)'       ,   5, 1, 0, 1, GETUTCDATE()),
  ( 230, 'EQ_Warehouse', 'ContractValue_Group'                       , 'contract_value_group_base', 'ValueAsDate'                               , 'value_as_timestamp'                        , 'TIMESTAMP'           ,   6, 1, 0, 1, GETUTCDATE()),
  ( 231, 'EQ_Warehouse', 'ContractValue_Group'                       , 'contract_value_group_base', 'StartDate'                                 , 'start_timestamp'                           , 'TIMESTAMP'           ,   7, 1, 0, 1, GETUTCDATE()),
  ( 232, 'EQ_Warehouse', 'ContractValue_Group'                       , 'contract_value_group_base', 'EndDate'                                   , 'end_timestamp'                             , 'TIMESTAMP'           ,   8, 1, 0, 1, GETUTCDATE());

-- [20] ContractDeposit_Group (22 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  ( 238, 'EQ_Warehouse', 'ContractDeposit_Group'                     , 'contract_deposit_group_base', 'ContractDepositGroupPK'                    , 'contract_deposit_group_id'                 , 'INT'                 ,   1, 1, 1, 1, GETUTCDATE()),
  ( 239, 'EQ_Warehouse', 'ContractDeposit_Group'                     , 'contract_deposit_group_base', 'SourceKey'                                 , 'source_key'                                , 'BIGINT'              ,   2, 1, 0, 1, GETUTCDATE()),
  ( 240, 'EQ_Warehouse', 'ContractDeposit_Group'                     , 'contract_deposit_group_base', 'ContractDepositGroupKey'                   , 'contract_deposit_group_key'                , 'INT'                 ,   3, 1, 0, 1, GETUTCDATE()),
  ( 241, 'EQ_Warehouse', 'ContractDeposit_Group'                     , 'contract_deposit_group_base', 'DepositType'                               , 'deposit_type'                              , 'STRING'              ,   4, 1, 0, 1, GETUTCDATE()),
  ( 242, 'EQ_Warehouse', 'ContractDeposit_Group'                     , 'contract_deposit_group_base', 'DepositSource'                             , 'deposit_source'                            , 'STRING'              ,   5, 1, 0, 1, GETUTCDATE()),
  ( 243, 'EQ_Warehouse', 'ContractDeposit_Group'                     , 'contract_deposit_group_base', 'OriginalContract'                          , 'original_contract'                         , 'STRING'              ,   6, 1, 0, 1, GETUTCDATE()),
  ( 244, 'EQ_Warehouse', 'ContractDeposit_Group'                     , 'contract_deposit_group_base', 'DateReceived'                              , 'date_received_timestamp'                   , 'TIMESTAMP'           ,   7, 1, 0, 1, GETUTCDATE()),
  ( 245, 'EQ_Warehouse', 'ContractDeposit_Group'                     , 'contract_deposit_group_base', 'ProcessDate'                               , 'process_timestamp'                         , 'TIMESTAMP'           ,   8, 1, 0, 1, GETUTCDATE()),
  ( 246, 'EQ_Warehouse', 'ContractDeposit_Group'                     , 'contract_deposit_group_base', 'TaxYear'                                   , 'tax_year'                                  , 'INT'                 ,   9, 1, 0, 1, GETUTCDATE()),
  ( 247, 'EQ_Warehouse', 'ContractDeposit_Group'                     , 'contract_deposit_group_base', 'ReplacementType'                           , 'replacement_type'                          , 'STRING'              ,  10, 1, 0, 1, GETUTCDATE()),
  ( 248, 'EQ_Warehouse', 'ContractDeposit_Group'                     , 'contract_deposit_group_base', 'PremiumType'                               , 'premium_type'                              , 'STRING'              ,  11, 1, 0, 1, GETUTCDATE()),
  ( 249, 'EQ_Warehouse', 'ContractDeposit_Group'                     , 'contract_deposit_group_base', 'PlannedIndicator'                          , 'planned_indicator'                         , 'STRING'              ,  12, 1, 0, 1, GETUTCDATE()),
  ( 250, 'EQ_Warehouse', 'ContractDeposit_Group'                     , 'contract_deposit_group_base', 'Reference'                                 , 'reference'                                 , 'STRING'              ,  13, 1, 0, 1, GETUTCDATE()),
  ( 251, 'EQ_Warehouse', 'ContractDeposit_Group'                     , 'contract_deposit_group_base', 'AnticipatedAmount'                         , 'anticipated_amount'                        , 'DECIMAL(18,4)'       ,  14, 1, 0, 1, GETUTCDATE()),
  ( 252, 'EQ_Warehouse', 'ContractDeposit_Group'                     , 'contract_deposit_group_base', 'ActualAmount'                              , 'actual_amount'                             , 'DECIMAL(18,4)'       ,  15, 1, 0, 1, GETUTCDATE()),
  ( 253, 'EQ_Warehouse', 'ContractDeposit_Group'                     , 'contract_deposit_group_base', 'CostBasis'                                 , 'cost_basis'                                , 'DECIMAL(18,4)'       ,  16, 1, 0, 1, GETUTCDATE()),
  ( 254, 'EQ_Warehouse', 'ContractDeposit_Group'                     , 'contract_deposit_group_base', 'RefundAmount'                              , 'refund_amount'                             , 'DECIMAL(18,4)'       ,  17, 1, 0, 1, GETUTCDATE());

-- [21] AgentSummary_Group (10 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  ( 260, 'EQ_Warehouse', 'AgentSummary_Group'                        , 'agent_summary_group_base', 'AgentSummaryGroupPK'                       , 'agent_summary_group_id'                    , 'INT'                 ,   1, 1, 1, 1, GETUTCDATE()),
  ( 261, 'EQ_Warehouse', 'AgentSummary_Group'                        , 'agent_summary_group_base', 'AgentSummaryGroupKey'                      , 'agent_summary_group_key'                   , 'INT'                 ,   2, 1, 0, 1, GETUTCDATE()),
  ( 262, 'EQ_Warehouse', 'AgentSummary_Group'                        , 'agent_summary_group_base', 'SummaryType'                               , 'summary_type'                              , 'STRING'              ,   3, 1, 0, 1, GETUTCDATE()),
  ( 263, 'EQ_Warehouse', 'AgentSummary_Group'                        , 'agent_summary_group_base', 'SummaryDate'                               , 'summary_timestamp'                         , 'TIMESTAMP'           ,   4, 1, 0, 1, GETUTCDATE()),
  ( 264, 'EQ_Warehouse', 'AgentSummary_Group'                        , 'agent_summary_group_base', 'SummaryValue'                              , 'summary_value'                             , 'DECIMAL(18,4)'       ,   5, 1, 0, 1, GETUTCDATE());

-- [22] AgentPrincipal_Group (10 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  ( 270, 'EQ_Warehouse', 'AgentPrincipal_Group'                      , 'agent_principal_group_base', 'AgentPrincipalGroupPK'                     , 'agent_principal_group_id'                  , 'INT'                 ,   1, 1, 1, 1, GETUTCDATE()),
  ( 271, 'EQ_Warehouse', 'AgentPrincipal_Group'                      , 'agent_principal_group_base', 'AgentPrincipalGroupKey'                    , 'agent_principal_group_key'                 , 'INT'                 ,   2, 1, 0, 1, GETUTCDATE()),
  ( 272, 'EQ_Warehouse', 'AgentPrincipal_Group'                      , 'agent_principal_group_base', 'PrincipalAgentFK'                          , 'principal_agent_id'                        , 'INT'                 ,   3, 1, 0, 1, GETUTCDATE()),
  ( 273, 'EQ_Warehouse', 'AgentPrincipal_Group'                      , 'agent_principal_group_base', 'StartDate'                                 , 'start_timestamp'                           , 'TIMESTAMP'           ,   4, 1, 0, 1, GETUTCDATE()),
  ( 274, 'EQ_Warehouse', 'AgentPrincipal_Group'                      , 'agent_principal_group_base', 'EndDate'                                   , 'end_timestamp'                             , 'TIMESTAMP'           ,   5, 1, 0, 1, GETUTCDATE());

-- [23] AgentLicense_Group (16 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  ( 280, 'EQ_Warehouse', 'AgentLicense_Group'                        , 'agent_license_group_base', 'AgentLicenseGroupPK'                       , 'agent_license_group_id'                    , 'INT'                 ,   1, 1, 1, 1, GETUTCDATE()),
  ( 281, 'EQ_Warehouse', 'AgentLicense_Group'                        , 'agent_license_group_base', 'SourceKey'                                 , 'source_key'                                , 'BIGINT'              ,   2, 1, 0, 1, GETUTCDATE()),
  ( 282, 'EQ_Warehouse', 'AgentLicense_Group'                        , 'agent_license_group_base', 'AgentLicenseGroupKey'                      , 'agent_license_group_key'                   , 'INT'                 ,   3, 1, 0, 1, GETUTCDATE()),
  ( 283, 'EQ_Warehouse', 'AgentLicense_Group'                        , 'agent_license_group_base', 'LicenseType'                               , 'license_type'                              , 'STRING'              ,   4, 1, 0, 1, GETUTCDATE()),
  ( 284, 'EQ_Warehouse', 'AgentLicense_Group'                        , 'agent_license_group_base', 'LicenseState'                              , 'license_state'                             , 'STRING'              ,   5, 1, 0, 1, GETUTCDATE()),
  ( 285, 'EQ_Warehouse', 'AgentLicense_Group'                        , 'agent_license_group_base', 'Resident'                                  , 'resident'                                  , 'STRING'              ,   6, 1, 0, 1, GETUTCDATE()),
  ( 286, 'EQ_Warehouse', 'AgentLicense_Group'                        , 'agent_license_group_base', 'LicenseNumber'                             , 'license_number'                            , 'STRING'              ,   7, 1, 0, 1, GETUTCDATE()),
  ( 287, 'EQ_Warehouse', 'AgentLicense_Group'                        , 'agent_license_group_base', 'Status'                                    , 'status'                                    , 'STRING'              ,   8, 1, 0, 1, GETUTCDATE()),
  ( 288, 'EQ_Warehouse', 'AgentLicense_Group'                        , 'agent_license_group_base', 'EffectiveDate'                             , 'effective_timestamp'                       , 'TIMESTAMP'           ,   9, 1, 0, 1, GETUTCDATE()),
  ( 289, 'EQ_Warehouse', 'AgentLicense_Group'                        , 'agent_license_group_base', 'ExpirationDate'                            , 'expiration_timestamp'                      , 'TIMESTAMP'           ,  10, 1, 0, 1, GETUTCDATE()),
  ( 290, 'EQ_Warehouse', 'AgentLicense_Group'                        , 'agent_license_group_base', 'TerminationDate'                           , 'termination_timestamp'                     , 'TIMESTAMP'           ,  11, 1, 0, 1, GETUTCDATE());

-- [24] AdditionalInfo_Group (19 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  ( 296, 'EQ_Warehouse', 'AdditionalInfo_Group'                      , 'additional_info_group_base', 'AdditionalInfoGroupPK'                     , 'additional_info_group_id'                  , 'INT'                 ,   1, 1, 1, 1, GETUTCDATE()),
  ( 297, 'EQ_Warehouse', 'AdditionalInfo_Group'                      , 'additional_info_group_base', 'AdditionalInfoGroupKey'                    , 'additional_info_group_key'                 , 'INT'                 ,   2, 1, 0, 1, GETUTCDATE()),
  ( 298, 'EQ_Warehouse', 'AdditionalInfo_Group'                      , 'additional_info_group_base', 'AdditionalInfoSource'                      , 'additional_info_source'                    , 'STRING'              ,   3, 1, 0, 1, GETUTCDATE()),
  ( 299, 'EQ_Warehouse', 'AdditionalInfo_Group'                      , 'additional_info_group_base', 'AdditionalInfoType'                        , 'additional_info_type'                      , 'STRING'              ,   4, 1, 0, 1, GETUTCDATE()),
  ( 300, 'EQ_Warehouse', 'AdditionalInfo_Group'                      , 'additional_info_group_base', 'AdditionalInfoDescription'                 , 'additional_info_description'               , 'STRING'              ,   5, 1, 0, 1, GETUTCDATE()),
  ( 301, 'EQ_Warehouse', 'AdditionalInfo_Group'                      , 'additional_info_group_base', 'AdditionalInfoValue'                       , 'additional_info_value'                     , 'STRING'              ,   6, 1, 0, 1, GETUTCDATE()),
  ( 302, 'EQ_Warehouse', 'AdditionalInfo_Group'                      , 'additional_info_group_base', 'AddressLine1'                              , 'address_line_1'                            , 'STRING'              ,   7, 1, 0, 1, GETUTCDATE()),
  ( 303, 'EQ_Warehouse', 'AdditionalInfo_Group'                      , 'additional_info_group_base', 'AddressLine2'                              , 'address_line_2'                            , 'STRING'              ,   8, 1, 0, 1, GETUTCDATE()),
  ( 304, 'EQ_Warehouse', 'AdditionalInfo_Group'                      , 'additional_info_group_base', 'AddressLine3'                              , 'address_line_3'                            , 'STRING'              ,   9, 1, 0, 1, GETUTCDATE()),
  ( 305, 'EQ_Warehouse', 'AdditionalInfo_Group'                      , 'additional_info_group_base', 'AddressLine4'                              , 'address_line_4'                            , 'STRING'              ,  10, 1, 0, 1, GETUTCDATE()),
  ( 306, 'EQ_Warehouse', 'AdditionalInfo_Group'                      , 'additional_info_group_base', 'City'                                      , 'city'                                      , 'STRING'              ,  11, 1, 0, 1, GETUTCDATE()),
  ( 307, 'EQ_Warehouse', 'AdditionalInfo_Group'                      , 'additional_info_group_base', 'State'                                     , 'state'                                     , 'STRING'              ,  12, 1, 0, 1, GETUTCDATE()),
  ( 308, 'EQ_Warehouse', 'AdditionalInfo_Group'                      , 'additional_info_group_base', 'ZipCode'                                   , 'zip_code'                                  , 'STRING'              ,  13, 1, 0, 1, GETUTCDATE()),
  ( 309, 'EQ_Warehouse', 'AdditionalInfo_Group'                      , 'additional_info_group_base', 'EffectiveDate'                             , 'effective_timestamp'                       , 'TIMESTAMP'           ,  14, 1, 0, 1, GETUTCDATE());

-- [25] AdditionalClient_Group (12 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  ( 315, 'EQ_Warehouse', 'AdditionalClient_Group'                    , 'additional_client_group_base', 'AdditionalClientGroupPK'                   , 'additional_client_group_id'                , 'INT'                 ,   1, 1, 1, 1, GETUTCDATE()),
  ( 316, 'EQ_Warehouse', 'AdditionalClient_Group'                    , 'additional_client_group_base', 'AdditionalClientGroupKey'                  , 'additional_client_group_key'               , 'INT'                 ,   2, 1, 0, 1, GETUTCDATE()),
  ( 317, 'EQ_Warehouse', 'AdditionalClient_Group'                    , 'additional_client_group_base', 'ClientFK'                                  , 'client_id'                                 , 'INT'                 ,   3, 1, 0, 1, GETUTCDATE()),
  ( 318, 'EQ_Warehouse', 'AdditionalClient_Group'                    , 'additional_client_group_base', 'AdditionalType'                            , 'additional_type'                           , 'STRING'              ,   4, 1, 0, 1, GETUTCDATE()),
  ( 319, 'EQ_Warehouse', 'AdditionalClient_Group'                    , 'additional_client_group_base', 'Relation'                                  , 'relation'                                  , 'STRING'              ,   5, 1, 0, 1, GETUTCDATE()),
  ( 320, 'EQ_Warehouse', 'AdditionalClient_Group'                    , 'additional_client_group_base', 'AllocationPercent'                         , 'allocation_percent'                        , 'DECIMAL(18,4)'       ,   6, 1, 0, 1, GETUTCDATE()),
  ( 321, 'EQ_Warehouse', 'AdditionalClient_Group'                    , 'additional_client_group_base', 'Active'                                    , 'is_active'                                 , 'BOOLEAN'             ,   7, 1, 0, 1, GETUTCDATE());

-- [26] AccountingReporting_Group (10 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  ( 327, 'EQ_Warehouse', 'AccountingReporting_Group'                 , 'accounting_reporting_group_base', 'AccountingReportingGroupPK'                , 'accounting_reporting_group_id'             , 'INT'                 ,   1, 1, 1, 1, GETUTCDATE()),
  ( 328, 'EQ_Warehouse', 'AccountingReporting_Group'                 , 'accounting_reporting_group_base', 'AccountingReportingGroupKey'               , 'accounting_reporting_group_key'            , 'INT'                 ,   2, 1, 0, 1, GETUTCDATE()),
  ( 329, 'EQ_Warehouse', 'AccountingReporting_Group'                 , 'accounting_reporting_group_base', 'ReportingCode'                             , 'reporting_code'                            , 'STRING'              ,   3, 1, 0, 1, GETUTCDATE()),
  ( 330, 'EQ_Warehouse', 'AccountingReporting_Group'                 , 'accounting_reporting_group_base', 'ReportingClassCode'                        , 'reporting_class_code'                      , 'STRING'              ,   4, 1, 0, 1, GETUTCDATE()),
  ( 331, 'EQ_Warehouse', 'AccountingReporting_Group'                 , 'accounting_reporting_group_base', 'ReportingDescription'                      , 'reporting_description'                     , 'STRING'              ,   5, 1, 0, 1, GETUTCDATE());

-- [27] ProductVariationDetail (9 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  ( 337, 'EQ_Warehouse', 'ProductVariationDetail'                    , 'product_variation_detail_base', 'ProductVariationDetailPK'                  , 'product_variation_detail_id'               , 'INT'                 ,   1, 1, 1, 1, GETUTCDATE()),
  ( 338, 'EQ_Warehouse', 'ProductVariationDetail'                    , 'product_variation_detail_base', 'DisclosureText'                            , 'disclosure_text'                           , 'STRING'              ,   2, 1, 0, 1, GETUTCDATE()),
  ( 339, 'EQ_Warehouse', 'ProductVariationDetail'                    , 'product_variation_detail_base', 'SortOrder'                                 , 'sort_order'                                , 'INT'                 ,   3, 1, 0, 1, GETUTCDATE()),
  ( 340, 'EQ_Warehouse', 'ProductVariationDetail'                    , 'product_variation_detail_base', 'Type'                                      , 'type'                                      , 'STRING'              ,   4, 1, 0, 1, GETUTCDATE());

-- [28] ProductStateVariation (9 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  ( 346, 'EQ_Warehouse', 'ProductStateVariation'                     , 'product_state_variation_base', 'ProductStateVariationPK'                   , 'product_state_variation_id'                , 'INT'                 ,   1, 1, 1, 1, GETUTCDATE()),
  ( 347, 'EQ_Warehouse', 'ProductStateVariation'                     , 'product_state_variation_base', 'ProductFK'                                 , 'product_id'                                , 'INT'                 ,   2, 1, 0, 1, GETUTCDATE()),
  ( 348, 'EQ_Warehouse', 'ProductStateVariation'                     , 'product_state_variation_base', 'StateCode'                                 , 'state_code'                                , 'STRING'              ,   3, 1, 0, 1, GETUTCDATE()),
  ( 349, 'EQ_Warehouse', 'ProductStateVariation'                     , 'product_state_variation_base', 'ProductVariationDetailFK'                  , 'product_variation_detail_id'               , 'INT'                 ,   4, 1, 0, 1, GETUTCDATE());

-- [29] ProductStateApprovalDisclosure (10 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  ( 355, 'EQ_Warehouse', 'ProductStateApprovalDisclosure'            , 'product_state_approval_disclosure_base', 'PSADisclosurePK'                           , 'product_state_approval_disclosure_id'      , 'INT'                 ,   1, 1, 1, 1, GETUTCDATE()),
  ( 356, 'EQ_Warehouse', 'ProductStateApprovalDisclosure'            , 'product_state_approval_disclosure_base', 'ProductStateApprovalFK'                    , 'product_state_approval_id'                 , 'INT'                 ,   2, 1, 0, 1, GETUTCDATE()),
  ( 357, 'EQ_Warehouse', 'ProductStateApprovalDisclosure'            , 'product_state_approval_disclosure_base', 'MarketingNameOverride'                     , 'marketing_name_override'                   , 'STRING'              ,   3, 1, 0, 1, GETUTCDATE()),
  ( 358, 'EQ_Warehouse', 'ProductStateApprovalDisclosure'            , 'product_state_approval_disclosure_base', 'DisclosureText'                            , 'disclosure_text'                           , 'STRING'              ,   4, 1, 0, 1, GETUTCDATE()),
  ( 359, 'EQ_Warehouse', 'ProductStateApprovalDisclosure'            , 'product_state_approval_disclosure_base', 'SortOrder'                                 , 'sort_order'                                , 'INT'                 ,   5, 1, 0, 1, GETUTCDATE());

-- [30] ProductStateApproval (11 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  ( 365, 'EQ_Warehouse', 'ProductStateApproval'                      , 'product_state_approval_base', 'ProductStateApprovalPK'                    , 'product_state_approval_id'                 , 'INT'                 ,   1, 1, 1, 1, GETUTCDATE()),
  ( 366, 'EQ_Warehouse', 'ProductStateApproval'                      , 'product_state_approval_base', 'ProductFK'                                 , 'product_id'                                , 'INT'                 ,   2, 1, 0, 1, GETUTCDATE()),
  ( 367, 'EQ_Warehouse', 'ProductStateApproval'                      , 'product_state_approval_base', 'StateCode'                                 , 'state_code'                                , 'STRING'              ,   3, 1, 0, 1, GETUTCDATE()),
  ( 368, 'EQ_Warehouse', 'ProductStateApproval'                      , 'product_state_approval_base', 'ApprovedInd'                               , 'is_approved'                               , 'BOOLEAN'             ,   4, 1, 0, 1, GETUTCDATE()),
  ( 369, 'EQ_Warehouse', 'ProductStateApproval'                      , 'product_state_approval_base', 'StartDate'                                 , 'start_timestamp'                           , 'TIMESTAMP'           ,   5, 1, 0, 1, GETUTCDATE()),
  ( 370, 'EQ_Warehouse', 'ProductStateApproval'                      , 'product_state_approval_base', 'EndDate'                                   , 'end_timestamp'                             , 'TIMESTAMP'           ,   6, 1, 0, 1, GETUTCDATE());

-- [31] hedge.Ratios (12 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  ( 376, 'EQ_Warehouse', 'hedge.Ratios'                              , 'hedge_ratios_base', 'RatiosPK'                                  , 'ratios_id'                                 , 'INT'                 ,   1, 1, 1, 1, GETUTCDATE()),
  ( 377, 'EQ_Warehouse', 'hedge.Ratios'                              , 'hedge_ratios_base', 'ContractFK'                                , 'contract_id'                               , 'INT'                 ,   2, 1, 0, 1, GETUTCDATE()),
  ( 378, 'EQ_Warehouse', 'hedge.Ratios'                              , 'hedge_ratios_base', 'ValueDate'                                 , 'value_timestamp'                           , 'TIMESTAMP'           ,   3, 1, 0, 1, GETUTCDATE()),
  ( 379, 'EQ_Warehouse', 'hedge.Ratios'                              , 'hedge_ratios_base', 'BaseHedgeRatio'                            , 'base_hedge_ratio'                          , 'DECIMAL(18,4)'       ,   4, 1, 0, 1, GETUTCDATE()),
  ( 380, 'EQ_Warehouse', 'hedge.Ratios'                              , 'hedge_ratios_base', 'BaseSurvivalRatio'                         , 'base_survival_ratio'                       , 'DECIMAL(18,4)'       ,   5, 1, 0, 1, GETUTCDATE()),
  ( 381, 'EQ_Warehouse', 'hedge.Ratios'                              , 'hedge_ratios_base', 'StartDate'                                 , 'start_timestamp'                           , 'TIMESTAMP'           ,   6, 1, 0, 1, GETUTCDATE()),
  ( 382, 'EQ_Warehouse', 'hedge.Ratios'                              , 'hedge_ratios_base', 'EndDate'                                   , 'end_timestamp'                             , 'TIMESTAMP'           ,   7, 1, 0, 1, GETUTCDATE());

-- [32] hedge.Options (26 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  ( 388, 'EQ_Warehouse', 'hedge.Options'                             , 'hedge_options_base', 'OptionsPK'                                 , 'options_id'                                , 'INT'                 ,   1, 1, 1, 1, GETUTCDATE()),
  ( 389, 'EQ_Warehouse', 'hedge.Options'                             , 'hedge_options_base', 'ContractFK'                                , 'contract_id'                               , 'INT'                 ,   2, 1, 0, 1, GETUTCDATE()),
  ( 390, 'EQ_Warehouse', 'hedge.Options'                             , 'hedge_options_base', 'InvestmentFK'                              , 'investment_id'                             , 'INT'                 ,   3, 1, 0, 1, GETUTCDATE()),
  ( 391, 'EQ_Warehouse', 'hedge.Options'                             , 'hedge_options_base', 'RenewalDate'                               , 'renewal_timestamp'                         , 'TIMESTAMP'           ,   4, 1, 0, 1, GETUTCDATE()),
  ( 392, 'EQ_Warehouse', 'hedge.Options'                             , 'hedge_options_base', 'IndexValue'                                , 'index_value'                               , 'DECIMAL(18,4)'       ,   5, 1, 0, 1, GETUTCDATE()),
  ( 393, 'EQ_Warehouse', 'hedge.Options'                             , 'hedge_options_base', 'HedgingPercentage'                         , 'hedging_percentage'                        , 'DECIMAL(18,4)'       ,   6, 1, 0, 1, GETUTCDATE()),
  ( 394, 'EQ_Warehouse', 'hedge.Options'                             , 'hedge_options_base', 'HedgeID1'                                  , 'hedge_id_1'                                , 'STRING'              ,   7, 1, 0, 1, GETUTCDATE()),
  ( 395, 'EQ_Warehouse', 'hedge.Options'                             , 'hedge_options_base', 'HedgeID2'                                  , 'hedge_id_2'                                , 'STRING'              ,   8, 1, 0, 1, GETUTCDATE()),
  ( 396, 'EQ_Warehouse', 'hedge.Options'                             , 'hedge_options_base', 'HedgeRenewalDate'                          , 'hedge_renewal_timestamp'                   , 'TIMESTAMP'           ,   9, 1, 0, 1, GETUTCDATE()),
  ( 397, 'EQ_Warehouse', 'hedge.Options'                             , 'hedge_options_base', 'ValueDate'                                 , 'value_timestamp'                           , 'TIMESTAMP'           ,  10, 1, 0, 1, GETUTCDATE()),
  ( 398, 'EQ_Warehouse', 'hedge.Options'                             , 'hedge_options_base', 'SeriatimHedgeRatio'                        , 'seriatim_hedge_ratio'                      , 'DECIMAL(18,4)'       ,  11, 1, 0, 1, GETUTCDATE()),
  ( 399, 'EQ_Warehouse', 'hedge.Options'                             , 'hedge_options_base', 'PresentValue'                              , 'present_value'                             , 'DECIMAL(18,4)'       ,  12, 1, 0, 1, GETUTCDATE()),
  ( 400, 'EQ_Warehouse', 'hedge.Options'                             , 'hedge_options_base', 'Delta'                                     , 'delta'                                     , 'DECIMAL(18,4)'       ,  13, 1, 0, 1, GETUTCDATE()),
  ( 401, 'EQ_Warehouse', 'hedge.Options'                             , 'hedge_options_base', 'Gamma'                                     , 'gamma'                                     , 'DECIMAL(18,4)'       ,  14, 1, 0, 1, GETUTCDATE()),
  ( 402, 'EQ_Warehouse', 'hedge.Options'                             , 'hedge_options_base', 'Vega'                                      , 'vega'                                      , 'DECIMAL(18,4)'       ,  15, 1, 0, 1, GETUTCDATE()),
  ( 403, 'EQ_Warehouse', 'hedge.Options'                             , 'hedge_options_base', 'Rho'                                       , 'rho'                                       , 'DECIMAL(18,4)'       ,  16, 1, 0, 1, GETUTCDATE()),
  ( 404, 'EQ_Warehouse', 'hedge.Options'                             , 'hedge_options_base', 'Theta'                                     , 'theta'                                     , 'DECIMAL(18,4)'       ,  17, 1, 0, 1, GETUTCDATE()),
  ( 405, 'EQ_Warehouse', 'hedge.Options'                             , 'hedge_options_base', 'NeedsHedged'                               , 'needs_hedged'                              , 'BOOLEAN'             ,  18, 1, 0, 1, GETUTCDATE()),
  ( 406, 'EQ_Warehouse', 'hedge.Options'                             , 'hedge_options_base', 'IsHedged'                                  , 'is_hedged'                                 , 'BOOLEAN'             ,  19, 1, 0, 1, GETUTCDATE()),
  ( 407, 'EQ_Warehouse', 'hedge.Options'                             , 'hedge_options_base', 'StartDate'                                 , 'start_timestamp'                           , 'TIMESTAMP'           ,  20, 1, 0, 1, GETUTCDATE()),
  ( 408, 'EQ_Warehouse', 'hedge.Options'                             , 'hedge_options_base', 'EndDate'                                   , 'end_timestamp'                             , 'TIMESTAMP'           ,  21, 1, 0, 1, GETUTCDATE());

-- [33] State (8 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  ( 414, 'EQ_Warehouse', 'State'                                     , 'state_base', 'StateCode'                                 , 'state_code'                                , 'STRING'              ,   1, 1, 0, 1, GETUTCDATE()),
  ( 415, 'EQ_Warehouse', 'State'                                     , 'state_base', 'StateName'                                 , 'state_name'                                , 'STRING'              ,   2, 1, 0, 1, GETUTCDATE()),
  ( 416, 'EQ_Warehouse', 'State'                                     , 'state_base', 'DisplayOrder'                              , 'display_order'                             , 'INT'                 ,   3, 1, 0, 1, GETUTCDATE());

-- [34] Date (37 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  ( 422, 'EQ_Warehouse', 'Date'                                      , 'date_base', 'DatePK'                                    , 'date_id'                                   , 'INT'                 ,   1, 1, 1, 1, GETUTCDATE()),
  ( 423, 'EQ_Warehouse', 'Date'                                      , 'date_base', 'Date'                                      , 'calendar_timestamp'                        , 'TIMESTAMP'           ,   2, 1, 0, 1, GETUTCDATE()),
  ( 424, 'EQ_Warehouse', 'Date'                                      , 'date_base', 'DateDisplay'                               , 'date_display'                              , 'STRING'              ,   3, 1, 0, 1, GETUTCDATE()),
  ( 425, 'EQ_Warehouse', 'Date'                                      , 'date_base', 'DayOfMonth'                                , 'day_of_month'                              , 'STRING'              ,   4, 1, 0, 1, GETUTCDATE()),
  ( 426, 'EQ_Warehouse', 'Date'                                      , 'date_base', 'DaySuffix'                                 , 'day_suffix'                                , 'STRING'              ,   5, 1, 0, 1, GETUTCDATE()),
  ( 427, 'EQ_Warehouse', 'Date'                                      , 'date_base', 'DayName'                                   , 'day_name'                                  , 'STRING'              ,   6, 1, 0, 1, GETUTCDATE()),
  ( 428, 'EQ_Warehouse', 'Date'                                      , 'date_base', 'DayOfWeek'                                 , 'day_of_week'                               , 'STRING'              ,   7, 1, 0, 1, GETUTCDATE()),
  ( 429, 'EQ_Warehouse', 'Date'                                      , 'date_base', 'DayOfWeekInMonth'                          , 'day_of_week_in_month'                      , 'STRING'              ,   8, 1, 0, 1, GETUTCDATE()),
  ( 430, 'EQ_Warehouse', 'Date'                                      , 'date_base', 'DayOfWeekInYear'                           , 'day_of_week_in_year'                       , 'STRING'              ,   9, 1, 0, 1, GETUTCDATE()),
  ( 431, 'EQ_Warehouse', 'Date'                                      , 'date_base', 'DayOfYear'                                 , 'day_of_year'                               , 'STRING'              ,  10, 1, 0, 1, GETUTCDATE()),
  ( 432, 'EQ_Warehouse', 'Date'                                      , 'date_base', 'WeekOfMonth'                               , 'week_of_month'                             , 'STRING'              ,  11, 1, 0, 1, GETUTCDATE()),
  ( 433, 'EQ_Warehouse', 'Date'                                      , 'date_base', 'WeekOfQuarter'                             , 'week_of_quarter'                           , 'STRING'              ,  12, 1, 0, 1, GETUTCDATE()),
  ( 434, 'EQ_Warehouse', 'Date'                                      , 'date_base', 'WeekOfYear'                                , 'week_of_year'                              , 'STRING'              ,  13, 1, 0, 1, GETUTCDATE()),
  ( 435, 'EQ_Warehouse', 'Date'                                      , 'date_base', 'Month'                                     , 'month'                                     , 'STRING'              ,  14, 1, 0, 1, GETUTCDATE()),
  ( 436, 'EQ_Warehouse', 'Date'                                      , 'date_base', 'MonthName'                                 , 'month_name'                                , 'STRING'              ,  15, 1, 0, 1, GETUTCDATE()),
  ( 437, 'EQ_Warehouse', 'Date'                                      , 'date_base', 'MonthOfQuarter'                            , 'month_of_quarter'                          , 'STRING'              ,  16, 1, 0, 1, GETUTCDATE()),
  ( 438, 'EQ_Warehouse', 'Date'                                      , 'date_base', 'Quarter'                                   , 'quarter'                                   , 'STRING'              ,  17, 1, 0, 1, GETUTCDATE()),
  ( 439, 'EQ_Warehouse', 'Date'                                      , 'date_base', 'QuarterName'                               , 'quarter_name'                              , 'STRING'              ,  18, 1, 0, 1, GETUTCDATE()),
  ( 440, 'EQ_Warehouse', 'Date'                                      , 'date_base', 'Year'                                      , 'year'                                      , 'STRING'              ,  19, 1, 0, 1, GETUTCDATE()),
  ( 441, 'EQ_Warehouse', 'Date'                                      , 'date_base', 'YearName'                                  , 'year_name'                                 , 'STRING'              ,  20, 1, 0, 1, GETUTCDATE()),
  ( 442, 'EQ_Warehouse', 'Date'                                      , 'date_base', 'MonthYear'                                 , 'month_year'                                , 'STRING'              ,  21, 1, 0, 1, GETUTCDATE()),
  ( 443, 'EQ_Warehouse', 'Date'                                      , 'date_base', 'MMYYYY'                                    , 'mmyyyy'                                    , 'STRING'              ,  22, 1, 0, 1, GETUTCDATE()),
  ( 444, 'EQ_Warehouse', 'Date'                                      , 'date_base', 'FirstDayOfMonth'                           , 'first_day_of_month'                        , 'DATE'                ,  23, 1, 0, 1, GETUTCDATE()),
  ( 445, 'EQ_Warehouse', 'Date'                                      , 'date_base', 'LastDayOfMonth'                            , 'last_day_of_month'                         , 'DATE'                ,  24, 1, 0, 1, GETUTCDATE()),
  ( 446, 'EQ_Warehouse', 'Date'                                      , 'date_base', 'FirstDayOfQuarter'                         , 'first_day_of_quarter'                      , 'DATE'                ,  25, 1, 0, 1, GETUTCDATE()),
  ( 447, 'EQ_Warehouse', 'Date'                                      , 'date_base', 'LastDayOfQuarter'                          , 'last_day_of_quarter'                       , 'DATE'                ,  26, 1, 0, 1, GETUTCDATE()),
  ( 448, 'EQ_Warehouse', 'Date'                                      , 'date_base', 'FirstDayOfYear'                            , 'first_day_of_year'                         , 'DATE'                ,  27, 1, 0, 1, GETUTCDATE()),
  ( 449, 'EQ_Warehouse', 'Date'                                      , 'date_base', 'LastDayOfYear'                             , 'last_day_of_year'                          , 'DATE'                ,  28, 1, 0, 1, GETUTCDATE()),
  ( 450, 'EQ_Warehouse', 'Date'                                      , 'date_base', 'IsWeekday'                                 , 'is_weekday'                                , 'BOOLEAN'             ,  29, 1, 0, 1, GETUTCDATE()),
  ( 451, 'EQ_Warehouse', 'Date'                                      , 'date_base', 'IsHoliday'                                 , 'is_holiday'                                , 'BOOLEAN'             ,  30, 1, 0, 1, GETUTCDATE()),
  ( 452, 'EQ_Warehouse', 'Date'                                      , 'date_base', 'HolidayName'                               , 'holiday_name'                              , 'STRING'              ,  31, 1, 0, 1, GETUTCDATE()),
  ( 453, 'EQ_Warehouse', 'Date'                                      , 'date_base', 'IsLastDayOfMonth'                          , 'is_last_day_of_month'                      , 'BOOLEAN'             ,  32, 1, 0, 1, GETUTCDATE());

-- [35] TrainingCourse (11 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  ( 459, 'EQ_Warehouse', 'TrainingCourse'                            , 'training_course_base', 'TrainingCoursePK'                          , 'training_course_id'                        , 'INT'                 ,   1, 1, 1, 1, GETUTCDATE()),
  ( 460, 'EQ_Warehouse', 'TrainingCourse'                            , 'training_course_base', 'CourseName'                                , 'course_name'                               , 'STRING'              ,   2, 1, 0, 1, GETUTCDATE()),
  ( 461, 'EQ_Warehouse', 'TrainingCourse'                            , 'training_course_base', 'Context'                                   , 'context'                                   , 'STRING'              ,   3, 1, 0, 1, GETUTCDATE()),
  ( 462, 'EQ_Warehouse', 'TrainingCourse'                            , 'training_course_base', 'TrainingProductGroupKey'                   , 'training_product_group_key'                , 'INT'                 ,   4, 1, 0, 1, GETUTCDATE()),
  ( 463, 'EQ_Warehouse', 'TrainingCourse'                            , 'training_course_base', 'TrainingStateGroupKey'                     , 'training_state_group_key'                  , 'INT'                 ,   5, 1, 0, 1, GETUTCDATE()),
  ( 464, 'EQ_Warehouse', 'TrainingCourse'                            , 'training_course_base', 'Description'                               , 'description'                               , 'STRING'              ,   6, 1, 0, 1, GETUTCDATE());

-- [36] AgentTraining (10 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  ( 470, 'EQ_Warehouse', 'AgentTraining'                             , 'agent_training_base', 'AgentTrainingPK'                           , 'agent_training_id'                         , 'INT'                 ,   1, 1, 1, 1, GETUTCDATE()),
  ( 471, 'EQ_Warehouse', 'AgentTraining'                             , 'agent_training_base', 'AgentFK'                                   , 'agent_id'                                  , 'INT'                 ,   2, 1, 0, 1, GETUTCDATE()),
  ( 472, 'EQ_Warehouse', 'AgentTraining'                             , 'agent_training_base', 'TrainingCourseFK'                          , 'training_course_id'                        , 'INT'                 ,   3, 1, 0, 1, GETUTCDATE()),
  ( 473, 'EQ_Warehouse', 'AgentTraining'                             , 'agent_training_base', 'CompletionDate'                            , 'completion_timestamp'                      , 'TIMESTAMP'           ,   4, 1, 0, 1, GETUTCDATE()),
  ( 474, 'EQ_Warehouse', 'AgentTraining'                             , 'agent_training_base', 'ExpirationDate'                            , 'expiration_timestamp'                      , 'TIMESTAMP'           ,   5, 1, 0, 1, GETUTCDATE());

-- [37] Company (17 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  ( 480, 'EQ_Warehouse', 'Company'                                   , 'company_base', 'CompanyPK'                                 , 'company_id'                                , 'INT'                 ,   1, 1, 1, 1, GETUTCDATE()),
  ( 481, 'EQ_Warehouse', 'Company'                                   , 'company_base', 'CompanyCode'                               , 'company_code'                              , 'STRING'              ,   2, 1, 0, 1, GETUTCDATE()),
  ( 482, 'EQ_Warehouse', 'Company'                                   , 'company_base', 'AgentFK'                                   , 'agent_id'                                  , 'INT'                 ,   3, 1, 0, 1, GETUTCDATE()),
  ( 483, 'EQ_Warehouse', 'Company'                                   , 'company_base', 'Name'                                      , 'name'                                      , 'STRING'              ,   4, 1, 0, 1, GETUTCDATE()),
  ( 484, 'EQ_Warehouse', 'Company'                                   , 'company_base', 'DisplayName'                               , 'display_name'                              , 'STRING'              ,   5, 1, 0, 1, GETUTCDATE()),
  ( 485, 'EQ_Warehouse', 'Company'                                   , 'company_base', 'AddressLine1'                              , 'address_line_1'                            , 'STRING'              ,   6, 1, 0, 1, GETUTCDATE()),
  ( 486, 'EQ_Warehouse', 'Company'                                   , 'company_base', 'AddressLine2'                              , 'address_line_2'                            , 'STRING'              ,   7, 1, 0, 1, GETUTCDATE()),
  ( 487, 'EQ_Warehouse', 'Company'                                   , 'company_base', 'City'                                      , 'city'                                      , 'STRING'              ,   8, 1, 0, 1, GETUTCDATE()),
  ( 488, 'EQ_Warehouse', 'Company'                                   , 'company_base', 'State'                                     , 'state'                                     , 'STRING'              ,   9, 1, 0, 1, GETUTCDATE()),
  ( 489, 'EQ_Warehouse', 'Company'                                   , 'company_base', 'ZipCode'                                   , 'zip_code'                                  , 'STRING'              ,  10, 1, 0, 1, GETUTCDATE()),
  ( 490, 'EQ_Warehouse', 'Company'                                   , 'company_base', 'Phone'                                     , 'phone'                                     , 'STRING'              ,  11, 1, 0, 1, GETUTCDATE()),
  ( 491, 'EQ_Warehouse', 'Company'                                   , 'company_base', 'Footer'                                    , 'footer'                                    , 'STRING'              ,  12, 1, 0, 1, GETUTCDATE());

-- [38] CAPStatusChange (12 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  ( 497, 'EQ_Warehouse', 'CAPStatusChange'                           , 'cap_status_change_base', 'CAPStatusChangePK'                         , 'cap_status_change_id'                      , 'INT'                 ,   1, 1, 1, 1, GETUTCDATE()),
  ( 498, 'EQ_Warehouse', 'CAPStatusChange'                           , 'cap_status_change_base', 'ContractFK'                                , 'contract_id'                               , 'INT'                 ,   2, 1, 0, 1, GETUTCDATE()),
  ( 499, 'EQ_Warehouse', 'CAPStatusChange'                           , 'cap_status_change_base', 'SourceCompanyFK'                           , 'source_company_id'                         , 'INT'                 ,   3, 1, 0, 1, GETUTCDATE()),
  ( 500, 'EQ_Warehouse', 'CAPStatusChange'                           , 'cap_status_change_base', 'StatusChangeDate'                          , 'status_change_date'                        , 'TIMESTAMP'           ,   4, 1, 0, 1, GETUTCDATE()),
  ( 501, 'EQ_Warehouse', 'CAPStatusChange'                           , 'cap_status_change_base', 'StatusChangeCode'                          , 'status_change_code'                        , 'STRING'              ,   5, 1, 0, 1, GETUTCDATE()),
  ( 502, 'EQ_Warehouse', 'CAPStatusChange'                           , 'cap_status_change_base', 'ProcessDate'                               , 'process_date'                              , 'TIMESTAMP'           ,   6, 1, 0, 1, GETUTCDATE()),
  ( 503, 'EQ_Warehouse', 'CAPStatusChange'                           , 'cap_status_change_base', 'RenewalPeriod'                             , 'renewal_period'                            , 'INT'                 ,   7, 1, 0, 1, GETUTCDATE());

-- [39] CAPRepayment (16 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  ( 509, 'EQ_Warehouse', 'CAPRepayment'                              , 'cap_repayment_base', 'CAPRepaymentPK'                            , 'cap_repayment_id'                          , 'INT'                 ,   1, 1, 1, 1, GETUTCDATE()),
  ( 510, 'EQ_Warehouse', 'CAPRepayment'                              , 'cap_repayment_base', 'SourceKey'                                 , 'source_key'                                , 'BIGINT'              ,   2, 1, 0, 1, GETUTCDATE()),
  ( 511, 'EQ_Warehouse', 'CAPRepayment'                              , 'cap_repayment_base', 'SourceCompanyFK'                           , 'source_company_id'                         , 'INT'                 ,   3, 1, 0, 1, GETUTCDATE()),
  ( 512, 'EQ_Warehouse', 'CAPRepayment'                              , 'cap_repayment_base', 'PlanCode'                                  , 'plan_code'                                 , 'STRING'              ,   4, 1, 0, 1, GETUTCDATE()),
  ( 513, 'EQ_Warehouse', 'CAPRepayment'                              , 'cap_repayment_base', 'PlanCode2'                                 , 'plan_code_2'                               , 'STRING'              ,   5, 1, 0, 1, GETUTCDATE()),
  ( 514, 'EQ_Warehouse', 'CAPRepayment'                              , 'cap_repayment_base', 'OwnerResState'                             , 'owner_res_state'                           , 'STRING'              ,   6, 1, 0, 1, GETUTCDATE()),
  ( 515, 'EQ_Warehouse', 'CAPRepayment'                              , 'cap_repayment_base', 'OwnerCountry'                              , 'owner_country'                             , 'STRING'              ,   7, 1, 0, 1, GETUTCDATE()),
  ( 516, 'EQ_Warehouse', 'CAPRepayment'                              , 'cap_repayment_base', 'TerminationDate'                           , 'termination_date'                          , 'TIMESTAMP'           ,   8, 1, 0, 1, GETUTCDATE()),
  ( 517, 'EQ_Warehouse', 'CAPRepayment'                              , 'cap_repayment_base', 'FactorTrail'                               , 'factor_trail'                              , 'DECIMAL(18,4)'       ,   9, 1, 0, 1, GETUTCDATE()),
  ( 518, 'EQ_Warehouse', 'CAPRepayment'                              , 'cap_repayment_base', 'RenewalPeriod'                             , 'renewal_period'                            , 'INT'                 ,  10, 1, 0, 1, GETUTCDATE()),
  ( 519, 'EQ_Warehouse', 'CAPRepayment'                              , 'cap_repayment_base', 'CommissionableAmount'                      , 'commissionable_amount'                     , 'DECIMAL(18,4)'       ,  11, 1, 0, 1, GETUTCDATE());

-- [40] ActivityType (11 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  ( 525, 'EQ_Warehouse', 'ActivityType'                              , 'activity_type_base', 'ActivityTypePK'                            , 'activity_type_id'                          , 'INT'                 ,   1, 1, 1, 1, GETUTCDATE()),
  ( 526, 'EQ_Warehouse', 'ActivityType'                              , 'activity_type_base', 'ActivityTypeName'                          , 'activity_type_name'                        , 'STRING'              ,   2, 1, 0, 1, GETUTCDATE()),
  ( 527, 'EQ_Warehouse', 'ActivityType'                              , 'activity_type_base', 'ActivityTypeQualifier'                     , 'activity_type_qualifier'                   , 'STRING'              ,   3, 1, 0, 1, GETUTCDATE()),
  ( 528, 'EQ_Warehouse', 'ActivityType'                              , 'activity_type_base', 'Source'                                    , 'source'                                    , 'STRING'              ,   4, 1, 0, 1, GETUTCDATE()),
  ( 529, 'EQ_Warehouse', 'ActivityType'                              , 'activity_type_base', 'ValueType'                                 , 'value_type'                                , 'STRING'              ,   5, 1, 0, 1, GETUTCDATE()),
  ( 530, 'EQ_Warehouse', 'ActivityType'                              , 'activity_type_base', 'SortOrder'                                 , 'sort_order'                                , 'INT'                 ,   6, 1, 0, 1, GETUTCDATE());

-- [41] ActivityFinancial (18 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  ( 536, 'EQ_Warehouse', 'ActivityFinancial'                         , 'activity_financial_base', 'ActivityPK'                                , 'activity_id'                               , 'BIGINT'              ,   1, 1, 0, 1, GETUTCDATE()),
  ( 537, 'EQ_Warehouse', 'ActivityFinancial'                         , 'activity_financial_base', 'FreeAmount'                                , 'free_amount'                               , 'DECIMAL(18,4)'       ,   2, 1, 0, 1, GETUTCDATE()),
  ( 538, 'EQ_Warehouse', 'ActivityFinancial'                         , 'activity_financial_base', 'SurrenderCharge'                           , 'surrender_charge'                          , 'DECIMAL(18,4)'       ,   3, 1, 0, 1, GETUTCDATE()),
  ( 539, 'EQ_Warehouse', 'ActivityFinancial'                         , 'activity_financial_base', 'MVA'                                       , 'mva'                                       , 'DECIMAL(18,4)'       ,   4, 1, 0, 1, GETUTCDATE()),
  ( 540, 'EQ_Warehouse', 'ActivityFinancial'                         , 'activity_financial_base', 'PolicyFee'                                 , 'policy_fee'                                , 'DECIMAL(18,4)'       ,   5, 1, 0, 1, GETUTCDATE()),
  ( 541, 'EQ_Warehouse', 'ActivityFinancial'                         , 'activity_financial_base', 'COIRefund'                                 , 'coi_refund'                                , 'DECIMAL(18,4)'       ,   6, 1, 0, 1, GETUTCDATE()),
  ( 542, 'EQ_Warehouse', 'ActivityFinancial'                         , 'activity_financial_base', 'ABRDiscountCharge'                         , 'abr_discount_charge'                       , 'DECIMAL(18,4)'       ,   7, 1, 0, 1, GETUTCDATE()),
  ( 543, 'EQ_Warehouse', 'ActivityFinancial'                         , 'activity_financial_base', 'AdminCharge'                               , 'admin_charge'                              , 'DECIMAL(18,4)'       ,   8, 1, 0, 1, GETUTCDATE()),
  ( 544, 'EQ_Warehouse', 'ActivityFinancial'                         , 'activity_financial_base', 'FederalTax'                                , 'federal_tax'                               , 'DECIMAL(18,4)'       ,   9, 1, 0, 1, GETUTCDATE()),
  ( 545, 'EQ_Warehouse', 'ActivityFinancial'                         , 'activity_financial_base', 'StateTax'                                  , 'state_tax'                                 , 'DECIMAL(18,4)'       ,  10, 1, 0, 1, GETUTCDATE()),
  ( 546, 'EQ_Warehouse', 'ActivityFinancial'                         , 'activity_financial_base', 'Rate'                                      , 'rate'                                      , 'DECIMAL(18,4)'       ,  11, 1, 0, 1, GETUTCDATE()),
  ( 547, 'EQ_Warehouse', 'ActivityFinancial'                         , 'activity_financial_base', 'BaseAmount'                                , 'base_amount'                               , 'DECIMAL(18,4)'       ,  12, 1, 0, 1, GETUTCDATE()),
  ( 548, 'EQ_Warehouse', 'ActivityFinancial'                         , 'activity_financial_base', 'TaxableBenefit'                            , 'taxable_benefit'                           , 'DECIMAL(18,4)'       ,  13, 1, 0, 1, GETUTCDATE());

-- [42] AccountingDetail (23 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  ( 554, 'EQ_Warehouse', 'AccountingDetail'                          , 'accounting_detail_base', 'AccountingPK'                              , 'accounting_id'                             , 'BIGINT'              ,   1, 1, 0, 1, GETUTCDATE()),
  ( 555, 'EQ_Warehouse', 'AccountingDetail'                          , 'accounting_detail_base', 'SourceCode'                                , 'source_code'                               , 'STRING'              ,   2, 1, 0, 1, GETUTCDATE()),
  ( 556, 'EQ_Warehouse', 'AccountingDetail'                          , 'accounting_detail_base', 'ReferenceData'                             , 'reference_data'                            , 'STRING'              ,   3, 1, 0, 1, GETUTCDATE()),
  ( 557, 'EQ_Warehouse', 'AccountingDetail'                          , 'accounting_detail_base', 'Approval'                                  , 'approval'                                  , 'STRING'              ,   4, 1, 0, 1, GETUTCDATE()),
  ( 558, 'EQ_Warehouse', 'AccountingDetail'                          , 'accounting_detail_base', 'Description'                               , 'description'                               , 'STRING'              ,   5, 1, 0, 1, GETUTCDATE()),
  ( 559, 'EQ_Warehouse', 'AccountingDetail'                          , 'accounting_detail_base', 'CompanyCode'                               , 'company_code'                              , 'STRING'              ,   6, 1, 0, 1, GETUTCDATE()),
  ( 560, 'EQ_Warehouse', 'AccountingDetail'                          , 'accounting_detail_base', 'DCIndicator'                               , 'dc_indicator'                              , 'STRING'              ,   7, 1, 0, 1, GETUTCDATE()),
  ( 561, 'EQ_Warehouse', 'AccountingDetail'                          , 'accounting_detail_base', 'EntryOperator'                             , 'entry_operator'                            , 'STRING'              ,   8, 1, 0, 1, GETUTCDATE()),
  ( 562, 'EQ_Warehouse', 'AccountingDetail'                          , 'accounting_detail_base', 'ApprovalOperator'                          , 'approval_operator'                         , 'STRING'              ,   9, 1, 0, 1, GETUTCDATE()),
  ( 563, 'EQ_Warehouse', 'AccountingDetail'                          , 'accounting_detail_base', 'APEXTIndicator'                            , 'apext_indicator'                           , 'STRING'              ,  10, 1, 0, 1, GETUTCDATE()),
  ( 564, 'EQ_Warehouse', 'AccountingDetail'                          , 'accounting_detail_base', 'SuspenseEXTIndicator'                      , 'suspense_ext_indicator'                    , 'STRING'              ,  11, 1, 0, 1, GETUTCDATE()),
  ( 565, 'EQ_Warehouse', 'AccountingDetail'                          , 'accounting_detail_base', 'EntryGenIndicator'                         , 'entry_gen_indicator'                       , 'STRING'              ,  12, 1, 0, 1, GETUTCDATE()),
  ( 566, 'EQ_Warehouse', 'AccountingDetail'                          , 'accounting_detail_base', 'Treaty'                                    , 'treaty'                                    , 'STRING'              ,  13, 1, 0, 1, GETUTCDATE()),
  ( 567, 'EQ_Warehouse', 'AccountingDetail'                          , 'accounting_detail_base', 'QualType'                                  , 'qual_type'                                 , 'STRING'              ,  14, 1, 0, 1, GETUTCDATE()),
  ( 568, 'EQ_Warehouse', 'AccountingDetail'                          , 'accounting_detail_base', 'SEG_EDITTrxPK'                             , 'seg_edit_trx_id'                           , 'BIGINT'              ,  15, 1, 0, 1, GETUTCDATE()),
  ( 569, 'EQ_Warehouse', 'AccountingDetail'                          , 'accounting_detail_base', 'SEG_PlacedAgentPK'                         , 'seg_placed_agent_id'                       , 'BIGINT'              ,  16, 1, 0, 1, GETUTCDATE()),
  ( 570, 'EQ_Warehouse', 'AccountingDetail'                          , 'accounting_detail_base', 'CostCenter'                                , 'cost_center'                               , 'STRING'              ,  17, 1, 0, 1, GETUTCDATE()),
  ( 571, 'EQ_Warehouse', 'AccountingDetail'                          , 'accounting_detail_base', 'SuspenseCode'                              , 'suspense_code'                             , 'STRING'              ,  18, 1, 0, 1, GETUTCDATE());

-- [43] AccountingAccount (16 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  ( 577, 'EQ_Warehouse', 'AccountingAccount'                         , 'accounting_account_base', 'AccountingAccountPK'                       , 'accounting_account_id'                     , 'INT'                 ,   1, 1, 1, 1, GETUTCDATE()),
  ( 578, 'EQ_Warehouse', 'AccountingAccount'                         , 'accounting_account_base', 'AccountNumber'                             , 'account_number'                            , 'STRING'              ,   2, 1, 0, 1, GETUTCDATE()),
  ( 579, 'EQ_Warehouse', 'AccountingAccount'                         , 'accounting_account_base', 'AccountSource'                             , 'account_source'                            , 'STRING'              ,   3, 1, 0, 1, GETUTCDATE()),
  ( 580, 'EQ_Warehouse', 'AccountingAccount'                         , 'accounting_account_base', 'ClassCode'                                 , 'class_code'                                , 'STRING'              ,   4, 1, 0, 1, GETUTCDATE()),
  ( 581, 'EQ_Warehouse', 'AccountingAccount'                         , 'accounting_account_base', 'CubeDescription'                           , 'cube_description'                          , 'STRING'              ,   5, 1, 0, 1, GETUTCDATE()),
  ( 582, 'EQ_Warehouse', 'AccountingAccount'                         , 'accounting_account_base', 'GroupIndicator'                            , 'group_indicator'                           , 'BOOLEAN'             ,   6, 1, 0, 1, GETUTCDATE()),
  ( 583, 'EQ_Warehouse', 'AccountingAccount'                         , 'accounting_account_base', 'CededIndicator'                            , 'ceded_indicator'                           , 'BOOLEAN'             ,   7, 1, 0, 1, GETUTCDATE()),
  ( 584, 'EQ_Warehouse', 'AccountingAccount'                         , 'accounting_account_base', 'Context'                                   , 'context'                                   , 'STRING'              ,   8, 1, 0, 1, GETUTCDATE()),
  ( 585, 'EQ_Warehouse', 'AccountingAccount'                         , 'accounting_account_base', 'ActuarialGrouping'                         , 'actuarial_grouping'                        , 'STRING'              ,   9, 1, 0, 1, GETUTCDATE()),
  ( 586, 'EQ_Warehouse', 'AccountingAccount'                         , 'accounting_account_base', 'AccountDescription'                        , 'account_description'                       , 'STRING'              ,  10, 1, 0, 1, GETUTCDATE()),
  ( 587, 'EQ_Warehouse', 'AccountingAccount'                         , 'accounting_account_base', 'AccountingReportingGroupKey'               , 'accounting_reporting_group_key'            , 'INT'                 ,  11, 1, 0, 1, GETUTCDATE());

-- [44] Accounting (24 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  ( 593, 'EQ_Warehouse', 'Accounting'                                , 'accounting_base', 'AccountingPK'                              , 'accounting_id'                             , 'BIGINT'              ,   1, 1, 1, 1, GETUTCDATE()),
  ( 594, 'EQ_Warehouse', 'Accounting'                                , 'accounting_base', 'SourceSystem'                              , 'source_system_code'                        , 'STRING'              ,   2, 1, 0, 1, GETUTCDATE()),
  ( 595, 'EQ_Warehouse', 'Accounting'                                , 'accounting_base', 'TranID'                                    , 'transaction_id'                            , 'INT'                 ,   3, 1, 0, 1, GETUTCDATE()),
  ( 596, 'EQ_Warehouse', 'Accounting'                                , 'accounting_base', 'TranDetailID'                              , 'transaction_detail_id'                     , 'BIGINT'              ,   4, 1, 0, 1, GETUTCDATE()),
  ( 597, 'EQ_Warehouse', 'Accounting'                                , 'accounting_base', 'StatusCode'                                , 'status_code'                               , 'STRING'              ,   5, 1, 0, 1, GETUTCDATE()),
  ( 598, 'EQ_Warehouse', 'Accounting'                                , 'accounting_base', 'StatusIndicator'                           , 'status_indicator'                          , 'STRING'              ,   6, 1, 0, 1, GETUTCDATE()),
  ( 599, 'EQ_Warehouse', 'Accounting'                                , 'accounting_base', 'BasisCode'                                 , 'basis_code'                                , 'STRING'              ,   7, 1, 0, 1, GETUTCDATE()),
  ( 600, 'EQ_Warehouse', 'Accounting'                                , 'accounting_base', 'State'                                     , 'state_code'                                , 'STRING'              ,   8, 1, 0, 1, GETUTCDATE()),
  ( 601, 'EQ_Warehouse', 'Accounting'                                , 'accounting_base', 'EffectiveDateFK'                           , 'effective_date_id'                         , 'INT'                 ,   9, 1, 0, 1, GETUTCDATE()),
  ( 602, 'EQ_Warehouse', 'Accounting'                                , 'accounting_base', 'PeriodDateFK'                              , 'period_date_id'                            , 'INT'                 ,  10, 1, 0, 1, GETUTCDATE()),
  ( 603, 'EQ_Warehouse', 'Accounting'                                , 'accounting_base', 'AccountingAccountFK'                       , 'accounting_account_id'                     , 'INT'                 ,  11, 1, 0, 1, GETUTCDATE()),
  ( 604, 'EQ_Warehouse', 'Accounting'                                , 'accounting_base', 'EntryDate'                                 , 'entry_date'                                , 'DATE'                ,  12, 1, 0, 1, GETUTCDATE()),
  ( 605, 'EQ_Warehouse', 'Accounting'                                , 'accounting_base', 'EntryUpdateDate'                           , 'entry_update_date'                         , 'DATE'                ,  13, 1, 0, 1, GETUTCDATE()),
  ( 606, 'EQ_Warehouse', 'Accounting'                                , 'accounting_base', 'ContractFK'                                , 'contract_id'                               , 'INT'                 ,  14, 1, 0, 1, GETUTCDATE()),
  ( 607, 'EQ_Warehouse', 'Accounting'                                , 'accounting_base', 'InvestmentFK'                              , 'investment_id'                             , 'INT'                 ,  15, 1, 0, 1, GETUTCDATE()),
  ( 608, 'EQ_Warehouse', 'Accounting'                                , 'accounting_base', 'ProductFK'                                 , 'product_id'                                , 'INT'                 ,  16, 1, 0, 1, GETUTCDATE()),
  ( 609, 'EQ_Warehouse', 'Accounting'                                , 'accounting_base', 'AgentFK'                                   , 'agent_id'                                  , 'INT'                 ,  17, 1, 0, 1, GETUTCDATE()),
  ( 610, 'EQ_Warehouse', 'Accounting'                                , 'accounting_base', 'Amount'                                    , 'amount'                                    , 'DECIMAL(18,4)'       ,  18, 1, 0, 1, GETUTCDATE()),
  ( 611, 'EQ_Warehouse', 'Accounting'                                , 'accounting_base', 'Block'                                     , 'block_code'                                , 'STRING'              ,  19, 1, 0, 1, GETUTCDATE());

-- [45] Surrender (18 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  ( 617, 'EQ_Warehouse', 'Surrender'                                 , 'surrender_base', 'SurrenderPK'                               , 'surrender_id'                              , 'INT'                 ,   1, 1, 1, 1, GETUTCDATE()),
  ( 618, 'EQ_Warehouse', 'Surrender'                                 , 'surrender_base', 'ProductFK'                                 , 'product_id'                                , 'INT'                 ,   2, 1, 0, 1, GETUTCDATE()),
  ( 619, 'EQ_Warehouse', 'Surrender'                                 , 'surrender_base', 'FundNumber'                                , 'fund_number'                               , 'STRING'              ,   3, 1, 0, 1, GETUTCDATE()),
  ( 620, 'EQ_Warehouse', 'Surrender'                                 , 'surrender_base', 'State'                                     , 'state_code'                                , 'STRING'              ,   4, 1, 0, 1, GETUTCDATE()),
  ( 621, 'EQ_Warehouse', 'Surrender'                                 , 'surrender_base', 'Gender'                                    , 'gender'                                    , 'STRING'              ,   5, 1, 0, 1, GETUTCDATE()),
  ( 622, 'EQ_Warehouse', 'Surrender'                                 , 'surrender_base', 'Class'                                     , 'risk_class'                                , 'STRING'              ,   6, 1, 0, 1, GETUTCDATE()),
  ( 623, 'EQ_Warehouse', 'Surrender'                                 , 'surrender_base', 'Age'                                       , 'customer_age'                              , 'INT'                 ,   7, 1, 0, 1, GETUTCDATE()),
  ( 624, 'EQ_Warehouse', 'Surrender'                                 , 'surrender_base', 'ContractYear'                              , 'policy_year'                               , 'INT'                 ,   8, 1, 0, 1, GETUTCDATE()),
  ( 625, 'EQ_Warehouse', 'Surrender'                                 , 'surrender_base', 'SurrenderLength'                           , 'penalty_duration_years'                    , 'INT'                 ,   9, 1, 0, 1, GETUTCDATE()),
  ( 626, 'EQ_Warehouse', 'Surrender'                                 , 'surrender_base', 'Rate'                                      , 'penalty_percentage'                        , 'DECIMAL(18,4)'       ,  10, 1, 0, 1, GETUTCDATE()),
  ( 627, 'EQ_Warehouse', 'Surrender'                                 , 'surrender_base', 'RateAppliedTo'                             , 'rate_calculation_basis'                    , 'STRING'              ,  11, 1, 0, 1, GETUTCDATE()),
  ( 628, 'EQ_Warehouse', 'Surrender'                                 , 'surrender_base', 'EffectiveDate'                             , 'rule_start_date'                           , 'TIMESTAMP'           ,  12, 1, 0, 1, GETUTCDATE()),
  ( 629, 'EQ_Warehouse', 'Surrender'                                 , 'surrender_base', 'EndDate'                                   , 'rule_end_date'                             , 'TIMESTAMP'           ,  13, 1, 0, 1, GETUTCDATE());

-- [46] InvestmentDetail (14 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  ( 635, 'EQ_Warehouse', 'InvestmentDetail'                          , 'investment_detail_base', 'InvestmentDetailPK'                        , 'investment_detail_id'                      , 'INT'                 ,   1, 1, 1, 1, GETUTCDATE()),
  ( 636, 'EQ_Warehouse', 'InvestmentDetail'                          , 'investment_detail_base', 'Name'                                      , 'investment_detail_name'                    , 'STRING'              ,   2, 1, 0, 1, GETUTCDATE()),
  ( 637, 'EQ_Warehouse', 'InvestmentDetail'                          , 'investment_detail_base', 'FundType'                                  , 'fund_type'                                 , 'STRING'              ,   3, 1, 0, 1, GETUTCDATE()),
  ( 638, 'EQ_Warehouse', 'InvestmentDetail'                          , 'investment_detail_base', 'GroupingName'                              , 'grouping_name'                             , 'STRING'              ,   4, 1, 0, 1, GETUTCDATE()),
  ( 639, 'EQ_Warehouse', 'InvestmentDetail'                          , 'investment_detail_base', 'MarketingName'                             , 'marketing_name'                            , 'STRING'              ,   5, 1, 0, 1, GETUTCDATE()),
  ( 640, 'EQ_Warehouse', 'InvestmentDetail'                          , 'investment_detail_base', 'AltMarketingName'                          , 'alt_marketing_name'                        , 'STRING'              ,   6, 1, 0, 1, GETUTCDATE()),
  ( 641, 'EQ_Warehouse', 'InvestmentDetail'                          , 'investment_detail_base', 'SortOrder'                                 , 'sort_order'                                , 'STRING'              ,   7, 1, 0, 1, GETUTCDATE()),
  ( 642, 'EQ_Warehouse', 'InvestmentDetail'                          , 'investment_detail_base', 'IsCap'                                     , 'is_cap_indicator'                          , 'BOOLEAN'             ,   8, 1, 0, 1, GETUTCDATE()),
  ( 643, 'EQ_Warehouse', 'InvestmentDetail'                          , 'investment_detail_base', 'FundStartDate'                             , 'fund_start_date'                           , 'TIMESTAMP'           ,   9, 1, 0, 1, GETUTCDATE());

-- [47] Investment (13 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  ( 649, 'EQ_Warehouse', 'Investment'                                , 'investment_base', 'InvestmentPK'                              , 'investment_id'                             , 'INT'                 ,   1, 1, 1, 1, GETUTCDATE()),
  ( 650, 'EQ_Warehouse', 'Investment'                                , 'investment_base', 'InvestmentKey'                             , 'investment_key'                            , 'INT'                 ,   2, 1, 0, 1, GETUTCDATE()),
  ( 651, 'EQ_Warehouse', 'Investment'                                , 'investment_base', 'InvestmentName'                            , 'investment_name'                           , 'STRING'              ,   3, 1, 0, 1, GETUTCDATE()),
  ( 652, 'EQ_Warehouse', 'Investment'                                , 'investment_base', 'InvestmentDescription'                     , 'investment_description'                    , 'STRING'              ,   4, 1, 0, 1, GETUTCDATE()),
  ( 653, 'EQ_Warehouse', 'Investment'                                , 'investment_base', 'EffectiveDate'                             , 'effective_date'                            , 'TIMESTAMP'           ,   5, 1, 0, 1, GETUTCDATE()),
  ( 654, 'EQ_Warehouse', 'Investment'                                , 'investment_base', 'Active'                                    , 'active_indicator'                          , 'BOOLEAN'             ,   6, 1, 0, 1, GETUTCDATE()),
  ( 655, 'EQ_Warehouse', 'Investment'                                , 'investment_base', 'StartDate'                                 , 'start_timestamp'                           , 'TIMESTAMP'           ,   7, 1, 0, 1, GETUTCDATE()),
  ( 656, 'EQ_Warehouse', 'Investment'                                , 'investment_base', 'EndDate'                                   , 'end_timestamp'                             , 'TIMESTAMP'           ,   8, 1, 0, 1, GETUTCDATE());

-- [48] Activity (27 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  ( 662, 'EQ_Warehouse', 'Activity'                                  , 'activity_base', 'ActivityPK'                                , 'activity_id'                               , 'BIGINT'              ,   1, 1, 1, 1, GETUTCDATE()),
  ( 663, 'EQ_Warehouse', 'Activity'                                  , 'activity_base', 'ActivityTypeFK'                            , 'activity_type_id'                          , 'INT'                 ,   2, 1, 0, 1, GETUTCDATE()),
  ( 664, 'EQ_Warehouse', 'Activity'                                  , 'activity_base', 'CompanyFK'                                 , 'company_id'                                , 'INT'                 ,   3, 1, 0, 1, GETUTCDATE()),
  ( 665, 'EQ_Warehouse', 'Activity'                                  , 'activity_base', 'ContractFK'                                , 'contract_id'                               , 'INT'                 ,   4, 1, 0, 1, GETUTCDATE()),
  ( 666, 'EQ_Warehouse', 'Activity'                                  , 'activity_base', 'ProductFK'                                 , 'product_id'                                , 'INT'                 ,   5, 1, 0, 1, GETUTCDATE()),
  ( 667, 'EQ_Warehouse', 'Activity'                                  , 'activity_base', 'InvestmentFK'                              , 'investment_id'                             , 'INT'                 ,   6, 1, 0, 1, GETUTCDATE()),
  ( 668, 'EQ_Warehouse', 'Activity'                                  , 'activity_base', 'AccountingFK'                              , 'accounting_id'                             , 'INT'                 ,   7, 1, 0, 1, GETUTCDATE()),
  ( 669, 'EQ_Warehouse', 'Activity'                                  , 'activity_base', 'AccountingAccountFK'                       , 'accounting_account_id'                     , 'INT'                 ,   8, 1, 0, 1, GETUTCDATE()),
  ( 670, 'EQ_Warehouse', 'Activity'                                  , 'activity_base', 'CAPRepaymentFK'                            , 'cap_repayment_id'                          , 'INT'                 ,   9, 1, 0, 1, GETUTCDATE()),
  ( 671, 'EQ_Warehouse', 'Activity'                                  , 'activity_base', 'HierarchySetKey'                           , 'hierarchy_set_id'                          , 'INT'                 ,  10, 1, 0, 1, GETUTCDATE()),
  ( 672, 'EQ_Warehouse', 'Activity'                                  , 'activity_base', 'AgentFK'                                   , 'agent_id'                                  , 'INT'                 ,  11, 1, 0, 1, GETUTCDATE()),
  ( 673, 'EQ_Warehouse', 'Activity'                                  , 'activity_base', 'ActivityClientFK'                          , 'activity_client_id'                        , 'INT'                 ,  12, 1, 0, 1, GETUTCDATE()),
  ( 674, 'EQ_Warehouse', 'Activity'                                  , 'activity_base', 'ActivityPayeeFK'                           , 'activity_payee_id'                         , 'INT'                 ,  13, 1, 0, 1, GETUTCDATE()),
  ( 675, 'EQ_Warehouse', 'Activity'                                  , 'activity_base', 'EffectiveDateFK'                           , 'effective_date_id'                         , 'INT'                 ,  14, 1, 0, 1, GETUTCDATE()),
  ( 676, 'EQ_Warehouse', 'Activity'                                  , 'activity_base', 'ProcessDateFK'                             , 'process_date_id'                           , 'INT'                 ,  15, 1, 0, 1, GETUTCDATE()),
  ( 677, 'EQ_Warehouse', 'Activity'                                  , 'activity_base', 'ReleaseDate'                               , 'release_date'                              , 'TIMESTAMP'           ,  16, 1, 0, 1, GETUTCDATE()),
  ( 678, 'EQ_Warehouse', 'Activity'                                  , 'activity_base', 'PeriodDate'                                , 'period_date'                               , 'TIMESTAMP'           ,  17, 1, 0, 1, GETUTCDATE()),
  ( 679, 'EQ_Warehouse', 'Activity'                                  , 'activity_base', 'GrossAmount'                               , 'gross_amount'                              , 'DECIMAL(18,4)'       ,  18, 1, 0, 1, GETUTCDATE()),
  ( 680, 'EQ_Warehouse', 'Activity'                                  , 'activity_base', 'NetAmount'                                 , 'net_amount'                                , 'DECIMAL(18,4)'       ,  19, 1, 0, 1, GETUTCDATE()),
  ( 681, 'EQ_Warehouse', 'Activity'                                  , 'activity_base', 'CheckAmount'                               , 'check_amount'                              , 'DECIMAL(18,4)'       ,  20, 1, 0, 1, GETUTCDATE()),
  ( 682, 'EQ_Warehouse', 'Activity'                                  , 'activity_base', 'DistributionType'                          , 'distribution_type'                         , 'STRING'              ,  21, 1, 0, 1, GETUTCDATE()),
  ( 683, 'EQ_Warehouse', 'Activity'                                  , 'activity_base', 'TextValue'                                 , 'activity_notes'                            , 'STRING'              ,  22, 1, 0, 1, GETUTCDATE());

-- [49] AccountValue (16 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  ( 689, 'EQ_Warehouse', 'AccountValue'                              , 'account_value_base', 'AccountValuePK'                            , 'account_value_id'                          , 'INT'                 ,   1, 1, 1, 1, GETUTCDATE()),
  ( 690, 'EQ_Warehouse', 'AccountValue'                              , 'account_value_base', 'ContractFK'                                , 'contract_id'                               , 'INT'                 ,   2, 1, 0, 1, GETUTCDATE()),
  ( 691, 'EQ_Warehouse', 'AccountValue'                              , 'account_value_base', 'InvestmentFK'                              , 'investment_id'                             , 'INT'                 ,   3, 1, 0, 1, GETUTCDATE()),
  ( 692, 'EQ_Warehouse', 'AccountValue'                              , 'account_value_base', 'Value'                                     , 'account_value_amount'                      , 'DECIMAL(18,4)'       ,   4, 1, 0, 1, GETUTCDATE()),
  ( 693, 'EQ_Warehouse', 'AccountValue'                              , 'account_value_base', 'CurrentInterestRate'                       , 'current_interest_rate'                     , 'DECIMAL(18,4)'       ,   5, 1, 0, 1, GETUTCDATE()),
  ( 694, 'EQ_Warehouse', 'AccountValue'                              , 'account_value_base', 'AllocationPercent'                         , 'allocation_percentage'                     , 'DECIMAL(18,4)'       ,   6, 1, 0, 1, GETUTCDATE()),
  ( 695, 'EQ_Warehouse', 'AccountValue'                              , 'account_value_base', 'DepositDate'                               , 'deposit_date'                              , 'TIMESTAMP'           ,   7, 1, 0, 1, GETUTCDATE()),
  ( 696, 'EQ_Warehouse', 'AccountValue'                              , 'account_value_base', 'RenewalDate'                               , 'renewal_date'                              , 'TIMESTAMP'           ,   8, 1, 0, 1, GETUTCDATE()),
  ( 697, 'EQ_Warehouse', 'AccountValue'                              , 'account_value_base', 'ValuationDate'                             , 'valuation_date'                            , 'TIMESTAMP'           ,   9, 1, 0, 1, GETUTCDATE()),
  ( 698, 'EQ_Warehouse', 'AccountValue'                              , 'account_value_base', 'StartDate'                                 , 'start_timestamp'                           , 'TIMESTAMP'           ,  10, 1, 0, 1, GETUTCDATE()),
  ( 699, 'EQ_Warehouse', 'AccountValue'                              , 'account_value_base', 'EndDate'                                   , 'end_timestamp'                             , 'TIMESTAMP'           ,  11, 1, 0, 1, GETUTCDATE());

-- [50] Product (14 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  ( 705, 'EQ_Warehouse', 'Product'                                   , 'product_base', 'ProductPK'                                 , 'product_id'                                , 'INT'                 ,   1, 1, 1, 1, GETUTCDATE()),
  ( 706, 'EQ_Warehouse', 'Product'                                   , 'product_base', 'ProductName'                               , 'product_name'                              , 'STRING'              ,   2, 1, 0, 1, GETUTCDATE()),
  ( 707, 'EQ_Warehouse', 'Product'                                   , 'product_base', 'MarketingName'                             , 'marketing_name'                            , 'STRING'              ,   3, 1, 0, 1, GETUTCDATE()),
  ( 708, 'EQ_Warehouse', 'Product'                                   , 'product_base', 'AltMarketingName'                          , 'alt_marketing_name'                        , 'STRING'              ,   4, 1, 0, 1, GETUTCDATE()),
  ( 709, 'EQ_Warehouse', 'Product'                                   , 'product_base', 'GroupName'                                 , 'group_name'                                , 'STRING'              ,   5, 1, 0, 1, GETUTCDATE()),
  ( 710, 'EQ_Warehouse', 'Product'                                   , 'product_base', 'AgentCommStatementAbbr'                    , 'agent_comm_statement_abbr'                 , 'STRING'              ,   6, 1, 0, 1, GETUTCDATE()),
  ( 711, 'EQ_Warehouse', 'Product'                                   , 'product_base', 'GLAbbr'                                    , 'gl_abbr'                                   , 'STRING'              ,   7, 1, 0, 1, GETUTCDATE()),
  ( 712, 'EQ_Warehouse', 'Product'                                   , 'product_base', 'GLLOB'                                     , 'gl_line_of_business'                       , 'STRING'              ,   8, 1, 0, 1, GETUTCDATE()),
  ( 713, 'EQ_Warehouse', 'Product'                                   , 'product_base', 'Context'                                   , 'product_context'                           , 'STRING'              ,   9, 1, 0, 1, GETUTCDATE()),
  ( 714, 'EQ_Warehouse', 'Product'                                   , 'product_base', 'ProductType'                               , 'product_type'                              , 'STRING'              ,  10, 1, 0, 1, GETUTCDATE()),
  ( 715, 'EQ_Warehouse', 'Product'                                   , 'product_base', 'CUSIPNumber'                               , 'cusip_number'                              , 'STRING'              ,  11, 1, 0, 1, GETUTCDATE()),
  ( 716, 'EQ_Warehouse', 'Product'                                   , 'product_base', 'SortOrder'                                 , 'sort_order'                                , 'INT'                 ,  12, 1, 0, 1, GETUTCDATE()),
  ( 717, 'EQ_Warehouse', 'Product'                                   , 'product_base', 'EffectiveDate'                             , 'effective_date'                            , 'TIMESTAMP'           ,  13, 1, 0, 1, GETUTCDATE()),
  ( 718, 'EQ_Warehouse', 'Product'                                   , 'product_base', 'Status'                                    , 'status'                                    , 'STRING'              ,  14, 1, 0, 1, GETUTCDATE());

-- [51] Agent (18 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  ( 719, 'EQ_Warehouse', 'Agent'                                     , 'agent_base', 'AgentPK'                                   , 'agent_id'                                  , 'INT'                 ,   1, 1, 1, 1, GETUTCDATE()),
  ( 720, 'EQ_Warehouse', 'Agent'                                     , 'agent_base', 'SourceKey'                                 , 'source_key'                                , 'BIGINT'              ,   2, 1, 0, 1, GETUTCDATE()),
  ( 721, 'EQ_Warehouse', 'Agent'                                     , 'agent_base', 'ClientFK'                                  , 'client_id'                                 , 'INT'                 ,   3, 1, 0, 1, GETUTCDATE()),
  ( 722, 'EQ_Warehouse', 'Agent'                                     , 'agent_base', 'DisplayName'                               , 'display_name'                              , 'STRING'              ,   4, 1, 0, 1, GETUTCDATE()),
  ( 723, 'EQ_Warehouse', 'Agent'                                     , 'agent_base', 'AgentNumber'                               , 'agent_number'                              , 'STRING'              ,   5, 1, 0, 1, GETUTCDATE()),
  ( 724, 'EQ_Warehouse', 'Agent'                                     , 'agent_base', 'NoteGroupKey'                              , 'note_group_key'                            , 'INT'                 ,   6, 1, 0, 1, GETUTCDATE()),
  ( 725, 'EQ_Warehouse', 'Agent'                                     , 'agent_base', 'RequirementGroupKey'                       , 'requirement_group_key'                     , 'INT'                 ,   7, 1, 0, 1, GETUTCDATE()),
  ( 726, 'EQ_Warehouse', 'Agent'                                     , 'agent_base', 'AgentLicenseGroupKey'                      , 'agent_license_group_key'                   , 'INT'                 ,   8, 1, 0, 1, GETUTCDATE()),
  ( 727, 'EQ_Warehouse', 'Agent'                                     , 'agent_base', 'AgentPrincipalGroupKey'                    , 'agent_principal_group_key'                 , 'INT'                 ,   9, 1, 0, 1, GETUTCDATE()),
  ( 728, 'EQ_Warehouse', 'Agent'                                     , 'agent_base', 'AgentSummaryGroupKey'                      , 'agent_summary_group_key'                   , 'INT'                 ,  10, 1, 0, 1, GETUTCDATE()),
  ( 729, 'EQ_Warehouse', 'Agent'                                     , 'agent_base', 'NPN'                                       , 'national_producer_number'                  , 'STRING'              ,  11, 1, 0, 1, GETUTCDATE()),
  ( 730, 'EQ_Warehouse', 'Agent'                                     , 'agent_base', 'NASD'                                      , 'nasd_finra_number'                         , 'STRING'              ,  12, 1, 0, 1, GETUTCDATE()),
  ( 731, 'EQ_Warehouse', 'Agent'                                     , 'agent_base', 'AgentType'                                 , 'agent_type'                                , 'STRING'              ,  13, 1, 0, 1, GETUTCDATE()),
  ( 732, 'EQ_Warehouse', 'Agent'                                     , 'agent_base', 'HireDate'                                  , 'hire_date'                                 , 'TIMESTAMP'           ,  14, 1, 0, 1, GETUTCDATE()),
  ( 733, 'EQ_Warehouse', 'Agent'                                     , 'agent_base', 'TerminationDate'                           , 'termination_date'                          , 'TIMESTAMP'           ,  15, 1, 0, 1, GETUTCDATE()),
  ( 734, 'EQ_Warehouse', 'Agent'                                     , 'agent_base', 'Status'                                    , 'status'                                    , 'STRING'              ,  16, 1, 0, 1, GETUTCDATE()),
  ( 735, 'EQ_Warehouse', 'Agent'                                     , 'agent_base', 'StartDate'                                 , 'start_timestamp'                           , 'TIMESTAMP'           ,  17, 1, 0, 1, GETUTCDATE()),
  ( 736, 'EQ_Warehouse', 'Agent'                                     , 'agent_base', 'EndDate'                                   , 'end_timestamp'                             , 'TIMESTAMP'           ,  18, 1, 0, 1, GETUTCDATE());

-- [52] Client (38 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  ( 739, 'EQ_Warehouse', 'Client'                                    , 'client_base', 'ClientPK'                                  , 'client_id'                                 , 'INT'                 ,   1, 1, 1, 1, GETUTCDATE()),
  ( 740, 'EQ_Warehouse', 'Client'                                    , 'client_base', 'SourceKey'                                 , 'source_key'                                , 'BIGINT'              ,   2, 1, 0, 1, GETUTCDATE()),
  ( 741, 'EQ_Warehouse', 'Client'                                    , 'client_base', 'TaxIDHash'                                 , 'tax_id_hash'                               , 'BINARY'              ,   3, 1, 0, 1, GETUTCDATE()),
  ( 742, 'EQ_Warehouse', 'Client'                                    , 'client_base', 'Last4Hash'                                 , 'last_4_hash'                               , 'BINARY'              ,   4, 1, 0, 1, GETUTCDATE()),
  ( 743, 'EQ_Warehouse', 'Client'                                    , 'client_base', 'Last4Token'                                , 'last_4_token'                              , 'STRING'              ,   5, 1, 0, 1, GETUTCDATE()),
  ( 744, 'EQ_Warehouse', 'Client'                                    , 'client_base', 'DisplayName'                               , 'display_name'                              , 'STRING'              ,   6, 1, 0, 1, GETUTCDATE()),
  ( 745, 'EQ_Warehouse', 'Client'                                    , 'client_base', 'FirstName'                                 , 'first_name'                                , 'STRING'              ,   7, 1, 0, 1, GETUTCDATE()),
  ( 746, 'EQ_Warehouse', 'Client'                                    , 'client_base', 'MiddleName'                                , 'middle_name'                               , 'STRING'              ,   8, 1, 0, 1, GETUTCDATE()),
  ( 747, 'EQ_Warehouse', 'Client'                                    , 'client_base', 'LastName'                                  , 'last_name'                                 , 'STRING'              ,   9, 1, 0, 1, GETUTCDATE()),
  ( 748, 'EQ_Warehouse', 'Client'                                    , 'client_base', 'Prefix'                                    , 'prefix'                                    , 'STRING'              ,  10, 1, 0, 1, GETUTCDATE()),
  ( 749, 'EQ_Warehouse', 'Client'                                    , 'client_base', 'Suffix'                                    , 'suffix'                                    , 'STRING'              ,  11, 1, 0, 1, GETUTCDATE()),
  ( 750, 'EQ_Warehouse', 'Client'                                    , 'client_base', 'CorporateName'                             , 'corporate_name'                            , 'STRING'              ,  12, 1, 0, 1, GETUTCDATE()),
  ( 751, 'EQ_Warehouse', 'Client'                                    , 'client_base', 'Gender'                                    , 'gender'                                    , 'STRING'              ,  13, 1, 0, 1, GETUTCDATE()),
  ( 752, 'EQ_Warehouse', 'Client'                                    , 'client_base', 'Phone'                                     , 'phone_number'                              , 'STRING'              ,  14, 1, 0, 1, GETUTCDATE()),
  ( 753, 'EQ_Warehouse', 'Client'                                    , 'client_base', 'Email'                                     , 'email_address'                             , 'STRING'              ,  15, 1, 0, 1, GETUTCDATE()),
  ( 754, 'EQ_Warehouse', 'Client'                                    , 'client_base', 'Fax'                                       , 'fax_number'                                , 'STRING'              ,  16, 1, 0, 1, GETUTCDATE()),
  ( 755, 'EQ_Warehouse', 'Client'                                    , 'client_base', 'BirthDate'                                 , 'birth_date'                                , 'TIMESTAMP'           ,  17, 1, 0, 1, GETUTCDATE()),
  ( 756, 'EQ_Warehouse', 'Client'                                    , 'client_base', 'DateOfDeath'                               , 'date_of_death'                             , 'TIMESTAMP'           ,  18, 1, 0, 1, GETUTCDATE()),
  ( 757, 'EQ_Warehouse', 'Client'                                    , 'client_base', 'Status'                                    , 'status'                                    , 'STRING'              ,  19, 1, 0, 1, GETUTCDATE()),
  ( 758, 'EQ_Warehouse', 'Client'                                    , 'client_base', 'PayPreference'                             , 'pay_preference'                            , 'STRING'              ,  20, 1, 0, 1, GETUTCDATE()),
  ( 759, 'EQ_Warehouse', 'Client'                                    , 'client_base', 'ExternalAccountGroupKey'                   , 'external_account_group_key'                , 'INT'                 ,  21, 1, 0, 1, GETUTCDATE()),
  ( 760, 'EQ_Warehouse', 'Client'                                    , 'client_base', 'AddressLine1'                              , 'address_line_1'                            , 'STRING'              ,  22, 1, 0, 1, GETUTCDATE()),
  ( 761, 'EQ_Warehouse', 'Client'                                    , 'client_base', 'AddressLine2'                              , 'address_line_2'                            , 'STRING'              ,  23, 1, 0, 1, GETUTCDATE()),
  ( 762, 'EQ_Warehouse', 'Client'                                    , 'client_base', 'AddressLine3'                              , 'address_line_3'                            , 'STRING'              ,  24, 1, 0, 1, GETUTCDATE()),
  ( 763, 'EQ_Warehouse', 'Client'                                    , 'client_base', 'AddressLine4'                              , 'address_line_4'                            , 'STRING'              ,  25, 1, 0, 1, GETUTCDATE()),
  ( 764, 'EQ_Warehouse', 'Client'                                    , 'client_base', 'City'                                      , 'city'                                      , 'STRING'              ,  26, 1, 0, 1, GETUTCDATE()),
  ( 765, 'EQ_Warehouse', 'Client'                                    , 'client_base', 'State'                                     , 'state_code'                                , 'STRING'              ,  27, 1, 0, 1, GETUTCDATE()),
  ( 766, 'EQ_Warehouse', 'Client'                                    , 'client_base', 'ZipCode'                                   , 'zip_code'                                  , 'STRING'              ,  28, 1, 0, 1, GETUTCDATE()),
  ( 767, 'EQ_Warehouse', 'Client'                                    , 'client_base', 'County'                                    , 'county'                                    , 'STRING'              ,  29, 1, 0, 1, GETUTCDATE()),
  ( 768, 'EQ_Warehouse', 'Client'                                    , 'client_base', 'Country'                                   , 'country_code'                              , 'STRING'              ,  30, 1, 0, 1, GETUTCDATE()),
  ( 769, 'EQ_Warehouse', 'Client'                                    , 'client_base', 'AdditionalInfoGroupKey'                    , 'additional_info_group_key'                 , 'INT'                 ,  31, 1, 0, 1, GETUTCDATE()),
  ( 770, 'EQ_Warehouse', 'Client'                                    , 'client_base', 'Verification'                              , 'verification_details'                      , 'STRING'              ,  32, 1, 0, 1, GETUTCDATE()),
  ( 771, 'EQ_Warehouse', 'Client'                                    , 'client_base', 'NoNewBusinessInd'                          , 'is_no_new_business'                        , 'BOOLEAN'             ,  33, 1, 0, 1, GETUTCDATE()),
  ( 772, 'EQ_Warehouse', 'Client'                                    , 'client_base', 'EffectiveDate'                             , 'effective_date'                            , 'TIMESTAMP'           ,  34, 1, 0, 1, GETUTCDATE()),
  ( 773, 'EQ_Warehouse', 'Client'                                    , 'client_base', 'StartDate'                                 , 'start_timestamp'                           , 'TIMESTAMP'           ,  35, 1, 0, 1, GETUTCDATE()),
  ( 774, 'EQ_Warehouse', 'Client'                                    , 'client_base', 'EndDate'                                   , 'end_timestamp'                             , 'TIMESTAMP'           ,  36, 1, 0, 1, GETUTCDATE());

-- [53] Contract (51 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  ( 778, 'EQ_Warehouse', 'Contract'                                  , 'contract_base', 'ContractPK'                                , 'contract_id'                               , 'INT'                 ,   1, 1, 1, 1, GETUTCDATE()),
  ( 779, 'EQ_Warehouse', 'Contract'                                  , 'contract_base', 'ContractNumber'                            , 'contract_number'                           , 'STRING'              ,   2, 1, 0, 1, GETUTCDATE()),
  ( 780, 'EQ_Warehouse', 'Contract'                                  , 'contract_base', 'HierarchyGroupKey'                         , 'hierarchy_group_key'                       , 'INT'                 ,   3, 1, 0, 1, GETUTCDATE()),
  ( 781, 'EQ_Warehouse', 'Contract'                                  , 'contract_base', 'ContractValueGroupKey'                     , 'contract_value_group_key'                  , 'INT'                 ,   4, 1, 0, 1, GETUTCDATE()),
  ( 782, 'EQ_Warehouse', 'Contract'                                  , 'contract_base', 'SurrenderFK'                               , 'surrender_id'                              , 'INT'                 ,   5, 1, 0, 1, GETUTCDATE()),
  ( 783, 'EQ_Warehouse', 'Contract'                                  , 'contract_base', 'ProductFK'                                 , 'product_id'                                , 'INT'                 ,   6, 1, 0, 1, GETUTCDATE()),
  ( 784, 'EQ_Warehouse', 'Contract'                                  , 'contract_base', 'OwnerFK'                                   , 'owner_client_id'                           , 'INT'                 ,   7, 1, 0, 1, GETUTCDATE()),
  ( 785, 'EQ_Warehouse', 'Contract'                                  , 'contract_base', 'Owner2FK'                                  , 'owner_2_client_id'                         , 'INT'                 ,   8, 1, 0, 1, GETUTCDATE()),
  ( 786, 'EQ_Warehouse', 'Contract'                                  , 'contract_base', 'AnnuitantInsuredFK'                        , 'annuitant_insured_client_id'               , 'INT'                 ,   9, 1, 0, 1, GETUTCDATE()),
  ( 787, 'EQ_Warehouse', 'Contract'                                  , 'contract_base', 'AnnuitantInsured2FK'                       , 'annuitant_insured_2_client_id'             , 'INT'                 ,  10, 1, 0, 1, GETUTCDATE()),
  ( 788, 'EQ_Warehouse', 'Contract'                                  , 'contract_base', 'AdditionalClientGroupKey'                  , 'additional_client_group_key'               , 'INT'                 ,  11, 1, 0, 1, GETUTCDATE()),
  ( 789, 'EQ_Warehouse', 'Contract'                                  , 'contract_base', 'ContractDepositGroupKey'                   , 'contract_deposit_group_key'                , 'INT'                 ,  12, 1, 0, 1, GETUTCDATE()),
  ( 790, 'EQ_Warehouse', 'Contract'                                  , 'contract_base', 'RiderGroupKey'                             , 'rider_group_key'                           , 'INT'                 ,  13, 1, 0, 1, GETUTCDATE()),
  ( 791, 'EQ_Warehouse', 'Contract'                                  , 'contract_base', 'NoteGroupKey'                              , 'note_group_key'                            , 'INT'                 ,  14, 1, 0, 1, GETUTCDATE()),
  ( 792, 'EQ_Warehouse', 'Contract'                                  , 'contract_base', 'RequirementGroupKey'                       , 'requirement_group_key'                     , 'INT'                 ,  15, 1, 0, 1, GETUTCDATE()),
  (2001, 'EQ_Warehouse', 'Contract'                                  , 'contract_base', 'ReinsuranceGroupKey'                       , 'reinsurance_group_key'                     , 'INT'                 ,  16, 1, 0, 1, GETUTCDATE()),
  (2002, 'EQ_Warehouse', 'Contract'                                  , 'contract_base', 'RecurringPaymentGroupKey'                  , 'recurring_payment_group_key'               , 'INT'                 ,  17, 1, 0, 1, GETUTCDATE()),
  (2003, 'EQ_Warehouse', 'Contract'                                  , 'contract_base', 'ApplicationReceivedDate'                   , 'application_received_timestamp'            , 'TIMESTAMP'           ,  18, 1, 0, 1, GETUTCDATE()),
  (2004, 'EQ_Warehouse', 'Contract'                                  , 'contract_base', 'ApplicationSignedDate'                     , 'application_signed_timestamp'              , 'TIMESTAMP'           ,  19, 1, 0, 1, GETUTCDATE()),
  (2005, 'EQ_Warehouse', 'Contract'                                  , 'contract_base', 'EffectiveDate'                             , 'effective_timestamp'                       , 'TIMESTAMP'           ,  20, 1, 0, 1, GETUTCDATE()),
  (2006, 'EQ_Warehouse', 'Contract'                                  , 'contract_base', 'IssueDate'                                 , 'issue_timestamp'                           , 'TIMESTAMP'           ,  21, 1, 0, 1, GETUTCDATE()),
  (2007, 'EQ_Warehouse', 'Contract'                                  , 'contract_base', 'IssueState'                                , 'issue_state_code'                          , 'STRING'              ,  22, 1, 0, 1, GETUTCDATE()),
  (2008, 'EQ_Warehouse', 'Contract'                                  , 'contract_base', 'IssueAge'                                  , 'issue_age'                                 , 'INT'                 ,  23, 1, 0, 1, GETUTCDATE()),
  (2009, 'EQ_Warehouse', 'Contract'                                  , 'contract_base', 'AttainedAge'                               , 'attained_age'                              , 'INT'                 ,  24, 1, 0, 1, GETUTCDATE()),
  (2010, 'EQ_Warehouse', 'Contract'                                  , 'contract_base', 'ContractStatus'                            , 'contract_status_code'                      , 'STRING'              ,  25, 1, 0, 1, GETUTCDATE()),
  (2011, 'EQ_Warehouse', 'Contract'                                  , 'contract_base', 'CostBasis'                                 , 'cost_basis'                                , 'DECIMAL(18,4)'       ,  26, 1, 0, 1, GETUTCDATE()),
  (2012, 'EQ_Warehouse', 'Contract'                                  , 'contract_base', 'RecoveredCostBasis'                        , 'recovered_cost_basis'                      , 'DECIMAL(18,4)'       ,  27, 1, 0, 1, GETUTCDATE()),
  (2013, 'EQ_Warehouse', 'Contract'                                  , 'contract_base', 'QualInd'                                   , 'qual_ind'                                  , 'STRING'              ,  28, 1, 0, 1, GETUTCDATE()),
  (2014, 'EQ_Warehouse', 'Contract'                                  , 'contract_base', 'QualType'                                  , 'qual_type'                                 , 'STRING'              ,  29, 1, 0, 1, GETUTCDATE()),
  (2015, 'EQ_Warehouse', 'Contract'                                  , 'contract_base', 'Option'                                    , 'contract_option'                           , 'STRING'              ,  30, 1, 0, 1, GETUTCDATE()),
  (2016, 'EQ_Warehouse', 'Contract'                                  , 'contract_base', 'CertainPeriod'                             , 'certain_period'                            , 'INT'                 ,  31, 1, 0, 1, GETUTCDATE()),
  (2017, 'EQ_Warehouse', 'Contract'                                  , 'contract_base', 'MECStatus'                                 , 'mec_status_code'                           , 'STRING'              ,  32, 1, 0, 1, GETUTCDATE()),
  (2018, 'EQ_Warehouse', 'Contract'                                  , 'contract_base', 'RelatedContractNumber'                     , 'related_contract_number'                   , 'STRING'              ,  33, 1, 0, 1, GETUTCDATE()),
  (2019, 'EQ_Warehouse', 'Contract'                                  , 'contract_base', 'SpousalContinuationInd'                    , 'is_spousal_continuation'                   , 'BOOLEAN'             ,  34, 1, 0, 1, GETUTCDATE()),
  (2020, 'EQ_Warehouse', 'Contract'                                  , 'contract_base', 'SupplementalContractInd'                   , 'is_supplemental_contract'                  , 'BOOLEAN'             ,  35, 1, 0, 1, GETUTCDATE()),
  (2021, 'EQ_Warehouse', 'Contract'                                  , 'contract_base', 'QDROInd'                                   , 'is_qdro'                                   , 'BOOLEAN'             ,  36, 1, 0, 1, GETUTCDATE()),
  (2022, 'EQ_Warehouse', 'Contract'                                  , 'contract_base', 'RiderClaimInd'                             , 'is_rider_claim'                            , 'BOOLEAN'             ,  37, 1, 0, 1, GETUTCDATE()),
  (2023, 'EQ_Warehouse', 'Contract'                                  , 'contract_base', 'ROTHConversionInd'                         , 'is_roth_conversion'                        , 'BOOLEAN'             ,  38, 1, 0, 1, GETUTCDATE()),
  (2024, 'EQ_Warehouse', 'Contract'                                  , 'contract_base', 'InternalReplacementInd'                    , 'is_internal_replacement'                   , 'BOOLEAN'             ,  39, 1, 0, 1, GETUTCDATE()),
  (2025, 'EQ_Warehouse', 'Contract'                                  , 'contract_base', 'PartialTaxConversionInd'                   , 'is_partial_tax_conversion'                 , 'BOOLEAN'             ,  40, 1, 0, 1, GETUTCDATE()),
  (2026, 'EQ_Warehouse', 'Contract'                                  , 'contract_base', 'WaiverInEffectInd'                         , 'is_waiver_in_effect'                       , 'BOOLEAN'             ,  41, 1, 0, 1, GETUTCDATE()),
  (2027, 'EQ_Warehouse', 'Contract'                                  , 'contract_base', 'EDeliveryInd'                              , 'is_e_delivery'                             , 'BOOLEAN'             ,  42, 1, 0, 1, GETUTCDATE()),
  (2028, 'EQ_Warehouse', 'Contract'                                  , 'contract_base', 'ClassCode'                                 , 'class_code'                                , 'STRING'              ,  43, 1, 0, 1, GETUTCDATE()),
  (2029, 'EQ_Warehouse', 'Contract'                                  , 'contract_base', 'UnderwritingClass'                         , 'underwriting_class'                        , 'STRING'              ,  44, 1, 0, 1, GETUTCDATE()),
  (2030, 'EQ_Warehouse', 'Contract'                                  , 'contract_base', 'UnderwritingDate'                          , 'underwriting_timestamp'                    , 'TIMESTAMP'           ,  45, 1, 0, 1, GETUTCDATE()),
  (2031, 'EQ_Warehouse', 'Contract'                                  , 'contract_base', 'CoverageRatio'                             , 'coverage_ratio'                            , 'DECIMAL(18,4)'       ,  46, 1, 0, 1, GETUTCDATE()),
  (2032, 'EQ_Warehouse', 'Contract'                                  , 'contract_base', 'ContractEndDate'                           , 'contract_end_timestamp'                    , 'TIMESTAMP'           ,  47, 1, 0, 1, GETUTCDATE()),
  (2033, 'EQ_Warehouse', 'Contract'                                  , 'contract_base', 'FundingCompanyFK'                          , 'funding_company_id'                        , 'INT'                 ,  48, 1, 0, 1, GETUTCDATE()),
  (2034, 'EQ_Warehouse', 'Contract'                                  , 'contract_base', 'SourceKey'                                 , 'source_key'                                , 'BIGINT'              ,  49, 1, 0, 1, GETUTCDATE()),
  (2035, 'EQ_Warehouse', 'Contract'                                  , 'contract_base', 'StartDate'                                 , 'start_timestamp'                           , 'TIMESTAMP'           ,  50, 1, 0, 1, GETUTCDATE()),
  (2036, 'EQ_Warehouse', 'Contract'                                  , 'contract_base', 'EndDate'                                   , 'end_timestamp'                             , 'TIMESTAMP'           ,  51, 1, 0, 1, GETUTCDATE());

-- Total: column mappings across EQ_Warehouse source tables (IDs 1-792) + HubSpot (IDs 911-1085)
-- EQ_ODS base table mappings start at ID 3001 (see section below)


-- ============================================================
-- HubSpot source — schema_config seed data
-- IDs 911–1085  (175 rows across 14 landing tables)
-- source_name = 'HubSpot'
-- source_column_name = API JSON field path (camelCase / dot-notation)
-- target_column_name = landing Delta column (snake_case)
-- include_in_md5hash: 0 for JSON blobs and URL-context columns, 1 for all others
-- ============================================================

-- [H01] marketing_events (22 fields)
-- source_column_name = actual landing column (already snake_case); no JSON expansion per spec
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  ( 911, 'HubSpot', 'marketing_events', 'marketing_events_base', 'object_id',          'object_id',          'STRING',   1, 1, 1, 1, GETUTCDATE()),
  ( 912, 'HubSpot', 'marketing_events', 'marketing_events_base', 'external_event_id',  'external_event_id',  'STRING',   2, 1, 0, 1, GETUTCDATE()),
  ( 913, 'HubSpot', 'marketing_events', 'marketing_events_base', 'event_name',         'event_name',         'STRING',   3, 1, 0, 1, GETUTCDATE()),
  ( 914, 'HubSpot', 'marketing_events', 'marketing_events_base', 'event_type',         'event_type',         'STRING',   4, 1, 0, 1, GETUTCDATE()),
  ( 915, 'HubSpot', 'marketing_events', 'marketing_events_base', 'event_status',       'event_status',       'STRING',   5, 1, 0, 1, GETUTCDATE()),
  ( 916, 'HubSpot', 'marketing_events', 'marketing_events_base', 'event_status_v2',    'event_status_v2',    'STRING',   6, 1, 0, 1, GETUTCDATE()),
  ( 917, 'HubSpot', 'marketing_events', 'marketing_events_base', 'start_date_time',    'start_date_time',    'STRING',   7, 1, 0, 1, GETUTCDATE()),
  ( 918, 'HubSpot', 'marketing_events', 'marketing_events_base', 'end_date_time',      'end_date_time',      'STRING',   8, 1, 0, 1, GETUTCDATE()),
  ( 919, 'HubSpot', 'marketing_events', 'marketing_events_base', 'event_organizer',    'event_organizer',    'STRING',   9, 1, 0, 1, GETUTCDATE()),
  ( 920, 'HubSpot', 'marketing_events', 'marketing_events_base', 'event_description',  'event_description',  'STRING',  10, 1, 0, 1, GETUTCDATE()),
  ( 921, 'HubSpot', 'marketing_events', 'marketing_events_base', 'event_url',          'event_url',          'STRING',  11, 1, 0, 1, GETUTCDATE()),
  ( 922, 'HubSpot', 'marketing_events', 'marketing_events_base', 'event_cancelled',    'event_cancelled',    'BOOLEAN', 12, 1, 0, 1, GETUTCDATE()),
  ( 923, 'HubSpot', 'marketing_events', 'marketing_events_base', 'event_completed',    'event_completed',    'BOOLEAN', 13, 1, 0, 1, GETUTCDATE()),
  ( 924, 'HubSpot', 'marketing_events', 'marketing_events_base', 'registrants',        'registrants',        'INT',     14, 1, 0, 1, GETUTCDATE()),
  ( 925, 'HubSpot', 'marketing_events', 'marketing_events_base', 'attendees',          'attendees',          'INT',     15, 1, 0, 1, GETUTCDATE()),
  ( 926, 'HubSpot', 'marketing_events', 'marketing_events_base', 'cancellations',      'cancellations',      'INT',     16, 1, 0, 1, GETUTCDATE()),
  ( 927, 'HubSpot', 'marketing_events', 'marketing_events_base', 'no_shows',           'no_shows',           'INT',     17, 1, 0, 1, GETUTCDATE()),
  ( 928, 'HubSpot', 'marketing_events', 'marketing_events_base', 'app_info_id',        'app_info_id',        'STRING',  18, 1, 0, 1, GETUTCDATE()),
  ( 929, 'HubSpot', 'marketing_events', 'marketing_events_base', 'app_info_name',      'app_info_name',      'STRING',  19, 1, 0, 1, GETUTCDATE()),
  ( 930, 'HubSpot', 'marketing_events', 'marketing_events_base', 'created_at',         'created_at',         'STRING',  20, 1, 0, 1, GETUTCDATE()),
  ( 931, 'HubSpot', 'marketing_events', 'marketing_events_base', 'updated_at',         'updated_at',         'STRING',  21, 1, 0, 1, GETUTCDATE()),
  ( 932, 'HubSpot', 'marketing_events', 'marketing_events_base', 'N/A',                'period',             'STRING',  22, 0, 0, 1, GETUTCDATE());

-- [H02] marketing_emails (53 base fields + 5 to_json expansions)
-- source_column_name = actual landing column (already snake_case)
-- from.*, subscriptionDetails.*, webversion.* are already flattened in lh_landing — plain mappings, no dot-notation
-- JSON blob columns: kept as STRING blobs (include_in_md5hash=0), except to_json which is expanded below
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  ( 933, 'HubSpot', 'marketing_emails', 'marketing_emails_base', 'id',                                'id',                                'STRING',   1, 1, 1, 1, GETUTCDATE()),
  ( 934, 'HubSpot', 'marketing_emails', 'marketing_emails_base', 'name',                              'name',                              'STRING',   2, 1, 0, 1, GETUTCDATE()),
  ( 935, 'HubSpot', 'marketing_emails', 'marketing_emails_base', 'subject',                           'subject',                           'STRING',   3, 1, 0, 1, GETUTCDATE()),
  ( 936, 'HubSpot', 'marketing_emails', 'marketing_emails_base', 'state',                             'state',                             'STRING',   4, 1, 0, 1, GETUTCDATE()),
  ( 937, 'HubSpot', 'marketing_emails', 'marketing_emails_base', 'type',                              'type',                              'STRING',   5, 1, 0, 1, GETUTCDATE()),
  ( 938, 'HubSpot', 'marketing_emails', 'marketing_emails_base', 'subcategory',                       'subcategory',                       'STRING',   6, 1, 0, 1, GETUTCDATE()),
  ( 939, 'HubSpot', 'marketing_emails', 'marketing_emails_base', 'language',                          'language',                          'STRING',   7, 1, 0, 1, GETUTCDATE()),
  ( 940, 'HubSpot', 'marketing_emails', 'marketing_emails_base', 'archived',                          'archived',                          'BOOLEAN',  8, 1, 0, 1, GETUTCDATE()),
  ( 941, 'HubSpot', 'marketing_emails', 'marketing_emails_base', 'is_ab',                             'is_ab',                             'BOOLEAN',  9, 1, 0, 1, GETUTCDATE()),
  ( 942, 'HubSpot', 'marketing_emails', 'marketing_emails_base', 'is_published',                      'is_published',                      'BOOLEAN', 10, 1, 0, 1, GETUTCDATE()),
  ( 943, 'HubSpot', 'marketing_emails', 'marketing_emails_base', 'is_transactional',                  'is_transactional',                  'BOOLEAN', 11, 1, 0, 1, GETUTCDATE()),
  ( 944, 'HubSpot', 'marketing_emails', 'marketing_emails_base', 'send_on_publish',                   'send_on_publish',                   'BOOLEAN', 12, 1, 0, 1, GETUTCDATE()),
  ( 945, 'HubSpot', 'marketing_emails', 'marketing_emails_base', 'jitter_send_time',                  'jitter_send_time',                  'BOOLEAN', 13, 1, 0, 1, GETUTCDATE()),
  ( 946, 'HubSpot', 'marketing_emails', 'marketing_emails_base', 'active_domain',                     'active_domain',                     'STRING',  14, 1, 0, 1, GETUTCDATE()),
  ( 947, 'HubSpot', 'marketing_emails', 'marketing_emails_base', 'campaign',                          'campaign',                          'STRING',  15, 1, 0, 1, GETUTCDATE()),
  ( 948, 'HubSpot', 'marketing_emails', 'marketing_emails_base', 'campaign_name',                     'campaign_name',                     'STRING',  16, 1, 0, 1, GETUTCDATE()),
  ( 949, 'HubSpot', 'marketing_emails', 'marketing_emails_base', 'campaign_utm',                      'campaign_utm',                      'STRING',  17, 1, 0, 1, GETUTCDATE()),
  ( 950, 'HubSpot', 'marketing_emails', 'marketing_emails_base', 'email_campaign_group_id',           'email_campaign_group_id',           'STRING',  18, 1, 0, 1, GETUTCDATE()),
  ( 951, 'HubSpot', 'marketing_emails', 'marketing_emails_base', 'primary_email_campaign_id',         'primary_email_campaign_id',         'STRING',  19, 1, 0, 1, GETUTCDATE()),
  ( 952, 'HubSpot', 'marketing_emails', 'marketing_emails_base', 'email_template_mode',               'email_template_mode',               'STRING',  20, 1, 0, 1, GETUTCDATE()),
  ( 953, 'HubSpot', 'marketing_emails', 'marketing_emails_base', 'feedback_survey_id',                'feedback_survey_id',                'STRING',  21, 1, 0, 1, GETUTCDATE()),
  ( 954, 'HubSpot', 'marketing_emails', 'marketing_emails_base', 'folder_id',                         'folder_id',                         'STRING',  22, 1, 0, 1, GETUTCDATE()),
  ( 955, 'HubSpot', 'marketing_emails', 'marketing_emails_base', 'business_unit_id',                  'business_unit_id',                  'STRING',  23, 1, 0, 1, GETUTCDATE()),
  ( 956, 'HubSpot', 'marketing_emails', 'marketing_emails_base', 'cloned_from',                       'cloned_from',                       'STRING',  24, 1, 0, 1, GETUTCDATE()),
  ( 957, 'HubSpot', 'marketing_emails', 'marketing_emails_base', 'preview_key',                       'preview_key',                       'STRING',  25, 1, 0, 1, GETUTCDATE()),
  ( 958, 'HubSpot', 'marketing_emails', 'marketing_emails_base', 'publish_date',                      'publish_date',                      'STRING',  26, 1, 0, 1, GETUTCDATE()),
  ( 959, 'HubSpot', 'marketing_emails', 'marketing_emails_base', 'published_at',                      'published_at',                      'STRING',  27, 1, 0, 1, GETUTCDATE()),
  ( 960, 'HubSpot', 'marketing_emails', 'marketing_emails_base', 'unpublished_at',                    'unpublished_at',                    'STRING',  28, 1, 0, 1, GETUTCDATE()),
  ( 961, 'HubSpot', 'marketing_emails', 'marketing_emails_base', 'published_by_email',                'published_by_email',                'STRING',  29, 1, 0, 1, GETUTCDATE()),
  ( 962, 'HubSpot', 'marketing_emails', 'marketing_emails_base', 'published_by_id',                   'published_by_id',                   'STRING',  30, 1, 0, 1, GETUTCDATE()),
  ( 963, 'HubSpot', 'marketing_emails', 'marketing_emails_base', 'published_by_name',                 'published_by_name',                 'STRING',  31, 1, 0, 1, GETUTCDATE()),
  ( 964, 'HubSpot', 'marketing_emails', 'marketing_emails_base', 'created_at',                        'created_at',                        'STRING',  32, 1, 0, 1, GETUTCDATE()),
  ( 965, 'HubSpot', 'marketing_emails', 'marketing_emails_base', 'created_by_id',                     'created_by_id',                     'STRING',  33, 1, 0, 1, GETUTCDATE()),
  ( 966, 'HubSpot', 'marketing_emails', 'marketing_emails_base', 'deleted_at',                        'deleted_at',                        'STRING',  34, 1, 0, 1, GETUTCDATE()),
  ( 967, 'HubSpot', 'marketing_emails', 'marketing_emails_base', 'updated_at',                        'updated_at',                        'STRING',  35, 1, 0, 1, GETUTCDATE()),
  ( 968, 'HubSpot', 'marketing_emails', 'marketing_emails_base', 'updated_by_id',                     'updated_by_id',                     'STRING',  36, 1, 0, 1, GETUTCDATE()),
  ( 969, 'HubSpot', 'marketing_emails', 'marketing_emails_base', 'from_name',                         'from_name',                         'STRING',  37, 1, 0, 1, GETUTCDATE()),
  ( 970, 'HubSpot', 'marketing_emails', 'marketing_emails_base', 'from_reply_to',                     'from_reply_to',                     'STRING',  38, 1, 0, 1, GETUTCDATE()),
  ( 971, 'HubSpot', 'marketing_emails', 'marketing_emails_base', 'from_custom_reply_to',              'from_custom_reply_to',              'STRING',  39, 1, 0, 1, GETUTCDATE()),
  ( 972, 'HubSpot', 'marketing_emails', 'marketing_emails_base', 'subscription_id',                   'subscription_id',                   'STRING',  40, 1, 0, 1, GETUTCDATE()),
  ( 973, 'HubSpot', 'marketing_emails', 'marketing_emails_base', 'subscription_name',                 'subscription_name',                 'STRING',  41, 1, 0, 1, GETUTCDATE()),
  ( 974, 'HubSpot', 'marketing_emails', 'marketing_emails_base', 'subscription_office_location_id',   'subscription_office_location_id',   'STRING',  42, 1, 0, 1, GETUTCDATE()),
  ( 975, 'HubSpot', 'marketing_emails', 'marketing_emails_base', 'subscription_preferences_group_id', 'subscription_preferences_group_id', 'STRING',  43, 1, 0, 1, GETUTCDATE()),
  ( 976, 'HubSpot', 'marketing_emails', 'marketing_emails_base', 'webversion_url',                    'webversion_url',                    'STRING',  44, 1, 0, 1, GETUTCDATE()),
  ( 977, 'HubSpot', 'marketing_emails', 'marketing_emails_base', 'webversion_enabled',                'webversion_enabled',                'BOOLEAN', 45, 1, 0, 1, GETUTCDATE()),
  ( 978, 'HubSpot', 'marketing_emails', 'marketing_emails_base', 'content_json',                      'content_json',                      'STRING',  46, 0, 0, 1, GETUTCDATE()),
  ( 979, 'HubSpot', 'marketing_emails', 'marketing_emails_base', 'stats_json',                        'stats_json',                        'STRING',  47, 0, 0, 1, GETUTCDATE()),
  ( 980, 'HubSpot', 'marketing_emails', 'marketing_emails_base', 'testing_json',                      'testing_json',                      'STRING',  48, 0, 0, 1, GETUTCDATE()),
  ( 981, 'HubSpot', 'marketing_emails', 'marketing_emails_base', 'rss_data_json',                     'rss_data_json',                     'STRING',  49, 0, 0, 1, GETUTCDATE()),
  ( 982, 'HubSpot', 'marketing_emails', 'marketing_emails_base', 'to_json',                           'to_json',                           'STRING',  50, 0, 0, 1, GETUTCDATE()),
  ( 983, 'HubSpot', 'marketing_emails', 'marketing_emails_base', 'all_email_campaign_ids_json',        'all_email_campaign_ids_json',       'STRING',  51, 0, 0, 1, GETUTCDATE()),
  ( 984, 'HubSpot', 'marketing_emails', 'marketing_emails_base', 'teams_with_access_json',            'teams_with_access_json',            'STRING',  52, 0, 0, 1, GETUTCDATE()),
  ( 985, 'HubSpot', 'marketing_emails', 'marketing_emails_base', 'workflow_names_json',               'workflow_names_json',               'STRING',  53, 0, 0, 1, GETUTCDATE());
-- to_json expansion — dot-notation triggers get_json_object() in nb_bronze_ingestion_v2
-- include_in_md5hash=1: recipient/targeting fields used for change detection
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  (1108, 'HubSpot', 'marketing_emails', 'marketing_emails_base', 'to_json.contactIds',         'to_contact_ids',          'STRING',  54, 1, 0, 1, GETUTCDATE()),
  (1109, 'HubSpot', 'marketing_emails', 'marketing_emails_base', 'to_json.contactIlsLists',    'to_contact_ils_lists',    'STRING',  55, 1, 0, 1, GETUTCDATE()),
  (1110, 'HubSpot', 'marketing_emails', 'marketing_emails_base', 'to_json.contactLists',       'to_contact_lists',        'STRING',  56, 1, 0, 1, GETUTCDATE()),
  (1111, 'HubSpot', 'marketing_emails', 'marketing_emails_base', 'to_json.limitSendFrequency', 'to_limit_send_frequency', 'BOOLEAN', 57, 1, 0, 1, GETUTCDATE()),
  (1112, 'HubSpot', 'marketing_emails', 'marketing_emails_base', 'to_json.suppressGraymail',   'to_suppress_graymail',    'BOOLEAN', 58, 1, 0, 1, GETUTCDATE());

-- [H03] events_event_types (1 field)
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  ( 986, 'HubSpot', 'events_event_types', 'events_event_types_base', '__item__', 'event_type', 'STRING', 1, 1, 1, 1, GETUTCDATE());

-- [H04–H14] CRM Objects — shared field set (9 fields × 11 object types)
-- source_column_name = landing column (already flattened); properties are stored as JSON blob

-- [H04] crm_contacts — 24 cols fully flattened (5 top-level + 19 properties.*)
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  ( 987, 'HubSpot', 'crm_contacts', 'crm_contacts_base', 'id',                              'id',                              'STRING',   1, 1, 1, 1, GETUTCDATE()),
  ( 988, 'HubSpot', 'crm_contacts', 'crm_contacts_base', 'createdAt',                       'created_at',                      'STRING',   2, 1, 0, 1, GETUTCDATE()),
  ( 989, 'HubSpot', 'crm_contacts', 'crm_contacts_base', 'updatedAt',                       'updated_at',                      'STRING',   3, 1, 0, 1, GETUTCDATE()),
  ( 990, 'HubSpot', 'crm_contacts', 'crm_contacts_base', 'archived',                        'archived',                        'BOOLEAN',  4, 1, 0, 1, GETUTCDATE()),
  ( 991, 'HubSpot', 'crm_contacts', 'crm_contacts_base', 'url',                             'url',                             'STRING',   5, 0, 0, 1, GETUTCDATE()),
  ( 992, 'HubSpot', 'crm_contacts', 'crm_contacts_base', 'properties.agent_id__c',          'agent_id_c',                      'STRING',   6, 1, 0, 1, GETUTCDATE()),
  ( 993, 'HubSpot', 'crm_contacts', 'crm_contacts_base', 'properties.agent_number',         'agent_number',                    'STRING',   7, 1, 0, 1, GETUTCDATE()),
  ( 994, 'HubSpot', 'crm_contacts', 'crm_contacts_base', 'properties.associatedcompanyid',  'associatedcompanyid',             'STRING',   8, 1, 0, 1, GETUTCDATE()),
  ( 995, 'HubSpot', 'crm_contacts', 'crm_contacts_base', 'properties.associatedcompanylastupdated', 'associatedcompanylastupdated', 'STRING', 9, 1, 0, 1, GETUTCDATE());
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  (1086, 'HubSpot', 'crm_contacts', 'crm_contacts_base', 'properties.company',                      'company',                      'STRING', 10, 1, 0, 1, GETUTCDATE()),
  (1087, 'HubSpot', 'crm_contacts', 'crm_contacts_base', 'properties.createdate',                   'createdate',                   'STRING', 11, 1, 0, 1, GETUTCDATE()),
  (1088, 'HubSpot', 'crm_contacts', 'crm_contacts_base', 'properties.email',                        'email',                        'STRING', 12, 1, 0, 1, GETUTCDATE()),
  (1089, 'HubSpot', 'crm_contacts', 'crm_contacts_base', 'properties.hs_email_click',               'hs_email_click',               'STRING', 13, 1, 0, 1, GETUTCDATE()),
  (1090, 'HubSpot', 'crm_contacts', 'crm_contacts_base', 'properties.hs_email_first_click_date',    'hs_email_first_click_date',    'STRING', 14, 1, 0, 1, GETUTCDATE()),
  (1091, 'HubSpot', 'crm_contacts', 'crm_contacts_base', 'properties.hs_email_first_open_date',     'hs_email_first_open_date',     'STRING', 15, 1, 0, 1, GETUTCDATE()),
  (1235, 'HubSpot', 'crm_contacts', 'crm_contacts_base', 'properties.hs_email_first_reply_date',    'hs_email_first_reply_date',    'STRING', 16, 1, 0, 1, GETUTCDATE()),
  (1236, 'HubSpot', 'crm_contacts', 'crm_contacts_base', 'properties.hs_email_first_send_date',     'hs_email_first_send_date',     'STRING', 17, 1, 0, 1, GETUTCDATE()),
  (1237, 'HubSpot', 'crm_contacts', 'crm_contacts_base', 'properties.hs_email_last_click_date',     'hs_email_last_click_date',     'STRING', 18, 1, 0, 1, GETUTCDATE()),
  (1238, 'HubSpot', 'crm_contacts', 'crm_contacts_base', 'properties.hs_email_last_email_name',     'hs_email_last_email_name',     'STRING', 19, 1, 0, 1, GETUTCDATE()),
  (1239, 'HubSpot', 'crm_contacts', 'crm_contacts_base', 'properties.hs_email_last_open_date',      'hs_email_last_open_date',      'STRING', 20, 1, 0, 1, GETUTCDATE()),
  (1240, 'HubSpot', 'crm_contacts', 'crm_contacts_base', 'properties.hs_email_last_reply_date',     'hs_email_last_reply_date',     'STRING', 21, 1, 0, 1, GETUTCDATE()),
  (1241, 'HubSpot', 'crm_contacts', 'crm_contacts_base', 'properties.hs_email_last_send_date',      'hs_email_last_send_date',      'STRING', 22, 1, 0, 1, GETUTCDATE()),
  (1242, 'HubSpot', 'crm_contacts', 'crm_contacts_base', 'properties.hs_object_id',                 'hs_object_id',                 'STRING', 23, 1, 0, 1, GETUTCDATE()),
  (1243, 'HubSpot', 'crm_contacts', 'crm_contacts_base', 'properties.lastmodifieddate',             'lastmodifieddate',             'STRING', 24, 1, 0, 1, GETUTCDATE());

-- [H05] crm_companies — 21 cols fully flattened (5 top-level + 16 properties.*)
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  ( 996, 'HubSpot', 'crm_companies', 'crm_companies_base', 'id',                          'id',                          'STRING',   1, 1, 1, 1, GETUTCDATE()),
  ( 997, 'HubSpot', 'crm_companies', 'crm_companies_base', 'createdAt',                   'created_at',                  'STRING',   2, 1, 0, 1, GETUTCDATE()),
  ( 998, 'HubSpot', 'crm_companies', 'crm_companies_base', 'updatedAt',                   'updated_at',                  'STRING',   3, 1, 0, 1, GETUTCDATE()),
  ( 999, 'HubSpot', 'crm_companies', 'crm_companies_base', 'archived',                    'archived',                    'BOOLEAN',  4, 1, 0, 1, GETUTCDATE()),
  (1000, 'HubSpot', 'crm_companies', 'crm_companies_base', 'url',                         'url',                         'STRING',   5, 0, 0, 1, GETUTCDATE()),
  (1001, 'HubSpot', 'crm_companies', 'crm_companies_base', 'properties.agent_id__c',      'agent_id_c',                  'STRING',   6, 1, 0, 1, GETUTCDATE()),
  (1002, 'HubSpot', 'crm_companies', 'crm_companies_base', 'properties.agent_number',     'agent_number',                'STRING',   7, 1, 0, 1, GETUTCDATE()),
  (1003, 'HubSpot', 'crm_companies', 'crm_companies_base', 'properties.agent_type__c',    'agent_type_c',                'STRING',   8, 1, 0, 1, GETUTCDATE()),
  (1004, 'HubSpot', 'crm_companies', 'crm_companies_base', 'properties.aggregation__c',   'aggregation_c',               'STRING',   9, 1, 0, 1, GETUTCDATE());
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  (1092, 'HubSpot', 'crm_companies', 'crm_companies_base', 'properties.createdate',                       'createdate',                       'STRING', 10, 1, 0, 1, GETUTCDATE()),
  (1093, 'HubSpot', 'crm_companies', 'crm_companies_base', 'properties.hs_lastmodifieddate',              'hs_lastmodifieddate',              'STRING', 11, 1, 0, 1, GETUTCDATE()),
  (1094, 'HubSpot', 'crm_companies', 'crm_companies_base', 'properties.hs_object_id',                     'hs_object_id',                     'STRING', 12, 1, 0, 1, GETUTCDATE()),
  (1095, 'HubSpot', 'crm_companies', 'crm_companies_base', 'properties.name',                             'name',                             'STRING', 13, 1, 0, 1, GETUTCDATE()),
  (1096, 'HubSpot', 'crm_companies', 'crm_companies_base', 'properties.parent_imo_agent',                 'parent_imo_agent',                 'STRING', 14, 1, 0, 1, GETUTCDATE()),
  (1228, 'HubSpot', 'crm_companies', 'crm_companies_base', 'properties.parent_imo_agent_id_annuity__c',   'parent_imo_agent_id_annuity_c',    'STRING', 15, 1, 0, 1, GETUTCDATE()),
  (1229, 'HubSpot', 'crm_companies', 'crm_companies_base', 'properties.parent_imo_agent_id_life__c',      'parent_imo_agent_id_life_c',       'STRING', 16, 1, 0, 1, GETUTCDATE()),
  (1230, 'HubSpot', 'crm_companies', 'crm_companies_base', 'properties.primary_contact_email__c',         'primary_contact_email_c',          'STRING', 17, 1, 0, 1, GETUTCDATE()),
  (1231, 'HubSpot', 'crm_companies', 'crm_companies_base', 'properties.salesforce_id',                    'salesforce_id',                    'STRING', 18, 1, 0, 1, GETUTCDATE()),
  (1232, 'HubSpot', 'crm_companies', 'crm_companies_base', 'properties.salesforceaccountid',              'salesforceaccountid',              'STRING', 19, 1, 0, 1, GETUTCDATE()),
  (1233, 'HubSpot', 'crm_companies', 'crm_companies_base', 'properties.salesforcedeleted',                'salesforcedeleted',                'STRING', 20, 1, 0, 1, GETUTCDATE()),
  (1234, 'HubSpot', 'crm_companies', 'crm_companies_base', 'properties.salesforcelastsynctime',           'salesforcelastsynctime',           'STRING', 21, 1, 0, 1, GETUTCDATE());


-- [H15] crm_owners — 11 cols, no properties_json; teams_json kept as blob
-- Landing columns are flat (no nested properties object for owners)
-- teams_json is a JSON array — kept as STRING blob; not expanded (structure varies)
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  (1097, 'HubSpot', 'crm_owners', 'crm_owners_base', 'id',                         'id',                         'STRING',   1, 1, 1, 1, GETUTCDATE()),
  (1098, 'HubSpot', 'crm_owners', 'crm_owners_base', 'email',                      'email',                      'STRING',   2, 1, 0, 1, GETUTCDATE()),
  (1099, 'HubSpot', 'crm_owners', 'crm_owners_base', 'first_name',                 'first_name',                 'STRING',   3, 1, 0, 1, GETUTCDATE()),
  (1100, 'HubSpot', 'crm_owners', 'crm_owners_base', 'last_name',                  'last_name',                  'STRING',   4, 1, 0, 1, GETUTCDATE()),
  (1101, 'HubSpot', 'crm_owners', 'crm_owners_base', 'type',                       'type',                       'STRING',   5, 1, 0, 1, GETUTCDATE()),
  (1102, 'HubSpot', 'crm_owners', 'crm_owners_base', 'user_id',                    'user_id',                    'INT',      6, 1, 0, 1, GETUTCDATE()),
  (1103, 'HubSpot', 'crm_owners', 'crm_owners_base', 'user_id_including_inactive', 'user_id_including_inactive', 'INT',      7, 1, 0, 1, GETUTCDATE()),
  (1104, 'HubSpot', 'crm_owners', 'crm_owners_base', 'created_at',                 'created_at',                 'STRING',   8, 1, 0, 1, GETUTCDATE()),
  (1105, 'HubSpot', 'crm_owners', 'crm_owners_base', 'updated_at',                 'updated_at',                 'STRING',   9, 1, 0, 1, GETUTCDATE()),
  (1106, 'HubSpot', 'crm_owners', 'crm_owners_base', 'archived',                   'archived',                   'BOOLEAN', 10, 1, 0, 1, GETUTCDATE()),
  (1107, 'HubSpot', 'crm_owners', 'crm_owners_base', 'teams_json',                 'teams_json',                 'STRING',  11, 0, 0, 1, GETUTCDATE());

-- [H16] marketing_email_statistics — 64 cols
--   email_id (PK, from context) + 16 agg counters + 13 agg ratios + 2 agg blobs
--   + campaign_id + 16 campaign counters + 13 campaign ratios + 2 campaign blobs
-- Source:  lh_landing.hubspot.marketing_email_statistics
-- Target:  lh_bronze.bronze_hubspot.marketing_email_statistics_base
-- campaign_* cols use $first/$first_key in schema JSON to navigate the dynamic UUID key.
-- Counters + ratios: include_in_md5hash=1.  JSON blobs: include_in_md5hash=0.
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  (1113, 'HubSpot', 'marketing_email_statistics', 'marketing_email_statistics_base', 'email_id',                       'email_id',                       'STRING',        1, 1, 1, 1, GETUTCDATE()),
  -- aggregate counters
  (1114, 'HubSpot', 'marketing_email_statistics', 'marketing_email_statistics_base', 'cnt_sent',                       'cnt_sent',                       'INT',           2, 1, 0, 1, GETUTCDATE()),
  (1115, 'HubSpot', 'marketing_email_statistics', 'marketing_email_statistics_base', 'cnt_open',                       'cnt_open',                       'INT',           3, 1, 0, 1, GETUTCDATE()),
  (1116, 'HubSpot', 'marketing_email_statistics', 'marketing_email_statistics_base', 'cnt_delivered',                  'cnt_delivered',                  'INT',           4, 1, 0, 1, GETUTCDATE()),
  (1117, 'HubSpot', 'marketing_email_statistics', 'marketing_email_statistics_base', 'cnt_bounce',                     'cnt_bounce',                     'INT',           5, 1, 0, 1, GETUTCDATE()),
  (1118, 'HubSpot', 'marketing_email_statistics', 'marketing_email_statistics_base', 'cnt_unsubscribed',               'cnt_unsubscribed',               'INT',           6, 1, 0, 1, GETUTCDATE()),
  (1119, 'HubSpot', 'marketing_email_statistics', 'marketing_email_statistics_base', 'cnt_click',                      'cnt_click',                      'INT',           7, 1, 0, 1, GETUTCDATE()),
  (1120, 'HubSpot', 'marketing_email_statistics', 'marketing_email_statistics_base', 'cnt_reply',                      'cnt_reply',                      'INT',           8, 1, 0, 1, GETUTCDATE()),
  (1121, 'HubSpot', 'marketing_email_statistics', 'marketing_email_statistics_base', 'cnt_dropped',                    'cnt_dropped',                    'INT',           9, 1, 0, 1, GETUTCDATE()),
  (1122, 'HubSpot', 'marketing_email_statistics', 'marketing_email_statistics_base', 'cnt_selected',                   'cnt_selected',                   'INT',          10, 1, 0, 1, GETUTCDATE()),
  (1123, 'HubSpot', 'marketing_email_statistics', 'marketing_email_statistics_base', 'cnt_spamreport',                 'cnt_spamreport',                 'INT',          11, 1, 0, 1, GETUTCDATE()),
  (1124, 'HubSpot', 'marketing_email_statistics', 'marketing_email_statistics_base', 'cnt_suppressed',                 'cnt_suppressed',                 'INT',          12, 1, 0, 1, GETUTCDATE()),
  (1125, 'HubSpot', 'marketing_email_statistics', 'marketing_email_statistics_base', 'cnt_hardbounced',                'cnt_hardbounced',                'INT',          13, 1, 0, 1, GETUTCDATE()),
  (1126, 'HubSpot', 'marketing_email_statistics', 'marketing_email_statistics_base', 'cnt_softbounced',                'cnt_softbounced',                'INT',          14, 1, 0, 1, GETUTCDATE()),
  (1127, 'HubSpot', 'marketing_email_statistics', 'marketing_email_statistics_base', 'cnt_pending',                    'cnt_pending',                    'INT',          15, 1, 0, 1, GETUTCDATE()),
  (1128, 'HubSpot', 'marketing_email_statistics', 'marketing_email_statistics_base', 'cnt_contactslost',               'cnt_contactslost',               'INT',          16, 1, 0, 1, GETUTCDATE()),
  (1129, 'HubSpot', 'marketing_email_statistics', 'marketing_email_statistics_base', 'cnt_notsent',                    'cnt_notsent',                    'INT',          17, 1, 0, 1, GETUTCDATE()),
  -- aggregate ratios
  (1130, 'HubSpot', 'marketing_email_statistics', 'marketing_email_statistics_base', 'ratio_click',                    'ratio_click',                    'FLOAT', 18, 1, 0, 1, GETUTCDATE()),
  (1131, 'HubSpot', 'marketing_email_statistics', 'marketing_email_statistics_base', 'ratio_clickthrough',             'ratio_clickthrough',             'FLOAT', 19, 1, 0, 1, GETUTCDATE()),
  (1132, 'HubSpot', 'marketing_email_statistics', 'marketing_email_statistics_base', 'ratio_delivered',                'ratio_delivered',                'FLOAT', 20, 1, 0, 1, GETUTCDATE()),
  (1133, 'HubSpot', 'marketing_email_statistics', 'marketing_email_statistics_base', 'ratio_open',                     'ratio_open',                     'FLOAT', 21, 1, 0, 1, GETUTCDATE()),
  (1134, 'HubSpot', 'marketing_email_statistics', 'marketing_email_statistics_base', 'ratio_reply',                    'ratio_reply',                    'FLOAT', 22, 1, 0, 1, GETUTCDATE()),
  (1135, 'HubSpot', 'marketing_email_statistics', 'marketing_email_statistics_base', 'ratio_unsubscribed',             'ratio_unsubscribed',             'FLOAT', 23, 1, 0, 1, GETUTCDATE()),
  (1136, 'HubSpot', 'marketing_email_statistics', 'marketing_email_statistics_base', 'ratio_spamreport',               'ratio_spamreport',               'FLOAT', 24, 1, 0, 1, GETUTCDATE()),
  (1137, 'HubSpot', 'marketing_email_statistics', 'marketing_email_statistics_base', 'ratio_bounce',                   'ratio_bounce',                   'FLOAT', 25, 1, 0, 1, GETUTCDATE()),
  (1138, 'HubSpot', 'marketing_email_statistics', 'marketing_email_statistics_base', 'ratio_hardbounce',               'ratio_hardbounce',               'FLOAT', 26, 1, 0, 1, GETUTCDATE()),
  (1139, 'HubSpot', 'marketing_email_statistics', 'marketing_email_statistics_base', 'ratio_softbounce',               'ratio_softbounce',               'FLOAT', 27, 1, 0, 1, GETUTCDATE()),
  (1140, 'HubSpot', 'marketing_email_statistics', 'marketing_email_statistics_base', 'ratio_contactslost',             'ratio_contactslost',             'FLOAT', 28, 1, 0, 1, GETUTCDATE()),
  (1141, 'HubSpot', 'marketing_email_statistics', 'marketing_email_statistics_base', 'ratio_pending',                  'ratio_pending',                  'FLOAT', 29, 1, 0, 1, GETUTCDATE()),
  (1142, 'HubSpot', 'marketing_email_statistics', 'marketing_email_statistics_base', 'ratio_notsent',                  'ratio_notsent',                  'FLOAT', 30, 1, 0, 1, GETUTCDATE()),
  -- aggregate blobs
  (1143, 'HubSpot', 'marketing_email_statistics', 'marketing_email_statistics_base', 'device_breakdown_json',          'device_breakdown_json',          'STRING',        31, 0, 0, 1, GETUTCDATE()),
  (1144, 'HubSpot', 'marketing_email_statistics', 'marketing_email_statistics_base', 'qualifier_stats_json',           'qualifier_stats_json',           'STRING',        32, 0, 0, 1, GETUTCDATE()),
  -- campaign (first entry of campaignAggregations — dynamic UUID key)
  (1145, 'HubSpot', 'marketing_email_statistics', 'marketing_email_statistics_base', 'campaign_id',                    'campaign_id',                    'STRING',        33, 1, 0, 1, GETUTCDATE()),
  -- campaign counters
  (1146, 'HubSpot', 'marketing_email_statistics', 'marketing_email_statistics_base', 'campaign_cnt_sent',              'campaign_cnt_sent',              'INT',           34, 1, 0, 1, GETUTCDATE()),
  (1147, 'HubSpot', 'marketing_email_statistics', 'marketing_email_statistics_base', 'campaign_cnt_open',              'campaign_cnt_open',              'INT',           35, 1, 0, 1, GETUTCDATE()),
  (1148, 'HubSpot', 'marketing_email_statistics', 'marketing_email_statistics_base', 'campaign_cnt_delivered',         'campaign_cnt_delivered',         'INT',           36, 1, 0, 1, GETUTCDATE()),
  (1149, 'HubSpot', 'marketing_email_statistics', 'marketing_email_statistics_base', 'campaign_cnt_bounce',            'campaign_cnt_bounce',            'INT',           37, 1, 0, 1, GETUTCDATE()),
  (1150, 'HubSpot', 'marketing_email_statistics', 'marketing_email_statistics_base', 'campaign_cnt_unsubscribed',      'campaign_cnt_unsubscribed',      'INT',           38, 1, 0, 1, GETUTCDATE()),
  (1151, 'HubSpot', 'marketing_email_statistics', 'marketing_email_statistics_base', 'campaign_cnt_click',             'campaign_cnt_click',             'INT',           39, 1, 0, 1, GETUTCDATE()),
  (1152, 'HubSpot', 'marketing_email_statistics', 'marketing_email_statistics_base', 'campaign_cnt_reply',             'campaign_cnt_reply',             'INT',           40, 1, 0, 1, GETUTCDATE()),
  (1153, 'HubSpot', 'marketing_email_statistics', 'marketing_email_statistics_base', 'campaign_cnt_dropped',           'campaign_cnt_dropped',           'INT',           41, 1, 0, 1, GETUTCDATE()),
  (1154, 'HubSpot', 'marketing_email_statistics', 'marketing_email_statistics_base', 'campaign_cnt_selected',          'campaign_cnt_selected',          'INT',           42, 1, 0, 1, GETUTCDATE()),
  (1155, 'HubSpot', 'marketing_email_statistics', 'marketing_email_statistics_base', 'campaign_cnt_spamreport',        'campaign_cnt_spamreport',        'INT',           43, 1, 0, 1, GETUTCDATE()),
  (1156, 'HubSpot', 'marketing_email_statistics', 'marketing_email_statistics_base', 'campaign_cnt_suppressed',        'campaign_cnt_suppressed',        'INT',           44, 1, 0, 1, GETUTCDATE()),
  (1157, 'HubSpot', 'marketing_email_statistics', 'marketing_email_statistics_base', 'campaign_cnt_hardbounced',       'campaign_cnt_hardbounced',       'INT',           45, 1, 0, 1, GETUTCDATE()),
  (1158, 'HubSpot', 'marketing_email_statistics', 'marketing_email_statistics_base', 'campaign_cnt_softbounced',       'campaign_cnt_softbounced',       'INT',           46, 1, 0, 1, GETUTCDATE()),
  (1159, 'HubSpot', 'marketing_email_statistics', 'marketing_email_statistics_base', 'campaign_cnt_pending',           'campaign_cnt_pending',           'INT',           47, 1, 0, 1, GETUTCDATE()),
  (1160, 'HubSpot', 'marketing_email_statistics', 'marketing_email_statistics_base', 'campaign_cnt_contactslost',      'campaign_cnt_contactslost',      'INT',           48, 1, 0, 1, GETUTCDATE()),
  (1161, 'HubSpot', 'marketing_email_statistics', 'marketing_email_statistics_base', 'campaign_cnt_notsent',           'campaign_cnt_notsent',           'INT',           49, 1, 0, 1, GETUTCDATE()),
  -- campaign ratios
  (1162, 'HubSpot', 'marketing_email_statistics', 'marketing_email_statistics_base', 'campaign_ratio_click',           'campaign_ratio_click',           'FLOAT', 50, 1, 0, 1, GETUTCDATE()),
  (1163, 'HubSpot', 'marketing_email_statistics', 'marketing_email_statistics_base', 'campaign_ratio_clickthrough',    'campaign_ratio_clickthrough',    'FLOAT', 51, 1, 0, 1, GETUTCDATE()),
  (1164, 'HubSpot', 'marketing_email_statistics', 'marketing_email_statistics_base', 'campaign_ratio_delivered',       'campaign_ratio_delivered',       'FLOAT', 52, 1, 0, 1, GETUTCDATE()),
  (1165, 'HubSpot', 'marketing_email_statistics', 'marketing_email_statistics_base', 'campaign_ratio_open',            'campaign_ratio_open',            'FLOAT', 53, 1, 0, 1, GETUTCDATE()),
  (1166, 'HubSpot', 'marketing_email_statistics', 'marketing_email_statistics_base', 'campaign_ratio_reply',           'campaign_ratio_reply',           'FLOAT', 54, 1, 0, 1, GETUTCDATE()),
  (1167, 'HubSpot', 'marketing_email_statistics', 'marketing_email_statistics_base', 'campaign_ratio_unsubscribed',    'campaign_ratio_unsubscribed',    'FLOAT', 55, 1, 0, 1, GETUTCDATE()),
  (1168, 'HubSpot', 'marketing_email_statistics', 'marketing_email_statistics_base', 'campaign_ratio_spamreport',      'campaign_ratio_spamreport',      'FLOAT', 56, 1, 0, 1, GETUTCDATE()),
  (1169, 'HubSpot', 'marketing_email_statistics', 'marketing_email_statistics_base', 'campaign_ratio_bounce',          'campaign_ratio_bounce',          'FLOAT', 57, 1, 0, 1, GETUTCDATE()),
  (1170, 'HubSpot', 'marketing_email_statistics', 'marketing_email_statistics_base', 'campaign_ratio_hardbounce',      'campaign_ratio_hardbounce',      'FLOAT', 58, 1, 0, 1, GETUTCDATE()),
  (1171, 'HubSpot', 'marketing_email_statistics', 'marketing_email_statistics_base', 'campaign_ratio_softbounce',      'campaign_ratio_softbounce',      'FLOAT', 59, 1, 0, 1, GETUTCDATE()),
  (1172, 'HubSpot', 'marketing_email_statistics', 'marketing_email_statistics_base', 'campaign_ratio_contactslost',    'campaign_ratio_contactslost',    'FLOAT', 60, 1, 0, 1, GETUTCDATE()),
  (1173, 'HubSpot', 'marketing_email_statistics', 'marketing_email_statistics_base', 'campaign_ratio_pending',         'campaign_ratio_pending',         'FLOAT', 61, 1, 0, 1, GETUTCDATE()),
  (1174, 'HubSpot', 'marketing_email_statistics', 'marketing_email_statistics_base', 'campaign_ratio_notsent',         'campaign_ratio_notsent',         'FLOAT', 62, 1, 0, 1, GETUTCDATE()),
  -- campaign blobs
  (1175, 'HubSpot', 'marketing_email_statistics', 'marketing_email_statistics_base', 'campaign_device_breakdown_json', 'campaign_device_breakdown_json', 'STRING',        63, 0, 0, 1, GETUTCDATE()),
  (1176, 'HubSpot', 'marketing_email_statistics', 'marketing_email_statistics_base', 'campaign_qualifier_stats_json',  'campaign_qualifier_stats_json',  'STRING',        64, 0, 0, 1, GETUTCDATE()),

-- [H17] event_details (IDs 1177–1227)
  (1177, 'HubSpot', 'event_details', 'event_details_base', 'id',                                        'id',                                        'STRING',  1, 0, 1, 1, GETUTCDATE()),
  (1178, 'HubSpot', 'event_details', 'event_details_base', 'objectType',                                'object_type',                               'STRING',  2, 1, 0, 1, GETUTCDATE()),
  (1179, 'HubSpot', 'event_details', 'event_details_base', 'objectId',                                  'object_id',                                 'STRING',  3, 1, 0, 1, GETUTCDATE()),
  (1180, 'HubSpot', 'event_details', 'event_details_base', 'eventType',                                 'event_type',                                'STRING',  4, 1, 0, 1, GETUTCDATE()),
  (1181, 'HubSpot', 'event_details', 'event_details_base', 'occurredAt',                                'occurred_at',                               'STRING',  5, 1, 0, 1, GETUTCDATE()),
  (1182, 'HubSpot', 'event_details', 'event_details_base', 'properties.hs_base_url',                   'hs_base_url',                               'STRING',  6, 1, 0, 1, GETUTCDATE()),
  (1183, 'HubSpot', 'event_details', 'event_details_base', 'properties.hs_url',                        'hs_url',                                    'STRING',  7, 1, 0, 1, GETUTCDATE()),
  (1184, 'HubSpot', 'event_details', 'event_details_base', 'properties.hs_query_params',               'hs_query_params',                           'STRING',  8, 1, 0, 1, GETUTCDATE()),
  (1185, 'HubSpot', 'event_details', 'event_details_base', 'properties.hs_canonical_url',              'hs_canonical_url',                          'STRING',  9, 1, 0, 1, GETUTCDATE()),
  (1186, 'HubSpot', 'event_details', 'event_details_base', 'properties.hs_url_domain',                 'hs_url_domain',                             'STRING', 10, 1, 0, 1, GETUTCDATE()),
  (1187, 'HubSpot', 'event_details', 'event_details_base', 'properties.hs_url_path',                   'hs_url_path',                               'STRING', 11, 1, 0, 1, GETUTCDATE()),
  (1188, 'HubSpot', 'event_details', 'event_details_base', 'properties.hs_analytics_normalized_page_url', 'hs_analytics_normalized_page_url',       'STRING', 12, 1, 0, 1, GETUTCDATE()),
  (1189, 'HubSpot', 'event_details', 'event_details_base', 'properties.hs_is_virtual_url',             'hs_is_virtual_url',                         'STRING', 13, 1, 0, 1, GETUTCDATE()),
  (1190, 'HubSpot', 'event_details', 'event_details_base', 'properties.hs_page_id',                    'hs_page_id',                                'STRING', 14, 1, 0, 1, GETUTCDATE()),
  (1191, 'HubSpot', 'event_details', 'event_details_base', 'properties.hs_page_title',                 'hs_page_title',                             'STRING', 15, 1, 0, 1, GETUTCDATE()),
  (1192, 'HubSpot', 'event_details', 'event_details_base', 'properties.hs_title',                      'hs_title',                                  'STRING', 16, 1, 0, 1, GETUTCDATE()),
  (1193, 'HubSpot', 'event_details', 'event_details_base', 'properties.hs_targeted_content_aggregation', 'hs_targeted_content_aggregation',         'STRING', 17, 1, 0, 1, GETUTCDATE()),
  (1194, 'HubSpot', 'event_details', 'event_details_base', 'properties.hs_is_virtual_referrer',        'hs_is_virtual_referrer',                    'STRING', 18, 1, 0, 1, GETUTCDATE()),
  (1195, 'HubSpot', 'event_details', 'event_details_base', 'properties.hs_is_external',                'hs_is_external',                            'STRING', 19, 1, 0, 1, GETUTCDATE()),
  (1196, 'HubSpot', 'event_details', 'event_details_base', 'properties.hs_is_amp',                     'hs_is_amp',                                 'STRING', 20, 1, 0, 1, GETUTCDATE()),
  (1197, 'HubSpot', 'event_details', 'event_details_base', 'properties.hs_is_in_chat_view',            'hs_is_in_chat_view',                        'STRING', 21, 1, 0, 1, GETUTCDATE()),
  (1198, 'HubSpot', 'event_details', 'event_details_base', 'properties.hs_is_new_cookie',              'hs_is_new_cookie',                          'STRING', 22, 1, 0, 1, GETUTCDATE()),
  (1199, 'HubSpot', 'event_details', 'event_details_base', 'properties.hs_is_contact',                 'hs_is_contact',                             'STRING', 23, 1, 0, 1, GETUTCDATE()),
  (1200, 'HubSpot', 'event_details', 'event_details_base', 'properties.hs_referrer',                   'hs_referrer',                               'STRING', 24, 1, 0, 1, GETUTCDATE()),
  (1201, 'HubSpot', 'event_details', 'event_details_base', 'properties.hs_device_type',                'hs_device_type',                            'STRING', 25, 1, 0, 1, GETUTCDATE()),
  (1202, 'HubSpot', 'event_details', 'event_details_base', 'properties.hs_device_name',                'hs_device_name',                            'STRING', 26, 1, 0, 1, GETUTCDATE()),
  (1203, 'HubSpot', 'event_details', 'event_details_base', 'properties.hs_browser',                    'hs_browser',                                'STRING', 27, 1, 0, 1, GETUTCDATE()),
  (1204, 'HubSpot', 'event_details', 'event_details_base', 'properties.hs_browser_type',               'hs_browser_type',                           'STRING', 28, 1, 0, 1, GETUTCDATE()),
  (1205, 'HubSpot', 'event_details', 'event_details_base', 'properties.hs_browser_version_major',      'hs_browser_version_major',                  'STRING', 29, 1, 0, 1, GETUTCDATE()),
  (1206, 'HubSpot', 'event_details', 'event_details_base', 'properties.hs_browser_fingerprint',        'hs_browser_fingerprint',                    'STRING', 30, 1, 0, 1, GETUTCDATE()),
  (1207, 'HubSpot', 'event_details', 'event_details_base', 'properties.hs_operating_system',           'hs_operating_system',                       'STRING', 31, 1, 0, 1, GETUTCDATE()),
  (1208, 'HubSpot', 'event_details', 'event_details_base', 'properties.hs_vendor',                     'hs_vendor',                                 'STRING', 32, 1, 0, 1, GETUTCDATE()),
  (1209, 'HubSpot', 'event_details', 'event_details_base', 'properties.hs_user_agent',                 'hs_user_agent',                             'STRING', 33, 1, 0, 1, GETUTCDATE()),
  (1210, 'HubSpot', 'event_details', 'event_details_base', 'properties.hs_country',                    'hs_country',                                'STRING', 34, 1, 0, 1, GETUTCDATE()),
  (1211, 'HubSpot', 'event_details', 'event_details_base', 'properties.hs_region',                     'hs_region',                                 'STRING', 35, 1, 0, 1, GETUTCDATE()),
  (1212, 'HubSpot', 'event_details', 'event_details_base', 'properties.hs_qualified_region',           'hs_qualified_region',                       'STRING', 36, 1, 0, 1, GETUTCDATE()),
  (1213, 'HubSpot', 'event_details', 'event_details_base', 'properties.hs_city',                       'hs_city',                                   'STRING', 37, 1, 0, 1, GETUTCDATE()),
  (1214, 'HubSpot', 'event_details', 'event_details_base', 'properties.hs_cf_bot_score',               'hs_cf_bot_score',                           'STRING', 38, 1, 0, 1, GETUTCDATE()),
  (1215, 'HubSpot', 'event_details', 'event_details_base', 'properties.hs_hash_id',                    'hs_hash_id',                                'STRING', 39, 1, 0, 1, GETUTCDATE()),
  (1216, 'HubSpot', 'event_details', 'event_details_base', 'properties.hs_log_line_timestamp',         'hs_log_line_timestamp',                     'STRING', 40, 1, 0, 1, GETUTCDATE()),
  (1217, 'HubSpot', 'event_details', 'event_details_base', 'properties.hs_processed_timestamp',        'hs_processed_timestamp',                    'STRING', 41, 1, 0, 1, GETUTCDATE()),
  (1218, 'HubSpot', 'event_details', 'event_details_base', 'properties.hs_visit_source',               'hs_visit_source',                           'STRING', 42, 1, 0, 1, GETUTCDATE()),
  (1219, 'HubSpot', 'event_details', 'event_details_base', 'properties.hs_visit_source_details_1',     'hs_visit_source_details_1',                 'STRING', 43, 1, 0, 1, GETUTCDATE()),
  (1220, 'HubSpot', 'event_details', 'event_details_base', 'properties.hs_visit_source_details_2',     'hs_visit_source_details_2',                 'STRING', 44, 1, 0, 1, GETUTCDATE()),
  (1221, 'HubSpot', 'event_details', 'event_details_base', 'properties.hs_utm_campaign',               'hs_utm_campaign',                           'STRING', 45, 1, 0, 1, GETUTCDATE()),
  (1222, 'HubSpot', 'event_details', 'event_details_base', 'properties.hs_leviathan_linked_vids',      'hs_leviathan_linked_vids',                  'STRING', 46, 1, 0, 1, GETUTCDATE()),
  (1223, 'HubSpot', 'event_details', 'event_details_base', 'properties.hs_company_id',                 'hs_company_id',                             'STRING', 47, 1, 0, 1, GETUTCDATE()),
  (1224, 'HubSpot', 'event_details', 'event_details_base', 'properties.hs_company_domain',             'hs_company_domain',                         'STRING', 48, 1, 0, 1, GETUTCDATE()),
  (1225, 'HubSpot', 'event_details', 'event_details_base', 'properties.hs_company_domain_by_association', 'hs_company_domain_by_association',       'STRING', 49, 1, 0, 1, GETUTCDATE()),
  (1226, 'HubSpot', 'event_details', 'event_details_base', 'properties.hs_historical_contact_associatedcompanyid', 'hs_historical_contact_associatedcompanyid', 'STRING', 50, 1, 0, 1, GETUTCDATE()),
  (1227, 'HubSpot', 'event_details', 'event_details_base', 'properties.hs_historical_contact_lifecyclestage',      'hs_historical_contact_lifecyclestage',      'STRING', 51, 1, 0, 1, GETUTCDATE());

-- Total HubSpot: 333 column mappings across 17 landing tables (IDs 911–1243)
--   911–932  : marketing_events                                          (22 rows)
--   933–985  : marketing_emails base cols                                (53 rows)
--   986      : events_event_types                                         (1 row)
--   987–995 + 1086–1091 + 1235–1243: crm_contacts fully flattened        (24 rows)
--   996–1004 + 1092–1096 + 1228–1234: crm_companies fully flattened      (21 rows)
--   1005–1085: crm_deals through crm_tasks (9 cols × 9 tables)           (81 rows)
--   1097–1107: crm_owners                                                (11 rows)
--   1108–1112: marketing_emails to_json expansion                         (5 rows)
--   1113–1176: marketing_email_statistics (agg + campaign fully flattened)(64 rows)
--   1177–1227: event_details (5 top-level + 46 properties.hs_* fields)   (51 rows)


-- ============================================================
-- EQ_ODS source — schema_config seed data
-- IDs 3001–3286  (286 rows across 15 base tables)
-- source_name     = 'EQ_ODS'
-- source_schema   = 'seg_editsolutions' (except ref_Product=dbo, ProductStructure=seg_engine)
-- target_schema   = 'seg_editsolutions' in lh_landing
-- Naming rules applied:
--   PK/FK suffix → _id   |   CT suffix → _code   |   Ind suffix → is_xxx
-- ============================================================

-- ── [O01] ref_Product  (EQ_ODS.dbo — 9 cols, IDs 3001-3009) ────────────────
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  (3001, 'EQ_ODS', 'ref_Product', 'ref_product_base', 'ProductPK',             'product_id',                'INT',     1, 0, 1, 1, GETUTCDATE()),
  (3002, 'EQ_ODS', 'ref_Product', 'ref_product_base', 'Product',               'product_name',              'STRING',  2, 1, 0, 1, GETUTCDATE()),
  (3003, 'EQ_ODS', 'ref_Product', 'ref_product_base', 'SecondSaleProduct',     'is_second_sale',            'BOOLEAN', 3, 1, 0, 1, GETUTCDATE()),
  (3004, 'EQ_ODS', 'ref_Product', 'ref_product_base', 'ProductGroupName',      'product_group_name',        'STRING',  4, 1, 0, 1, GETUTCDATE()),
  (3005, 'EQ_ODS', 'ref_Product', 'ref_product_base', 'AgentCommStatmentAbbr', 'agent_comm_statement_abbr', 'STRING',  5, 1, 0, 1, GETUTCDATE()),
  (3006, 'EQ_ODS', 'ref_Product', 'ref_product_base', 'GLAbbr',                'gl_abbr',                   'STRING',  6, 1, 0, 1, GETUTCDATE()),
  (3007, 'EQ_ODS', 'ref_Product', 'ref_product_base', 'GLLOB',                 'gl_line_of_business',       'STRING',  7, 1, 0, 1, GETUTCDATE()),
  (3008, 'EQ_ODS', 'ref_Product', 'ref_product_base', 'MarketingName',         'marketing_name',            'STRING',  8, 1, 0, 1, GETUTCDATE()),
  (3009, 'EQ_ODS', 'ref_Product', 'ref_product_base', 'CUSIPNumber',           'cusip_number',              'STRING',  9, 1, 0, 1, GETUTCDATE());

-- ── [O02] ContractClient  (25 cols, IDs 3010-3034) ──────────────────────────
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  (3010, 'EQ_ODS', 'ContractClient', 'contract_client_base', 'ContractClientPK',            'contract_client_id',             'INT',            1, 0, 1, 1, GETUTCDATE()),
  (3011, 'EQ_ODS', 'ContractClient', 'contract_client_base', 'ClientRoleFK',                'client_role_id',                 'INT',            2, 1, 0, 1, GETUTCDATE()),
  (3012, 'EQ_ODS', 'ContractClient', 'contract_client_base', 'SegmentFK',                   'segment_id',                     'INT',            3, 1, 0, 1, GETUTCDATE()),
  (3013, 'EQ_ODS', 'ContractClient', 'contract_client_base', 'IssueAge',                    'issue_age',                      'INT',            4, 1, 0, 1, GETUTCDATE()),
  (3014, 'EQ_ODS', 'ContractClient', 'contract_client_base', 'EffectiveDate',               'effective_date',                 'TIMESTAMP',      5, 1, 0, 1, GETUTCDATE()),
  (3015, 'EQ_ODS', 'ContractClient', 'contract_client_base', 'TerminationDate',             'termination_date',               'TIMESTAMP',      6, 1, 0, 1, GETUTCDATE()),
  (3016, 'EQ_ODS', 'ContractClient', 'contract_client_base', 'RelationshipToInsuredCT',     'relationship_to_insured_code',   'STRING',         7, 1, 0, 1, GETUTCDATE()),
  (3017, 'EQ_ODS', 'ContractClient', 'contract_client_base', 'TelephoneAuthorizationCT',    'telephone_authorization_code',   'STRING',         8, 1, 0, 1, GETUTCDATE()),
  (3018, 'EQ_ODS', 'ContractClient', 'contract_client_base', 'ClassCT',                     'class_code',                     'STRING',         9, 1, 0, 1, GETUTCDATE()),
  (3019, 'EQ_ODS', 'ContractClient', 'contract_client_base', 'FlatExtra',                   'flat_extra',                     'DECIMAL(18,4)', 10, 1, 0, 1, GETUTCDATE()),
  (3020, 'EQ_ODS', 'ContractClient', 'contract_client_base', 'FlatExtraAge',                'flat_extra_age',                 'INT',           11, 1, 0, 1, GETUTCDATE()),
  (3021, 'EQ_ODS', 'ContractClient', 'contract_client_base', 'FlatExtraDur',                'flat_extra_duration',            'INT',           12, 1, 0, 1, GETUTCDATE()),
  (3022, 'EQ_ODS', 'ContractClient', 'contract_client_base', 'PercentExtra',                'percent_extra',                  'DECIMAL(18,4)', 13, 1, 0, 1, GETUTCDATE()),
  (3023, 'EQ_ODS', 'ContractClient', 'contract_client_base', 'PercentExtraAge',             'percent_extra_age',              'INT',           14, 1, 0, 1, GETUTCDATE()),
  (3024, 'EQ_ODS', 'ContractClient', 'contract_client_base', 'PercentExtraDur',             'percent_extra_duration',         'INT',           15, 1, 0, 1, GETUTCDATE()),
  (3025, 'EQ_ODS', 'ContractClient', 'contract_client_base', 'TableRatingCT',               'table_rating_code',              'STRING',        16, 1, 0, 1, GETUTCDATE()),
  (3026, 'EQ_ODS', 'ContractClient', 'contract_client_base', 'DisbursementAddressTypeCT',   'disbursement_address_type_code', 'STRING',        17, 1, 0, 1, GETUTCDATE()),
  (3027, 'EQ_ODS', 'ContractClient', 'contract_client_base', 'CorrespondenceAddressTypeCT', 'correspondence_address_type_code','STRING',       18, 1, 0, 1, GETUTCDATE()),
  (3028, 'EQ_ODS', 'ContractClient', 'contract_client_base', 'PendingClassChangeInd',       'is_pending_class_change',        'BOOLEAN',       19, 1, 0, 1, GETUTCDATE()),
  (3029, 'EQ_ODS', 'ContractClient', 'contract_client_base', 'PayorOfCT',                   'payor_of_code',                  'STRING',        20, 1, 0, 1, GETUTCDATE()),
  (3030, 'EQ_ODS', 'ContractClient', 'contract_client_base', 'RatedGenderCT',               'rated_gender_code',              'STRING',        21, 1, 0, 1, GETUTCDATE()),
  (3031, 'EQ_ODS', 'ContractClient', 'contract_client_base', 'UnderwritingClassCT',         'underwriting_class_code',        'STRING',        22, 1, 0, 1, GETUTCDATE()),
  (3032, 'EQ_ODS', 'ContractClient', 'contract_client_base', 'TerminationReasonCT',         'termination_reason_code',        'STRING',        23, 1, 0, 1, GETUTCDATE()),
  (3033, 'EQ_ODS', 'ContractClient', 'contract_client_base', 'EDeliveryIndicator',          'is_edelivery',                   'BOOLEAN',       24, 1, 0, 1, GETUTCDATE()),
  (3034, 'EQ_ODS', 'ContractClient', 'contract_client_base', 'OverrideStatus',              'override_status',                'STRING',        25, 1, 0, 1, GETUTCDATE());

-- ── [O03] ClientRole  (10 cols, IDs 3035-3044) ──────────────────────────────
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  (3035, 'EQ_ODS', 'ClientRole', 'client_role_base', 'ClientRolePK',                   'client_role_id',                    'INT',        1, 0, 1, 1, GETUTCDATE()),
  (3036, 'EQ_ODS', 'ClientRole', 'client_role_base', 'ClientDetailFK',                 'client_detail_id',                  'INT',        2, 1, 0, 1, GETUTCDATE()),
  (3037, 'EQ_ODS', 'ClientRole', 'client_role_base', 'AgentFK',                        'agent_id',                          'INT',        3, 1, 0, 1, GETUTCDATE()),
  (3038, 'EQ_ODS', 'ClientRole', 'client_role_base', 'PreferenceFK',                   'preference_id',                     'INT',        4, 1, 0, 1, GETUTCDATE()),
  (3039, 'EQ_ODS', 'ClientRole', 'client_role_base', 'TaxProfileFK',                   'tax_profile_id',                    'INT',        5, 1, 0, 1, GETUTCDATE()),
  (3040, 'EQ_ODS', 'ClientRole', 'client_role_base', 'RoleTypeCT',                     'role_type_code',                    'STRING',     6, 1, 0, 1, GETUTCDATE()),
  (3041, 'EQ_ODS', 'ClientRole', 'client_role_base', 'NewIssuesEligibilityStatusCT',   'new_issues_eligibility_status_code','STRING',     7, 1, 0, 1, GETUTCDATE()),
  (3042, 'EQ_ODS', 'ClientRole', 'client_role_base', 'NewIssuesEligibilityStartDate',  'new_issues_eligibility_start_date', 'TIMESTAMP',  8, 1, 0, 1, GETUTCDATE()),
  (3043, 'EQ_ODS', 'ClientRole', 'client_role_base', 'ReferenceID',                    'reference_id',                      'STRING',     9, 1, 0, 1, GETUTCDATE()),
  (3044, 'EQ_ODS', 'ClientRole', 'client_role_base', 'OverrideStatus',                 'override_status',                   'STRING',    10, 1, 0, 1, GETUTCDATE());

-- ── [O04] ClientDetail  (26 cols, IDs 3045-3070) ────────────────────────────
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  (3045, 'EQ_ODS', 'ClientDetail', 'client_detail_base', 'ClientDetailPK',           'client_detail_id',              'INT',        1, 0, 1, 1, GETUTCDATE()),
  (3046, 'EQ_ODS', 'ClientDetail', 'client_detail_base', 'ClientIdentification',     'client_identification',         'STRING',     2, 1, 0, 1, GETUTCDATE()),
  (3047, 'EQ_ODS', 'ClientDetail', 'client_detail_base', 'TaxIdentification',        'tax_identification',            'STRING',     3, 1, 0, 1, GETUTCDATE()),
  (3048, 'EQ_ODS', 'ClientDetail', 'client_detail_base', 'LastName',                 'last_name',                     'STRING',     4, 1, 0, 1, GETUTCDATE()),
  (3049, 'EQ_ODS', 'ClientDetail', 'client_detail_base', 'FirstName',                'first_name',                    'STRING',     5, 1, 0, 1, GETUTCDATE()),
  (3050, 'EQ_ODS', 'ClientDetail', 'client_detail_base', 'MiddleName',               'middle_name',                   'STRING',     6, 1, 0, 1, GETUTCDATE()),
  (3051, 'EQ_ODS', 'ClientDetail', 'client_detail_base', 'NamePrefix',               'name_prefix',                   'STRING',     7, 1, 0, 1, GETUTCDATE()),
  (3052, 'EQ_ODS', 'ClientDetail', 'client_detail_base', 'NameSuffix',               'name_suffix',                   'STRING',     8, 1, 0, 1, GETUTCDATE()),
  (3053, 'EQ_ODS', 'ClientDetail', 'client_detail_base', 'CorporateName',            'corporate_name',                'STRING',     9, 1, 0, 1, GETUTCDATE()),
  (3054, 'EQ_ODS', 'ClientDetail', 'client_detail_base', 'BirthDate',                'birth_date',                    'TIMESTAMP', 10, 1, 0, 1, GETUTCDATE()),
  (3055, 'EQ_ODS', 'ClientDetail', 'client_detail_base', 'MothersMaidenName',        'mothers_maiden_name',           'STRING',    11, 1, 0, 1, GETUTCDATE()),
  (3056, 'EQ_ODS', 'ClientDetail', 'client_detail_base', 'Occupation',               'occupation',                    'STRING',    12, 1, 0, 1, GETUTCDATE()),
  (3057, 'EQ_ODS', 'ClientDetail', 'client_detail_base', 'DateOfDeath',              'date_of_death',                 'TIMESTAMP', 13, 1, 0, 1, GETUTCDATE()),
  (3058, 'EQ_ODS', 'ClientDetail', 'client_detail_base', 'Operator',                 'operator',                      'STRING',    14, 1, 0, 1, GETUTCDATE()),
  (3059, 'EQ_ODS', 'ClientDetail', 'client_detail_base', 'MaintDateTime',            'maint_datetime',                'TIMESTAMP', 15, 1, 0, 1, GETUTCDATE()),
  (3060, 'EQ_ODS', 'ClientDetail', 'client_detail_base', 'GenderCT',                 'gender_code',                   'STRING',    16, 1, 0, 1, GETUTCDATE()),
  (3061, 'EQ_ODS', 'ClientDetail', 'client_detail_base', 'TrustTypeCT',              'trust_type_code',               'STRING',    17, 1, 0, 1, GETUTCDATE()),
  (3062, 'EQ_ODS', 'ClientDetail', 'client_detail_base', 'StatusCT',                 'status_code',                   'STRING',    18, 1, 0, 1, GETUTCDATE()),
  (3063, 'EQ_ODS', 'ClientDetail', 'client_detail_base', 'PrivacyInd',               'is_privacy',                    'BOOLEAN',   19, 1, 0, 1, GETUTCDATE()),
  (3064, 'EQ_ODS', 'ClientDetail', 'client_detail_base', 'LastOFACCheckDate',        'last_ofac_check_date',          'TIMESTAMP', 20, 1, 0, 1, GETUTCDATE()),
  (3065, 'EQ_ODS', 'ClientDetail', 'client_detail_base', 'StateOfDeathCT',           'state_of_death_code',           'STRING',    21, 1, 0, 1, GETUTCDATE()),
  (3066, 'EQ_ODS', 'ClientDetail', 'client_detail_base', 'ResidentStateAtDeathCT',   'resident_state_at_death_code',  'STRING',    22, 1, 0, 1, GETUTCDATE()),
  (3067, 'EQ_ODS', 'ClientDetail', 'client_detail_base', 'ProofOfDeathReceivedDate', 'proof_of_death_received_date',  'TIMESTAMP', 23, 1, 0, 1, GETUTCDATE()),
  (3068, 'EQ_ODS', 'ClientDetail', 'client_detail_base', 'CaseTrackingProcess',      'case_tracking_process',         'STRING',    24, 1, 0, 1, GETUTCDATE()),
  (3069, 'EQ_ODS', 'ClientDetail', 'client_detail_base', 'NotificationReceivedDate', 'notification_received_date',    'TIMESTAMP', 25, 1, 0, 1, GETUTCDATE()),
  (3070, 'EQ_ODS', 'ClientDetail', 'client_detail_base', 'OverrideStatus',           'override_status',               'STRING',    26, 1, 0, 1, GETUTCDATE());

-- ── [O05] ContractClientAllocation  (6 cols, IDs 3071-3076) ─────────────────
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  (3071, 'EQ_ODS', 'ContractClientAllocation', 'contract_client_allocation_base', 'ContractClientAllocationPK', 'contract_client_allocation_id', 'INT',            1, 0, 1, 1, GETUTCDATE()),
  (3072, 'EQ_ODS', 'ContractClientAllocation', 'contract_client_allocation_base', 'ContractClientFK',           'contract_client_id',            'INT',            2, 1, 0, 1, GETUTCDATE()),
  (3073, 'EQ_ODS', 'ContractClientAllocation', 'contract_client_allocation_base', 'AllocationPercent',          'allocation_percent',            'DECIMAL(18,4)',  3, 1, 0, 1, GETUTCDATE()),
  (3074, 'EQ_ODS', 'ContractClientAllocation', 'contract_client_allocation_base', 'AllocationDollars',          'allocation_dollars',            'DECIMAL(18,4)',  4, 1, 0, 1, GETUTCDATE()),
  (3075, 'EQ_ODS', 'ContractClientAllocation', 'contract_client_allocation_base', 'SplitEqual',                 'is_split_equal',                'BOOLEAN',        5, 1, 0, 1, GETUTCDATE()),
  (3076, 'EQ_ODS', 'ContractClientAllocation', 'contract_client_allocation_base', 'OverrideStatus',             'override_status',               'STRING',         6, 1, 0, 1, GETUTCDATE());

-- ── [O06] Segment  (73 cols, IDs 3077-3149) ─────────────────────────────────
-- Source for both vw_SEG_ContractPrimarySegment (SegmentFK IS NULL) and
-- vw_SEG_ContractRiderSegment (SegmentFK IS NOT NULL) — same table, different filters.
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  (3077, 'EQ_ODS', 'Segment', 'segment_base', 'SegmentPK',                   'segment_id',                     'INT',            1, 0, 1, 1, GETUTCDATE()),
  (3078, 'EQ_ODS', 'Segment', 'segment_base', 'SegmentFK',                   'parent_segment_id',              'INT',            2, 1, 0, 1, GETUTCDATE()),
  (3079, 'EQ_ODS', 'Segment', 'segment_base', 'ProductStructureFK',          'product_structure_id',           'INT',            3, 1, 0, 1, GETUTCDATE()),
  (3080, 'EQ_ODS', 'Segment', 'segment_base', 'ContractNumber',              'contract_number',                'STRING',         4, 1, 0, 1, GETUTCDATE()),
  (3081, 'EQ_ODS', 'Segment', 'segment_base', 'EffectiveDate',               'effective_date',                 'TIMESTAMP',      5, 1, 0, 1, GETUTCDATE()),
  (3082, 'EQ_ODS', 'Segment', 'segment_base', 'Amount',                      'amount',                         'DECIMAL(18,4)',  6, 1, 0, 1, GETUTCDATE()),
  (3083, 'EQ_ODS', 'Segment', 'segment_base', 'QualNonQualCT',               'qual_non_qual_code',             'STRING',         7, 1, 0, 1, GETUTCDATE()),
  (3084, 'EQ_ODS', 'Segment', 'segment_base', 'ExchangeInd',                 'is_exchange',                    'BOOLEAN',        8, 1, 0, 1, GETUTCDATE()),
  (3085, 'EQ_ODS', 'Segment', 'segment_base', 'CostBasis',                   'cost_basis',                     'DECIMAL(18,4)',  9, 1, 0, 1, GETUTCDATE()),
  (3086, 'EQ_ODS', 'Segment', 'segment_base', 'RecoveredCostBasis',          'recovered_cost_basis',           'DECIMAL(18,4)', 10, 1, 0, 1, GETUTCDATE()),
  (3087, 'EQ_ODS', 'Segment', 'segment_base', 'TerminationDate',             'termination_date',               'TIMESTAMP',     11, 1, 0, 1, GETUTCDATE()),
  (3088, 'EQ_ODS', 'Segment', 'segment_base', 'StatusChangeDate',            'status_change_date',             'TIMESTAMP',     12, 1, 0, 1, GETUTCDATE()),
  (3089, 'EQ_ODS', 'Segment', 'segment_base', 'SegmentNameCT',               'segment_name_code',              'STRING',        13, 1, 0, 1, GETUTCDATE()),
  (3090, 'EQ_ODS', 'Segment', 'segment_base', 'SegmentStatusCT',             'segment_status_code',            'STRING',        14, 1, 0, 1, GETUTCDATE()),
  (3091, 'EQ_ODS', 'Segment', 'segment_base', 'OptionCodeCT',                'option_code',                    'STRING',        15, 1, 0, 1, GETUTCDATE()),
  (3092, 'EQ_ODS', 'Segment', 'segment_base', 'IssueStateCT',                'issue_state_code',               'STRING',        16, 1, 0, 1, GETUTCDATE()),
  (3093, 'EQ_ODS', 'Segment', 'segment_base', 'QualifiedTypeCT',             'qualified_type_code',            'STRING',        17, 1, 0, 1, GETUTCDATE()),
  (3094, 'EQ_ODS', 'Segment', 'segment_base', 'QuoteDate',                   'quote_date',                     'TIMESTAMP',     18, 1, 0, 1, GETUTCDATE()),
  (3095, 'EQ_ODS', 'Segment', 'segment_base', 'Charges',                     'charges',                        'DECIMAL(18,4)', 19, 1, 0, 1, GETUTCDATE()),
  (3096, 'EQ_ODS', 'Segment', 'segment_base', 'Loads',                       'loads',                          'DECIMAL(18,4)', 20, 1, 0, 1, GETUTCDATE()),
  (3097, 'EQ_ODS', 'Segment', 'segment_base', 'Fees',                        'fees',                           'DECIMAL(18,4)', 21, 1, 0, 1, GETUTCDATE()),
  (3098, 'EQ_ODS', 'Segment', 'segment_base', 'TaxReportingGroup',           'tax_reporting_group',            'STRING',        22, 1, 0, 1, GETUTCDATE()),
  (3099, 'EQ_ODS', 'Segment', 'segment_base', 'IssueDate',                   'issue_date',                     'TIMESTAMP',     23, 1, 0, 1, GETUTCDATE()),
  (3100, 'EQ_ODS', 'Segment', 'segment_base', 'CashWithAppInd',              'is_cash_with_app',               'BOOLEAN',       24, 1, 0, 1, GETUTCDATE()),
  (3101, 'EQ_ODS', 'Segment', 'segment_base', 'WaiverInEffect',              'is_waiver_in_effect',            'BOOLEAN',       25, 1, 0, 1, GETUTCDATE()),
  (3102, 'EQ_ODS', 'Segment', 'segment_base', 'FreeAmountRemaining',         'free_amount_remaining',          'DECIMAL(18,4)', 26, 1, 0, 1, GETUTCDATE()),
  (3103, 'EQ_ODS', 'Segment', 'segment_base', 'FreeAmount',                  'free_amount',                    'DECIMAL(18,4)', 27, 1, 0, 1, GETUTCDATE()),
  (3104, 'EQ_ODS', 'Segment', 'segment_base', 'DateInEffect',                'date_in_effect',                 'TIMESTAMP',     28, 1, 0, 1, GETUTCDATE()),
  (3105, 'EQ_ODS', 'Segment', 'segment_base', 'CreationOperator',            'creation_operator',              'STRING',        29, 1, 0, 1, GETUTCDATE()),
  (3106, 'EQ_ODS', 'Segment', 'segment_base', 'CreationDate',                'creation_date',                  'TIMESTAMP',     30, 1, 0, 1, GETUTCDATE()),
  (3107, 'EQ_ODS', 'Segment', 'segment_base', 'LastAnniversaryDate',         'last_anniversary_date',          'TIMESTAMP',     31, 1, 0, 1, GETUTCDATE()),
  (3108, 'EQ_ODS', 'Segment', 'segment_base', 'ApplicationSignedDate',       'application_signed_date',        'TIMESTAMP',     32, 1, 0, 1, GETUTCDATE()),
  (3109, 'EQ_ODS', 'Segment', 'segment_base', 'ApplicationReceivedDate',     'application_received_date',      'TIMESTAMP',     33, 1, 0, 1, GETUTCDATE()),
  (3110, 'EQ_ODS', 'Segment', 'segment_base', 'SavingsPercent',              'savings_percent',                'DECIMAL(18,4)', 34, 1, 0, 1, GETUTCDATE()),
  (3111, 'EQ_ODS', 'Segment', 'segment_base', 'AnnualInsuranceAmount',       'annual_insurance_amount',        'DECIMAL(18,4)', 35, 1, 0, 1, GETUTCDATE()),
  (3112, 'EQ_ODS', 'Segment', 'segment_base', 'AnnualInvestmentAmount',      'annual_investment_amount',       'DECIMAL(18,4)', 36, 1, 0, 1, GETUTCDATE()),
  (3113, 'EQ_ODS', 'Segment', 'segment_base', 'DismembermentPercent',        'dismemberment_percent',          'DECIMAL(18,4)', 37, 1, 0, 1, GETUTCDATE()),
  (3114, 'EQ_ODS', 'Segment', 'segment_base', 'PolicyDeliveryDate',          'policy_delivery_date',           'TIMESTAMP',     38, 1, 0, 1, GETUTCDATE()),
  (3115, 'EQ_ODS', 'Segment', 'segment_base', 'WaiveFreeLookIndicator',      'is_waive_free_look',             'BOOLEAN',       39, 1, 0, 1, GETUTCDATE()),
  (3116, 'EQ_ODS', 'Segment', 'segment_base', 'FreeLookDaysOverride',        'free_look_days_override',        'INT',           40, 1, 0, 1, GETUTCDATE()),
  (3117, 'EQ_ODS', 'Segment', 'segment_base', 'FreeLookEndDate',             'free_look_end_date',             'TIMESTAMP',     41, 1, 0, 1, GETUTCDATE()),
  (3118, 'EQ_ODS', 'Segment', 'segment_base', 'PointInScaleIndicator',       'is_point_in_scale',              'BOOLEAN',       42, 1, 0, 1, GETUTCDATE()),
  (3119, 'EQ_ODS', 'Segment', 'segment_base', 'ChargeDeductDivisionInd',     'is_charge_deduct_division',      'BOOLEAN',       43, 1, 0, 1, GETUTCDATE()),
  (3120, 'EQ_ODS', 'Segment', 'segment_base', 'DialableSalesLoadPercentage', 'dialable_sales_load_percentage', 'DECIMAL(18,4)', 44, 1, 0, 1, GETUTCDATE()),
  (3121, 'EQ_ODS', 'Segment', 'segment_base', 'ChargeDeductAmount',          'charge_deduct_amount',           'DECIMAL(18,4)', 45, 1, 0, 1, GETUTCDATE()),
  (3122, 'EQ_ODS', 'Segment', 'segment_base', 'RiderNumber',                 'rider_number',                   'INT',           46, 1, 0, 1, GETUTCDATE()),
  (3123, 'EQ_ODS', 'Segment', 'segment_base', 'CommitmentIndicator',         'is_commitment',                  'BOOLEAN',       47, 1, 0, 1, GETUTCDATE()),
  (3124, 'EQ_ODS', 'Segment', 'segment_base', 'CommitmentAmount',            'commitment_amount',              'DECIMAL(18,4)', 48, 1, 0, 1, GETUTCDATE()),
  (3125, 'EQ_ODS', 'Segment', 'segment_base', 'ChargeCodeStatus',            'charge_code_status',             'STRING',        49, 1, 0, 1, GETUTCDATE()),
  (3126, 'EQ_ODS', 'Segment', 'segment_base', 'ROTHConvInd',                 'is_roth_conversion',             'BOOLEAN',       50, 1, 0, 1, GETUTCDATE()),
  (3127, 'EQ_ODS', 'Segment', 'segment_base', 'DateOfDeathValue',            'date_of_death_value',            'DECIMAL(18,4)', 51, 1, 0, 1, GETUTCDATE()),
  (3128, 'EQ_ODS', 'Segment', 'segment_base', 'SuppOriginalContractNumber',  'supp_original_contract_number',  'STRING',        52, 1, 0, 1, GETUTCDATE()),
  (3129, 'EQ_ODS', 'Segment', 'segment_base', 'OpenClaimEndDate',            'open_claim_end_date',            'TIMESTAMP',     53, 1, 0, 1, GETUTCDATE()),
  (3130, 'EQ_ODS', 'Segment', 'segment_base', 'AnnuitizationValue',          'annuitization_value',            'DECIMAL(18,4)', 54, 1, 0, 1, GETUTCDATE()),
  (3131, 'EQ_ODS', 'Segment', 'segment_base', 'CasetrackingOptionCT',        'casetracking_option_code',       'STRING',        55, 1, 0, 1, GETUTCDATE()),
  (3132, 'EQ_ODS', 'Segment', 'segment_base', 'PrintLine1',                  'print_line_1',                   'STRING',        56, 1, 0, 1, GETUTCDATE()),
  (3133, 'EQ_ODS', 'Segment', 'segment_base', 'PrintLine2',                  'print_line_2',                   'STRING',        57, 1, 0, 1, GETUTCDATE()),
  (3134, 'EQ_ODS', 'Segment', 'segment_base', 'TotalActiveBeneficiaries',    'total_active_beneficiaries',     'INT',           58, 1, 0, 1, GETUTCDATE()),
  (3135, 'EQ_ODS', 'Segment', 'segment_base', 'RemainingBeneficiaries',      'remaining_beneficiaries',        'INT',           59, 1, 0, 1, GETUTCDATE()),
  (3136, 'EQ_ODS', 'Segment', 'segment_base', 'SettlementAmount',            'settlement_amount',              'DECIMAL(18,4)', 60, 1, 0, 1, GETUTCDATE()),
  (3137, 'EQ_ODS', 'Segment', 'segment_base', 'LastSettlementValDate',       'last_settlement_val_date',       'TIMESTAMP',     61, 1, 0, 1, GETUTCDATE()),
  (3138, 'EQ_ODS', 'Segment', 'segment_base', 'ContractTypeCT',              'contract_type_code',             'STRING',        62, 1, 0, 1, GETUTCDATE()),
  (3139, 'EQ_ODS', 'Segment', 'segment_base', 'TotalFaceAmount',             'total_face_amount',              'DECIMAL(18,4)', 63, 1, 0, 1, GETUTCDATE()),
  (3140, 'EQ_ODS', 'Segment', 'segment_base', 'IncomeStartDate',             'income_start_date',              'TIMESTAMP',     64, 1, 0, 1, GETUTCDATE()),
  (3141, 'EQ_ODS', 'Segment', 'segment_base', 'IncomeStartAge',              'income_start_age',               'INT',           65, 1, 0, 1, GETUTCDATE()),
  (3142, 'EQ_ODS', 'Segment', 'segment_base', 'ExtendedIncomePeriodDate',    'extended_income_period_date',    'TIMESTAMP',     66, 1, 0, 1, GETUTCDATE()),
  (3143, 'EQ_ODS', 'Segment', 'segment_base', 'BenefitBase',                 'benefit_base',                   'DECIMAL(18,4)', 67, 1, 0, 1, GETUTCDATE()),
  (3144, 'EQ_ODS', 'Segment', 'segment_base', 'BenefitBaseLastValDate',      'benefit_base_last_val_date',     'TIMESTAMP',     68, 1, 0, 1, GETUTCDATE()),
  (3145, 'EQ_ODS', 'Segment', 'segment_base', 'IncomeWDAmount',              'income_wd_amount',               'DECIMAL(18,4)', 69, 1, 0, 1, GETUTCDATE()),
  (3146, 'EQ_ODS', 'Segment', 'segment_base', 'RemainingIncomeWDAmount',     'remaining_income_wd_amount',     'DECIMAL(18,4)', 70, 1, 0, 1, GETUTCDATE()),
  (3147, 'EQ_ODS', 'Segment', 'segment_base', 'SysGainAccum',                'sys_gain_accum',                 'DECIMAL(18,4)', 71, 1, 0, 1, GETUTCDATE()),
  (3148, 'EQ_ODS', 'Segment', 'segment_base', 'BillScheduleFK',              'bill_schedule_id',               'INT',           72, 1, 0, 1, GETUTCDATE()),
  (3149, 'EQ_ODS', 'Segment', 'segment_base', 'FirstNotifyDate',             'first_notify_date',              'TIMESTAMP',     73, 1, 0, 1, GETUTCDATE());

-- ── [O07] Agent (ODS)  (18 cols, IDs 3150-3167) ─────────────────────────────
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  (3150, 'EQ_ODS', 'Agent', 'agent_ods_base', 'AgentPK',                      'agent_id',                        'INT',        1, 0, 1, 1, GETUTCDATE()),
  (3151, 'EQ_ODS', 'Agent', 'agent_ods_base', 'CompanyFK',                    'company_id',                      'INT',        2, 1, 0, 1, GETUTCDATE()),
  (3152, 'EQ_ODS', 'Agent', 'agent_ods_base', 'HireDate',                     'hire_date',                       'TIMESTAMP',  3, 1, 0, 1, GETUTCDATE()),
  (3153, 'EQ_ODS', 'Agent', 'agent_ods_base', 'TerminationDate',              'termination_date',                'TIMESTAMP',  4, 1, 0, 1, GETUTCDATE()),
  (3154, 'EQ_ODS', 'Agent', 'agent_ods_base', 'AgentStatusCT',                'agent_status_code',               'STRING',     5, 1, 0, 1, GETUTCDATE()),
  (3155, 'EQ_ODS', 'Agent', 'agent_ods_base', 'AgentTypeCT',                  'agent_type_code',                 'STRING',     6, 1, 0, 1, GETUTCDATE()),
  (3156, 'EQ_ODS', 'Agent', 'agent_ods_base', 'WithholdingStatus',            'withholding_status',              'STRING',     7, 1, 0, 1, GETUTCDATE()),
  (3157, 'EQ_ODS', 'Agent', 'agent_ods_base', 'Department',                   'department',                      'STRING',     8, 1, 0, 1, GETUTCDATE()),
  (3158, 'EQ_ODS', 'Agent', 'agent_ods_base', 'Region',                       'region',                          'STRING',     9, 1, 0, 1, GETUTCDATE()),
  (3159, 'EQ_ODS', 'Agent', 'agent_ods_base', 'Branch',                       'branch',                          'STRING',    10, 1, 0, 1, GETUTCDATE()),
  (3160, 'EQ_ODS', 'Agent', 'agent_ods_base', 'NPN',                          'npn',                             'STRING',    11, 1, 0, 1, GETUTCDATE()),
  (3161, 'EQ_ODS', 'Agent', 'agent_ods_base', 'IntDebitBalStatusCT',          'int_debit_bal_status_code',       'STRING',    12, 1, 0, 1, GETUTCDATE()),
  (3162, 'EQ_ODS', 'Agent', 'agent_ods_base', 'HoldCommStatus',               'hold_comm_status',                'STRING',    13, 1, 0, 1, GETUTCDATE()),
  (3163, 'EQ_ODS', 'Agent', 'agent_ods_base', 'Operator',                     'operator',                        'STRING',    14, 1, 0, 1, GETUTCDATE()),
  (3164, 'EQ_ODS', 'Agent', 'agent_ods_base', 'MaintDateTime',                'maint_datetime',                  'TIMESTAMP', 15, 1, 0, 1, GETUTCDATE()),
  (3165, 'EQ_ODS', 'Agent', 'agent_ods_base', 'DisbursementAddressTypeCT',    'disbursement_address_type_code',  'STRING',    16, 1, 0, 1, GETUTCDATE()),
  (3166, 'EQ_ODS', 'Agent', 'agent_ods_base', 'CorrespondenceAddressTypeCT',  'correspondence_address_type_code','STRING',    17, 1, 0, 1, GETUTCDATE()),
  (3167, 'EQ_ODS', 'Agent', 'agent_ods_base', 'RehireEligibleDate',           'rehire_eligible_date',            'TIMESTAMP', 18, 1, 0, 1, GETUTCDATE());

-- ── [O08] ContractTreaty  (20 cols, IDs 3168-3187) ──────────────────────────
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  (3168, 'EQ_ODS', 'ContractTreaty', 'contract_treaty_base', 'ContractTreatyPK',        'contract_treaty_id',         'INT',            1, 0, 1, 1, GETUTCDATE()),
  (3169, 'EQ_ODS', 'ContractTreaty', 'contract_treaty_base', 'SegmentFK',               'segment_id',                 'INT',            2, 1, 0, 1, GETUTCDATE()),
  (3170, 'EQ_ODS', 'ContractTreaty', 'contract_treaty_base', 'TreatyFK',                'treaty_id',                  'INT',            3, 1, 0, 1, GETUTCDATE()),
  (3171, 'EQ_ODS', 'ContractTreaty', 'contract_treaty_base', 'ReinsuranceIndicatorCT',  'reinsurance_indicator_code', 'STRING',         4, 1, 0, 1, GETUTCDATE()),
  (3172, 'EQ_ODS', 'ContractTreaty', 'contract_treaty_base', 'EffectiveDate',           'effective_date',             'TIMESTAMP',      5, 1, 0, 1, GETUTCDATE()),
  (3173, 'EQ_ODS', 'ContractTreaty', 'contract_treaty_base', 'ReinsuranceClassCT',      'reinsurance_class_code',     'STRING',         6, 1, 0, 1, GETUTCDATE()),
  (3174, 'EQ_ODS', 'ContractTreaty', 'contract_treaty_base', 'RetentionAmount',         'retention_amount',           'DECIMAL(18,4)',  7, 1, 0, 1, GETUTCDATE()),
  (3175, 'EQ_ODS', 'ContractTreaty', 'contract_treaty_base', 'PoolPercentage',          'pool_percentage',            'DECIMAL(18,4)',  8, 1, 0, 1, GETUTCDATE()),
  (3176, 'EQ_ODS', 'ContractTreaty', 'contract_treaty_base', 'ReinsuranceTypeCT',       'reinsurance_type_code',      'STRING',         9, 1, 0, 1, GETUTCDATE()),
  (3177, 'EQ_ODS', 'ContractTreaty', 'contract_treaty_base', 'TableRatingCT',           'table_rating_code',          'STRING',        10, 1, 0, 1, GETUTCDATE()),
  (3178, 'EQ_ODS', 'ContractTreaty', 'contract_treaty_base', 'FlatExtra',               'flat_extra',                 'DECIMAL(18,4)', 11, 1, 0, 1, GETUTCDATE()),
  (3179, 'EQ_ODS', 'ContractTreaty', 'contract_treaty_base', 'FlatExtraAge',            'flat_extra_age',             'INT',           12, 1, 0, 1, GETUTCDATE()),
  (3180, 'EQ_ODS', 'ContractTreaty', 'contract_treaty_base', 'FlatExtraDuration',       'flat_extra_duration',        'INT',           13, 1, 0, 1, GETUTCDATE()),
  (3181, 'EQ_ODS', 'ContractTreaty', 'contract_treaty_base', 'PercentExtra',            'percent_extra',              'DECIMAL(18,4)', 14, 1, 0, 1, GETUTCDATE()),
  (3182, 'EQ_ODS', 'ContractTreaty', 'contract_treaty_base', 'PercentExtraAge',         'percent_extra_age',          'INT',           15, 1, 0, 1, GETUTCDATE()),
  (3183, 'EQ_ODS', 'ContractTreaty', 'contract_treaty_base', 'PercentExtraDuration',    'percent_extra_duration',     'INT',           16, 1, 0, 1, GETUTCDATE()),
  (3184, 'EQ_ODS', 'ContractTreaty', 'contract_treaty_base', 'MaxReinsuranceAmount',    'max_reinsurance_amount',     'DECIMAL(18,4)', 17, 1, 0, 1, GETUTCDATE()),
  (3185, 'EQ_ODS', 'ContractTreaty', 'contract_treaty_base', 'TreatyOverrideInd',       'is_treaty_override',         'BOOLEAN',       18, 1, 0, 1, GETUTCDATE()),
  (3186, 'EQ_ODS', 'ContractTreaty', 'contract_treaty_base', 'PolicyOverrideInd',       'is_policy_override',         'BOOLEAN',       19, 1, 0, 1, GETUTCDATE()),
  (3187, 'EQ_ODS', 'ContractTreaty', 'contract_treaty_base', 'Status',                  'status',                     'STRING',        20, 1, 0, 1, GETUTCDATE());

-- ── [O09] Treaty  (10 cols, IDs 3188-3197) ──────────────────────────────────
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  (3188, 'EQ_ODS', 'Treaty', 'treaty_base', 'TreatyPK',             'treaty_id',              'INT',            1, 0, 1, 1, GETUTCDATE()),
  (3189, 'EQ_ODS', 'Treaty', 'treaty_base', 'TreatyGroupFK',        'treaty_group_id',        'INT',            2, 1, 0, 1, GETUTCDATE()),
  (3190, 'EQ_ODS', 'Treaty', 'treaty_base', 'StartDate',            'start_date',             'TIMESTAMP',      3, 1, 0, 1, GETUTCDATE()),
  (3191, 'EQ_ODS', 'Treaty', 'treaty_base', 'StopDate',             'stop_date',              'TIMESTAMP',      4, 1, 0, 1, GETUTCDATE()),
  (3192, 'EQ_ODS', 'Treaty', 'treaty_base', 'SettlementPeriod',     'settlement_period',      'INT',            5, 1, 0, 1, GETUTCDATE()),
  (3193, 'EQ_ODS', 'Treaty', 'treaty_base', 'PaymentModeCT',        'payment_mode_code',      'STRING',         6, 1, 0, 1, GETUTCDATE()),
  (3194, 'EQ_ODS', 'Treaty', 'treaty_base', 'CalculationModeCT',    'calculation_mode_code',  'STRING',         7, 1, 0, 1, GETUTCDATE()),
  (3195, 'EQ_ODS', 'Treaty', 'treaty_base', 'LastCheckDate',        'last_check_date',        'TIMESTAMP',      8, 1, 0, 1, GETUTCDATE()),
  (3196, 'EQ_ODS', 'Treaty', 'treaty_base', 'ReinsurerBalance',     'reinsurer_balance',      'DECIMAL(18,4)',  9, 1, 0, 1, GETUTCDATE()),
  (3197, 'EQ_ODS', 'Treaty', 'treaty_base', 'CoinsurancePercentage','coinsurance_percentage', 'DECIMAL(18,4)', 10, 1, 0, 1, GETUTCDATE());

-- ── [O10] TreatyGroup  (2 cols, IDs 3198-3199) ──────────────────────────────
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  (3198, 'EQ_ODS', 'TreatyGroup', 'treaty_group_base', 'TreatyGroupPK',     'treaty_group_id',     'INT',    1, 0, 1, 1, GETUTCDATE()),
  (3199, 'EQ_ODS', 'TreatyGroup', 'treaty_group_base', 'TreatyGroupNumber', 'treaty_group_number', 'STRING', 2, 1, 0, 1, GETUTCDATE());

-- ── [O11] EDITTrx  (38 cols, IDs 3200-3237) ─────────────────────────────────
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  (3200, 'EQ_ODS', 'EDITTrx', 'edit_trx_base', 'EDITTrxPK',                    'edit_trx_id',                    'BIGINT',         1, 0, 1, 1, GETUTCDATE()),
  (3201, 'EQ_ODS', 'EDITTrx', 'edit_trx_base', 'ClientSetupFK',                'client_setup_id',                'INT',            2, 1, 0, 1, GETUTCDATE()),
  (3202, 'EQ_ODS', 'EDITTrx', 'edit_trx_base', 'EffectiveDate',                'effective_date',                 'TIMESTAMP',      3, 1, 0, 1, GETUTCDATE()),
  (3203, 'EQ_ODS', 'EDITTrx', 'edit_trx_base', 'Status',                       'status',                         'STRING',         4, 1, 0, 1, GETUTCDATE()),
  (3204, 'EQ_ODS', 'EDITTrx', 'edit_trx_base', 'PendingStatus',                'pending_status',                 'STRING',         5, 1, 0, 1, GETUTCDATE()),
  (3205, 'EQ_ODS', 'EDITTrx', 'edit_trx_base', 'SequenceNumber',               'sequence_number',                'INT',            6, 1, 0, 1, GETUTCDATE()),
  (3206, 'EQ_ODS', 'EDITTrx', 'edit_trx_base', 'TaxYear',                      'tax_year',                       'INT',            7, 1, 0, 1, GETUTCDATE()),
  (3207, 'EQ_ODS', 'EDITTrx', 'edit_trx_base', 'TrxAmount',                    'trx_amount',                     'DECIMAL(18,4)',  8, 1, 0, 1, GETUTCDATE()),
  (3208, 'EQ_ODS', 'EDITTrx', 'edit_trx_base', 'DueDate',                      'due_date',                       'TIMESTAMP',      9, 1, 0, 1, GETUTCDATE()),
  (3209, 'EQ_ODS', 'EDITTrx', 'edit_trx_base', 'TransactionTypeCT',            'transaction_type_code',          'STRING',        10, 1, 0, 1, GETUTCDATE()),
  (3210, 'EQ_ODS', 'EDITTrx', 'edit_trx_base', 'TrxIsRescheduledInd',          'is_trx_rescheduled',             'BOOLEAN',       11, 1, 0, 1, GETUTCDATE()),
  (3211, 'EQ_ODS', 'EDITTrx', 'edit_trx_base', 'ReapplyEDITTrxFK',             'reapply_edit_trx_id',            'BIGINT',        12, 1, 0, 1, GETUTCDATE()),
  (3212, 'EQ_ODS', 'EDITTrx', 'edit_trx_base', 'CommissionStatus',             'commission_status',              'STRING',        13, 1, 0, 1, GETUTCDATE()),
  (3213, 'EQ_ODS', 'EDITTrx', 'edit_trx_base', 'LookBackInd',                  'is_look_back',                   'BOOLEAN',       14, 1, 0, 1, GETUTCDATE()),
  (3214, 'EQ_ODS', 'EDITTrx', 'edit_trx_base', 'OriginatingTrxFK',             'originating_trx_id',             'BIGINT',        15, 1, 0, 1, GETUTCDATE()),
  (3215, 'EQ_ODS', 'EDITTrx', 'edit_trx_base', 'NoCorrespondenceInd',          'is_no_correspondence',           'BOOLEAN',       16, 1, 0, 1, GETUTCDATE()),
  (3216, 'EQ_ODS', 'EDITTrx', 'edit_trx_base', 'NoAccountingInd',              'is_no_accounting',               'BOOLEAN',       17, 1, 0, 1, GETUTCDATE()),
  (3217, 'EQ_ODS', 'EDITTrx', 'edit_trx_base', 'NoCommissionInd',              'is_no_commission',               'BOOLEAN',       18, 1, 0, 1, GETUTCDATE()),
  (3218, 'EQ_ODS', 'EDITTrx', 'edit_trx_base', 'MaintDateTime',                'maint_datetime',                 'TIMESTAMP',     19, 1, 0, 1, GETUTCDATE()),
  (3219, 'EQ_ODS', 'EDITTrx', 'edit_trx_base', 'Operator',                     'operator',                       'STRING',        20, 1, 0, 1, GETUTCDATE()),
  (3220, 'EQ_ODS', 'EDITTrx', 'edit_trx_base', 'NotificationAmount',           'notification_amount',            'DECIMAL(18,4)', 21, 1, 0, 1, GETUTCDATE()),
  (3221, 'EQ_ODS', 'EDITTrx', 'edit_trx_base', 'NotificationAmountReceived',   'notification_amount_received',   'DECIMAL(18,4)', 22, 1, 0, 1, GETUTCDATE()),
  (3222, 'EQ_ODS', 'EDITTrx', 'edit_trx_base', 'TransferTypeCT',               'transfer_type_code',             'STRING',        23, 1, 0, 1, GETUTCDATE()),
  (3223, 'EQ_ODS', 'EDITTrx', 'edit_trx_base', 'AdvanceNotificationOverride',  'advance_notification_override',  'INT',           24, 1, 0, 1, GETUTCDATE()),
  (3224, 'EQ_ODS', 'EDITTrx', 'edit_trx_base', 'AccountingPeriod',             'accounting_period',              'STRING',        25, 1, 0, 1, GETUTCDATE()),
  (3225, 'EQ_ODS', 'EDITTrx', 'edit_trx_base', 'ReinsuranceStatus',            'reinsurance_status',             'STRING',        26, 1, 0, 1, GETUTCDATE()),
  (3226, 'EQ_ODS', 'EDITTrx', 'edit_trx_base', 'BonusCommissionAmount',        'bonus_commission_amount',        'DECIMAL(18,4)', 27, 1, 0, 1, GETUTCDATE()),
  (3227, 'EQ_ODS', 'EDITTrx', 'edit_trx_base', 'ExcessBonusCommissionAmount',  'excess_bonus_commission_amount', 'DECIMAL(18,4)', 28, 1, 0, 1, GETUTCDATE()),
  (3228, 'EQ_ODS', 'EDITTrx', 'edit_trx_base', 'DateContributionExcess',       'date_contribution_excess',       'TIMESTAMP',     29, 1, 0, 1, GETUTCDATE()),
  (3229, 'EQ_ODS', 'EDITTrx', 'edit_trx_base', 'TransferUnitsType',            'transfer_units_type',            'STRING',        30, 1, 0, 1, GETUTCDATE()),
  (3230, 'EQ_ODS', 'EDITTrx', 'edit_trx_base', 'NoCheckEFT',                   'is_no_check_eft',                'BOOLEAN',       31, 1, 0, 1, GETUTCDATE()),
  (3231, 'EQ_ODS', 'EDITTrx', 'edit_trx_base', 'InterestProceedsOverride',     'interest_proceeds_override',     'DECIMAL(18,4)', 32, 1, 0, 1, GETUTCDATE()),
  (3232, 'EQ_ODS', 'EDITTrx', 'edit_trx_base', 'NewPolicyNumber',              'new_policy_number',              'STRING',        33, 1, 0, 1, GETUTCDATE()),
  (3233, 'EQ_ODS', 'EDITTrx', 'edit_trx_base', 'ReversalReasonCodeCT',         'reversal_reason_code',           'STRING',        34, 1, 0, 1, GETUTCDATE()),
  (3234, 'EQ_ODS', 'EDITTrx', 'edit_trx_base', 'CheckAdjustmentFK',            'check_adjustment_id',            'INT',           35, 1, 0, 1, GETUTCDATE()),
  (3235, 'EQ_ODS', 'EDITTrx', 'edit_trx_base', 'TrxPercent',                   'trx_percent',                    'DECIMAL(18,4)', 36, 1, 0, 1, GETUTCDATE()),
  (3236, 'EQ_ODS', 'EDITTrx', 'edit_trx_base', 'OriginalAccountingPeriod',     'original_accounting_period',     'STRING',        37, 1, 0, 1, GETUTCDATE()),
  (3237, 'EQ_ODS', 'EDITTrx', 'edit_trx_base', 'BGA',                          'bga',                            'STRING',        38, 1, 0, 1, GETUTCDATE());

-- ── [O12] ClientSetup  (4 cols, IDs 3238-3241) ──────────────────────────────
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  (3238, 'EQ_ODS', 'ClientSetup', 'client_setup_base', 'ClientSetupPK',      'client_setup_id',      'INT', 1, 0, 1, 1, GETUTCDATE()),
  (3239, 'EQ_ODS', 'ClientSetup', 'client_setup_base', 'ClientRoleFK',       'client_role_id',       'INT', 2, 1, 0, 1, GETUTCDATE()),
  (3240, 'EQ_ODS', 'ClientSetup', 'client_setup_base', 'ContractSetupFK',    'contract_setup_id',    'INT', 3, 1, 0, 1, GETUTCDATE()),
  (3241, 'EQ_ODS', 'ClientSetup', 'client_setup_base', 'ContractClientFK',   'contract_client_id',   'INT', 4, 1, 0, 1, GETUTCDATE());

-- ── [O13] EDITTrxHistory  (13 cols, IDs 3242-3254) ──────────────────────────
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  (3242, 'EQ_ODS', 'EDITTrxHistory', 'edit_trx_history_base', 'EDITTrxHistoryPK',          'edit_trx_history_id',         'BIGINT',    1, 0, 1, 1, GETUTCDATE()),
  (3243, 'EQ_ODS', 'EDITTrxHistory', 'edit_trx_history_base', 'EDITTrxFK',                 'edit_trx_id',                 'BIGINT',    2, 1, 0, 1, GETUTCDATE()),
  (3244, 'EQ_ODS', 'EDITTrxHistory', 'edit_trx_history_base', 'CycleDate',                 'cycle_date',                  'TIMESTAMP', 3, 1, 0, 1, GETUTCDATE()),
  (3245, 'EQ_ODS', 'EDITTrxHistory', 'edit_trx_history_base', 'OriginalProcessDateTime',   'original_process_datetime',   'TIMESTAMP', 4, 1, 0, 1, GETUTCDATE()),
  (3246, 'EQ_ODS', 'EDITTrxHistory', 'edit_trx_history_base', 'AccountingPendingStatus',   'accounting_pending_status',   'STRING',    5, 1, 0, 1, GETUTCDATE()),
  (3247, 'EQ_ODS', 'EDITTrxHistory', 'edit_trx_history_base', 'ControlNumber',             'control_number',              'STRING',    6, 1, 0, 1, GETUTCDATE()),
  (3248, 'EQ_ODS', 'EDITTrxHistory', 'edit_trx_history_base', 'ReleaseDate',               'release_date',                'TIMESTAMP', 7, 1, 0, 1, GETUTCDATE()),
  (3249, 'EQ_ODS', 'EDITTrxHistory', 'edit_trx_history_base', 'ReturnDate',                'return_date',                 'TIMESTAMP', 8, 1, 0, 1, GETUTCDATE()),
  (3250, 'EQ_ODS', 'EDITTrxHistory', 'edit_trx_history_base', 'CorrespondenceTypeCT',      'correspondence_type_code',    'STRING',    9, 1, 0, 1, GETUTCDATE()),
  (3251, 'EQ_ODS', 'EDITTrxHistory', 'edit_trx_history_base', 'ProcessID',                 'process_id',                  'STRING',   10, 1, 0, 1, GETUTCDATE()),
  (3252, 'EQ_ODS', 'EDITTrxHistory', 'edit_trx_history_base', 'RealTimeInd',               'is_real_time',                'BOOLEAN',  11, 1, 0, 1, GETUTCDATE()),
  (3253, 'EQ_ODS', 'EDITTrxHistory', 'edit_trx_history_base', 'AddressTypeCT',             'address_type_code',           'STRING',   12, 1, 0, 1, GETUTCDATE()),
  (3254, 'EQ_ODS', 'EDITTrxHistory', 'edit_trx_history_base', 'ProcessDateTime',           'process_datetime',            'TIMESTAMP',13, 1, 0, 1, GETUTCDATE());

-- ── [O14] FinancialHistory  (27 cols, IDs 3255-3281) ────────────────────────
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  (3255, 'EQ_ODS', 'FinancialHistory', 'financial_history_base', 'FinancialHistoryPK',        'financial_history_id',       'BIGINT',         1, 0, 1, 1, GETUTCDATE()),
  (3256, 'EQ_ODS', 'FinancialHistory', 'financial_history_base', 'EDITTrxHistoryFK',          'edit_trx_history_id',        'BIGINT',         2, 1, 0, 1, GETUTCDATE()),
  (3257, 'EQ_ODS', 'FinancialHistory', 'financial_history_base', 'GrossAmount',               'gross_amount',               'DECIMAL(18,4)',  3, 1, 0, 1, GETUTCDATE()),
  (3258, 'EQ_ODS', 'FinancialHistory', 'financial_history_base', 'NetAmount',                 'net_amount',                 'DECIMAL(18,4)',  4, 1, 0, 1, GETUTCDATE()),
  (3259, 'EQ_ODS', 'FinancialHistory', 'financial_history_base', 'CheckAmount',               'check_amount',               'DECIMAL(18,4)',  5, 1, 0, 1, GETUTCDATE()),
  (3260, 'EQ_ODS', 'FinancialHistory', 'financial_history_base', 'FreeAmount',                'free_amount',                'DECIMAL(18,4)',  6, 1, 0, 1, GETUTCDATE()),
  (3261, 'EQ_ODS', 'FinancialHistory', 'financial_history_base', 'TaxableBenefit',            'taxable_benefit',            'DECIMAL(18,4)',  7, 1, 0, 1, GETUTCDATE()),
  (3262, 'EQ_ODS', 'FinancialHistory', 'financial_history_base', 'DisbursementSourceCT',      'disbursement_source_code',   'STRING',         8, 1, 0, 1, GETUTCDATE()),
  (3263, 'EQ_ODS', 'FinancialHistory', 'financial_history_base', 'Liability',                 'liability',                  'DECIMAL(18,4)',  9, 1, 0, 1, GETUTCDATE()),
  (3264, 'EQ_ODS', 'FinancialHistory', 'financial_history_base', 'CommissionableAmount',      'commissionable_amount',      'DECIMAL(18,4)', 10, 1, 0, 1, GETUTCDATE()),
  (3265, 'EQ_ODS', 'FinancialHistory', 'financial_history_base', 'MaxCommissionAmount',       'max_commission_amount',      'DECIMAL(18,4)', 11, 1, 0, 1, GETUTCDATE()),
  (3266, 'EQ_ODS', 'FinancialHistory', 'financial_history_base', 'CostBasis',                 'cost_basis',                 'DECIMAL(18,4)', 12, 1, 0, 1, GETUTCDATE()),
  (3267, 'EQ_ODS', 'FinancialHistory', 'financial_history_base', 'AccumulatedValue',          'accumulated_value',          'DECIMAL(18,4)', 13, 1, 0, 1, GETUTCDATE()),
  (3268, 'EQ_ODS', 'FinancialHistory', 'financial_history_base', 'SurrenderValue',            'surrender_value',            'DECIMAL(18,4)', 14, 1, 0, 1, GETUTCDATE()),
  (3269, 'EQ_ODS', 'FinancialHistory', 'financial_history_base', 'GuarAccumulatedValue',      'guar_accumulated_value',     'DECIMAL(18,4)', 15, 1, 0, 1, GETUTCDATE()),
  (3270, 'EQ_ODS', 'FinancialHistory', 'financial_history_base', 'PriorDueDate',              'prior_due_date',             'TIMESTAMP',     16, 1, 0, 1, GETUTCDATE()),
  (3271, 'EQ_ODS', 'FinancialHistory', 'financial_history_base', 'PriorExtractDate',          'prior_extract_date',         'TIMESTAMP',     17, 1, 0, 1, GETUTCDATE()),
  (3272, 'EQ_ODS', 'FinancialHistory', 'financial_history_base', 'PriorFixedAmount',          'prior_fixed_amount',         'DECIMAL(18,4)', 18, 1, 0, 1, GETUTCDATE()),
  (3273, 'EQ_ODS', 'FinancialHistory', 'financial_history_base', 'PrevComplexChangeValue',    'prev_complex_change_value',  'DECIMAL(18,4)', 19, 1, 0, 1, GETUTCDATE()),
  (3274, 'EQ_ODS', 'FinancialHistory', 'financial_history_base', 'TaxableIndicator',          'is_taxable',                 'BOOLEAN',       20, 1, 0, 1, GETUTCDATE()),
  (3275, 'EQ_ODS', 'FinancialHistory', 'financial_history_base', 'NetAmountAtRisk',           'net_amount_at_risk',         'DECIMAL(18,4)', 21, 1, 0, 1, GETUTCDATE()),
  (3276, 'EQ_ODS', 'FinancialHistory', 'financial_history_base', 'DistributionCodeCT',        'distribution_code',          'STRING',        22, 1, 0, 1, GETUTCDATE()),
  (3277, 'EQ_ODS', 'FinancialHistory', 'financial_history_base', 'NetIncomeAttributable',     'net_income_attributable',    'DECIMAL(18,4)', 23, 1, 0, 1, GETUTCDATE()),
  (3278, 'EQ_ODS', 'FinancialHistory', 'financial_history_base', 'InterestProceeds',          'interest_proceeds',          'DECIMAL(18,4)', 24, 1, 0, 1, GETUTCDATE()),
  (3279, 'EQ_ODS', 'FinancialHistory', 'financial_history_base', 'PriorInitialCYAccumValue',  'prior_initial_cy_accum_value','DECIMAL(18,4)',25, 1, 0, 1, GETUTCDATE()),
  (3280, 'EQ_ODS', 'FinancialHistory', 'financial_history_base', 'InsuranceInforce',          'insurance_inforce',          'DECIMAL(18,4)', 26, 1, 0, 1, GETUTCDATE()),
  (3281, 'EQ_ODS', 'FinancialHistory', 'financial_history_base', 'SevenPayRate',              'seven_pay_rate',             'DECIMAL(18,4)', 27, 1, 0, 1, GETUTCDATE());

-- ── [O15] ProductStructure (SEG_ENGINE)  (4 cols, IDs 3282-3285) ────────────
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  (3282, 'EQ_ODS', 'ProductStructure', 'product_structure_base', 'ProductStructurePK',    'product_structure_id',    'INT',    1, 0, 1, 1, GETUTCDATE()),
  (3283, 'EQ_ODS', 'ProductStructure', 'product_structure_base', 'MarketingPackageName',  'marketing_package_name',  'STRING', 2, 1, 0, 1, GETUTCDATE()),
  (3284, 'EQ_ODS', 'ProductStructure', 'product_structure_base', 'BusinessContractName',  'business_contract_name',  'STRING', 3, 1, 0, 1, GETUTCDATE()),
  (3285, 'EQ_ODS', 'ProductStructure', 'product_structure_base', 'ProductTypeCT',         'product_type_code',       'STRING', 4, 1, 0, 1, GETUTCDATE());

-- Total EQ_ODS: 285 column mappings across 15 base tables (IDs 3001-3285)


-- ============================================================
-- Raw-landing migration — HubSpot source_column_name updates
-- Changes flat snake_case landing column names → camelCase JSON paths
-- that the v3 bronze notebook reads directly from raw_json.
-- ============================================================

-- [U01] marketing_events
UPDATE schema_config SET source_column_name = 'objectId'          WHERE id = 911;
UPDATE schema_config SET source_column_name = 'externalEventId'   WHERE id = 912;
UPDATE schema_config SET source_column_name = 'eventName'         WHERE id = 913;
UPDATE schema_config SET source_column_name = 'eventType'         WHERE id = 914;
UPDATE schema_config SET source_column_name = 'eventStatus'       WHERE id = 915;
UPDATE schema_config SET source_column_name = 'eventStatusV2'     WHERE id = 916;
UPDATE schema_config SET source_column_name = 'startDateTime'     WHERE id = 917;
UPDATE schema_config SET source_column_name = 'endDateTime'       WHERE id = 918;
UPDATE schema_config SET source_column_name = 'eventOrganizer'    WHERE id = 919;
UPDATE schema_config SET source_column_name = 'eventDescription'  WHERE id = 920;
UPDATE schema_config SET source_column_name = 'eventUrl'          WHERE id = 921;
UPDATE schema_config SET source_column_name = 'eventCancelled'    WHERE id = 922;
UPDATE schema_config SET source_column_name = 'eventCompleted'    WHERE id = 923;
UPDATE schema_config SET source_column_name = 'noShows'           WHERE id = 927;
UPDATE schema_config SET source_column_name = 'appInfo.id'        WHERE id = 928;
UPDATE schema_config SET source_column_name = 'appInfo.name'      WHERE id = 929;
UPDATE schema_config SET source_column_name = 'createdAt'         WHERE id = 930;
UPDATE schema_config SET source_column_name = 'updatedAt'         WHERE id = 931;

-- [U02] marketing_emails base cols
UPDATE schema_config SET source_column_name = 'isAb'                                WHERE id = 941;
UPDATE schema_config SET source_column_name = 'isPublished'                         WHERE id = 942;
UPDATE schema_config SET source_column_name = 'isTransactional'                     WHERE id = 943;
UPDATE schema_config SET source_column_name = 'sendOnPublish'                       WHERE id = 944;
UPDATE schema_config SET source_column_name = 'jitterSendTime'                      WHERE id = 945;
UPDATE schema_config SET source_column_name = 'activeDomain'                        WHERE id = 946;
UPDATE schema_config SET source_column_name = 'campaignName'                        WHERE id = 948;
UPDATE schema_config SET source_column_name = 'campaignUtm'                         WHERE id = 949;
UPDATE schema_config SET source_column_name = 'emailCampaignGroupId'                WHERE id = 950;
UPDATE schema_config SET source_column_name = 'primaryEmailCampaignId'              WHERE id = 951;
UPDATE schema_config SET source_column_name = 'emailTemplateMode'                   WHERE id = 952;
UPDATE schema_config SET source_column_name = 'feedbackSurveyId'                    WHERE id = 953;
UPDATE schema_config SET source_column_name = 'folderId'                            WHERE id = 954;
UPDATE schema_config SET source_column_name = 'businessUnitId'                      WHERE id = 955;
UPDATE schema_config SET source_column_name = 'clonedFrom'                          WHERE id = 956;
UPDATE schema_config SET source_column_name = 'previewKey'                          WHERE id = 957;
UPDATE schema_config SET source_column_name = 'publishDate'                         WHERE id = 958;
UPDATE schema_config SET source_column_name = 'publishedAt'                         WHERE id = 959;
UPDATE schema_config SET source_column_name = 'unpublishedAt'                       WHERE id = 960;
UPDATE schema_config SET source_column_name = 'publishedByEmail'                    WHERE id = 961;
UPDATE schema_config SET source_column_name = 'publishedById'                       WHERE id = 962;
UPDATE schema_config SET source_column_name = 'publishedByName'                     WHERE id = 963;
UPDATE schema_config SET source_column_name = 'createdAt'                           WHERE id = 964;
UPDATE schema_config SET source_column_name = 'createdById'                         WHERE id = 965;
UPDATE schema_config SET source_column_name = 'deletedAt'                           WHERE id = 966;
UPDATE schema_config SET source_column_name = 'updatedAt'                           WHERE id = 967;
UPDATE schema_config SET source_column_name = 'updatedById'                         WHERE id = 968;
UPDATE schema_config SET source_column_name = 'from.fromName'                       WHERE id = 969;
UPDATE schema_config SET source_column_name = 'from.replyTo'                        WHERE id = 970;
UPDATE schema_config SET source_column_name = 'from.customReplyTo'                  WHERE id = 971;
UPDATE schema_config SET source_column_name = 'subscriptionDetails.subscriptionId'  WHERE id = 972;
UPDATE schema_config SET source_column_name = 'subscriptionDetails.subscriptionName' WHERE id = 973;
UPDATE schema_config SET source_column_name = 'subscriptionDetails.officeLocationId' WHERE id = 974;
UPDATE schema_config SET source_column_name = 'subscriptionDetails.preferencesGroupId' WHERE id = 975;
UPDATE schema_config SET source_column_name = 'webversion.url'                      WHERE id = 976;
UPDATE schema_config SET source_column_name = 'webversion.enabled'                  WHERE id = 977;
UPDATE schema_config SET source_column_name = 'content'                             WHERE id = 978;
UPDATE schema_config SET source_column_name = 'stats'                               WHERE id = 979;
UPDATE schema_config SET source_column_name = 'testing'                             WHERE id = 980;
UPDATE schema_config SET source_column_name = 'rssData'                             WHERE id = 981;
UPDATE schema_config SET source_column_name = 'to'                                  WHERE id = 982;
UPDATE schema_config SET source_column_name = 'allEmailCampaignIds'                 WHERE id = 983;
UPDATE schema_config SET source_column_name = 'teamsWithAccess'                     WHERE id = 984;
UPDATE schema_config SET source_column_name = 'workflowNames'                       WHERE id = 985;

-- [U08] crm_owners
UPDATE schema_config SET source_column_name = 'firstName'              WHERE id = 1099;
UPDATE schema_config SET source_column_name = 'lastName'               WHERE id = 1100;
UPDATE schema_config SET source_column_name = 'userId'                 WHERE id = 1102;
UPDATE schema_config SET source_column_name = 'userIdIncludingInactive' WHERE id = 1103;
UPDATE schema_config SET source_column_name = 'createdAt'              WHERE id = 1104;
UPDATE schema_config SET source_column_name = 'updatedAt'              WHERE id = 1105;
UPDATE schema_config SET source_column_name = 'teams'                  WHERE id = 1107;

-- [U09] marketing_emails to_json expansion
UPDATE schema_config SET source_column_name = 'to.contactIds'         WHERE id = 1108;
UPDATE schema_config SET source_column_name = 'to.contactIlsLists'    WHERE id = 1109;
UPDATE schema_config SET source_column_name = 'to.contactLists'       WHERE id = 1110;
UPDATE schema_config SET source_column_name = 'to.limitSendFrequency' WHERE id = 1111;
UPDATE schema_config SET source_column_name = 'to.suppressGraymail'   WHERE id = 1112;

-- [U10] marketing_email_statistics — flat names → JSON paths
UPDATE schema_config SET source_column_name = 'emails.$0'                                   WHERE id = 1113;
UPDATE schema_config SET source_column_name = 'aggregate.counters.sent'                     WHERE id = 1114;
UPDATE schema_config SET source_column_name = 'aggregate.counters.open'                     WHERE id = 1115;
UPDATE schema_config SET source_column_name = 'aggregate.counters.delivered'                WHERE id = 1116;
UPDATE schema_config SET source_column_name = 'aggregate.counters.bounce'                   WHERE id = 1117;
UPDATE schema_config SET source_column_name = 'aggregate.counters.unsubscribed'             WHERE id = 1118;
UPDATE schema_config SET source_column_name = 'aggregate.counters.click'                    WHERE id = 1119;
UPDATE schema_config SET source_column_name = 'aggregate.counters.reply'                    WHERE id = 1120;
UPDATE schema_config SET source_column_name = 'aggregate.counters.dropped'                  WHERE id = 1121;
UPDATE schema_config SET source_column_name = 'aggregate.counters.selected'                 WHERE id = 1122;
UPDATE schema_config SET source_column_name = 'aggregate.counters.spamreport'               WHERE id = 1123;
UPDATE schema_config SET source_column_name = 'aggregate.counters.suppressed'               WHERE id = 1124;
UPDATE schema_config SET source_column_name = 'aggregate.counters.hardbounced'              WHERE id = 1125;
UPDATE schema_config SET source_column_name = 'aggregate.counters.softbounced'              WHERE id = 1126;
UPDATE schema_config SET source_column_name = 'aggregate.counters.pending'                  WHERE id = 1127;
UPDATE schema_config SET source_column_name = 'aggregate.counters.contactslost'             WHERE id = 1128;
UPDATE schema_config SET source_column_name = 'aggregate.counters.notsent'                  WHERE id = 1129;
UPDATE schema_config SET source_column_name = 'aggregate.ratios.clickratio'                 WHERE id = 1130;
UPDATE schema_config SET source_column_name = 'aggregate.ratios.clickthroughratio'          WHERE id = 1131;
UPDATE schema_config SET source_column_name = 'aggregate.ratios.deliveredratio'             WHERE id = 1132;
UPDATE schema_config SET source_column_name = 'aggregate.ratios.openratio'                  WHERE id = 1133;
UPDATE schema_config SET source_column_name = 'aggregate.ratios.replyratio'                 WHERE id = 1134;
UPDATE schema_config SET source_column_name = 'aggregate.ratios.unsubscribedratio'          WHERE id = 1135;
UPDATE schema_config SET source_column_name = 'aggregate.ratios.spamreportratio'            WHERE id = 1136;
UPDATE schema_config SET source_column_name = 'aggregate.ratios.bounceratio'                WHERE id = 1137;
UPDATE schema_config SET source_column_name = 'aggregate.ratios.hardbounceratio'            WHERE id = 1138;
UPDATE schema_config SET source_column_name = 'aggregate.ratios.softbounceratio'            WHERE id = 1139;
UPDATE schema_config SET source_column_name = 'aggregate.ratios.contactslostratio'          WHERE id = 1140;
UPDATE schema_config SET source_column_name = 'aggregate.ratios.pendingratio'               WHERE id = 1141;
UPDATE schema_config SET source_column_name = 'aggregate.ratios.notsentratio'               WHERE id = 1142;
UPDATE schema_config SET source_column_name = 'aggregate.deviceBreakdown'                   WHERE id = 1143;
UPDATE schema_config SET source_column_name = 'aggregate.qualifierStats'                    WHERE id = 1144;
UPDATE schema_config SET source_column_name = 'campaignAggregations.$first_key'             WHERE id = 1145;
UPDATE schema_config SET source_column_name = 'campaignAggregations.$first.counters.sent'        WHERE id = 1146;
UPDATE schema_config SET source_column_name = 'campaignAggregations.$first.counters.open'        WHERE id = 1147;
UPDATE schema_config SET source_column_name = 'campaignAggregations.$first.counters.delivered'   WHERE id = 1148;
UPDATE schema_config SET source_column_name = 'campaignAggregations.$first.counters.bounce'      WHERE id = 1149;
UPDATE schema_config SET source_column_name = 'campaignAggregations.$first.counters.unsubscribed' WHERE id = 1150;
UPDATE schema_config SET source_column_name = 'campaignAggregations.$first.counters.click'       WHERE id = 1151;
UPDATE schema_config SET source_column_name = 'campaignAggregations.$first.counters.reply'       WHERE id = 1152;
UPDATE schema_config SET source_column_name = 'campaignAggregations.$first.counters.dropped'     WHERE id = 1153;
UPDATE schema_config SET source_column_name = 'campaignAggregations.$first.counters.selected'    WHERE id = 1154;
UPDATE schema_config SET source_column_name = 'campaignAggregations.$first.counters.spamreport'  WHERE id = 1155;
UPDATE schema_config SET source_column_name = 'campaignAggregations.$first.counters.suppressed'  WHERE id = 1156;
UPDATE schema_config SET source_column_name = 'campaignAggregations.$first.counters.hardbounced' WHERE id = 1157;
UPDATE schema_config SET source_column_name = 'campaignAggregations.$first.counters.softbounced' WHERE id = 1158;
UPDATE schema_config SET source_column_name = 'campaignAggregations.$first.counters.pending'     WHERE id = 1159;
UPDATE schema_config SET source_column_name = 'campaignAggregations.$first.counters.contactslost' WHERE id = 1160;
UPDATE schema_config SET source_column_name = 'campaignAggregations.$first.counters.notsent'     WHERE id = 1161;
UPDATE schema_config SET source_column_name = 'campaignAggregations.$first.ratios.clickratio'        WHERE id = 1162;
UPDATE schema_config SET source_column_name = 'campaignAggregations.$first.ratios.clickthroughratio' WHERE id = 1163;
UPDATE schema_config SET source_column_name = 'campaignAggregations.$first.ratios.deliveredratio'    WHERE id = 1164;
UPDATE schema_config SET source_column_name = 'campaignAggregations.$first.ratios.openratio'         WHERE id = 1165;
UPDATE schema_config SET source_column_name = 'campaignAggregations.$first.ratios.replyratio'        WHERE id = 1166;
UPDATE schema_config SET source_column_name = 'campaignAggregations.$first.ratios.unsubscribedratio' WHERE id = 1167;
UPDATE schema_config SET source_column_name = 'campaignAggregations.$first.ratios.spamreportratio'   WHERE id = 1168;
UPDATE schema_config SET source_column_name = 'campaignAggregations.$first.ratios.bounceratio'       WHERE id = 1169;
UPDATE schema_config SET source_column_name = 'campaignAggregations.$first.ratios.hardbounceratio'   WHERE id = 1170;
UPDATE schema_config SET source_column_name = 'campaignAggregations.$first.ratios.softbounceratio'   WHERE id = 1171;
UPDATE schema_config SET source_column_name = 'campaignAggregations.$first.ratios.contactslostratio' WHERE id = 1172;
UPDATE schema_config SET source_column_name = 'campaignAggregations.$first.ratios.pendingratio'      WHERE id = 1173;
UPDATE schema_config SET source_column_name = 'campaignAggregations.$first.ratios.notsentratio'      WHERE id = 1174;
UPDATE schema_config SET source_column_name = 'campaignAggregations.$first.deviceBreakdown'          WHERE id = 1175;
UPDATE schema_config SET source_column_name = 'campaignAggregations.$first.qualifierStats'           WHERE id = 1176;


-- ============================================================
-- Missing CRM object tables — IDs 1005-1085
-- 9 tables × 9 cols = 81 rows; all share crm_objects.json schema
-- source_path = 'results' (set in ingestion_config)
-- ============================================================

-- [H06] crm_deals (IDs 1005-1013)
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  (1005, 'HubSpot', 'crm_deals', 'crm_deals_base', 'id',                   'id',                    'STRING',   1, 1, 1, 1, GETUTCDATE()),
  (1006, 'HubSpot', 'crm_deals', 'crm_deals_base', 'createdAt',            'created_at',            'STRING',   2, 1, 0, 1, GETUTCDATE()),
  (1007, 'HubSpot', 'crm_deals', 'crm_deals_base', 'updatedAt',            'updated_at',            'STRING',   3, 1, 0, 1, GETUTCDATE()),
  (1008, 'HubSpot', 'crm_deals', 'crm_deals_base', 'archived',             'archived',              'BOOLEAN',  4, 1, 0, 1, GETUTCDATE()),
  (1009, 'HubSpot', 'crm_deals', 'crm_deals_base', 'archivedAt',           'archived_at',           'STRING',   5, 1, 0, 1, GETUTCDATE()),
  (1010, 'HubSpot', 'crm_deals', 'crm_deals_base', 'objectWriteTraceId',   'object_write_trace_id', 'STRING',   6, 1, 0, 1, GETUTCDATE()),
  (1011, 'HubSpot', 'crm_deals', 'crm_deals_base', 'url',                  'url',                   'STRING',   7, 0, 0, 1, GETUTCDATE()),
  (1012, 'HubSpot', 'crm_deals', 'crm_deals_base', 'properties',           'properties_json',       'STRING',   8, 0, 0, 1, GETUTCDATE()),
  (1013, 'HubSpot', 'crm_deals', 'crm_deals_base', 'N/A',                  'object_type',           'STRING',   9, 0, 0, 1, GETUTCDATE());

-- [H07] crm_tickets (IDs 1014-1022)
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  (1014, 'HubSpot', 'crm_tickets', 'crm_tickets_base', 'id',                   'id',                    'STRING',   1, 1, 1, 1, GETUTCDATE()),
  (1015, 'HubSpot', 'crm_tickets', 'crm_tickets_base', 'createdAt',            'created_at',            'STRING',   2, 1, 0, 1, GETUTCDATE()),
  (1016, 'HubSpot', 'crm_tickets', 'crm_tickets_base', 'updatedAt',            'updated_at',            'STRING',   3, 1, 0, 1, GETUTCDATE()),
  (1017, 'HubSpot', 'crm_tickets', 'crm_tickets_base', 'archived',             'archived',              'BOOLEAN',  4, 1, 0, 1, GETUTCDATE()),
  (1018, 'HubSpot', 'crm_tickets', 'crm_tickets_base', 'archivedAt',           'archived_at',           'STRING',   5, 1, 0, 1, GETUTCDATE()),
  (1019, 'HubSpot', 'crm_tickets', 'crm_tickets_base', 'objectWriteTraceId',   'object_write_trace_id', 'STRING',   6, 1, 0, 1, GETUTCDATE()),
  (1020, 'HubSpot', 'crm_tickets', 'crm_tickets_base', 'url',                  'url',                   'STRING',   7, 0, 0, 1, GETUTCDATE()),
  (1021, 'HubSpot', 'crm_tickets', 'crm_tickets_base', 'properties',           'properties_json',       'STRING',   8, 0, 0, 1, GETUTCDATE()),
  (1022, 'HubSpot', 'crm_tickets', 'crm_tickets_base', 'N/A',                  'object_type',           'STRING',   9, 0, 0, 1, GETUTCDATE());

-- [H08] crm_products (IDs 1023-1031)
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  (1023, 'HubSpot', 'crm_products', 'crm_products_base', 'id',                   'id',                    'STRING',   1, 1, 1, 1, GETUTCDATE()),
  (1024, 'HubSpot', 'crm_products', 'crm_products_base', 'createdAt',            'created_at',            'STRING',   2, 1, 0, 1, GETUTCDATE()),
  (1025, 'HubSpot', 'crm_products', 'crm_products_base', 'updatedAt',            'updated_at',            'STRING',   3, 1, 0, 1, GETUTCDATE()),
  (1026, 'HubSpot', 'crm_products', 'crm_products_base', 'archived',             'archived',              'BOOLEAN',  4, 1, 0, 1, GETUTCDATE()),
  (1027, 'HubSpot', 'crm_products', 'crm_products_base', 'archivedAt',           'archived_at',           'STRING',   5, 1, 0, 1, GETUTCDATE()),
  (1028, 'HubSpot', 'crm_products', 'crm_products_base', 'objectWriteTraceId',   'object_write_trace_id', 'STRING',   6, 1, 0, 1, GETUTCDATE()),
  (1029, 'HubSpot', 'crm_products', 'crm_products_base', 'url',                  'url',                   'STRING',   7, 0, 0, 1, GETUTCDATE()),
  (1030, 'HubSpot', 'crm_products', 'crm_products_base', 'properties',           'properties_json',       'STRING',   8, 0, 0, 1, GETUTCDATE()),
  (1031, 'HubSpot', 'crm_products', 'crm_products_base', 'N/A',                  'object_type',           'STRING',   9, 0, 0, 1, GETUTCDATE());

-- [H09] crm_line_items (IDs 1032-1040)
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  (1032, 'HubSpot', 'crm_line_items', 'crm_line_items_base', 'id',                   'id',                    'STRING',   1, 1, 1, 1, GETUTCDATE()),
  (1033, 'HubSpot', 'crm_line_items', 'crm_line_items_base', 'createdAt',            'created_at',            'STRING',   2, 1, 0, 1, GETUTCDATE()),
  (1034, 'HubSpot', 'crm_line_items', 'crm_line_items_base', 'updatedAt',            'updated_at',            'STRING',   3, 1, 0, 1, GETUTCDATE()),
  (1035, 'HubSpot', 'crm_line_items', 'crm_line_items_base', 'archived',             'archived',              'BOOLEAN',  4, 1, 0, 1, GETUTCDATE()),
  (1036, 'HubSpot', 'crm_line_items', 'crm_line_items_base', 'archivedAt',           'archived_at',           'STRING',   5, 1, 0, 1, GETUTCDATE()),
  (1037, 'HubSpot', 'crm_line_items', 'crm_line_items_base', 'objectWriteTraceId',   'object_write_trace_id', 'STRING',   6, 1, 0, 1, GETUTCDATE()),
  (1038, 'HubSpot', 'crm_line_items', 'crm_line_items_base', 'url',                  'url',                   'STRING',   7, 0, 0, 1, GETUTCDATE()),
  (1039, 'HubSpot', 'crm_line_items', 'crm_line_items_base', 'properties',           'properties_json',       'STRING',   8, 0, 0, 1, GETUTCDATE()),
  (1040, 'HubSpot', 'crm_line_items', 'crm_line_items_base', 'N/A',                  'object_type',           'STRING',   9, 0, 0, 1, GETUTCDATE());

-- [H10] crm_quotes (IDs 1041-1049)
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  (1041, 'HubSpot', 'crm_quotes', 'crm_quotes_base', 'id',                   'id',                    'STRING',   1, 1, 1, 1, GETUTCDATE()),
  (1042, 'HubSpot', 'crm_quotes', 'crm_quotes_base', 'createdAt',            'created_at',            'STRING',   2, 1, 0, 1, GETUTCDATE()),
  (1043, 'HubSpot', 'crm_quotes', 'crm_quotes_base', 'updatedAt',            'updated_at',            'STRING',   3, 1, 0, 1, GETUTCDATE()),
  (1044, 'HubSpot', 'crm_quotes', 'crm_quotes_base', 'archived',             'archived',              'BOOLEAN',  4, 1, 0, 1, GETUTCDATE()),
  (1045, 'HubSpot', 'crm_quotes', 'crm_quotes_base', 'archivedAt',           'archived_at',           'STRING',   5, 1, 0, 1, GETUTCDATE()),
  (1046, 'HubSpot', 'crm_quotes', 'crm_quotes_base', 'objectWriteTraceId',   'object_write_trace_id', 'STRING',   6, 1, 0, 1, GETUTCDATE()),
  (1047, 'HubSpot', 'crm_quotes', 'crm_quotes_base', 'url',                  'url',                   'STRING',   7, 0, 0, 1, GETUTCDATE()),
  (1048, 'HubSpot', 'crm_quotes', 'crm_quotes_base', 'properties',           'properties_json',       'STRING',   8, 0, 0, 1, GETUTCDATE()),
  (1049, 'HubSpot', 'crm_quotes', 'crm_quotes_base', 'N/A',                  'object_type',           'STRING',   9, 0, 0, 1, GETUTCDATE());

-- [H11] crm_calls (IDs 1050-1058)
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  (1050, 'HubSpot', 'crm_calls', 'crm_calls_base', 'id',                   'id',                    'STRING',   1, 1, 1, 1, GETUTCDATE()),
  (1051, 'HubSpot', 'crm_calls', 'crm_calls_base', 'createdAt',            'created_at',            'STRING',   2, 1, 0, 1, GETUTCDATE()),
  (1052, 'HubSpot', 'crm_calls', 'crm_calls_base', 'updatedAt',            'updated_at',            'STRING',   3, 1, 0, 1, GETUTCDATE()),
  (1053, 'HubSpot', 'crm_calls', 'crm_calls_base', 'archived',             'archived',              'BOOLEAN',  4, 1, 0, 1, GETUTCDATE()),
  (1054, 'HubSpot', 'crm_calls', 'crm_calls_base', 'archivedAt',           'archived_at',           'STRING',   5, 1, 0, 1, GETUTCDATE()),
  (1055, 'HubSpot', 'crm_calls', 'crm_calls_base', 'objectWriteTraceId',   'object_write_trace_id', 'STRING',   6, 1, 0, 1, GETUTCDATE()),
  (1056, 'HubSpot', 'crm_calls', 'crm_calls_base', 'url',                  'url',                   'STRING',   7, 0, 0, 1, GETUTCDATE()),
  (1057, 'HubSpot', 'crm_calls', 'crm_calls_base', 'properties',           'properties_json',       'STRING',   8, 0, 0, 1, GETUTCDATE()),
  (1058, 'HubSpot', 'crm_calls', 'crm_calls_base', 'N/A',                  'object_type',           'STRING',   9, 0, 0, 1, GETUTCDATE());

-- [H12] crm_meetings (IDs 1059-1067)
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  (1059, 'HubSpot', 'crm_meetings', 'crm_meetings_base', 'id',                   'id',                    'STRING',   1, 1, 1, 1, GETUTCDATE()),
  (1060, 'HubSpot', 'crm_meetings', 'crm_meetings_base', 'createdAt',            'created_at',            'STRING',   2, 1, 0, 1, GETUTCDATE()),
  (1061, 'HubSpot', 'crm_meetings', 'crm_meetings_base', 'updatedAt',            'updated_at',            'STRING',   3, 1, 0, 1, GETUTCDATE()),
  (1062, 'HubSpot', 'crm_meetings', 'crm_meetings_base', 'archived',             'archived',              'BOOLEAN',  4, 1, 0, 1, GETUTCDATE()),
  (1063, 'HubSpot', 'crm_meetings', 'crm_meetings_base', 'archivedAt',           'archived_at',           'STRING',   5, 1, 0, 1, GETUTCDATE()),
  (1064, 'HubSpot', 'crm_meetings', 'crm_meetings_base', 'objectWriteTraceId',   'object_write_trace_id', 'STRING',   6, 1, 0, 1, GETUTCDATE()),
  (1065, 'HubSpot', 'crm_meetings', 'crm_meetings_base', 'url',                  'url',                   'STRING',   7, 0, 0, 1, GETUTCDATE()),
  (1066, 'HubSpot', 'crm_meetings', 'crm_meetings_base', 'properties',           'properties_json',       'STRING',   8, 0, 0, 1, GETUTCDATE()),
  (1067, 'HubSpot', 'crm_meetings', 'crm_meetings_base', 'N/A',                  'object_type',           'STRING',   9, 0, 0, 1, GETUTCDATE());

-- [H13] crm_notes (IDs 1068-1076)
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  (1068, 'HubSpot', 'crm_notes', 'crm_notes_base', 'id',                   'id',                    'STRING',   1, 1, 1, 1, GETUTCDATE()),
  (1069, 'HubSpot', 'crm_notes', 'crm_notes_base', 'createdAt',            'created_at',            'STRING',   2, 1, 0, 1, GETUTCDATE()),
  (1070, 'HubSpot', 'crm_notes', 'crm_notes_base', 'updatedAt',            'updated_at',            'STRING',   3, 1, 0, 1, GETUTCDATE()),
  (1071, 'HubSpot', 'crm_notes', 'crm_notes_base', 'archived',             'archived',              'BOOLEAN',  4, 1, 0, 1, GETUTCDATE()),
  (1072, 'HubSpot', 'crm_notes', 'crm_notes_base', 'archivedAt',           'archived_at',           'STRING',   5, 1, 0, 1, GETUTCDATE()),
  (1073, 'HubSpot', 'crm_notes', 'crm_notes_base', 'objectWriteTraceId',   'object_write_trace_id', 'STRING',   6, 1, 0, 1, GETUTCDATE()),
  (1074, 'HubSpot', 'crm_notes', 'crm_notes_base', 'url',                  'url',                   'STRING',   7, 0, 0, 1, GETUTCDATE()),
  (1075, 'HubSpot', 'crm_notes', 'crm_notes_base', 'properties',           'properties_json',       'STRING',   8, 0, 0, 1, GETUTCDATE()),
  (1076, 'HubSpot', 'crm_notes', 'crm_notes_base', 'N/A',                  'object_type',           'STRING',   9, 0, 0, 1, GETUTCDATE());

-- [H14] crm_tasks (IDs 1077-1085)
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  (1077, 'HubSpot', 'crm_tasks', 'crm_tasks_base', 'id',                   'id',                    'STRING',   1, 1, 1, 1, GETUTCDATE()),
  (1078, 'HubSpot', 'crm_tasks', 'crm_tasks_base', 'createdAt',            'created_at',            'STRING',   2, 1, 0, 1, GETUTCDATE()),
  (1079, 'HubSpot', 'crm_tasks', 'crm_tasks_base', 'updatedAt',            'updated_at',            'STRING',   3, 1, 0, 1, GETUTCDATE()),
  (1080, 'HubSpot', 'crm_tasks', 'crm_tasks_base', 'archived',             'archived',              'BOOLEAN',  4, 1, 0, 1, GETUTCDATE()),
  (1081, 'HubSpot', 'crm_tasks', 'crm_tasks_base', 'archivedAt',           'archived_at',           'STRING',   5, 1, 0, 1, GETUTCDATE()),
  (1082, 'HubSpot', 'crm_tasks', 'crm_tasks_base', 'objectWriteTraceId',   'object_write_trace_id', 'STRING',   6, 1, 0, 1, GETUTCDATE()),
  (1083, 'HubSpot', 'crm_tasks', 'crm_tasks_base', 'url',                  'url',                   'STRING',   7, 0, 0, 1, GETUTCDATE()),
  (1084, 'HubSpot', 'crm_tasks', 'crm_tasks_base', 'properties',           'properties_json',       'STRING',   8, 0, 0, 1, GETUTCDATE()),
  (1085, 'HubSpot', 'crm_tasks', 'crm_tasks_base', 'N/A',                  'object_type',           'STRING',   9, 0, 0, 1, GETUTCDATE());


-- ============================================================
-- ── Auto-assigned IDs for new sources (Webex) ────────────────────────────
SET IDENTITY_INSERT dbo.schema_config OFF;
GO

-- Webex source — schema_config seed data
-- source_name = 'Webex'  (IDs auto-assigned by IDENTITY)
-- source_column_name = camelCase JSON path within each result record
-- context fields use __top__.<key> to pull from the top-level envelope
-- include_in_md5hash: 0 for JSON blobs and context fields, 1 for data scalars
-- ============================================================

-- [W01] agent_activity — 13 data fields + 4 context
INSERT INTO schema_config
    (source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  ('Webex', 'agent_activity', 'agent_activity_base', 'agentId',                       'agent_id',                       'STRING',  1, 1, 1, 1, GETUTCDATE()),
  ('Webex', 'agent_activity', 'agent_activity_base', 'agentName',                     'agent_name',                     'STRING',  2, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_activity', 'agent_activity_base', 'agentSessionId',                'agent_session_id',               'STRING',  3, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_activity', 'agent_activity_base', 'siteId',                        'site_id',                        'STRING',  4, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_activity', 'agent_activity_base', 'siteName',                      'site_name',                      'STRING',  5, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_activity', 'agent_activity_base', 'teamId',                        'team_id',                        'STRING',  6, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_activity', 'agent_activity_base', 'teamName',                      'team_name',                      'STRING',  7, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_activity', 'agent_activity_base', 'userLoginId',                   'user_login_id',                  'STRING',  8, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_activity', 'agent_activity_base', 'channelInfo.$0.channelId',      'channel_info_channel_id',        'STRING',  9, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_activity', 'agent_activity_base', 'channelInfo.$0.channelType',    'channel_info_channel_type',      'STRING', 10, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_activity', 'agent_activity_base', 'channelInfo.$0.subChannelType', 'channel_info_sub_channel_type',  'STRING', 11, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_activity', 'agent_activity_base', 'channelInfo.$0.agentPhoneNumber','channel_info_agent_phone_number','STRING', 12, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_activity', 'agent_activity_base', 'channelInfo.$0.activities',     'channel_info_activities_json',   'STRING', 13, 0, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_activity', 'agent_activity_base', 'N/A',                           'start_date',                     'STRING', 14, 0, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_activity', 'agent_activity_base', 'N/A',                           'end_date',                       'STRING', 15, 0, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_activity', 'agent_activity_base', 'N/A',                           'record_type',                    'STRING', 16, 0, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_activity', 'agent_activity_base', 'N/A',                           'source',                         'STRING', 17, 0, 0, 1, GETUTCDATE());

-- [W02] agent_session — 113 data fields + 4 context
INSERT INTO schema_config
    (source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  ('Webex', 'agent_session', 'agent_session_base', 'agentId',                                              'agent_id',                                        'STRING',   1, 1, 1, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'agentName',                                            'agent_name',                                      'STRING',   2, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'agentSessionId',                                       'agent_session_id',                                'STRING',   3, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'agentSignOutReason',                                   'agent_sign_out_reason',                           'STRING',   4, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'endTime',                                              'end_time',                                        'BIGINT',   5, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'isActive',                                             'is_active',                                       'BOOLEAN',  6, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'multiMediaProfileType',                                'multi_media_profile_type',                        'STRING',   7, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'orgId',                                                'org_id',                                          'STRING',   8, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'orgName',                                              'org_name',                                        'STRING',   9, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'parentOrgId',                                          'parent_org_id',                                   'STRING',  10, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'parentOrgName',                                        'parent_org_name',                                 'STRING',  11, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'siteId',                                               'site_id',                                         'STRING',  12, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'siteName',                                             'site_name',                                       'STRING',  13, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'skillsProfile',                                        'skills_profile',                                  'STRING',  14, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'startTime',                                            'start_time',                                      'BIGINT',  15, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'state',                                                'state',                                           'STRING',  16, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'teamId',                                               'team_id',                                         'STRING',  17, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'teamName',                                             'team_name',                                       'STRING',  18, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'userLoginId',                                          'user_login_id',                                   'STRING',  19, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'agentSkills.$0.name',                                  'agent_skill_name',                                'STRING',  20, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'agentSkills.$0.intVal',                                'agent_skill_value',                               'INT',     21, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.agentPhoneNumber',                      'channel_agent_phone_number',                      'STRING',  22, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.channelId',                             'channel_id',                                      'STRING',  23, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.channelType',                           'channel_type',                                    'STRING',  24, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.subChannelType',                        'channel_sub_type',                                'STRING',  25, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.currentState',                          'channel_current_state',                           'STRING',  26, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.idleCodeName',                          'channel_idle_code_name',                          'STRING',  27, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.lastActivityTime',                      'channel_last_activity_time',                      'BIGINT',  28, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.totalDuration',                         'channel_total_duration',                          'INT',     29, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.totalReservationTime',                  'channel_total_reservation_time',                  'INT',     30, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.availableCount',                        'channel_available_count',                         'INT',     31, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.availableDuration',                     'channel_available_duration',                      'INT',     32, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.idleCount',                             'channel_idle_count',                              'INT',     33, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.idleDuration',                          'channel_idle_duration',                           'INT',     34, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.reservationCount',                      'channel_reservation_count',                       'INT',     35, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.connectedCount',                        'channel_connected_count',                         'INT',     36, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.connectedDuration',                     'channel_connected_duration',                      'INT',     37, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.ringingCount',                          'channel_ringing_count',                           'INT',     38, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.ringingDuration',                       'channel_ringing_duration',                        'INT',     39, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.holdCount',                             'channel_hold_count',                              'INT',     40, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.holdDuration',                          'channel_hold_duration',                           'INT',     41, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.wrapupCount',                           'channel_wrapup_count',                            'INT',     42, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.wrapupDuration',                        'channel_wrapup_duration',                         'INT',     43, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.postCallCount',                         'channel_post_call_count',                         'INT',     44, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.postCallDuration',                      'channel_post_call_duration',                      'INT',     45, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.postCallAssistanceCount',               'channel_post_call_assistance_count',              'INT',     46, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.postCallAssistanceDuration',            'channel_post_call_assistance_duration',           'INT',     47, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.notRespondedCount',                     'channel_not_responded_count',                     'INT',     48, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.notRespondedDuration',                  'channel_not_responded_duration',                  'INT',     49, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.manualAssignCount',                     'channel_manual_assign_count',                     'INT',     50, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.blindTransferCount',                    'channel_blind_transfer_count',                    'INT',     51, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.callBackCount',                         'channel_call_back_count',                         'INT',     52, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.transferCount',                         'channel_transfer_count',                          'INT',     53, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.conferenceCount',                       'channel_conference_count',                        'INT',     54, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.conferenceDuration',                    'channel_conference_duration',                     'INT',     55, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.conferenceTransferInCount',             'channel_conference_transfer_in_count',            'INT',     56, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.consultCount',                          'channel_consult_count',                           'INT',     57, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.consultDuration',                       'channel_consult_duration',                        'INT',     58, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.consultRequestCount',                   'channel_consult_request_count',                   'INT',     59, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.consultRequestDuration',                'channel_consult_request_duration',                'INT',     60, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.consultAnswerCount',                    'channel_consult_answer_count',                    'INT',     61, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.consultAnswerDuration',                 'channel_consult_answer_duration',                 'INT',     62, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.consultTransferInCount',                'channel_consult_transfer_in_count',               'INT',     63, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.consultToQueueCount',                   'channel_consult_to_queue_count',                  'INT',     64, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.consultToQueueDuration',                'channel_consult_to_queue_duration',               'INT',     65, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.consultToQueueRequestCount',            'channel_consult_to_queue_request_count',          'INT',     66, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.consultToQueueRequestDuration',         'channel_consult_to_queue_request_duration',       'INT',     67, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.consultToQueueAnswerCount',             'channel_consult_to_queue_answer_count',           'INT',     68, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.consultToQueueAnswerDuration',          'channel_consult_to_queue_answer_duration',        'INT',     69, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.consultToEpRequestedCount',             'channel_consult_to_ep_requested_count',           'INT',     70, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.consultToEpRequestedDuration',          'channel_consult_to_ep_requested_duration',        'INT',     71, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.consultToEpAnsweredCount',              'channel_consult_to_ep_answered_count',            'INT',     72, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.consultToEpAnsweredDuration',           'channel_consult_to_ep_answered_duration',         'INT',     73, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.disconnectedCount',                     'channel_disconnected_count',                      'INT',     74, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.disconnectedHoldCallsCount',            'channel_disconnected_hold_calls_count',           'INT',     75, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.agentToAgentTransferCount',             'channel_agent_to_agent_transfer_count',           'INT',     76, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.agentTransferToQueueRequestCount',      'channel_agent_transfer_to_queue_request_count',   'INT',     77, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.outdialCount',                          'channel_outdial_count',                           'INT',     78, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.outdialConnectedCount',                 'channel_outdial_connected_count',                 'INT',     79, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.outdialConnectedDuration',              'channel_outdial_connected_duration',              'INT',     80, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.outdialHoldCount',                      'channel_outdial_hold_count',                      'INT',     81, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.outdialHoldDuration',                   'channel_outdial_hold_duration',                   'INT',     82, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.outdialWrapupCount',                    'channel_outdial_wrapup_count',                    'INT',     83, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.outdialWrapupDuration',                 'channel_outdial_wrapup_duration',                 'INT',     84, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.outdialRingingCount',                   'channel_outdial_ringing_count',                   'INT',     85, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.outdialRingingDuration',                'channel_outdial_ringing_duration',                'INT',     86, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.outdialNotRespondedCount',              'channel_outdial_not_responded_count',             'INT',     87, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.outdialNotRespondedDuration',           'channel_outdial_not_responded_duration',          'INT',     88, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.outdialBlindTransferCount',             'channel_outdial_blind_transfer_count',            'INT',     89, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.outdialTransferCount',                  'channel_outdial_transfer_count',                  'INT',     90, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.outdialConferenceCount',                'channel_outdial_conference_count',                'INT',     91, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.outdialConferenceDuration',             'channel_outdial_conference_duration',             'INT',     92, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.outdialPostCallCount',                  'channel_outdial_post_call_count',                 'INT',     93, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.outdialPostCallDuration',               'channel_outdial_post_call_duration',              'INT',     94, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.outdialPostCallAssistanceCount',        'channel_outdial_post_call_assistance_count',      'INT',     95, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.outdialPostCallAssistanceDuration',     'channel_outdial_post_call_assistance_duration',   'INT',     96, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.outdialConsultCount',                   'channel_outdial_consult_count',                   'INT',     97, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.outdialConsultDuration',                'channel_outdial_consult_duration',                'INT',     98, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.outdialConsultRequestCount',            'channel_outdial_consult_request_count',           'INT',     99, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.outdialConsultRequestDuration',         'channel_outdial_consult_request_duration',        'INT',    100, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.outdialConsultAnswerCount',             'channel_outdial_consult_answer_count',            'INT',    101, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.outdialConsultAnswerDuration',          'channel_outdial_consult_answer_duration',         'INT',    102, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.outdialConsultToQueueCount',            'channel_outdial_consult_to_queue_count',          'INT',    103, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.outdialConsultToQueueDuration',         'channel_outdial_consult_to_queue_duration',       'INT',    104, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.outdialConsultToQueueRequestCount',     'channel_outdial_consult_to_queue_request_count',  'INT',    105, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.outdialConsultToQueueRequestDuration',  'channel_outdial_consult_to_queue_request_duration','INT',   106, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.outdialConsultToEpRequestedCount',      'channel_outdial_consult_to_ep_requested_count',   'INT',    107, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.outdialConsultToEpRequestedDuration',   'channel_outdial_consult_to_ep_requested_duration','INT',    108, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.outdialConsultToEpAnsweredCount',       'channel_outdial_consult_to_ep_answered_count',    'INT',    109, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.outdialConsultToEpAnsweredDuration',    'channel_outdial_consult_to_ep_answered_duration', 'INT',    110, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.outdialConsultTransferDuration',        'channel_outdial_consult_transfer_duration',       'INT',    111, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.outdialAgentToAgentTransferCount',      'channel_outdial_agent_to_agent_transfer_count',   'INT',    112, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'channelInfo.$0.outdialAgentTransferToQueueRequestCount','channel_outdial_agent_transfer_to_queue_request_count','INT',113, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'N/A',                                                  'start_date',                                      'STRING', 114, 0, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'N/A',                                                  'end_date',                                        'STRING', 115, 0, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'N/A',                                                  'record_type',                                     'STRING', 116, 0, 0, 1, GETUTCDATE()),
  ('Webex', 'agent_session', 'agent_session_base', 'N/A',                                                  'source',                                          'STRING', 117, 0, 0, 1, GETUTCDATE());

-- [W03] call_leg — 117 data fields + 4 context
INSERT INTO schema_config
    (source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  ('Webex', 'call_leg', 'call_leg_base', 'id',                              'id',                                 'STRING',   1, 1, 1, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'taskId',                          'task_id',                            'STRING',   2, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'callLegType',                     'call_leg_type',                      'STRING',   3, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'channelType',                     'channel_type',                       'STRING',   4, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'channelSubType',                  'channel_sub_type',                   'STRING',   5, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'direction',                       'direction',                          'STRING',   6, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'origin',                          'origin',                             'STRING',   7, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'destination',                     'destination',                        'STRING',   8, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'contactState',                    'contact_state',                      'STRING',   9, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'status',                          'status',                             'STRING',  10, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'createdTime',                     'created_time',                       'BIGINT',  11, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'endedTime',                       'ended_time',                         'BIGINT',  12, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'lastActivityTime',                'last_activity_time',                 'BIGINT',  13, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'handleTime',                      'handle_time',                        'INT',     14, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'handleType',                      'handle_type',                        'STRING',  15, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'isActive',                        'is_active',                          'BOOLEAN', 16, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'isOutdial',                       'is_outdial',                         'BOOLEAN', 17, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'isOptOutOfQueue',                 'is_opt_out_of_queue',                'BOOLEAN', 18, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'isTaskLegHandled',                'is_task_leg_handled',                'BOOLEAN', 19, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'isWithinServiceLevel',            'is_within_service_level',            'BOOLEAN', 20, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'isHandledByPreferredAgent',       'is_handled_by_preferred_agent',      'BOOLEAN', 21, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'customer.email',                  'customer_email',                     'STRING',  22, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'customer.name',                   'customer_name',                      'STRING',  23, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'customer.phoneNumber',            'customer_phone_number',              'STRING',  24, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'entryPoint.id',                   'entry_point_id',                     'STRING',  25, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'entryPoint.name',                 'entry_point_name',                   'STRING',  26, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'owner.id',                        'owner_id',                           'STRING',  27, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'owner.name',                      'owner_name',                         'STRING',  28, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'owner.channelId',                 'owner_channel_id',                   'STRING',  29, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'owner.phoneNumber',               'owner_phone_number',                 'STRING',  30, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'owner.sessionId',                 'owner_session_id',                   'STRING',  31, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'owner.signInId',                  'owner_sign_in_id',                   'STRING',  32, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'queue.id',                        'queue_id',                           'STRING',  33, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'queue.name',                      'queue_name',                         'STRING',  34, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'queue.duration',                  'queue_duration',                     'INT',     35, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'site.id',                         'site_id',                            'STRING',  36, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'site.name',                       'site_name',                          'STRING',  37, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'team.id',                         'team_id',                            'STRING',  38, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'team.name',                       'team_name',                          'STRING',  39, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'nextDestination.agent',           'next_destination_agent',             'STRING',  40, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'nextDestination.queue',           'next_destination_queue',             'STRING',  41, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'nextDestination.team',            'next_destination_team',              'STRING',  42, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'queueCount',                      'queue_count',                        'INT',     43, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'queuedTo',                        'queued_to',                          'STRING',  44, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'optOutOfQueueTimestamp',          'opt_out_of_queue_timestamp',         'BIGINT',  45, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'holdCount',                       'hold_count',                         'INT',     46, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'holdDuration',                    'hold_duration',                      'INT',     47, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'connectedCount',                  'connected_count',                    'INT',     48, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'connectedDuration',               'connected_duration',                 'INT',     49, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'ringingDuration',                 'ringing_duration',                   'INT',     50, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'wrapupDuration',                  'wrapup_duration',                    'INT',     51, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'selfserviceCount',                'selfservice_count',                  'INT',     52, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'selfserviceDuration',             'selfservice_duration',               'INT',     53, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'consultDuration',                 'consult_duration',                   'INT',     54, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'consultSuccessCount',             'consult_success_count',              'INT',     55, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'consultToAgentErrorCount',        'consult_to_agent_error_count',       'INT',     56, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'consultToDnErrorCount',           'consult_to_dn_error_count',          'INT',     57, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'consultToEPCount',                'consult_to_ep_count',                'INT',     58, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'consultToEPDuration',             'consult_to_ep_duration',             'INT',     59, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'consultToEpErrorCount',           'consult_to_ep_error_count',          'INT',     60, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'consultToQueueCount',             'consult_to_queue_count',             'INT',     61, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'consultToQueueDuration',          'consult_to_queue_duration',          'INT',     62, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'consultToQueueErrorCount',        'consult_to_queue_error_count',       'INT',     63, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'consultToQueueHandledCount',      'consult_to_queue_handled_count',     'INT',     64, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'conferenceDuration',              'conference_duration',                'INT',     65, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'conferenceSuccessCount',          'conference_success_count',           'INT',     66, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'conferenceConnectedCount',        'conference_connected_count',         'STRING',  67, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'connectErrorCount',               'connect_error_count',                'INT',     68, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'transferCount',                   'transfer_count',                     'INT',     69, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'transferOutCount',                'transfer_out_count',                 'INT',     70, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'transferErrorCount',              'transfer_error_count',               'INT',     71, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'transferEpDN',                    'transfer_ep_dn',                     'STRING',  72, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'blindTransferCount',              'blind_transfer_count',               'INT',     73, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'blindTransferToAgentCount',       'blind_transfer_to_agent_count',      'INT',     74, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'agentToDnTransferCount',          'agent_to_dn_transfer_count',         'INT',     75, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'agentTransferedInCount',          'agent_transfered_in_count',          'INT',     76, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'interQueueBlindTransferCount',    'inter_queue_blind_transfer_count',   'INT',     77, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'interQueueConsultTransferCount',  'inter_queue_consult_transfer_count', 'INT',     78, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'outdialConferenceCount',          'outdial_conference_count',           'INT',     79, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'outdialConferenceDuration',       'outdial_conference_duration',        'INT',     80, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'outdialConsultCount',             'outdial_consult_count',              'INT',     81, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'outdialConsultDuration',          'outdial_consult_duration',           'INT',     82, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'outdialConsultToEPCount',         'outdial_consult_to_ep_count',        'INT',     83, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'outdialConsultToEPDuration',      'outdial_consult_to_ep_duration',     'INT',     84, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'outdialConsultToQueueCount',      'outdial_consult_to_queue_count',     'INT',     85, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'outdialConsultToQueueDuration',   'outdial_consult_to_queue_duration',  'INT',     86, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'outdialConsultToQueueErrorCount', 'outdial_consult_to_queue_error_count','INT',    87, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'outdialConsultToQueueHandledCount','outdial_consult_to_queue_handled_count','INT', 88, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'postCallConnectedCount',          'post_call_connected_count',          'STRING',  89, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'postCallConsultDuration',         'post_call_consult_duration',         'INT',     90, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'postCallDuration',                'post_call_duration',                 'INT',     91, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'ronaCount',                       'rona_count',                         'INT',     92, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'callRejectedCount',               'call_rejected_count',                'INT',     93, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'callType',                        'call_type',                          'STRING',  94, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'abandonedSlCount',                'abandoned_sl_count',                 'STRING',  95, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'abandonedType',                   'abandoned_type',                     'STRING',  96, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'slaValue',                        'sla_value',                          'STRING',  97, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'routingType',                     'routing_type',                       'STRING',  98, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'skillsAssignedIn',                'skills_assigned_in',                 'STRING',  99, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'matchedSkills',                   'matched_skills',                     'STRING', 100, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'matchedSkillsProfile',            'matched_skills_profile',             'STRING', 101, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'requiredSkills',                  'required_skills',                    'STRING', 102, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'preferredAgentName',              'preferred_agent_name',               'STRING', 103, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'preferredAgentSystemId',          'preferred_agent_system_id',          'STRING', 104, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'childContactId',                  'child_contact_id',                   'STRING', 105, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'childContactType',                'child_contact_type',                 'STRING', 106, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'consultEpId',                     'consult_ep_id',                      'STRING', 107, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'consultEpName',                   'consult_ep_name',                    'STRING', 108, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'taskLegCount',                    'task_leg_count',                     'INT',    109, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'manualAssignCount',               'manual_assign_count',                'INT',    110, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'ivrScriptId',                     'ivr_script_id',                      'STRING', 111, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'ivrScriptName',                   'ivr_script_name',                    'STRING', 112, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'ivrScriptTagId',                  'ivr_script_tag_id',                  'STRING', 113, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'ivrScriptTagName',                'ivr_script_tag_name',                'STRING', 114, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'lastWrapupCodeName',              'last_wrapup_code_name',              'STRING', 115, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'terminatingEnd',                  'terminating_end',                    'STRING', 116, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'terminationReason',               'termination_reason',                 'STRING', 117, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'N/A',                             'start_date',                         'STRING', 118, 0, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'N/A',                             'end_date',                           'STRING', 119, 0, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'N/A',                             'record_type',                        'STRING', 120, 0, 0, 1, GETUTCDATE()),
  ('Webex', 'call_leg', 'call_leg_base', 'N/A',                             'source',                             'STRING', 121, 0, 0, 1, GETUTCDATE());

-- [W04] customer_activity — 15 data fields + 4 context
INSERT INTO schema_config
    (source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  ('Webex', 'customer_activity', 'customer_activity_base', 'id',                   'id',                    'STRING',   1, 1, 1, 1, GETUTCDATE()),
  ('Webex', 'customer_activity', 'customer_activity_base', 'channelType',           'channel_type',          'STRING',   2, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_activity', 'customer_activity_base', 'channelSubType',        'channel_sub_type',      'STRING',   3, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_activity', 'customer_activity_base', 'destination',           'destination',           'STRING',   4, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_activity', 'customer_activity_base', 'origin',                'origin',                'STRING',   5, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_activity', 'customer_activity_base', 'isOutdial',             'is_outdial',            'BOOLEAN',  6, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_activity', 'customer_activity_base', 'isEmailSent',           'is_email_sent',         'BOOLEAN',  7, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_activity', 'customer_activity_base', 'emailToList',           'email_to_list',         'STRING',   8, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_activity', 'customer_activity_base', 'emailCcList',           'email_cc_list',         'STRING',   9, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_activity', 'customer_activity_base', 'emailBccList',          'email_bcc_list',        'STRING',  10, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_activity', 'customer_activity_base', 'emailReplyTo',          'email_reply_to',        'STRING',  11, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_activity', 'customer_activity_base', 'matchedSkillsProfile',  'matched_skills_profile','STRING',  12, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_activity', 'customer_activity_base', 'preferredAgentName',    'preferred_agent_name',  'STRING',  13, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_activity', 'customer_activity_base', 'routingType',           'routing_type',          'STRING',  14, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_activity', 'customer_activity_base', 'activities.nodes',      'activity_nodes_json',   'STRING',  15, 0, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_activity', 'customer_activity_base', 'N/A',                   'start_date',            'STRING',  16, 0, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_activity', 'customer_activity_base', 'N/A',                   'end_date',              'STRING',  17, 0, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_activity', 'customer_activity_base', 'N/A',                   'record_type',           'STRING',  18, 0, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_activity', 'customer_activity_base', 'N/A',                   'source',                'STRING',  19, 0, 0, 1, GETUTCDATE());

-- [W05] customer_session — 207 data fields + 4 context  [part 1 of 3: ordinals 1-90]
INSERT INTO schema_config
    (source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  ('Webex', 'customer_session', 'customer_session_base', 'id',                                'id',                                 'STRING',   1, 1, 1, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'channelType',                       'channel_type',                       'STRING',   2, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'channelSubType',                    'channel_sub_type',                   'STRING',   3, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'direction',                         'direction',                          'STRING',   4, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'origin',                            'origin',                             'STRING',   5, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'destination',                       'destination',                        'STRING',   6, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'status',                            'status',                             'STRING',   7, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'createdTime',                       'created_time',                       'BIGINT',   8, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'endedTime',                         'ended_time',                         'BIGINT',   9, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'lastActivityTime',                  'last_activity_time',                 'BIGINT',  10, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'totalDuration',                     'total_duration',                     'INT',     11, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'isActive',                          'is_active',                          'BOOLEAN', 12, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'isOutdial',                         'is_outdial',                         'BOOLEAN', 13, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'isCallback',                        'is_callback',                        'BOOLEAN', 14, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'isCampaign',                        'is_campaign',                        'BOOLEAN', 15, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'isBarged',                          'is_barged',                          'BOOLEAN', 16, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'isMonitored',                       'is_monitored',                       'BOOLEAN', 17, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'isContactHandled',                  'is_contact_handled',                 'BOOLEAN', 18, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'isContactOffered',                  'is_contact_offered',                 'BOOLEAN', 19, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'isContactEscalatedToQueue',         'is_contact_escalated_to_queue',      'BOOLEAN', 20, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'isOptOutOfQueue',                   'is_opt_out_of_queue',                'BOOLEAN', 21, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'isHandledByPreferredAgent',         'is_handled_by_preferred_agent',      'BOOLEAN', 22, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'isWithInServiceLevel',              'is_with_in_service_level',           'BOOLEAN', 23, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'isEmailSent',                       'is_email_sent',                      'BOOLEAN', 24, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'isRecordingDeleted',                'is_recording_deleted',               'BOOLEAN', 25, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'isRealtimeTranscriptionEnabled',    'is_realtime_transcription_enabled',  'BOOLEAN', 26, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'isTranscriptionAvailable',          'is_transcription_available',         'BOOLEAN', 27, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'isSuggestedResponseRequested',      'is_suggested_response_requested',    'BOOLEAN', 28, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'captureRequested',                  'capture_requested',                  'BOOLEAN', 29, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'customer.email',                    'customer_email',                     'STRING',  30, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'customer.name',                      'customer_name',                      'STRING',  31, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'customer.phoneNumber',              'customer_phone_number',              'STRING',  32, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'lastAgent.id',                      'last_agent_id',                      'STRING',  33, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'lastAgent.name',                    'last_agent_name',                    'STRING',  34, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'lastAgent.channelId',               'last_agent_channel_id',              'STRING',  35, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'lastAgent.phoneNumber',             'last_agent_phone_number',            'STRING',  36, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'lastAgent.sessionId',               'last_agent_session_id',              'STRING',  37, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'lastAgent.signInId',                'last_agent_sign_in_id',              'STRING',  38, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'lastEntryPoint.id',                 'last_entry_point_id',                'STRING',  39, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'lastEntryPoint.name',               'last_entry_point_name',              'STRING',  40, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'lastQueue.id',                      'last_queue_id',                      'STRING',  41, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'lastQueue.name',                    'last_queue_name',                    'STRING',  42, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'lastQueue.duration',                'last_queue_duration',                'INT',     43, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'lastSite.id',                       'last_site_id',                       'STRING',  44, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'lastSite.name',                     'last_site_name',                     'STRING',  45, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'lastTeam.id',                       'last_team_id',                       'STRING',  46, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'lastTeam.name',                     'last_team_name',                     'STRING',  47, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'previousQueue.id',                  'previous_queue_id',                  'STRING',  48, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'previousQueue.name',                'previous_queue_name',                'STRING',  49, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'callbackData.callbackAgentName',    'callback_agent_name',                'STRING',  50, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'callbackData.callbackConnectTime',  'callback_connect_time',              'BIGINT',  51, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'callbackData.callbackNumber',       'callback_number',                    'STRING',  52, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'callbackData.callbackOrigin',       'callback_origin',                    'STRING',  53, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'callbackData.callbackQueueName',    'callback_queue_name',                'STRING',  54, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'callbackData.callbackRequestTime',  'callback_request_time',              'BIGINT',  55, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'callbackData.callbackRetryCount',   'callback_retry_count',               'INT',     56, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'callbackData.callbackStatus',       'callback_status',                    'STRING',  57, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'callbackData.callbackTeamName',     'callback_team_name',                 'STRING',  58, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'callbackData.callbackType',         'callback_type',                      'STRING',  59, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'channelMetaData.chat',              'channel_meta_chat',                  'STRING',  60, 0, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'channelMetaData.email',             'channel_meta_email',                 'STRING',  61, 0, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'channelMetaData.inBoundTranscript', 'channel_meta_inbound_transcript',    'STRING',  62, 0, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'channelMetaData.outBoundTranscript','channel_meta_outbound_transcript',   'STRING',  63, 0, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'feedback.comment',                  'feedback_comment',                   'STRING',  64, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'feedback.questionsAnswered',        'feedback_questions_answered',        'INT',     65, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'feedback.questionsPresented',       'feedback_questions_presented',       'INT',     66, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'feedback.surveyCompleted',          'feedback_survey_completed',          'BOOLEAN', 67, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'feedback.surveyOptIn',              'feedback_survey_opt_in',             'STRING',  68, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'feedback.type',                     'feedback_type',                      'STRING',  69, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'matchedSkills.$0.name',             'matched_skill_name',                 'STRING',  70, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'matchedSkills.$0.intVal',           'matched_skill_value',                'INT',     71, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'requiredSkills.$0.operand',         'required_skill_operand',             'STRING',  72, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'requiredSkills.$0.name',            'required_skill_name',                'STRING',  73, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'requiredSkills.$0.intVal',          'required_skill_value',               'INT',     74, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'firstQueueId',                      'first_queue_id',                     'STRING',  75, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'firstQueueName',                    'first_queue_name',                   'STRING',  76, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'contactHandleType',                 'contact_handle_type',                'STRING',  77, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'contactPriority',                   'contact_priority',                   'INT',     78, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'contactReason',                     'contact_reason',                     'STRING',  79, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'contactDriver',                     'contact_driver',                     'STRING',  80, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'routingType',                       'routing_type',                       'STRING',  81, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'skillsAssignedIn',                  'skills_assigned_in',                 'STRING',  82, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'matchedSkillsProfile',              'matched_skills_profile',             'STRING',  83, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'connectedCount',                    'connected_count',                    'INT',     84, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'connectedDuration',                 'connected_duration',                 'INT',     85, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'holdCount',                         'hold_count',                         'INT',     86, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'holdDuration',                      'hold_duration',                      'INT',     87, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'wrapupDuration',                    'wrapup_duration',                    'INT',     88, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'queueCount',                        'queue_count',                        'INT',     89, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'queueDuration',                     'queue_duration',                     'INT',     90, 1, 0, 1, GETUTCDATE());

-- [W05] customer_session — 207 data fields + 4 context  [part 2 of 3: ordinals 91-180]
INSERT INTO schema_config
    (source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  ('Webex', 'customer_session', 'customer_session_base', 'ringingDuration',                   'ringing_duration',                   'INT',     91, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'selfserviceCount',                  'selfservice_count',                  'INT',     92, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'selfserviceDuration',               'selfservice_duration',               'INT',     93, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'consultCount',                      'consult_count',                      'INT',     94, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'consultDuration',                   'consult_duration',                   'INT',     95, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'consultToEPCount',                  'consult_to_ep_count',                'INT',     96, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'consultToEPDuration',               'consult_to_ep_duration',             'INT',     97, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'consultToQueueCount',               'consult_to_queue_count',             'INT',     98, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'consultToQueueDuration',            'consult_to_queue_duration',          'INT',     99, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'conferenceCount',                   'conference_count',                   'INT',    100, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'conferenceDuration',                'conference_duration',                'INT',    101, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'blindTransferCount',                'blind_transfer_count',               'INT',    102, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'transferCount',                     'transfer_count',                     'INT',    103, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'transferErrorCount',                'transfer_error_count',               'INT',    104, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'transferEpDN',                      'transfer_ep_dn',                     'STRING', 105, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'transferInToEPCount',               'transfer_in_to_ep_count',            'INT',    106, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'agentToDnTransferCount',            'agent_to_dn_transfer_count',         'INT',    107, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'agentToQueueTransferCount',         'agent_to_queue_transfer_count',      'INT',    108, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'agentToEntrypointTransferCount',    'agent_to_entrypoint_transfer_count', 'INT',    109, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'agentTransferedInCount',            'agent_transfered_in_count',          'INT',    110, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'agentToAgentTransferCount',         'agent_to_agent_transfer_count',      'STRING', 111, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'queueTransferToEPCount',            'queue_transfer_to_ep_count',         'INT',    112, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'queueTransferToQueueCount',         'queue_transfer_to_queue_count',      'INT',    113, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'epTransferToEPCount',               'ep_transfer_to_ep_count',            'INT',    114, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'chainedInToEPCount',                'chained_in_to_ep_count',             'INT',    115, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'chainedInToQueueCount',             'chained_in_to_queue_count',          'INT',    116, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'outdialConsultCount',               'outdial_consult_count',              'INT',    117, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'outdialConsultToEPCount',           'outdial_consult_to_ep_count',        'INT',    118, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'outdialConsultToEPDuration',        'outdial_consult_to_ep_duration',     'INT',    119, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'outdialConsultToQueueCount',        'outdial_consult_to_queue_count',     'INT',    120, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'outdialConsultToQueueDuration',     'outdial_consult_to_queue_duration',  'INT',    121, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'overflowCount',                     'overflow_count',                     'INT',    122, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'bargedInCount',                     'barged_in_count',                    'INT',    123, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'bargedInDuration',                  'barged_in_duration',                 'INT',    124, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'bargedInFailedCount',               'barged_in_failed_count',             'INT',    125, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'fullMonitoringCount',               'full_monitoring_count',              'INT',    126, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'silentMonitoringCount',             'silent_monitoring_count',            'INT',    127, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'midcallMonitoringCount',            'midcall_monitoring_count',           'INT',    128, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'totalMonitoringCount',              'total_monitoring_count',             'INT',    129, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'monitoringTimestamp',               'monitoring_timestamp',               'BIGINT', 130, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'monitorFullName',                   'monitor_full_name',                  'STRING', 131, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'pausedCount',                       'paused_count',                       'INT',    132, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'pausedDuration',                    'paused_duration',                    'INT',    133, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'resumedCount',                      'resumed_count',                      'INT',    134, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'deadAirCount',                      'dead_air_count',                     'INT',    135, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'deadAirTime',                       'dead_air_time',                      'INT',    136, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'crossTalkCount',                    'cross_talk_count',                   'INT',    137, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'crossTalkTime',                     'cross_talk_time',                    'INT',    138, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'totalBnrDuration',                  'total_bnr_duration',                 'INT',    139, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'shortInIVRCount',                   'short_in_ivr_count',                 'INT',    140, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'shortInQueueCount',                 'short_in_queue_count',               'INT',    141, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'midCallSummaryCount',               'mid_call_summary_count',             'INT',    142, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'postCallSummaryCount',              'post_call_summary_count',            'INT',    143, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'postCallConsultDuration',           'post_call_consult_duration',         'INT',    144, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'postCallDuration',                  'post_call_duration',                 'INT',    145, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'recordingCount',                    'recording_count',                    'INT',    146, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'recordingErrorCount',               'recording_error_count',              'INT',    147, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'recordingFileSize',                 'recording_file_size',                'INT',    148, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'recordingLocation',                 'recording_location',                 'STRING', 149, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'recordingStereoBlobId',             'recording_stereo_blob_id',           'STRING', 150, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'vaRecordingAvailable',              'va_recording_available',             'BOOLEAN',151, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'vaTranscriptionAvailable',          'va_transcription_available',         'STRING', 152, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'csatScore',                         'csat_score',                         'INT',    153, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'autoCsat',                          'auto_csat',                          'STRING', 154, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'customerSentimentScore',            'customer_sentiment_score',           'STRING', 155, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'evalScore',                         'eval_score',                         'STRING', 156, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'evalScoreType',                     'eval_score_type',                    'STRING', 157, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'evalSectionsFailureCount',          'eval_sections_failure_count',        'INT',    158, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'evalStatus',                        'eval_status',                        'STRING', 159, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'overallEvalScore',                  'overall_eval_score',                 'STRING', 160, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'wordRatioCount',                    'word_ratio_count',                   'INT',    161, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'wordRatioScore',                    'word_ratio_score',                   'STRING', 162, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'suddenDisconnectCount',             'sudden_disconnect_count',            'INT',    163, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'terminatingEnd',                    'terminating_end',                    'STRING', 164, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'terminationReason',                 'termination_reason',                 'STRING', 165, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'terminationType',                   'termination_type',                   'STRING', 166, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'flowActivityName',                  'flow_activity_name',                 'STRING', 167, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'flowActivitySequence',              'flow_activity_sequence',             'STRING', 168, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'ivrScriptId',                       'ivr_script_id',                      'STRING', 169, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'ivrScriptName',                     'ivr_script_name',                    'STRING', 170, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'ivrScriptTagId',                    'ivr_script_tag_id',                  'STRING', 171, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'ivrScriptTagName',                  'ivr_script_tag_name',                'STRING', 172, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'ivrEndedCount',                     'ivr_ended_count',                    'INT',    173, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'campaignId',                        'campaign_id',                        'STRING', 174, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'campaignName',                      'campaign_name',                      'STRING', 175, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'campaignStatus',                    'campaign_status',                    'STRING', 176, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'cpaStatus',                         'cpa_status',                         'STRING', 177, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'botName',                           'bot_name',                           'STRING', 178, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'chatType',                          'chat_type',                          'STRING', 179, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'outdialType',                       'outdial_type',                       'STRING', 180, 1, 0, 1, GETUTCDATE());

-- [W05] customer_session — 207 data fields + 4 context  [part 3 of 3: ordinals 181-211]
INSERT INTO schema_config
    (source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  ('Webex', 'customer_session', 'customer_session_base', 'agentHangupCount',                  'agent_hangup_count',                 'INT',    181, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'callCompletedCount',                'call_completed_count',               'INT',    182, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'lastWrapUpCodeId',                  'last_wrap_up_code_id',               'STRING', 183, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'lastWrapupCodeName',                'last_wrapup_code_name',              'STRING', 184, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'manualAssignCount',                 'manual_assign_count',                'INT',    185, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'previousAgentId',                   'previous_agent_id',                  'STRING', 186, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'previousAgentName',                 'previous_agent_name',                'STRING', 187, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'previousAgentSessionId',            'previous_agent_session_id',          'STRING', 188, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'preferredAgentName',                'preferred_agent_name',               'STRING', 189, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'preferredAgentSystemId',            'preferred_agent_system_id',          'STRING', 190, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'personalCallBackAgentName',         'personal_call_back_agent_name',      'STRING', 191, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'emailHasAttachments',               'email_has_attachments',              'BOOLEAN',192, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'emailDate',                         'email_date',                         'INT',    193, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'emailBccList',                      'email_bcc_list',                     'STRING', 194, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'emailCcList',                       'email_cc_list',                      'STRING', 195, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'emailReplyTo',                      'email_reply_to',                     'STRING', 196, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'emailToList',                       'email_to_list',                      'STRING', 197, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'emailMessageId',                    'email_message_id',                   'STRING', 198, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'emailRef',                          'email_ref',                          'STRING', 199, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'emailBody',                         'email_body',                         'STRING', 200, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'emailFullMessage',                  'email_full_message',                 'STRING', 201, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'emailReplyBody',                    'email_reply_body',                   'STRING', 202, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'emailContent',                      'email_content',                      'STRING', 203, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'emailContentType',                  'email_content_type',                 'STRING', 204, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'emailReplyContentType',             'email_reply_content_type',           'STRING', 205, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'topicName',                         'topic_name',                         'STRING', 206, 1, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'globalVariables',                   'global_variables_json',              'STRING', 207, 0, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'N/A',                               'start_date',                         'STRING', 208, 0, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'N/A',                               'end_date',                           'STRING', 209, 0, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'N/A',                               'record_type',                        'STRING', 210, 0, 0, 1, GETUTCDATE()),
  ('Webex', 'customer_session', 'customer_session_base', 'N/A',                               'source',                             'STRING', 211, 0, 0, 1, GETUTCDATE());

-- Total Webex: 485 rows (agent_activity 17 + agent_session 117 + call_leg 121 + customer_activity 19 + customer_session 211)


-- ============================================================
-- Salesforce source — schema_config seed data
-- source_name = 'Salesforce'  (IDs auto-assigned by IDENTITY)
-- source_column_name = field path within each SOQL record (PascalCase),
--   or attributes.<key> for the SObject metadata envelope.
-- context fields (start_date/end_date/record_type/source) use 'N/A'.
-- include_in_md5hash: 1 for data scalars, 0 for metadata + context fields.
-- Mirrors fabric/workspaces/eq-hub/schemas/salesforce/*.json.
-- ============================================================

SET IDENTITY_INSERT dbo.schema_config OFF;
GO

-- [SF01] account — 2 data fields + 2 metadata + 4 context
INSERT INTO schema_config
    (source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  ('Salesforce', 'account', 'account_base', 'attributes.type', 'attributes_type', 'STRING', 1, 0, 0, 1, GETUTCDATE()),
  ('Salesforce', 'account', 'account_base', 'attributes.url',  'attributes_url',  'STRING', 2, 0, 0, 1, GETUTCDATE()),
  ('Salesforce', 'account', 'account_base', 'Id',              'id',              'STRING', 3, 1, 1, 1, GETUTCDATE()),
  ('Salesforce', 'account', 'account_base', 'Name',            'name',            'STRING', 4, 1, 0, 1, GETUTCDATE()),
  ('Salesforce', 'account', 'account_base', 'N/A',             'start_date',      'STRING', 5, 0, 0, 1, GETUTCDATE()),
  ('Salesforce', 'account', 'account_base', 'N/A',             'end_date',        'STRING', 6, 0, 0, 1, GETUTCDATE()),
  ('Salesforce', 'account', 'account_base', 'N/A',             'record_type',     'STRING', 7, 0, 0, 1, GETUTCDATE()),
  ('Salesforce', 'account', 'account_base', 'N/A',             'source',          'STRING', 8, 0, 0, 1, GETUTCDATE());

-- [SF02] campaign — 9 data fields + 2 metadata + 4 context
INSERT INTO schema_config
    (source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  ('Salesforce', 'campaign', 'campaign_base', 'attributes.type', 'attributes_type',     'STRING',  1, 0, 0, 1, GETUTCDATE()),
  ('Salesforce', 'campaign', 'campaign_base', 'attributes.url',  'attributes_url',      'STRING',  2, 0, 0, 1, GETUTCDATE()),
  ('Salesforce', 'campaign', 'campaign_base', 'Id',              'id',                  'STRING',  3, 1, 1, 1, GETUTCDATE()),
  ('Salesforce', 'campaign', 'campaign_base', 'Name',            'name',                'STRING',  4, 1, 0, 1, GETUTCDATE()),
  ('Salesforce', 'campaign', 'campaign_base', 'Status',          'status',              'STRING',  5, 1, 0, 1, GETUTCDATE()),
  ('Salesforce', 'campaign', 'campaign_base', 'StartDate',       'campaign_start_date', 'STRING',  6, 1, 0, 1, GETUTCDATE()),
  ('Salesforce', 'campaign', 'campaign_base', 'EndDate',         'campaign_end_date',   'STRING',  7, 1, 0, 1, GETUTCDATE()),
  ('Salesforce', 'campaign', 'campaign_base', 'Type',            'type',                'STRING',  8, 1, 0, 1, GETUTCDATE()),
  ('Salesforce', 'campaign', 'campaign_base', 'IsActive',        'is_active',           'BOOLEAN', 9, 1, 0, 1, GETUTCDATE()),
  ('Salesforce', 'campaign', 'campaign_base', 'Description',     'description',         'STRING', 10, 1, 0, 1, GETUTCDATE()),
  ('Salesforce', 'campaign', 'campaign_base', 'OwnerId',         'owner_id',            'STRING', 11, 1, 0, 1, GETUTCDATE()),
  ('Salesforce', 'campaign', 'campaign_base', 'N/A',             'start_date',          'STRING', 12, 0, 0, 1, GETUTCDATE()),
  ('Salesforce', 'campaign', 'campaign_base', 'N/A',             'end_date',            'STRING', 13, 0, 0, 1, GETUTCDATE()),
  ('Salesforce', 'campaign', 'campaign_base', 'N/A',             'record_type',         'STRING', 14, 0, 0, 1, GETUTCDATE()),
  ('Salesforce', 'campaign', 'campaign_base', 'N/A',             'source',              'STRING', 15, 0, 0, 1, GETUTCDATE());

-- [SF03] task — 9 data fields + 2 metadata + 4 context
INSERT INTO schema_config
    (source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  ('Salesforce', 'task', 'task_base', 'attributes.type', 'attributes_type', 'STRING',  1, 0, 0, 1, GETUTCDATE()),
  ('Salesforce', 'task', 'task_base', 'attributes.url',  'attributes_url',  'STRING',  2, 0, 0, 1, GETUTCDATE()),
  ('Salesforce', 'task', 'task_base', 'Id',              'id',              'STRING',  3, 1, 1, 1, GETUTCDATE()),
  ('Salesforce', 'task', 'task_base', 'Subject',         'subject',         'STRING',  4, 1, 0, 1, GETUTCDATE()),
  ('Salesforce', 'task', 'task_base', 'Status',          'status',          'STRING',  5, 1, 0, 1, GETUTCDATE()),
  ('Salesforce', 'task', 'task_base', 'Priority',        'priority',        'STRING',  6, 1, 0, 1, GETUTCDATE()),
  ('Salesforce', 'task', 'task_base', 'ActivityDate',    'activity_date',   'STRING',  7, 1, 0, 1, GETUTCDATE()),
  ('Salesforce', 'task', 'task_base', 'Description',     'description',     'STRING',  8, 1, 0, 1, GETUTCDATE()),
  ('Salesforce', 'task', 'task_base', 'OwnerId',         'owner_id',        'STRING',  9, 1, 0, 1, GETUTCDATE()),
  ('Salesforce', 'task', 'task_base', 'WhoId',           'who_id',          'STRING', 10, 1, 0, 1, GETUTCDATE()),
  ('Salesforce', 'task', 'task_base', 'WhatId',          'what_id',         'STRING', 11, 1, 0, 1, GETUTCDATE()),
  ('Salesforce', 'task', 'task_base', 'N/A',             'start_date',      'STRING', 12, 0, 0, 1, GETUTCDATE()),
  ('Salesforce', 'task', 'task_base', 'N/A',             'end_date',        'STRING', 13, 0, 0, 1, GETUTCDATE()),
  ('Salesforce', 'task', 'task_base', 'N/A',             'record_type',     'STRING', 14, 0, 0, 1, GETUTCDATE()),
  ('Salesforce', 'task', 'task_base', 'N/A',             'source',          'STRING', 15, 0, 0, 1, GETUTCDATE());

-- [SF04] event — 9 data fields + 2 metadata + 4 context
INSERT INTO schema_config
    (source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  ('Salesforce', 'event', 'event_base', 'attributes.type', 'attributes_type', 'STRING',  1, 0, 0, 1, GETUTCDATE()),
  ('Salesforce', 'event', 'event_base', 'attributes.url',  'attributes_url',  'STRING',  2, 0, 0, 1, GETUTCDATE()),
  ('Salesforce', 'event', 'event_base', 'Id',              'id',              'STRING',  3, 1, 1, 1, GETUTCDATE()),
  ('Salesforce', 'event', 'event_base', 'Subject',         'subject',         'STRING',  4, 1, 0, 1, GETUTCDATE()),
  ('Salesforce', 'event', 'event_base', 'StartDateTime',   'start_date_time', 'STRING',  5, 1, 0, 1, GETUTCDATE()),
  ('Salesforce', 'event', 'event_base', 'EndDateTime',     'end_date_time',   'STRING',  6, 1, 0, 1, GETUTCDATE()),
  ('Salesforce', 'event', 'event_base', 'Location',        'location',        'STRING',  7, 1, 0, 1, GETUTCDATE()),
  ('Salesforce', 'event', 'event_base', 'Description',     'description',     'STRING',  8, 1, 0, 1, GETUTCDATE()),
  ('Salesforce', 'event', 'event_base', 'OwnerId',         'owner_id',        'STRING',  9, 1, 0, 1, GETUTCDATE()),
  ('Salesforce', 'event', 'event_base', 'WhoId',           'who_id',          'STRING', 10, 1, 0, 1, GETUTCDATE()),
  ('Salesforce', 'event', 'event_base', 'WhatId',          'what_id',         'STRING', 11, 1, 0, 1, GETUTCDATE()),
  ('Salesforce', 'event', 'event_base', 'N/A',             'start_date',      'STRING', 12, 0, 0, 1, GETUTCDATE()),
  ('Salesforce', 'event', 'event_base', 'N/A',             'end_date',        'STRING', 13, 0, 0, 1, GETUTCDATE()),
  ('Salesforce', 'event', 'event_base', 'N/A',             'record_type',     'STRING', 14, 0, 0, 1, GETUTCDATE()),
  ('Salesforce', 'event', 'event_base', 'N/A',             'source',          'STRING', 15, 0, 0, 1, GETUTCDATE());

-- Total Salesforce: 53 rows (account 8 + campaign 15 + task 15 + event 15)
GO