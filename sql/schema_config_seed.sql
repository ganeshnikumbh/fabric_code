-- ============================================================
-- schema_config seed data — EQ_Warehouse source system
-- Generated from: EquiTrust_Data_Source_Intake_Template_eqWarehouse.xlsx
-- Target table  : control.schema_config
-- Columns       : id, source_table_name, source_column_name,
--                 target_column_name, target_data_type,
--                 ordinal_position, include_in_md5hash, is_active, created_at
-- ============================================================

-- [01] Territory (7 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  (   1, 'Territory'                                 , 'TerritoryPK'                               , 'territory_id'                              , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  (   2, 'Territory'                                 , 'TerritoryName'                             , 'territory_name'                            , 'STRING'              ,   2, 1, 1, GETUTCDATE()),
  (   3, 'Territory'                                 , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,   3, 0, 1, GETUTCDATE()),
  (   4, 'Territory'                                 , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,   4, 0, 1, GETUTCDATE()),
  (   5, 'Territory'                                 , 'N/A'                                       , 'source_system'                             , 'STRING'              ,   5, 0, 1, GETUTCDATE()),
  (   6, 'Territory'                                 , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,   6, 0, 1, GETUTCDATE()),
  (   7, 'Territory'                                 , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,   7, 0, 1, GETUTCDATE());

-- [02] HierarchyTerritory (8 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  (   8, 'HierarchyTerritory'                        , 'HierarchyTerritoryPK'                      , 'hierarchy_territory_id'                    , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  (   9, 'HierarchyTerritory'                        , 'HierarchySetKey'                           , 'hierarchy_set_key'                         , 'INT'                 ,   2, 1, 1, GETUTCDATE()),
  (  10, 'HierarchyTerritory'                        , 'TerritoryFK'                               , 'territory_id'                              , 'INT'                 ,   3, 1, 1, GETUTCDATE()),
  (  11, 'HierarchyTerritory'                        , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,   4, 0, 1, GETUTCDATE()),
  (  12, 'HierarchyTerritory'                        , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,   5, 0, 1, GETUTCDATE()),
  (  13, 'HierarchyTerritory'                        , 'N/A'                                       , 'source_system'                             , 'STRING'              ,   6, 0, 1, GETUTCDATE()),
  (  14, 'HierarchyTerritory'                        , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,   7, 0, 1, GETUTCDATE()),
  (  15, 'HierarchyTerritory'                        , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,   8, 0, 1, GETUTCDATE());

-- [03] Hierarchy_SuperHierarchy (10 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  (  16, 'Hierarchy_SuperHierarchy'                  , 'SuperHierarchyPK'                          , 'super_hierarchy_id'                        , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  (  17, 'Hierarchy_SuperHierarchy'                  , 'AgentContractFK'                           , 'agent_contract_id'                         , 'INT'                 ,   2, 1, 1, GETUTCDATE()),
  (  18, 'Hierarchy_SuperHierarchy'                  , 'HierarchySetKey'                           , 'hierarchy_set_key'                         , 'INT'                 ,   3, 1, 1, GETUTCDATE()),
  (  19, 'Hierarchy_SuperHierarchy'                  , 'ReverseLevel'                              , 'reverse_level'                             , 'DECIMAL(18,4)'       ,   4, 1, 1, GETUTCDATE()),
  (  20, 'Hierarchy_SuperHierarchy'                  , 'DisplayName'                               , 'display_name'                              , 'STRING'              ,   5, 1, 1, GETUTCDATE()),
  (  21, 'Hierarchy_SuperHierarchy'                  , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,   6, 0, 1, GETUTCDATE()),
  (  22, 'Hierarchy_SuperHierarchy'                  , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,   7, 0, 1, GETUTCDATE()),
  (  23, 'Hierarchy_SuperHierarchy'                  , 'N/A'                                       , 'source_system'                             , 'STRING'              ,   8, 0, 1, GETUTCDATE()),
  (  24, 'Hierarchy_SuperHierarchy'                  , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,   9, 0, 1, GETUTCDATE()),
  (  25, 'Hierarchy_SuperHierarchy'                  , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  10, 0, 1, GETUTCDATE());

-- [04] Hierarchy_Option (9 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  (  26, 'Hierarchy_Option'                          , 'HierarchyOptionPK'                         , 'hierarchy_option_id'                       , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  (  27, 'Hierarchy_Option'                          , 'HierarchyBridgeFK'                         , 'hierarchy_bridge_id'                       , 'INT'                 ,   2, 1, 1, GETUTCDATE()),
  (  28, 'Hierarchy_Option'                          , 'AgentContractFK'                           , 'agent_contract_id'                         , 'INT'                 ,   3, 1, 1, GETUTCDATE()),
  (  29, 'Hierarchy_Option'                          , 'AccessRemovedInd'                          , 'is_access_removed'                         , 'BOOLEAN'             ,   4, 1, 1, GETUTCDATE()),
  (  30, 'Hierarchy_Option'                          , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,   5, 0, 1, GETUTCDATE()),
  (  31, 'Hierarchy_Option'                          , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,   6, 0, 1, GETUTCDATE()),
  (  32, 'Hierarchy_Option'                          , 'N/A'                                       , 'source_system'                             , 'STRING'              ,   7, 0, 1, GETUTCDATE()),
  (  33, 'Hierarchy_Option'                          , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,   8, 0, 1, GETUTCDATE()),
  (  34, 'Hierarchy_Option'                          , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,   9, 0, 1, GETUTCDATE());

-- [05] Hierarchy_Bridge (15 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  (  35, 'Hierarchy_Bridge'                          , 'HierarchyBridgePK'                         , 'hierarchy_bridge_id'                       , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  (  36, 'Hierarchy_Bridge'                          , 'HierarchyGroupKey'                         , 'hierarchy_group_key'                       , 'INT'                 ,   2, 1, 1, GETUTCDATE()),
  (  37, 'Hierarchy_Bridge'                          , 'HierarchySetKey'                           , 'hierarchy_set_key'                         , 'INT'                 ,   3, 1, 1, GETUTCDATE()),
  (  38, 'Hierarchy_Bridge'                          , 'SplitPercent'                              , 'split_percent'                             , 'DECIMAL(18,4)'       ,   4, 1, 1, GETUTCDATE()),
  (  39, 'Hierarchy_Bridge'                          , 'ServicingAgentIndicator'                   , 'servicing_agent_indicator'                 , 'STRING'              ,   5, 1, 1, GETUTCDATE()),
  (  40, 'Hierarchy_Bridge'                          , 'CommissionOnlyIndicator'                   , 'commission_only_indicator'                 , 'STRING'              ,   6, 1, 1, GETUTCDATE()),
  (  41, 'Hierarchy_Bridge'                          , 'CommissionOption'                          , 'commission_option'                         , 'STRING'              ,   7, 1, 1, GETUTCDATE()),
  (  42, 'Hierarchy_Bridge'                          , 'HierarchyOrder'                            , 'hierarchy_order'                           , 'INT'                 ,   8, 1, 1, GETUTCDATE()),
  (  43, 'Hierarchy_Bridge'                          , 'StartDate'                                 , 'start_timestamp'                           , 'TIMESTAMP'           ,   9, 1, 1, GETUTCDATE()),
  (  44, 'Hierarchy_Bridge'                          , 'StopDate'                                  , 'stop_timestamp'                            , 'TIMESTAMP'           ,  10, 1, 1, GETUTCDATE()),
  (  45, 'Hierarchy_Bridge'                          , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,  11, 0, 1, GETUTCDATE()),
  (  46, 'Hierarchy_Bridge'                          , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,  12, 0, 1, GETUTCDATE()),
  (  47, 'Hierarchy_Bridge'                          , 'N/A'                                       , 'source_system'                             , 'STRING'              ,  13, 0, 1, GETUTCDATE()),
  (  48, 'Hierarchy_Bridge'                          , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  14, 0, 1, GETUTCDATE()),
  (  49, 'Hierarchy_Bridge'                          , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  15, 0, 1, GETUTCDATE());

-- [06] Hierarchy (10 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  (  50, 'Hierarchy'                                 , 'Source Column Name'                        , 'Target Column Name'                        , 'TARGET DATA TYPE'    ,   1, 1, 1, GETUTCDATE()),
  (  51, 'Hierarchy'                                 , 'HierarchyPK'                               , 'hierarchy_id'                              , 'INT'                 ,   2, 1, 1, GETUTCDATE()),
  (  52, 'Hierarchy'                                 , 'HierarchySetKey'                           , 'hierarchy_set_key'                         , 'INT'                 ,   3, 1, 1, GETUTCDATE()),
  (  53, 'Hierarchy'                                 , 'AgentContractFK'                           , 'agent_contract_id'                         , 'INT'                 ,   4, 1, 1, GETUTCDATE()),
  (  54, 'Hierarchy'                                 , 'ReverseLevel'                              , 'reverse_level'                             , 'INT'                 ,   5, 1, 1, GETUTCDATE()),
  (  55, 'Hierarchy'                                 , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,   6, 0, 1, GETUTCDATE()),
  (  56, 'Hierarchy'                                 , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,   7, 0, 1, GETUTCDATE()),
  (  57, 'Hierarchy'                                 , 'N/A'                                       , 'source_system'                             , 'STRING'              ,   8, 0, 1, GETUTCDATE()),
  (  58, 'Hierarchy'                                 , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,   9, 0, 1, GETUTCDATE()),
  (  59, 'Hierarchy'                                 , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  10, 0, 1, GETUTCDATE());

-- [07] CommissionLevelRank (8 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  (  60, 'CommissionLevelRank'                       , 'CommissionLevelRankPK'                     , 'commission_level_rank_id'                  , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  (  61, 'CommissionLevelRank'                       , 'CommissionLevel'                           , 'commission_level'                          , 'STRING'              ,   2, 1, 1, GETUTCDATE()),
  (  62, 'CommissionLevelRank'                       , 'Rank'                                      , 'rank'                                      , 'INT'                 ,   3, 1, 1, GETUTCDATE()),
  (  63, 'CommissionLevelRank'                       , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,   4, 0, 1, GETUTCDATE()),
  (  64, 'CommissionLevelRank'                       , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,   5, 0, 1, GETUTCDATE()),
  (  65, 'CommissionLevelRank'                       , 'N/A'                                       , 'source_system'                             , 'STRING'              ,   6, 0, 1, GETUTCDATE()),
  (  66, 'CommissionLevelRank'                       , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,   7, 0, 1, GETUTCDATE()),
  (  67, 'CommissionLevelRank'                       , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,   8, 0, 1, GETUTCDATE());

-- [08] AgentContract (16 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  (  68, 'AgentContract'                             , 'AgentContractPK'                           , 'agent_contract_id'                         , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  (  69, 'AgentContract'                             , 'AgentNumber'                               , 'agent_number'                              , 'STRING'              ,   2, 1, 1, GETUTCDATE()),
  (  70, 'AgentContract'                             , 'AgentFK'                                   , 'agent_id'                                  , 'INT'                 ,   3, 1, 1, GETUTCDATE()),
  (  71, 'AgentContract'                             , 'Context'                                   , 'context'                                   , 'STRING'              ,   4, 1, 1, GETUTCDATE()),
  (  72, 'AgentContract'                             , 'Status'                                    , 'status'                                    , 'STRING'              ,   5, 1, 1, GETUTCDATE()),
  (  73, 'AgentContract'                             , 'CommissionLevel'                           , 'commission_level'                          , 'STRING'              ,   6, 1, 1, GETUTCDATE()),
  (  74, 'AgentContract'                             , 'SituationCode'                             , 'situation_code'                            , 'STRING'              ,   7, 1, 1, GETUTCDATE()),
  (  75, 'AgentContract'                             , 'ContractEffectiveDate'                     , 'contract_effective_timestamp'              , 'TIMESTAMP'           ,   8, 1, 1, GETUTCDATE()),
  (  76, 'AgentContract'                             , 'ContractTerminationDate'                   , 'contract_termination_timestamp'            , 'TIMESTAMP'           ,   9, 1, 1, GETUTCDATE()),
  (  77, 'AgentContract'                             , 'CurrentRecord'                             , 'is_current_record'                         , 'STRING'              ,  10, 1, 1, GETUTCDATE()),
  (  78, 'AgentContract'                             , 'SetToCurrentDate'                          , 'set_to_current_timestamp'                  , 'TIMESTAMP'           ,  11, 1, 1, GETUTCDATE()),
  (  79, 'AgentContract'                             , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,  12, 0, 1, GETUTCDATE()),
  (  80, 'AgentContract'                             , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,  13, 0, 1, GETUTCDATE()),
  (  81, 'AgentContract'                             , 'N/A'                                       , 'source_system'                             , 'STRING'              ,  14, 0, 1, GETUTCDATE()),
  (  82, 'AgentContract'                             , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  15, 0, 1, GETUTCDATE()),
  (  83, 'AgentContract'                             , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  16, 0, 1, GETUTCDATE());

-- [09] TrainingState_Group (10 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  (  84, 'TrainingState_Group'                       , 'TrainingStateGroupPK'                      , 'training_state_group_id'                   , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  (  85, 'TrainingState_Group'                       , 'TrainingStateGroupKey'                     , 'training_state_group_key'                  , 'INT'                 ,   2, 1, 1, GETUTCDATE()),
  (  86, 'TrainingState_Group'                       , 'State'                                     , 'state_code'                                , 'STRING'              ,   3, 1, 1, GETUTCDATE()),
  (  87, 'TrainingState_Group'                       , 'Required'                                  , 'is_required'                               , 'BOOLEAN'             ,   4, 1, 1, GETUTCDATE()),
  (  88, 'TrainingState_Group'                       , 'EffectiveDate'                             , 'effective_timestamp'                       , 'TIMESTAMP'           ,   5, 1, 1, GETUTCDATE()),
  (  89, 'TrainingState_Group'                       , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,   6, 0, 1, GETUTCDATE()),
  (  90, 'TrainingState_Group'                       , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,   7, 0, 1, GETUTCDATE()),
  (  91, 'TrainingState_Group'                       , 'N/A'                                       , 'source_system'                             , 'STRING'              ,   8, 0, 1, GETUTCDATE()),
  (  92, 'TrainingState_Group'                       , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,   9, 0, 1, GETUTCDATE()),
  (  93, 'TrainingState_Group'                       , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  10, 0, 1, GETUTCDATE());

-- [10] TrainingProduct_Group (9 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  (  94, 'TrainingProduct_Group'                     , 'TrainingProductGroupPK'                    , 'training_product_group_id'                 , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  (  95, 'TrainingProduct_Group'                     , 'TrainingProductGroupKey'                   , 'training_product_group_key'                , 'INT'                 ,   2, 1, 1, GETUTCDATE()),
  (  96, 'TrainingProduct_Group'                     , 'ProductFK'                                 , 'product_id'                                , 'INT'                 ,   3, 1, 1, GETUTCDATE()),
  (  97, 'TrainingProduct_Group'                     , 'Required'                                  , 'is_required'                               , 'BOOLEAN'             ,   4, 1, 1, GETUTCDATE()),
  (  98, 'TrainingProduct_Group'                     , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,   5, 0, 1, GETUTCDATE()),
  (  99, 'TrainingProduct_Group'                     , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,   6, 0, 1, GETUTCDATE()),
  ( 100, 'TrainingProduct_Group'                     , 'N/A'                                       , 'source_system'                             , 'STRING'              ,   7, 0, 1, GETUTCDATE()),
  ( 101, 'TrainingProduct_Group'                     , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,   8, 0, 1, GETUTCDATE()),
  ( 102, 'TrainingProduct_Group'                     , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,   9, 0, 1, GETUTCDATE());

-- [11] Rider_Group (20 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 103, 'Rider_Group'                               , 'RiderGroupPK'                              , 'rider_group_id'                            , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 104, 'Rider_Group'                               , 'RiderGroupKey'                             , 'rider_group_key'                           , 'INT'                 ,   2, 1, 1, GETUTCDATE()),
  ( 105, 'Rider_Group'                               , 'Code'                                      , 'rider_code'                                , 'STRING'              ,   3, 1, 1, GETUTCDATE()),
  ( 106, 'Rider_Group'                               , 'Description'                               , 'description'                               , 'STRING'              ,   4, 1, 1, GETUTCDATE()),
  ( 107, 'Rider_Group'                               , 'BaseValue'                                 , 'base_value'                                , 'DECIMAL(18,4)'       ,   5, 1, 1, GETUTCDATE()),
  ( 108, 'Rider_Group'                               , 'EligibilityDate'                           , 'eligibility_timestamp'                     , 'TIMESTAMP'           ,   6, 1, 1, GETUTCDATE()),
  ( 109, 'Rider_Group'                               , 'FeePercent'                                , 'fee_percent'                               , 'DECIMAL(18,4)'       ,   7, 1, 1, GETUTCDATE()),
  ( 110, 'Rider_Group'                               , 'Lives'                                     , 'lives'                                     , 'STRING'              ,   8, 1, 1, GETUTCDATE()),
  ( 111, 'Rider_Group'                               , 'PayValue'                                  , 'pay_value'                                 , 'DECIMAL(18,4)'       ,   9, 1, 1, GETUTCDATE()),
  ( 112, 'Rider_Group'                               , 'Frequency'                                 , 'frequency'                                 , 'STRING'              ,  10, 1, 1, GETUTCDATE()),
  ( 113, 'Rider_Group'                               , 'WellnessEnrollment'                        , 'is_wellness_enrollment'                    , 'BOOLEAN'             ,  11, 1, 1, GETUTCDATE()),
  ( 114, 'Rider_Group'                               , 'WellnessCredits'                           , 'wellness_credits'                          , 'DECIMAL(18,4)'       ,  12, 1, 1, GETUTCDATE()),
  ( 115, 'Rider_Group'                               , 'StartAge'                                  , 'start_age'                                 , 'INT'                 ,  13, 1, 1, GETUTCDATE()),
  ( 116, 'Rider_Group'                               , 'StartDate'                                 , 'start_timestamp'                           , 'TIMESTAMP'           ,  14, 1, 1, GETUTCDATE()),
  ( 117, 'Rider_Group'                               , 'StopDate'                                  , 'stop_timestamp'                            , 'TIMESTAMP'           ,  15, 1, 1, GETUTCDATE()),
  ( 118, 'Rider_Group'                               , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,  16, 0, 1, GETUTCDATE()),
  ( 119, 'Rider_Group'                               , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,  17, 0, 1, GETUTCDATE()),
  ( 120, 'Rider_Group'                               , 'N/A'                                       , 'source_system'                             , 'STRING'              ,  18, 0, 1, GETUTCDATE()),
  ( 121, 'Rider_Group'                               , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  19, 0, 1, GETUTCDATE()),
  ( 122, 'Rider_Group'                               , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  20, 0, 1, GETUTCDATE());

-- [12] Requirement_Group (14 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 123, 'Requirement_Group'                         , 'RequirementGroupPK'                        , 'requirement_group_id'                      , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 124, 'Requirement_Group'                         , 'RequirementGroupKey'                       , 'requirement_group_key'                     , 'INT'                 ,   2, 1, 1, GETUTCDATE()),
  ( 125, 'Requirement_Group'                         , 'Code'                                      , 'requirement_code'                          , 'STRING'              ,   3, 1, 1, GETUTCDATE()),
  ( 126, 'Requirement_Group'                         , 'Description'                               , 'description'                               , 'STRING'              ,   4, 1, 1, GETUTCDATE()),
  ( 127, 'Requirement_Group'                         , 'Status'                                    , 'status'                                    , 'STRING'              ,   5, 1, 1, GETUTCDATE()),
  ( 128, 'Requirement_Group'                         , 'EffectiveDate'                             , 'effective_timestamp'                       , 'TIMESTAMP'           ,   6, 1, 1, GETUTCDATE()),
  ( 129, 'Requirement_Group'                         , 'FollowUpDate'                              , 'follow_up_timestamp'                       , 'TIMESTAMP'           ,   7, 1, 1, GETUTCDATE()),
  ( 130, 'Requirement_Group'                         , 'ReceivedDate'                              , 'received_timestamp'                        , 'TIMESTAMP'           ,   8, 1, 1, GETUTCDATE()),
  ( 131, 'Requirement_Group'                         , 'ExecutedDate'                              , 'executed_timestamp'                        , 'TIMESTAMP'           ,   9, 1, 1, GETUTCDATE()),
  ( 132, 'Requirement_Group'                         , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,  10, 0, 1, GETUTCDATE()),
  ( 133, 'Requirement_Group'                         , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,  11, 0, 1, GETUTCDATE()),
  ( 134, 'Requirement_Group'                         , 'N/A'                                       , 'source_system'                             , 'STRING'              ,  12, 0, 1, GETUTCDATE()),
  ( 135, 'Requirement_Group'                         , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  13, 0, 1, GETUTCDATE()),
  ( 136, 'Requirement_Group'                         , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  14, 0, 1, GETUTCDATE());

-- [13] RenewalRate_Group (11 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 137, 'RenewalRate_Group'                         , 'RenewalRateGroupPK'                        , 'renewal_rate_group_id'                     , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 138, 'RenewalRate_Group'                         , 'RenewalRateGroupKey'                       , 'renewal_rate_group_key'                    , 'INT'                 ,   2, 1, 1, GETUTCDATE()),
  ( 139, 'RenewalRate_Group'                         , 'EffectiveDate'                             , 'effective_timestamp'                       , 'TIMESTAMP'           ,   3, 1, 1, GETUTCDATE()),
  ( 140, 'RenewalRate_Group'                         , 'Year'                                      , 'year'                                      , 'INT'                 ,   4, 1, 1, GETUTCDATE()),
  ( 141, 'RenewalRate_Group'                         , 'YearDisplay'                               , 'year_display'                              , 'STRING'              ,   5, 1, 1, GETUTCDATE()),
  ( 142, 'RenewalRate_Group'                         , 'Rate'                                      , 'rate'                                      , 'DECIMAL(18,4)'       ,   6, 1, 1, GETUTCDATE()),
  ( 143, 'RenewalRate_Group'                         , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,   7, 0, 1, GETUTCDATE()),
  ( 144, 'RenewalRate_Group'                         , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,   8, 0, 1, GETUTCDATE()),
  ( 145, 'RenewalRate_Group'                         , 'N/A'                                       , 'source_system'                             , 'STRING'              ,   9, 0, 1, GETUTCDATE()),
  ( 146, 'RenewalRate_Group'                         , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  10, 0, 1, GETUTCDATE()),
  ( 147, 'RenewalRate_Group'                         , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  11, 0, 1, GETUTCDATE());

-- [14] Reinsurance_Group (9 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 148, 'Reinsurance_Group'                         , 'ReinsuranceGroupPK'                        , 'reinsurance_group_id'                      , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 149, 'Reinsurance_Group'                         , 'ReinsuranceGroupKey'                       , 'reinsurance_group_key'                     , 'INT'                 ,   2, 1, 1, GETUTCDATE()),
  ( 150, 'Reinsurance_Group'                         , 'TreatyCode'                                , 'treaty_code'                               , 'STRING'              ,   3, 1, 1, GETUTCDATE()),
  ( 151, 'Reinsurance_Group'                         , 'CoinsurancePercentage'                     , 'coinsurance_percentage'                    , 'DECIMAL(18,4)'       ,   4, 1, 1, GETUTCDATE()),
  ( 152, 'Reinsurance_Group'                         , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,   5, 0, 1, GETUTCDATE()),
  ( 153, 'Reinsurance_Group'                         , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,   6, 0, 1, GETUTCDATE()),
  ( 154, 'Reinsurance_Group'                         , 'N/A'                                       , 'source_system'                             , 'STRING'              ,   7, 0, 1, GETUTCDATE()),
  ( 155, 'Reinsurance_Group'                         , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,   8, 0, 1, GETUTCDATE()),
  ( 156, 'Reinsurance_Group'                         , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,   9, 0, 1, GETUTCDATE());

-- [15] RecurringPayment_Group (21 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 157, 'RecurringPayment_Group'                    , 'RecurringPaymentGroupPK'                   , 'recurring_payment_group_id'                , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 158, 'RecurringPayment_Group'                    , 'RecurringPaymentGroupKey'                  , 'recurring_payment_group_key'               , 'INT'                 ,   2, 1, 1, GETUTCDATE()),
  ( 159, 'RecurringPayment_Group'                    , 'ActivityTypeFK'                            , 'activity_type_id'                          , 'INT'                 ,   3, 1, 1, GETUTCDATE()),
  ( 160, 'RecurringPayment_Group'                    , 'PayeeFK'                                   , 'payee_id'                                  , 'INT'                 ,   4, 1, 1, GETUTCDATE()),
  ( 161, 'RecurringPayment_Group'                    , 'NextEffectiveDate'                         , 'next_effective_timestamp'                  , 'TIMESTAMP'           ,   5, 1, 1, GETUTCDATE()),
  ( 162, 'RecurringPayment_Group'                    , 'PausedInd'                                 , 'is_paused'                                 , 'BOOLEAN'             ,   6, 1, 1, GETUTCDATE()),
  ( 163, 'RecurringPayment_Group'                    , 'DistributionType'                          , 'distribution_type'                         , 'STRING'              ,   7, 1, 1, GETUTCDATE()),
  ( 164, 'RecurringPayment_Group'                    , 'Lives'                                     , 'lives'                                     , 'STRING'              ,   8, 1, 1, GETUTCDATE()),
  ( 165, 'RecurringPayment_Group'                    , 'Frequency'                                 , 'frequency'                                 , 'STRING'              ,   9, 1, 1, GETUTCDATE()),
  ( 166, 'RecurringPayment_Group'                    , 'WithdrawalType'                            , 'withdrawal_type'                           , 'STRING'              ,  10, 1, 1, GETUTCDATE()),
  ( 167, 'RecurringPayment_Group'                    , 'FirstDate'                                 , 'first_timestamp'                           , 'TIMESTAMP'           ,  11, 1, 1, GETUTCDATE()),
  ( 168, 'RecurringPayment_Group'                    , 'PriorDate'                                 , 'prior_timestamp'                           , 'TIMESTAMP'           ,  12, 1, 1, GETUTCDATE()),
  ( 169, 'RecurringPayment_Group'                    , 'PriorActivityFK'                           , 'prior_activity_id'                         , 'INT'                 ,  13, 1, 1, GETUTCDATE()),
  ( 170, 'RecurringPayment_Group'                    , 'EligibleRMDDate'                           , 'eligible_rmd_timestamp'                    , 'TIMESTAMP'           ,  14, 1, 1, GETUTCDATE()),
  ( 171, 'RecurringPayment_Group'                    , 'CalculatedAmount'                          , 'calculated_amount'                         , 'DECIMAL(18,4)'       ,  15, 1, 1, GETUTCDATE()),
  ( 172, 'RecurringPayment_Group'                    , 'GrossNet'                                  , 'gross_net'                                 , 'STRING'              ,  16, 1, 1, GETUTCDATE()),
  ( 173, 'RecurringPayment_Group'                    , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,  17, 0, 1, GETUTCDATE()),
  ( 174, 'RecurringPayment_Group'                    , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,  18, 0, 1, GETUTCDATE()),
  ( 175, 'RecurringPayment_Group'                    , 'N/A'                                       , 'source_system'                             , 'STRING'              ,  19, 0, 1, GETUTCDATE()),
  ( 176, 'RecurringPayment_Group'                    , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  20, 0, 1, GETUTCDATE()),
  ( 177, 'RecurringPayment_Group'                    , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  21, 0, 1, GETUTCDATE());

-- [16] Note_Group (21 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 178, 'Note_Group'                                , 'NoteGroupPK'                               , 'note_group_id'                             , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 179, 'Note_Group'                                , 'SourceKey'                                 , 'source_key'                                , 'BIGINT'              ,   2, 1, 1, GETUTCDATE()),
  ( 180, 'Note_Group'                                , 'NoteGroupKey'                              , 'note_group_key'                            , 'INT'                 ,   3, 1, 1, GETUTCDATE()),
  ( 181, 'Note_Group'                                , 'Order'                                     , 'sort_order'                                , 'INT'                 ,   4, 1, 1, GETUTCDATE()),
  ( 182, 'Note_Group'                                , 'Text'                                      , 'note_text'                                 , 'STRING'              ,   5, 1, 1, GETUTCDATE()),
  ( 183, 'Note_Group'                                , 'Type'                                      , 'note_type'                                 , 'STRING'              ,   6, 1, 1, GETUTCDATE()),
  ( 184, 'Note_Group'                                , 'Role'                                      , 'role'                                      , 'STRING'              ,   7, 1, 1, GETUTCDATE()),
  ( 185, 'Note_Group'                                , 'MaintDate'                                 , 'maint_timestamp'                           , 'TIMESTAMP'           ,   8, 1, 1, GETUTCDATE()),
  ( 186, 'Note_Group'                                , 'MaintBy'                                   , 'maint_by'                                  , 'STRING'              ,   9, 1, 1, GETUTCDATE()),
  ( 187, 'Note_Group'                                , 'Call_ID'                                   , 'call_id'                                   , 'INT'                 ,  10, 1, 1, GETUTCDATE()),
  ( 188, 'Note_Group'                                , 'Call_Length'                               , 'call_length'                               , 'INT'                 ,  11, 1, 1, GETUTCDATE()),
  ( 189, 'Note_Group'                                , 'Call_StartDate'                            , 'call_start_timestamp'                      , 'TIMESTAMP'           ,  12, 1, 1, GETUTCDATE()),
  ( 190, 'Note_Group'                                , 'Call_InOut'                                , 'call_direction'                            , 'STRING'              ,  13, 1, 1, GETUTCDATE()),
  ( 191, 'Note_Group'                                , 'Call_Operators'                            , 'call_operators'                            , 'STRING'              ,  14, 1, 1, GETUTCDATE()),
  ( 192, 'Note_Group'                                , 'Call_FilePath'                             , 'call_file_path'                            , 'STRING'              ,  15, 1, 1, GETUTCDATE()),
  ( 193, 'Note_Group'                                , 'Call_EncryptKey'                           , 'call_encrypt_key'                          , 'STRING'              ,  16, 1, 1, GETUTCDATE()),
  ( 194, 'Note_Group'                                , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,  17, 0, 1, GETUTCDATE()),
  ( 195, 'Note_Group'                                , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,  18, 0, 1, GETUTCDATE()),
  ( 196, 'Note_Group'                                , 'N/A'                                       , 'source_system'                             , 'STRING'              ,  19, 0, 1, GETUTCDATE()),
  ( 197, 'Note_Group'                                , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  20, 0, 1, GETUTCDATE()),
  ( 198, 'Note_Group'                                , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  21, 0, 1, GETUTCDATE());

-- [17] IndexValue_Group (12 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 199, 'IndexValue_Group'                          , 'IndexValueGroupPK'                         , 'index_value_group_id'                      , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 200, 'IndexValue_Group'                          , 'IndexValueGroupKey'                        , 'index_value_group_key'                     , 'INT'                 ,   2, 1, 1, GETUTCDATE()),
  ( 201, 'IndexValue_Group'                          , 'Ticker'                                    , 'ticker'                                    , 'STRING'              ,   3, 1, 1, GETUTCDATE()),
  ( 202, 'IndexValue_Group'                          , 'IndexName'                                 , 'index_name'                                , 'STRING'              ,   4, 1, 1, GETUTCDATE()),
  ( 203, 'IndexValue_Group'                          , 'EffectiveDate'                             , 'effective_timestamp'                       , 'TIMESTAMP'           ,   5, 1, 1, GETUTCDATE()),
  ( 204, 'IndexValue_Group'                          , 'IndexValue'                                , 'index_value'                               , 'DECIMAL(18,4)'       ,   6, 1, 1, GETUTCDATE()),
  ( 205, 'IndexValue_Group'                          , 'Change'                                    , 'change_amount'                             , 'DECIMAL(18,4)'       ,   7, 1, 1, GETUTCDATE()),
  ( 206, 'IndexValue_Group'                          , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,   8, 0, 1, GETUTCDATE()),
  ( 207, 'IndexValue_Group'                          , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,   9, 0, 1, GETUTCDATE()),
  ( 208, 'IndexValue_Group'                          , 'N/A'                                       , 'source_system'                             , 'STRING'              ,  10, 0, 1, GETUTCDATE()),
  ( 209, 'IndexValue_Group'                          , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  11, 0, 1, GETUTCDATE()),
  ( 210, 'IndexValue_Group'                          , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  12, 0, 1, GETUTCDATE());

-- [18] ExternalAccount_Group (14 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 211, 'ExternalAccount_Group'                     , 'ExternalAccountGroupPK'                    , 'external_account_group_id'                 , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 212, 'ExternalAccount_Group'                     , 'ExternalAccountGroupKey'                   , 'external_account_group_key'                , 'INT'                 ,   2, 1, 1, GETUTCDATE()),
  ( 213, 'ExternalAccount_Group'                     , 'ExternalCompanyName'                       , 'external_company_name'                     , 'STRING'              ,   3, 1, 1, GETUTCDATE()),
  ( 214, 'ExternalAccount_Group'                     , 'AccountType'                               , 'account_type'                              , 'STRING'              ,   4, 1, 1, GETUTCDATE()),
  ( 215, 'ExternalAccount_Group'                     , 'AccountNumber'                             , 'account_number'                            , 'STRING'              ,   5, 1, 1, GETUTCDATE()),
  ( 216, 'ExternalAccount_Group'                     , 'Status'                                    , 'status'                                    , 'STRING'              ,   6, 1, 1, GETUTCDATE()),
  ( 217, 'ExternalAccount_Group'                     , 'Active'                                    , 'is_active'                                 , 'BOOLEAN'             ,   7, 1, 1, GETUTCDATE()),
  ( 218, 'ExternalAccount_Group'                     , 'StartDate'                                 , 'start_timestamp'                           , 'TIMESTAMP'           ,   8, 1, 1, GETUTCDATE()),
  ( 219, 'ExternalAccount_Group'                     , 'EndDate'                                   , 'end_timestamp'                             , 'TIMESTAMP'           ,   9, 1, 1, GETUTCDATE()),
  ( 220, 'ExternalAccount_Group'                     , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,  10, 0, 1, GETUTCDATE()),
  ( 221, 'ExternalAccount_Group'                     , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,  11, 0, 1, GETUTCDATE()),
  ( 222, 'ExternalAccount_Group'                     , 'N/A'                                       , 'source_system'                             , 'STRING'              ,  12, 0, 1, GETUTCDATE()),
  ( 223, 'ExternalAccount_Group'                     , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  13, 0, 1, GETUTCDATE()),
  ( 224, 'ExternalAccount_Group'                     , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  14, 0, 1, GETUTCDATE());

-- [19] ContractValue_Group (13 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 225, 'ContractValue_Group'                       , 'ContractValueGroupPK'                      , 'contract_value_group_id'                   , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 226, 'ContractValue_Group'                       , 'ContractValueGroupKey'                     , 'contract_value_group_key'                  , 'INT'                 ,   2, 1, 1, GETUTCDATE()),
  ( 227, 'ContractValue_Group'                       , 'ValueType'                                 , 'value_type'                                , 'STRING'              ,   3, 1, 1, GETUTCDATE()),
  ( 228, 'ContractValue_Group'                       , 'ValueDate'                                 , 'value_timestamp'                           , 'TIMESTAMP'           ,   4, 1, 1, GETUTCDATE()),
  ( 229, 'ContractValue_Group'                       , 'Value'                                     , 'value'                                     , 'DECIMAL(18,4)'       ,   5, 1, 1, GETUTCDATE()),
  ( 230, 'ContractValue_Group'                       , 'ValueAsDate'                               , 'value_as_timestamp'                        , 'TIMESTAMP'           ,   6, 1, 1, GETUTCDATE()),
  ( 231, 'ContractValue_Group'                       , 'StartDate'                                 , 'start_timestamp'                           , 'TIMESTAMP'           ,   7, 1, 1, GETUTCDATE()),
  ( 232, 'ContractValue_Group'                       , 'EndDate'                                   , 'end_timestamp'                             , 'TIMESTAMP'           ,   8, 1, 1, GETUTCDATE()),
  ( 233, 'ContractValue_Group'                       , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,   9, 0, 1, GETUTCDATE()),
  ( 234, 'ContractValue_Group'                       , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,  10, 0, 1, GETUTCDATE()),
  ( 235, 'ContractValue_Group'                       , 'N/A'                                       , 'source_system'                             , 'STRING'              ,  11, 0, 1, GETUTCDATE()),
  ( 236, 'ContractValue_Group'                       , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  12, 0, 1, GETUTCDATE()),
  ( 237, 'ContractValue_Group'                       , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  13, 0, 1, GETUTCDATE());

-- [20] ContractDeposit_Group (22 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 238, 'ContractDeposit_Group'                     , 'ContractDepositGroupPK'                    , 'contract_deposit_group_id'                 , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 239, 'ContractDeposit_Group'                     , 'SourceKey'                                 , 'source_key'                                , 'BIGINT'              ,   2, 1, 1, GETUTCDATE()),
  ( 240, 'ContractDeposit_Group'                     , 'ContractDepositGroupKey'                   , 'contract_deposit_group_key'                , 'INT'                 ,   3, 1, 1, GETUTCDATE()),
  ( 241, 'ContractDeposit_Group'                     , 'DepositType'                               , 'deposit_type'                              , 'STRING'              ,   4, 1, 1, GETUTCDATE()),
  ( 242, 'ContractDeposit_Group'                     , 'DepositSource'                             , 'deposit_source'                            , 'STRING'              ,   5, 1, 1, GETUTCDATE()),
  ( 243, 'ContractDeposit_Group'                     , 'OriginalContract'                          , 'original_contract'                         , 'STRING'              ,   6, 1, 1, GETUTCDATE()),
  ( 244, 'ContractDeposit_Group'                     , 'DateReceived'                              , 'date_received_timestamp'                   , 'TIMESTAMP'           ,   7, 1, 1, GETUTCDATE()),
  ( 245, 'ContractDeposit_Group'                     , 'ProcessDate'                               , 'process_timestamp'                         , 'TIMESTAMP'           ,   8, 1, 1, GETUTCDATE()),
  ( 246, 'ContractDeposit_Group'                     , 'TaxYear'                                   , 'tax_year'                                  , 'INT'                 ,   9, 1, 1, GETUTCDATE()),
  ( 247, 'ContractDeposit_Group'                     , 'ReplacementType'                           , 'replacement_type'                          , 'STRING'              ,  10, 1, 1, GETUTCDATE()),
  ( 248, 'ContractDeposit_Group'                     , 'PremiumType'                               , 'premium_type'                              , 'STRING'              ,  11, 1, 1, GETUTCDATE()),
  ( 249, 'ContractDeposit_Group'                     , 'PlannedIndicator'                          , 'planned_indicator'                         , 'STRING'              ,  12, 1, 1, GETUTCDATE()),
  ( 250, 'ContractDeposit_Group'                     , 'Reference'                                 , 'reference'                                 , 'STRING'              ,  13, 1, 1, GETUTCDATE()),
  ( 251, 'ContractDeposit_Group'                     , 'AnticipatedAmount'                         , 'anticipated_amount'                        , 'DECIMAL(18,4)'       ,  14, 1, 1, GETUTCDATE()),
  ( 252, 'ContractDeposit_Group'                     , 'ActualAmount'                              , 'actual_amount'                             , 'DECIMAL(18,4)'       ,  15, 1, 1, GETUTCDATE()),
  ( 253, 'ContractDeposit_Group'                     , 'CostBasis'                                 , 'cost_basis'                                , 'DECIMAL(18,4)'       ,  16, 1, 1, GETUTCDATE()),
  ( 254, 'ContractDeposit_Group'                     , 'RefundAmount'                              , 'refund_amount'                             , 'DECIMAL(18,4)'       ,  17, 1, 1, GETUTCDATE()),
  ( 255, 'ContractDeposit_Group'                     , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,  18, 0, 1, GETUTCDATE()),
  ( 256, 'ContractDeposit_Group'                     , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,  19, 0, 1, GETUTCDATE()),
  ( 257, 'ContractDeposit_Group'                     , 'N/A'                                       , 'source_system'                             , 'STRING'              ,  20, 0, 1, GETUTCDATE()),
  ( 258, 'ContractDeposit_Group'                     , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  21, 0, 1, GETUTCDATE()),
  ( 259, 'ContractDeposit_Group'                     , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  22, 0, 1, GETUTCDATE());

-- [21] AgentSummary_Group (10 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 260, 'AgentSummary_Group'                        , 'AgentSummaryGroupPK'                       , 'agent_summary_group_id'                    , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 261, 'AgentSummary_Group'                        , 'AgentSummaryGroupKey'                      , 'agent_summary_group_key'                   , 'INT'                 ,   2, 1, 1, GETUTCDATE()),
  ( 262, 'AgentSummary_Group'                        , 'SummaryType'                               , 'summary_type'                              , 'STRING'              ,   3, 1, 1, GETUTCDATE()),
  ( 263, 'AgentSummary_Group'                        , 'SummaryDate'                               , 'summary_timestamp'                         , 'TIMESTAMP'           ,   4, 1, 1, GETUTCDATE()),
  ( 264, 'AgentSummary_Group'                        , 'SummaryValue'                              , 'summary_value'                             , 'DECIMAL(18,4)'       ,   5, 1, 1, GETUTCDATE()),
  ( 265, 'AgentSummary_Group'                        , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,   6, 0, 1, GETUTCDATE()),
  ( 266, 'AgentSummary_Group'                        , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,   7, 0, 1, GETUTCDATE()),
  ( 267, 'AgentSummary_Group'                        , 'N/A'                                       , 'source_system'                             , 'STRING'              ,   8, 0, 1, GETUTCDATE()),
  ( 268, 'AgentSummary_Group'                        , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,   9, 0, 1, GETUTCDATE()),
  ( 269, 'AgentSummary_Group'                        , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  10, 0, 1, GETUTCDATE());

-- [22] AgentPrincipal_Group (10 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 270, 'AgentPrincipal_Group'                      , 'AgentPrincipalGroupPK'                     , 'agent_principal_group_id'                  , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 271, 'AgentPrincipal_Group'                      , 'AgentPrincipalGroupKey'                    , 'agent_principal_group_key'                 , 'INT'                 ,   2, 1, 1, GETUTCDATE()),
  ( 272, 'AgentPrincipal_Group'                      , 'PrincipalAgentFK'                          , 'principal_agent_id'                        , 'INT'                 ,   3, 1, 1, GETUTCDATE()),
  ( 273, 'AgentPrincipal_Group'                      , 'StartDate'                                 , 'start_timestamp'                           , 'TIMESTAMP'           ,   4, 1, 1, GETUTCDATE()),
  ( 274, 'AgentPrincipal_Group'                      , 'EndDate'                                   , 'end_timestamp'                             , 'TIMESTAMP'           ,   5, 1, 1, GETUTCDATE()),
  ( 275, 'AgentPrincipal_Group'                      , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,   6, 0, 1, GETUTCDATE()),
  ( 276, 'AgentPrincipal_Group'                      , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,   7, 0, 1, GETUTCDATE()),
  ( 277, 'AgentPrincipal_Group'                      , 'N/A'                                       , 'source_system'                             , 'STRING'              ,   8, 0, 1, GETUTCDATE()),
  ( 278, 'AgentPrincipal_Group'                      , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,   9, 0, 1, GETUTCDATE()),
  ( 279, 'AgentPrincipal_Group'                      , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  10, 0, 1, GETUTCDATE());

-- [23] AgentLicense_Group (16 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 280, 'AgentLicense_Group'                        , 'AgentLicenseGroupPK'                       , 'agent_license_group_id'                    , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 281, 'AgentLicense_Group'                        , 'SourceKey'                                 , 'source_key'                                , 'BIGINT'              ,   2, 1, 1, GETUTCDATE()),
  ( 282, 'AgentLicense_Group'                        , 'AgentLicenseGroupKey'                      , 'agent_license_group_key'                   , 'INT'                 ,   3, 1, 1, GETUTCDATE()),
  ( 283, 'AgentLicense_Group'                        , 'LicenseType'                               , 'license_type'                              , 'STRING'              ,   4, 1, 1, GETUTCDATE()),
  ( 284, 'AgentLicense_Group'                        , 'LicenseState'                              , 'license_state'                             , 'STRING'              ,   5, 1, 1, GETUTCDATE()),
  ( 285, 'AgentLicense_Group'                        , 'Resident'                                  , 'resident'                                  , 'STRING'              ,   6, 1, 1, GETUTCDATE()),
  ( 286, 'AgentLicense_Group'                        , 'LicenseNumber'                             , 'license_number'                            , 'STRING'              ,   7, 1, 1, GETUTCDATE()),
  ( 287, 'AgentLicense_Group'                        , 'Status'                                    , 'status'                                    , 'STRING'              ,   8, 1, 1, GETUTCDATE()),
  ( 288, 'AgentLicense_Group'                        , 'EffectiveDate'                             , 'effective_timestamp'                       , 'TIMESTAMP'           ,   9, 1, 1, GETUTCDATE()),
  ( 289, 'AgentLicense_Group'                        , 'ExpirationDate'                            , 'expiration_timestamp'                      , 'TIMESTAMP'           ,  10, 1, 1, GETUTCDATE()),
  ( 290, 'AgentLicense_Group'                        , 'TerminationDate'                           , 'termination_timestamp'                     , 'TIMESTAMP'           ,  11, 1, 1, GETUTCDATE()),
  ( 291, 'AgentLicense_Group'                        , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,  12, 0, 1, GETUTCDATE()),
  ( 292, 'AgentLicense_Group'                        , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,  13, 0, 1, GETUTCDATE()),
  ( 293, 'AgentLicense_Group'                        , 'N/A'                                       , 'source_system'                             , 'STRING'              ,  14, 0, 1, GETUTCDATE()),
  ( 294, 'AgentLicense_Group'                        , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  15, 0, 1, GETUTCDATE()),
  ( 295, 'AgentLicense_Group'                        , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  16, 0, 1, GETUTCDATE());

-- [24] AdditionalInfo_Group (19 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 296, 'AdditionalInfo_Group'                      , 'AdditionalInfoGroupPK'                     , 'additional_info_group_id'                  , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 297, 'AdditionalInfo_Group'                      , 'AdditionalInfoGroupKey'                    , 'additional_info_group_key'                 , 'INT'                 ,   2, 1, 1, GETUTCDATE()),
  ( 298, 'AdditionalInfo_Group'                      , 'AdditionalInfoSource'                      , 'additional_info_source'                    , 'STRING'              ,   3, 1, 1, GETUTCDATE()),
  ( 299, 'AdditionalInfo_Group'                      , 'AdditionalInfoType'                        , 'additional_info_type'                      , 'STRING'              ,   4, 1, 1, GETUTCDATE()),
  ( 300, 'AdditionalInfo_Group'                      , 'AdditionalInfoDescription'                 , 'additional_info_description'               , 'STRING'              ,   5, 1, 1, GETUTCDATE()),
  ( 301, 'AdditionalInfo_Group'                      , 'AdditionalInfoValue'                       , 'additional_info_value'                     , 'STRING'              ,   6, 1, 1, GETUTCDATE()),
  ( 302, 'AdditionalInfo_Group'                      , 'AddressLine1'                              , 'address_line_1'                            , 'STRING'              ,   7, 1, 1, GETUTCDATE()),
  ( 303, 'AdditionalInfo_Group'                      , 'AddressLine2'                              , 'address_line_2'                            , 'STRING'              ,   8, 1, 1, GETUTCDATE()),
  ( 304, 'AdditionalInfo_Group'                      , 'AddressLine3'                              , 'address_line_3'                            , 'STRING'              ,   9, 1, 1, GETUTCDATE()),
  ( 305, 'AdditionalInfo_Group'                      , 'AddressLine4'                              , 'address_line_4'                            , 'STRING'              ,  10, 1, 1, GETUTCDATE()),
  ( 306, 'AdditionalInfo_Group'                      , 'City'                                      , 'city'                                      , 'STRING'              ,  11, 1, 1, GETUTCDATE()),
  ( 307, 'AdditionalInfo_Group'                      , 'State'                                     , 'state'                                     , 'STRING'              ,  12, 1, 1, GETUTCDATE()),
  ( 308, 'AdditionalInfo_Group'                      , 'ZipCode'                                   , 'zip_code'                                  , 'STRING'              ,  13, 1, 1, GETUTCDATE()),
  ( 309, 'AdditionalInfo_Group'                      , 'EffectiveDate'                             , 'effective_timestamp'                       , 'TIMESTAMP'           ,  14, 1, 1, GETUTCDATE()),
  ( 310, 'AdditionalInfo_Group'                      , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,  15, 0, 1, GETUTCDATE()),
  ( 311, 'AdditionalInfo_Group'                      , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,  16, 0, 1, GETUTCDATE()),
  ( 312, 'AdditionalInfo_Group'                      , 'N/A'                                       , 'source_system'                             , 'STRING'              ,  17, 0, 1, GETUTCDATE()),
  ( 313, 'AdditionalInfo_Group'                      , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  18, 0, 1, GETUTCDATE()),
  ( 314, 'AdditionalInfo_Group'                      , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  19, 0, 1, GETUTCDATE());

-- [25] AdditionalClient_Group (12 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 315, 'AdditionalClient_Group'                    , 'AdditionalClientGroupPK'                   , 'additional_client_group_id'                , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 316, 'AdditionalClient_Group'                    , 'AdditionalClientGroupKey'                  , 'additional_client_group_key'               , 'INT'                 ,   2, 1, 1, GETUTCDATE()),
  ( 317, 'AdditionalClient_Group'                    , 'ClientFK'                                  , 'client_id'                                 , 'INT'                 ,   3, 1, 1, GETUTCDATE()),
  ( 318, 'AdditionalClient_Group'                    , 'AdditionalType'                            , 'additional_type'                           , 'STRING'              ,   4, 1, 1, GETUTCDATE()),
  ( 319, 'AdditionalClient_Group'                    , 'Relation'                                  , 'relation'                                  , 'STRING'              ,   5, 1, 1, GETUTCDATE()),
  ( 320, 'AdditionalClient_Group'                    , 'AllocationPercent'                         , 'allocation_percent'                        , 'DECIMAL(18,4)'       ,   6, 1, 1, GETUTCDATE()),
  ( 321, 'AdditionalClient_Group'                    , 'Active'                                    , 'is_active'                                 , 'BOOLEAN'             ,   7, 1, 1, GETUTCDATE()),
  ( 322, 'AdditionalClient_Group'                    , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,   8, 0, 1, GETUTCDATE()),
  ( 323, 'AdditionalClient_Group'                    , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,   9, 0, 1, GETUTCDATE()),
  ( 324, 'AdditionalClient_Group'                    , 'N/A'                                       , 'source_system'                             , 'STRING'              ,  10, 0, 1, GETUTCDATE()),
  ( 325, 'AdditionalClient_Group'                    , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  11, 0, 1, GETUTCDATE()),
  ( 326, 'AdditionalClient_Group'                    , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  12, 0, 1, GETUTCDATE());

-- [26] AccountingReporting_Group (10 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 327, 'AccountingReporting_Group'                 , 'AccountingReportingGroupPK'                , 'accounting_reporting_group_id'             , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 328, 'AccountingReporting_Group'                 , 'AccountingReportingGroupKey'               , 'accounting_reporting_group_key'            , 'INT'                 ,   2, 1, 1, GETUTCDATE()),
  ( 329, 'AccountingReporting_Group'                 , 'ReportingCode'                             , 'reporting_code'                            , 'STRING'              ,   3, 1, 1, GETUTCDATE()),
  ( 330, 'AccountingReporting_Group'                 , 'ReportingClassCode'                        , 'reporting_class_code'                      , 'STRING'              ,   4, 1, 1, GETUTCDATE()),
  ( 331, 'AccountingReporting_Group'                 , 'ReportingDescription'                      , 'reporting_description'                     , 'STRING'              ,   5, 1, 1, GETUTCDATE()),
  ( 332, 'AccountingReporting_Group'                 , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,   6, 0, 1, GETUTCDATE()),
  ( 333, 'AccountingReporting_Group'                 , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,   7, 0, 1, GETUTCDATE()),
  ( 334, 'AccountingReporting_Group'                 , 'N/A'                                       , 'source_system'                             , 'STRING'              ,   8, 0, 1, GETUTCDATE()),
  ( 335, 'AccountingReporting_Group'                 , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,   9, 0, 1, GETUTCDATE()),
  ( 336, 'AccountingReporting_Group'                 , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  10, 0, 1, GETUTCDATE());

-- [27] ProductVariationDetail (9 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 337, 'ProductVariationDetail'                    , 'ProductVariationDetailPK'                  , 'product_variation_detail_id'               , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 338, 'ProductVariationDetail'                    , 'DisclosureText'                            , 'disclosure_text'                           , 'STRING'              ,   2, 1, 1, GETUTCDATE()),
  ( 339, 'ProductVariationDetail'                    , 'SortOrder'                                 , 'sort_order'                                , 'INT'                 ,   3, 1, 1, GETUTCDATE()),
  ( 340, 'ProductVariationDetail'                    , 'Type'                                      , 'type'                                      , 'STRING'              ,   4, 1, 1, GETUTCDATE()),
  ( 341, 'ProductVariationDetail'                    , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,   5, 0, 1, GETUTCDATE()),
  ( 342, 'ProductVariationDetail'                    , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,   6, 0, 1, GETUTCDATE()),
  ( 343, 'ProductVariationDetail'                    , 'N/A'                                       , 'source_system'                             , 'STRING'              ,   7, 0, 1, GETUTCDATE()),
  ( 344, 'ProductVariationDetail'                    , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,   8, 0, 1, GETUTCDATE()),
  ( 345, 'ProductVariationDetail'                    , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,   9, 0, 1, GETUTCDATE());

-- [28] ProductStateVariation (9 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 346, 'ProductStateVariation'                     , 'ProductStateVariationPK'                   , 'product_state_variation_id'                , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 347, 'ProductStateVariation'                     , 'ProductFK'                                 , 'product_id'                                , 'INT'                 ,   2, 1, 1, GETUTCDATE()),
  ( 348, 'ProductStateVariation'                     , 'StateCode'                                 , 'state_code'                                , 'STRING'              ,   3, 1, 1, GETUTCDATE()),
  ( 349, 'ProductStateVariation'                     , 'ProductVariationDetailFK'                  , 'product_variation_detail_id'               , 'INT'                 ,   4, 1, 1, GETUTCDATE()),
  ( 350, 'ProductStateVariation'                     , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,   5, 0, 1, GETUTCDATE()),
  ( 351, 'ProductStateVariation'                     , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,   6, 0, 1, GETUTCDATE()),
  ( 352, 'ProductStateVariation'                     , 'N/A'                                       , 'source_system'                             , 'STRING'              ,   7, 0, 1, GETUTCDATE()),
  ( 353, 'ProductStateVariation'                     , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,   8, 0, 1, GETUTCDATE()),
  ( 354, 'ProductStateVariation'                     , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,   9, 0, 1, GETUTCDATE());

-- [29] ProductStateApprovalDisclosure (10 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 355, 'ProductStateApprovalDisclosure'            , 'PSADisclosurePK'                           , 'product_state_approval_disclosure_id'      , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 356, 'ProductStateApprovalDisclosure'            , 'ProductStateApprovalFK'                    , 'product_state_approval_id'                 , 'INT'                 ,   2, 1, 1, GETUTCDATE()),
  ( 357, 'ProductStateApprovalDisclosure'            , 'MarketingNameOverride'                     , 'marketing_name_override'                   , 'STRING'              ,   3, 1, 1, GETUTCDATE()),
  ( 358, 'ProductStateApprovalDisclosure'            , 'DisclosureText'                            , 'disclosure_text'                           , 'STRING'              ,   4, 1, 1, GETUTCDATE()),
  ( 359, 'ProductStateApprovalDisclosure'            , 'SortOrder'                                 , 'sort_order'                                , 'INT'                 ,   5, 1, 1, GETUTCDATE()),
  ( 360, 'ProductStateApprovalDisclosure'            , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,   6, 0, 1, GETUTCDATE()),
  ( 361, 'ProductStateApprovalDisclosure'            , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,   7, 0, 1, GETUTCDATE()),
  ( 362, 'ProductStateApprovalDisclosure'            , 'N/A'                                       , 'source_system'                             , 'STRING'              ,   8, 0, 1, GETUTCDATE()),
  ( 363, 'ProductStateApprovalDisclosure'            , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,   9, 0, 1, GETUTCDATE()),
  ( 364, 'ProductStateApprovalDisclosure'            , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  10, 0, 1, GETUTCDATE());

-- [30] ProductStateApproval (11 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 365, 'ProductStateApproval'                      , 'ProductStateApprovalPK'                    , 'product_state_approval_id'                 , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 366, 'ProductStateApproval'                      , 'ProductFK'                                 , 'product_id'                                , 'INT'                 ,   2, 1, 1, GETUTCDATE()),
  ( 367, 'ProductStateApproval'                      , 'StateCode'                                 , 'state_code'                                , 'STRING'              ,   3, 1, 1, GETUTCDATE()),
  ( 368, 'ProductStateApproval'                      , 'ApprovedInd'                               , 'is_approved'                               , 'BOOLEAN'             ,   4, 1, 1, GETUTCDATE()),
  ( 369, 'ProductStateApproval'                      , 'StartDate'                                 , 'start_timestamp'                           , 'TIMESTAMP'           ,   5, 1, 1, GETUTCDATE()),
  ( 370, 'ProductStateApproval'                      , 'EndDate'                                   , 'end_timestamp'                             , 'TIMESTAMP'           ,   6, 1, 1, GETUTCDATE()),
  ( 371, 'ProductStateApproval'                      , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,   7, 0, 1, GETUTCDATE()),
  ( 372, 'ProductStateApproval'                      , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,   8, 0, 1, GETUTCDATE()),
  ( 373, 'ProductStateApproval'                      , 'N/A'                                       , 'source_system'                             , 'STRING'              ,   9, 0, 1, GETUTCDATE()),
  ( 374, 'ProductStateApproval'                      , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  10, 0, 1, GETUTCDATE()),
  ( 375, 'ProductStateApproval'                      , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  11, 0, 1, GETUTCDATE());

-- [31] hedge.Ratios (12 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 376, 'hedge.Ratios'                              , 'RatiosPK'                                  , 'ratios_id'                                 , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 377, 'hedge.Ratios'                              , 'ContractFK'                                , 'contract_id'                               , 'INT'                 ,   2, 1, 1, GETUTCDATE()),
  ( 378, 'hedge.Ratios'                              , 'ValueDate'                                 , 'value_timestamp'                           , 'TIMESTAMP'           ,   3, 1, 1, GETUTCDATE()),
  ( 379, 'hedge.Ratios'                              , 'BaseHedgeRatio'                            , 'base_hedge_ratio'                          , 'DECIMAL(18,4)'       ,   4, 1, 1, GETUTCDATE()),
  ( 380, 'hedge.Ratios'                              , 'BaseSurvivalRatio'                         , 'base_survival_ratio'                       , 'DECIMAL(18,4)'       ,   5, 1, 1, GETUTCDATE()),
  ( 381, 'hedge.Ratios'                              , 'StartDate'                                 , 'start_timestamp'                           , 'TIMESTAMP'           ,   6, 1, 1, GETUTCDATE()),
  ( 382, 'hedge.Ratios'                              , 'EndDate'                                   , 'end_timestamp'                             , 'TIMESTAMP'           ,   7, 1, 1, GETUTCDATE()),
  ( 383, 'hedge.Ratios'                              , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,   8, 0, 1, GETUTCDATE()),
  ( 384, 'hedge.Ratios'                              , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,   9, 0, 1, GETUTCDATE()),
  ( 385, 'hedge.Ratios'                              , 'N/A'                                       , 'source_system'                             , 'STRING'              ,  10, 0, 1, GETUTCDATE()),
  ( 386, 'hedge.Ratios'                              , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  11, 0, 1, GETUTCDATE()),
  ( 387, 'hedge.Ratios'                              , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  12, 0, 1, GETUTCDATE());

-- [32] hedge.Options (26 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 388, 'hedge.Options'                             , 'OptionsPK'                                 , 'options_id'                                , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 389, 'hedge.Options'                             , 'ContractFK'                                , 'contract_id'                               , 'INT'                 ,   2, 1, 1, GETUTCDATE()),
  ( 390, 'hedge.Options'                             , 'InvestmentFK'                              , 'investment_id'                             , 'INT'                 ,   3, 1, 1, GETUTCDATE()),
  ( 391, 'hedge.Options'                             , 'RenewalDate'                               , 'renewal_timestamp'                         , 'TIMESTAMP'           ,   4, 1, 1, GETUTCDATE()),
  ( 392, 'hedge.Options'                             , 'IndexValue'                                , 'index_value'                               , 'DECIMAL(18,4)'       ,   5, 1, 1, GETUTCDATE()),
  ( 393, 'hedge.Options'                             , 'HedgingPercentage'                         , 'hedging_percentage'                        , 'DECIMAL(18,4)'       ,   6, 1, 1, GETUTCDATE()),
  ( 394, 'hedge.Options'                             , 'HedgeID1'                                  , 'hedge_id_1'                                , 'STRING'              ,   7, 1, 1, GETUTCDATE()),
  ( 395, 'hedge.Options'                             , 'HedgeID2'                                  , 'hedge_id_2'                                , 'STRING'              ,   8, 1, 1, GETUTCDATE()),
  ( 396, 'hedge.Options'                             , 'HedgeRenewalDate'                          , 'hedge_renewal_timestamp'                   , 'TIMESTAMP'           ,   9, 1, 1, GETUTCDATE()),
  ( 397, 'hedge.Options'                             , 'ValueDate'                                 , 'value_timestamp'                           , 'TIMESTAMP'           ,  10, 1, 1, GETUTCDATE()),
  ( 398, 'hedge.Options'                             , 'SeriatimHedgeRatio'                        , 'seriatim_hedge_ratio'                      , 'DECIMAL(18,4)'       ,  11, 1, 1, GETUTCDATE()),
  ( 399, 'hedge.Options'                             , 'PresentValue'                              , 'present_value'                             , 'DECIMAL(18,4)'       ,  12, 1, 1, GETUTCDATE()),
  ( 400, 'hedge.Options'                             , 'Delta'                                     , 'delta'                                     , 'DECIMAL(18,4)'       ,  13, 1, 1, GETUTCDATE()),
  ( 401, 'hedge.Options'                             , 'Gamma'                                     , 'gamma'                                     , 'DECIMAL(18,4)'       ,  14, 1, 1, GETUTCDATE()),
  ( 402, 'hedge.Options'                             , 'Vega'                                      , 'vega'                                      , 'DECIMAL(18,4)'       ,  15, 1, 1, GETUTCDATE()),
  ( 403, 'hedge.Options'                             , 'Rho'                                       , 'rho'                                       , 'DECIMAL(18,4)'       ,  16, 1, 1, GETUTCDATE()),
  ( 404, 'hedge.Options'                             , 'Theta'                                     , 'theta'                                     , 'DECIMAL(18,4)'       ,  17, 1, 1, GETUTCDATE()),
  ( 405, 'hedge.Options'                             , 'NeedsHedged'                               , 'needs_hedged'                              , 'BOOLEAN'             ,  18, 1, 1, GETUTCDATE()),
  ( 406, 'hedge.Options'                             , 'IsHedged'                                  , 'is_hedged'                                 , 'BOOLEAN'             ,  19, 1, 1, GETUTCDATE()),
  ( 407, 'hedge.Options'                             , 'StartDate'                                 , 'start_timestamp'                           , 'TIMESTAMP'           ,  20, 1, 1, GETUTCDATE()),
  ( 408, 'hedge.Options'                             , 'EndDate'                                   , 'end_timestamp'                             , 'TIMESTAMP'           ,  21, 1, 1, GETUTCDATE()),
  ( 409, 'hedge.Options'                             , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,  22, 0, 1, GETUTCDATE()),
  ( 410, 'hedge.Options'                             , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,  23, 0, 1, GETUTCDATE()),
  ( 411, 'hedge.Options'                             , 'N/A'                                       , 'source_system'                             , 'STRING'              ,  24, 0, 1, GETUTCDATE()),
  ( 412, 'hedge.Options'                             , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  25, 0, 1, GETUTCDATE()),
  ( 413, 'hedge.Options'                             , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  26, 0, 1, GETUTCDATE());

-- [33] State (8 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 414, 'State'                                     , 'StateCode'                                 , 'state_code'                                , 'STRING'              ,   1, 1, 1, GETUTCDATE()),
  ( 415, 'State'                                     , 'StateName'                                 , 'state_name'                                , 'STRING'              ,   2, 1, 1, GETUTCDATE()),
  ( 416, 'State'                                     , 'DisplayOrder'                              , 'display_order'                             , 'INT'                 ,   3, 1, 1, GETUTCDATE()),
  ( 417, 'State'                                     , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,   4, 0, 1, GETUTCDATE()),
  ( 418, 'State'                                     , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,   5, 0, 1, GETUTCDATE()),
  ( 419, 'State'                                     , 'N/A'                                       , 'source_system'                             , 'STRING'              ,   6, 0, 1, GETUTCDATE()),
  ( 420, 'State'                                     , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,   7, 0, 1, GETUTCDATE()),
  ( 421, 'State'                                     , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,   8, 0, 1, GETUTCDATE());

-- [34] Date (37 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 422, 'Date'                                      , 'DatePK'                                    , 'date_id'                                   , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 423, 'Date'                                      , 'Date'                                      , 'calendar_timestamp'                        , 'TIMESTAMP'           ,   2, 1, 1, GETUTCDATE()),
  ( 424, 'Date'                                      , 'DateDisplay'                               , 'date_display'                              , 'STRING'              ,   3, 1, 1, GETUTCDATE()),
  ( 425, 'Date'                                      , 'DayOfMonth'                                , 'day_of_month'                              , 'STRING'              ,   4, 1, 1, GETUTCDATE()),
  ( 426, 'Date'                                      , 'DaySuffix'                                 , 'day_suffix'                                , 'STRING'              ,   5, 1, 1, GETUTCDATE()),
  ( 427, 'Date'                                      , 'DayName'                                   , 'day_name'                                  , 'STRING'              ,   6, 1, 1, GETUTCDATE()),
  ( 428, 'Date'                                      , 'DayOfWeek'                                 , 'day_of_week'                               , 'STRING'              ,   7, 1, 1, GETUTCDATE()),
  ( 429, 'Date'                                      , 'DayOfWeekInMonth'                          , 'day_of_week_in_month'                      , 'STRING'              ,   8, 1, 1, GETUTCDATE()),
  ( 430, 'Date'                                      , 'DayOfWeekInYear'                           , 'day_of_week_in_year'                       , 'STRING'              ,   9, 1, 1, GETUTCDATE()),
  ( 431, 'Date'                                      , 'DayOfYear'                                 , 'day_of_year'                               , 'STRING'              ,  10, 1, 1, GETUTCDATE()),
  ( 432, 'Date'                                      , 'WeekOfMonth'                               , 'week_of_month'                             , 'STRING'              ,  11, 1, 1, GETUTCDATE()),
  ( 433, 'Date'                                      , 'WeekOfQuarter'                             , 'week_of_quarter'                           , 'STRING'              ,  12, 1, 1, GETUTCDATE()),
  ( 434, 'Date'                                      , 'WeekOfYear'                                , 'week_of_year'                              , 'STRING'              ,  13, 1, 1, GETUTCDATE()),
  ( 435, 'Date'                                      , 'Month'                                     , 'month'                                     , 'STRING'              ,  14, 1, 1, GETUTCDATE()),
  ( 436, 'Date'                                      , 'MonthName'                                 , 'month_name'                                , 'STRING'              ,  15, 1, 1, GETUTCDATE()),
  ( 437, 'Date'                                      , 'MonthOfQuarter'                            , 'month_of_quarter'                          , 'STRING'              ,  16, 1, 1, GETUTCDATE()),
  ( 438, 'Date'                                      , 'Quarter'                                   , 'quarter'                                   , 'STRING'              ,  17, 1, 1, GETUTCDATE()),
  ( 439, 'Date'                                      , 'QuarterName'                               , 'quarter_name'                              , 'STRING'              ,  18, 1, 1, GETUTCDATE()),
  ( 440, 'Date'                                      , 'Year'                                      , 'year'                                      , 'STRING'              ,  19, 1, 1, GETUTCDATE()),
  ( 441, 'Date'                                      , 'YearName'                                  , 'year_name'                                 , 'STRING'              ,  20, 1, 1, GETUTCDATE()),
  ( 442, 'Date'                                      , 'MonthYear'                                 , 'month_year'                                , 'STRING'              ,  21, 1, 1, GETUTCDATE()),
  ( 443, 'Date'                                      , 'MMYYYY'                                    , 'mmyyyy'                                    , 'STRING'              ,  22, 1, 1, GETUTCDATE()),
  ( 444, 'Date'                                      , 'FirstDayOfMonth'                           , 'first_day_of_month'                        , 'DATE'                ,  23, 1, 1, GETUTCDATE()),
  ( 445, 'Date'                                      , 'LastDayOfMonth'                            , 'last_day_of_month'                         , 'DATE'                ,  24, 1, 1, GETUTCDATE()),
  ( 446, 'Date'                                      , 'FirstDayOfQuarter'                         , 'first_day_of_quarter'                      , 'DATE'                ,  25, 1, 1, GETUTCDATE()),
  ( 447, 'Date'                                      , 'LastDayOfQuarter'                          , 'last_day_of_quarter'                       , 'DATE'                ,  26, 1, 1, GETUTCDATE()),
  ( 448, 'Date'                                      , 'FirstDayOfYear'                            , 'first_day_of_year'                         , 'DATE'                ,  27, 1, 1, GETUTCDATE()),
  ( 449, 'Date'                                      , 'LastDayOfYear'                             , 'last_day_of_year'                          , 'DATE'                ,  28, 1, 1, GETUTCDATE()),
  ( 450, 'Date'                                      , 'IsWeekday'                                 , 'is_weekday'                                , 'BOOLEAN'             ,  29, 1, 1, GETUTCDATE()),
  ( 451, 'Date'                                      , 'IsHoliday'                                 , 'is_holiday'                                , 'BOOLEAN'             ,  30, 1, 1, GETUTCDATE()),
  ( 452, 'Date'                                      , 'HolidayName'                               , 'holiday_name'                              , 'STRING'              ,  31, 1, 1, GETUTCDATE()),
  ( 453, 'Date'                                      , 'IsLastDayOfMonth'                          , 'is_last_day_of_month'                      , 'BOOLEAN'             ,  32, 1, 1, GETUTCDATE()),
  ( 454, 'Date'                                      , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,  33, 0, 1, GETUTCDATE()),
  ( 455, 'Date'                                      , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,  34, 0, 1, GETUTCDATE()),
  ( 456, 'Date'                                      , 'N/A'                                       , 'source_system'                             , 'STRING'              ,  35, 0, 1, GETUTCDATE()),
  ( 457, 'Date'                                      , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  36, 0, 1, GETUTCDATE()),
  ( 458, 'Date'                                      , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  37, 0, 1, GETUTCDATE());

-- [35] TrainingCourse (11 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 459, 'TrainingCourse'                            , 'TrainingCoursePK'                          , 'training_course_id'                        , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 460, 'TrainingCourse'                            , 'CourseName'                                , 'course_name'                               , 'STRING'              ,   2, 1, 1, GETUTCDATE()),
  ( 461, 'TrainingCourse'                            , 'Context'                                   , 'context'                                   , 'STRING'              ,   3, 1, 1, GETUTCDATE()),
  ( 462, 'TrainingCourse'                            , 'TrainingProductGroupKey'                   , 'training_product_group_key'                , 'INT'                 ,   4, 1, 1, GETUTCDATE()),
  ( 463, 'TrainingCourse'                            , 'TrainingStateGroupKey'                     , 'training_state_group_key'                  , 'INT'                 ,   5, 1, 1, GETUTCDATE()),
  ( 464, 'TrainingCourse'                            , 'Description'                               , 'description'                               , 'STRING'              ,   6, 1, 1, GETUTCDATE()),
  ( 465, 'TrainingCourse'                            , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,   7, 0, 1, GETUTCDATE()),
  ( 466, 'TrainingCourse'                            , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,   8, 0, 1, GETUTCDATE()),
  ( 467, 'TrainingCourse'                            , 'N/A'                                       , 'source_system'                             , 'STRING'              ,   9, 0, 1, GETUTCDATE()),
  ( 468, 'TrainingCourse'                            , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  10, 0, 1, GETUTCDATE()),
  ( 469, 'TrainingCourse'                            , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  11, 0, 1, GETUTCDATE());

-- [36] AgentTraining (10 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 470, 'AgentTraining'                             , 'AgentTrainingPK'                           , 'agent_training_id'                         , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 471, 'AgentTraining'                             , 'AgentFK'                                   , 'agent_id'                                  , 'INT'                 ,   2, 1, 1, GETUTCDATE()),
  ( 472, 'AgentTraining'                             , 'TrainingCourseFK'                          , 'training_course_id'                        , 'INT'                 ,   3, 1, 1, GETUTCDATE()),
  ( 473, 'AgentTraining'                             , 'CompletionDate'                            , 'completion_timestamp'                      , 'TIMESTAMP'           ,   4, 1, 1, GETUTCDATE()),
  ( 474, 'AgentTraining'                             , 'ExpirationDate'                            , 'expiration_timestamp'                      , 'TIMESTAMP'           ,   5, 1, 1, GETUTCDATE()),
  ( 475, 'AgentTraining'                             , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,   6, 0, 1, GETUTCDATE()),
  ( 476, 'AgentTraining'                             , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,   7, 0, 1, GETUTCDATE()),
  ( 477, 'AgentTraining'                             , 'N/A'                                       , 'source_system'                             , 'STRING'              ,   8, 0, 1, GETUTCDATE()),
  ( 478, 'AgentTraining'                             , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,   9, 0, 1, GETUTCDATE()),
  ( 479, 'AgentTraining'                             , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  10, 0, 1, GETUTCDATE());

-- [37] Company (17 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 480, 'Company'                                   , 'CompanyPK'                                 , 'company_id'                                , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 481, 'Company'                                   , 'CompanyCode'                               , 'company_code'                              , 'STRING'              ,   2, 1, 1, GETUTCDATE()),
  ( 482, 'Company'                                   , 'AgentFK'                                   , 'agent_id'                                  , 'INT'                 ,   3, 1, 1, GETUTCDATE()),
  ( 483, 'Company'                                   , 'Name'                                      , 'name'                                      , 'STRING'              ,   4, 1, 1, GETUTCDATE()),
  ( 484, 'Company'                                   , 'DisplayName'                               , 'display_name'                              , 'STRING'              ,   5, 1, 1, GETUTCDATE()),
  ( 485, 'Company'                                   , 'AddressLine1'                              , 'address_line_1'                            , 'STRING'              ,   6, 1, 1, GETUTCDATE()),
  ( 486, 'Company'                                   , 'AddressLine2'                              , 'address_line_2'                            , 'STRING'              ,   7, 1, 1, GETUTCDATE()),
  ( 487, 'Company'                                   , 'City'                                      , 'city'                                      , 'STRING'              ,   8, 1, 1, GETUTCDATE()),
  ( 488, 'Company'                                   , 'State'                                     , 'state'                                     , 'STRING'              ,   9, 1, 1, GETUTCDATE()),
  ( 489, 'Company'                                   , 'ZipCode'                                   , 'zip_code'                                  , 'STRING'              ,  10, 1, 1, GETUTCDATE()),
  ( 490, 'Company'                                   , 'Phone'                                     , 'phone'                                     , 'STRING'              ,  11, 1, 1, GETUTCDATE()),
  ( 491, 'Company'                                   , 'Footer'                                    , 'footer'                                    , 'STRING'              ,  12, 1, 1, GETUTCDATE()),
  ( 492, 'Company'                                   , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,  13, 0, 1, GETUTCDATE()),
  ( 493, 'Company'                                   , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,  14, 0, 1, GETUTCDATE()),
  ( 494, 'Company'                                   , 'N/A'                                       , 'source_system'                             , 'STRING'              ,  15, 0, 1, GETUTCDATE()),
  ( 495, 'Company'                                   , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  16, 0, 1, GETUTCDATE()),
  ( 496, 'Company'                                   , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  17, 0, 1, GETUTCDATE());

-- [38] CAPStatusChange (12 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 497, 'CAPStatusChange'                           , 'CAPStatusChangePK'                         , 'cap_status_change_id'                      , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 498, 'CAPStatusChange'                           , 'ContractFK'                                , 'contract_id'                               , 'INT'                 ,   2, 1, 1, GETUTCDATE()),
  ( 499, 'CAPStatusChange'                           , 'SourceCompanyFK'                           , 'source_company_id'                         , 'INT'                 ,   3, 1, 1, GETUTCDATE()),
  ( 500, 'CAPStatusChange'                           , 'StatusChangeDate'                          , 'status_change_date'                        , 'TIMESTAMP'           ,   4, 1, 1, GETUTCDATE()),
  ( 501, 'CAPStatusChange'                           , 'StatusChangeCode'                          , 'status_change_code'                        , 'STRING'              ,   5, 1, 1, GETUTCDATE()),
  ( 502, 'CAPStatusChange'                           , 'ProcessDate'                               , 'process_date'                              , 'TIMESTAMP'           ,   6, 1, 1, GETUTCDATE()),
  ( 503, 'CAPStatusChange'                           , 'RenewalPeriod'                             , 'renewal_period'                            , 'INT'                 ,   7, 1, 1, GETUTCDATE()),
  ( 504, 'CAPStatusChange'                           , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,   8, 0, 1, GETUTCDATE()),
  ( 505, 'CAPStatusChange'                           , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,   9, 0, 1, GETUTCDATE()),
  ( 506, 'CAPStatusChange'                           , 'N/A'                                       , 'source_system'                             , 'STRING'              ,  10, 0, 1, GETUTCDATE()),
  ( 507, 'CAPStatusChange'                           , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  11, 0, 1, GETUTCDATE()),
  ( 508, 'CAPStatusChange'                           , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  12, 0, 1, GETUTCDATE());

-- [39] CAPRepayment (16 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 509, 'CAPRepayment'                              , 'CAPRepaymentPK'                            , 'cap_repayment_id'                          , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 510, 'CAPRepayment'                              , 'SourceKey'                                 , 'source_key'                                , 'BIGINT'              ,   2, 1, 1, GETUTCDATE()),
  ( 511, 'CAPRepayment'                              , 'SourceCompanyFK'                           , 'source_company_id'                         , 'INT'                 ,   3, 1, 1, GETUTCDATE()),
  ( 512, 'CAPRepayment'                              , 'PlanCode'                                  , 'plan_code'                                 , 'STRING'              ,   4, 1, 1, GETUTCDATE()),
  ( 513, 'CAPRepayment'                              , 'PlanCode2'                                 , 'plan_code_2'                               , 'STRING'              ,   5, 1, 1, GETUTCDATE()),
  ( 514, 'CAPRepayment'                              , 'OwnerResState'                             , 'owner_res_state'                           , 'STRING'              ,   6, 1, 1, GETUTCDATE()),
  ( 515, 'CAPRepayment'                              , 'OwnerCountry'                              , 'owner_country'                             , 'STRING'              ,   7, 1, 1, GETUTCDATE()),
  ( 516, 'CAPRepayment'                              , 'TerminationDate'                           , 'termination_date'                          , 'TIMESTAMP'           ,   8, 1, 1, GETUTCDATE()),
  ( 517, 'CAPRepayment'                              , 'FactorTrail'                               , 'factor_trail'                              , 'DECIMAL(18,4)'       ,   9, 1, 1, GETUTCDATE()),
  ( 518, 'CAPRepayment'                              , 'RenewalPeriod'                             , 'renewal_period'                            , 'INT'                 ,  10, 1, 1, GETUTCDATE()),
  ( 519, 'CAPRepayment'                              , 'CommissionableAmount'                      , 'commissionable_amount'                     , 'DECIMAL(18,4)'       ,  11, 1, 1, GETUTCDATE()),
  ( 520, 'CAPRepayment'                              , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,  12, 0, 1, GETUTCDATE()),
  ( 521, 'CAPRepayment'                              , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,  13, 0, 1, GETUTCDATE()),
  ( 522, 'CAPRepayment'                              , 'N/A'                                       , 'source_system'                             , 'STRING'              ,  14, 0, 1, GETUTCDATE()),
  ( 523, 'CAPRepayment'                              , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  15, 0, 1, GETUTCDATE()),
  ( 524, 'CAPRepayment'                              , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  16, 0, 1, GETUTCDATE());

-- [40] ActivityType (11 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 525, 'ActivityType'                              , 'ActivityTypePK'                            , 'activity_type_id'                          , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 526, 'ActivityType'                              , 'ActivityTypeName'                          , 'activity_type_name'                        , 'STRING'              ,   2, 1, 1, GETUTCDATE()),
  ( 527, 'ActivityType'                              , 'ActivityTypeQualifier'                     , 'activity_type_qualifier'                   , 'STRING'              ,   3, 1, 1, GETUTCDATE()),
  ( 528, 'ActivityType'                              , 'Source'                                    , 'source'                                    , 'STRING'              ,   4, 1, 1, GETUTCDATE()),
  ( 529, 'ActivityType'                              , 'ValueType'                                 , 'value_type'                                , 'STRING'              ,   5, 1, 1, GETUTCDATE()),
  ( 530, 'ActivityType'                              , 'SortOrder'                                 , 'sort_order'                                , 'INT'                 ,   6, 1, 1, GETUTCDATE()),
  ( 531, 'ActivityType'                              , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,   7, 0, 1, GETUTCDATE()),
  ( 532, 'ActivityType'                              , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,   8, 0, 1, GETUTCDATE()),
  ( 533, 'ActivityType'                              , 'N/A'                                       , 'source_system'                             , 'STRING'              ,   9, 0, 1, GETUTCDATE()),
  ( 534, 'ActivityType'                              , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  10, 0, 1, GETUTCDATE()),
  ( 535, 'ActivityType'                              , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  11, 0, 1, GETUTCDATE());

-- [41] ActivityFinancial (18 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 536, 'ActivityFinancial'                         , 'ActivityPK'                                , 'activity_id'                               , 'BIGINT'              ,   1, 1, 1, GETUTCDATE()),
  ( 537, 'ActivityFinancial'                         , 'FreeAmount'                                , 'free_amount'                               , 'DECIMAL(18,4)'       ,   2, 1, 1, GETUTCDATE()),
  ( 538, 'ActivityFinancial'                         , 'SurrenderCharge'                           , 'surrender_charge'                          , 'DECIMAL(18,4)'       ,   3, 1, 1, GETUTCDATE()),
  ( 539, 'ActivityFinancial'                         , 'MVA'                                       , 'mva'                                       , 'DECIMAL(18,4)'       ,   4, 1, 1, GETUTCDATE()),
  ( 540, 'ActivityFinancial'                         , 'PolicyFee'                                 , 'policy_fee'                                , 'DECIMAL(18,4)'       ,   5, 1, 1, GETUTCDATE()),
  ( 541, 'ActivityFinancial'                         , 'COIRefund'                                 , 'coi_refund'                                , 'DECIMAL(18,4)'       ,   6, 1, 1, GETUTCDATE()),
  ( 542, 'ActivityFinancial'                         , 'ABRDiscountCharge'                         , 'abr_discount_charge'                       , 'DECIMAL(18,4)'       ,   7, 1, 1, GETUTCDATE()),
  ( 543, 'ActivityFinancial'                         , 'AdminCharge'                               , 'admin_charge'                              , 'DECIMAL(18,4)'       ,   8, 1, 1, GETUTCDATE()),
  ( 544, 'ActivityFinancial'                         , 'FederalTax'                                , 'federal_tax'                               , 'DECIMAL(18,4)'       ,   9, 1, 1, GETUTCDATE()),
  ( 545, 'ActivityFinancial'                         , 'StateTax'                                  , 'state_tax'                                 , 'DECIMAL(18,4)'       ,  10, 1, 1, GETUTCDATE()),
  ( 546, 'ActivityFinancial'                         , 'Rate'                                      , 'rate'                                      , 'DECIMAL(18,4)'       ,  11, 1, 1, GETUTCDATE()),
  ( 547, 'ActivityFinancial'                         , 'BaseAmount'                                , 'base_amount'                               , 'DECIMAL(18,4)'       ,  12, 1, 1, GETUTCDATE()),
  ( 548, 'ActivityFinancial'                         , 'TaxableBenefit'                            , 'taxable_benefit'                           , 'DECIMAL(18,4)'       ,  13, 1, 1, GETUTCDATE()),
  ( 549, 'ActivityFinancial'                         , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,  14, 0, 1, GETUTCDATE()),
  ( 550, 'ActivityFinancial'                         , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,  15, 0, 1, GETUTCDATE()),
  ( 551, 'ActivityFinancial'                         , 'N/A'                                       , 'source_system'                             , 'STRING'              ,  16, 0, 1, GETUTCDATE()),
  ( 552, 'ActivityFinancial'                         , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  17, 0, 1, GETUTCDATE()),
  ( 553, 'ActivityFinancial'                         , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  18, 0, 1, GETUTCDATE());

-- [42] AccountingDetail (23 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 554, 'AccountingDetail'                          , 'AccountingPK'                              , 'accounting_id'                             , 'BIGINT'              ,   1, 1, 1, GETUTCDATE()),
  ( 555, 'AccountingDetail'                          , 'SourceCode'                                , 'source_code'                               , 'STRING'              ,   2, 1, 1, GETUTCDATE()),
  ( 556, 'AccountingDetail'                          , 'ReferenceData'                             , 'reference_data'                            , 'STRING'              ,   3, 1, 1, GETUTCDATE()),
  ( 557, 'AccountingDetail'                          , 'Approval'                                  , 'approval'                                  , 'STRING'              ,   4, 1, 1, GETUTCDATE()),
  ( 558, 'AccountingDetail'                          , 'Description'                               , 'description'                               , 'STRING'              ,   5, 1, 1, GETUTCDATE()),
  ( 559, 'AccountingDetail'                          , 'CompanyCode'                               , 'company_code'                              , 'STRING'              ,   6, 1, 1, GETUTCDATE()),
  ( 560, 'AccountingDetail'                          , 'DCIndicator'                               , 'dc_indicator'                              , 'STRING'              ,   7, 1, 1, GETUTCDATE()),
  ( 561, 'AccountingDetail'                          , 'EntryOperator'                             , 'entry_operator'                            , 'STRING'              ,   8, 1, 1, GETUTCDATE()),
  ( 562, 'AccountingDetail'                          , 'ApprovalOperator'                          , 'approval_operator'                         , 'STRING'              ,   9, 1, 1, GETUTCDATE()),
  ( 563, 'AccountingDetail'                          , 'APEXTIndicator'                            , 'apext_indicator'                           , 'STRING'              ,  10, 1, 1, GETUTCDATE()),
  ( 564, 'AccountingDetail'                          , 'SuspenseEXTIndicator'                      , 'suspense_ext_indicator'                    , 'STRING'              ,  11, 1, 1, GETUTCDATE()),
  ( 565, 'AccountingDetail'                          , 'EntryGenIndicator'                         , 'entry_gen_indicator'                       , 'STRING'              ,  12, 1, 1, GETUTCDATE()),
  ( 566, 'AccountingDetail'                          , 'Treaty'                                    , 'treaty'                                    , 'STRING'              ,  13, 1, 1, GETUTCDATE()),
  ( 567, 'AccountingDetail'                          , 'QualType'                                  , 'qual_type'                                 , 'STRING'              ,  14, 1, 1, GETUTCDATE()),
  ( 568, 'AccountingDetail'                          , 'SEG_EDITTrxPK'                             , 'seg_edit_trx_id'                           , 'BIGINT'              ,  15, 1, 1, GETUTCDATE()),
  ( 569, 'AccountingDetail'                          , 'SEG_PlacedAgentPK'                         , 'seg_placed_agent_id'                       , 'BIGINT'              ,  16, 1, 1, GETUTCDATE()),
  ( 570, 'AccountingDetail'                          , 'CostCenter'                                , 'cost_center'                               , 'STRING'              ,  17, 1, 1, GETUTCDATE()),
  ( 571, 'AccountingDetail'                          , 'SuspenseCode'                              , 'suspense_code'                             , 'STRING'              ,  18, 1, 1, GETUTCDATE()),
  ( 572, 'AccountingDetail'                          , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,  19, 0, 1, GETUTCDATE()),
  ( 573, 'AccountingDetail'                          , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,  20, 0, 1, GETUTCDATE()),
  ( 574, 'AccountingDetail'                          , 'N/A'                                       , 'source_system'                             , 'STRING'              ,  21, 0, 1, GETUTCDATE()),
  ( 575, 'AccountingDetail'                          , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  22, 0, 1, GETUTCDATE()),
  ( 576, 'AccountingDetail'                          , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  23, 0, 1, GETUTCDATE());

-- [43] AccountingAccount (16 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 577, 'AccountingAccount'                         , 'AccountingAccountPK'                       , 'accounting_account_id'                     , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 578, 'AccountingAccount'                         , 'AccountNumber'                             , 'account_number'                            , 'STRING'              ,   2, 1, 1, GETUTCDATE()),
  ( 579, 'AccountingAccount'                         , 'AccountSource'                             , 'account_source'                            , 'STRING'              ,   3, 1, 1, GETUTCDATE()),
  ( 580, 'AccountingAccount'                         , 'ClassCode'                                 , 'class_code'                                , 'STRING'              ,   4, 1, 1, GETUTCDATE()),
  ( 581, 'AccountingAccount'                         , 'CubeDescription'                           , 'cube_description'                          , 'STRING'              ,   5, 1, 1, GETUTCDATE()),
  ( 582, 'AccountingAccount'                         , 'GroupIndicator'                            , 'group_indicator'                           , 'BOOLEAN'             ,   6, 1, 1, GETUTCDATE()),
  ( 583, 'AccountingAccount'                         , 'CededIndicator'                            , 'ceded_indicator'                           , 'BOOLEAN'             ,   7, 1, 1, GETUTCDATE()),
  ( 584, 'AccountingAccount'                         , 'Context'                                   , 'context'                                   , 'STRING'              ,   8, 1, 1, GETUTCDATE()),
  ( 585, 'AccountingAccount'                         , 'ActuarialGrouping'                         , 'actuarial_grouping'                        , 'STRING'              ,   9, 1, 1, GETUTCDATE()),
  ( 586, 'AccountingAccount'                         , 'AccountDescription'                        , 'account_description'                       , 'STRING'              ,  10, 1, 1, GETUTCDATE()),
  ( 587, 'AccountingAccount'                         , 'AccountingReportingGroupKey'               , 'accounting_reporting_group_key'            , 'INT'                 ,  11, 1, 1, GETUTCDATE()),
  ( 588, 'AccountingAccount'                         , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,  12, 0, 1, GETUTCDATE()),
  ( 589, 'AccountingAccount'                         , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,  13, 0, 1, GETUTCDATE()),
  ( 590, 'AccountingAccount'                         , 'N/A'                                       , 'source_system'                             , 'STRING'              ,  14, 0, 1, GETUTCDATE()),
  ( 591, 'AccountingAccount'                         , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  15, 0, 1, GETUTCDATE()),
  ( 592, 'AccountingAccount'                         , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  16, 0, 1, GETUTCDATE());

-- [44] Accounting (24 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 593, 'Accounting'                                , 'AccountingPK'                              , 'accounting_id'                             , 'BIGINT'              ,   1, 1, 1, GETUTCDATE()),
  ( 594, 'Accounting'                                , 'SourceSystem'                              , 'source_system_code'                        , 'STRING'              ,   2, 1, 1, GETUTCDATE()),
  ( 595, 'Accounting'                                , 'TranID'                                    , 'transaction_id'                            , 'INT'                 ,   3, 1, 1, GETUTCDATE()),
  ( 596, 'Accounting'                                , 'TranDetailID'                              , 'transaction_detail_id'                     , 'BIGINT'              ,   4, 1, 1, GETUTCDATE()),
  ( 597, 'Accounting'                                , 'StatusCode'                                , 'status_code'                               , 'STRING'              ,   5, 1, 1, GETUTCDATE()),
  ( 598, 'Accounting'                                , 'StatusIndicator'                           , 'status_indicator'                          , 'STRING'              ,   6, 1, 1, GETUTCDATE()),
  ( 599, 'Accounting'                                , 'BasisCode'                                 , 'basis_code'                                , 'STRING'              ,   7, 1, 1, GETUTCDATE()),
  ( 600, 'Accounting'                                , 'State'                                     , 'state_code'                                , 'STRING'              ,   8, 1, 1, GETUTCDATE()),
  ( 601, 'Accounting'                                , 'EffectiveDateFK'                           , 'effective_date_id'                         , 'INT'                 ,   9, 1, 1, GETUTCDATE()),
  ( 602, 'Accounting'                                , 'PeriodDateFK'                              , 'period_date_id'                            , 'INT'                 ,  10, 1, 1, GETUTCDATE()),
  ( 603, 'Accounting'                                , 'AccountingAccountFK'                       , 'accounting_account_id'                     , 'INT'                 ,  11, 1, 1, GETUTCDATE()),
  ( 604, 'Accounting'                                , 'EntryDate'                                 , 'entry_date'                                , 'DATE'                ,  12, 1, 1, GETUTCDATE()),
  ( 605, 'Accounting'                                , 'EntryUpdateDate'                           , 'entry_update_date'                         , 'DATE'                ,  13, 1, 1, GETUTCDATE()),
  ( 606, 'Accounting'                                , 'ContractFK'                                , 'contract_id'                               , 'INT'                 ,  14, 1, 1, GETUTCDATE()),
  ( 607, 'Accounting'                                , 'InvestmentFK'                              , 'investment_id'                             , 'INT'                 ,  15, 1, 1, GETUTCDATE()),
  ( 608, 'Accounting'                                , 'ProductFK'                                 , 'product_id'                                , 'INT'                 ,  16, 1, 1, GETUTCDATE()),
  ( 609, 'Accounting'                                , 'AgentFK'                                   , 'agent_id'                                  , 'INT'                 ,  17, 1, 1, GETUTCDATE()),
  ( 610, 'Accounting'                                , 'Amount'                                    , 'amount'                                    , 'DECIMAL(18,4)'       ,  18, 1, 1, GETUTCDATE()),
  ( 611, 'Accounting'                                , 'Block'                                     , 'block_code'                                , 'STRING'              ,  19, 1, 1, GETUTCDATE()),
  ( 612, 'Accounting'                                , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,  20, 0, 1, GETUTCDATE()),
  ( 613, 'Accounting'                                , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,  21, 0, 1, GETUTCDATE()),
  ( 614, 'Accounting'                                , 'N/A'                                       , 'source_system'                             , 'STRING'              ,  22, 0, 1, GETUTCDATE()),
  ( 615, 'Accounting'                                , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  23, 0, 1, GETUTCDATE()),
  ( 616, 'Accounting'                                , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  24, 0, 1, GETUTCDATE());

-- [45] Surrender (18 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 617, 'Surrender'                                 , 'SurrenderPK'                               , 'surrender_id'                              , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 618, 'Surrender'                                 , 'ProductFK'                                 , 'product_id'                                , 'INT'                 ,   2, 1, 1, GETUTCDATE()),
  ( 619, 'Surrender'                                 , 'FundNumber'                                , 'fund_number'                               , 'STRING'              ,   3, 1, 1, GETUTCDATE()),
  ( 620, 'Surrender'                                 , 'State'                                     , 'state_code'                                , 'STRING'              ,   4, 1, 1, GETUTCDATE()),
  ( 621, 'Surrender'                                 , 'Gender'                                    , 'gender'                                    , 'STRING'              ,   5, 1, 1, GETUTCDATE()),
  ( 622, 'Surrender'                                 , 'Class'                                     , 'risk_class'                                , 'STRING'              ,   6, 1, 1, GETUTCDATE()),
  ( 623, 'Surrender'                                 , 'Age'                                       , 'customer_age'                              , 'INT'                 ,   7, 1, 1, GETUTCDATE()),
  ( 624, 'Surrender'                                 , 'ContractYear'                              , 'policy_year'                               , 'INT'                 ,   8, 1, 1, GETUTCDATE()),
  ( 625, 'Surrender'                                 , 'SurrenderLength'                           , 'penalty_duration_years'                    , 'INT'                 ,   9, 1, 1, GETUTCDATE()),
  ( 626, 'Surrender'                                 , 'Rate'                                      , 'penalty_percentage'                        , 'DECIMAL(18,4)'       ,  10, 1, 1, GETUTCDATE()),
  ( 627, 'Surrender'                                 , 'RateAppliedTo'                             , 'rate_calculation_basis'                    , 'STRING'              ,  11, 1, 1, GETUTCDATE()),
  ( 628, 'Surrender'                                 , 'EffectiveDate'                             , 'rule_start_date'                           , 'TIMESTAMP'           ,  12, 1, 1, GETUTCDATE()),
  ( 629, 'Surrender'                                 , 'EndDate'                                   , 'rule_end_date'                             , 'TIMESTAMP'           ,  13, 1, 1, GETUTCDATE()),
  ( 630, 'Surrender'                                 , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,  14, 0, 1, GETUTCDATE()),
  ( 631, 'Surrender'                                 , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,  15, 0, 1, GETUTCDATE()),
  ( 632, 'Surrender'                                 , 'N/A'                                       , 'source_system'                             , 'STRING'              ,  16, 0, 1, GETUTCDATE()),
  ( 633, 'Surrender'                                 , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  17, 0, 1, GETUTCDATE()),
  ( 634, 'Surrender'                                 , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  18, 0, 1, GETUTCDATE());

-- [46] InvestmentDetail (14 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 635, 'InvestmentDetail'                          , 'InvestmentDetailPK'                        , 'investment_detail_id'                      , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 636, 'InvestmentDetail'                          , 'Name'                                      , 'investment_detail_name'                    , 'STRING'              ,   2, 1, 1, GETUTCDATE()),
  ( 637, 'InvestmentDetail'                          , 'FundType'                                  , 'fund_type'                                 , 'STRING'              ,   3, 1, 1, GETUTCDATE()),
  ( 638, 'InvestmentDetail'                          , 'GroupingName'                              , 'grouping_name'                             , 'STRING'              ,   4, 1, 1, GETUTCDATE()),
  ( 639, 'InvestmentDetail'                          , 'MarketingName'                             , 'marketing_name'                            , 'STRING'              ,   5, 1, 1, GETUTCDATE()),
  ( 640, 'InvestmentDetail'                          , 'AltMarketingName'                          , 'alt_marketing_name'                        , 'STRING'              ,   6, 1, 1, GETUTCDATE()),
  ( 641, 'InvestmentDetail'                          , 'SortOrder'                                 , 'sort_order'                                , 'STRING'              ,   7, 1, 1, GETUTCDATE()),
  ( 642, 'InvestmentDetail'                          , 'IsCap'                                     , 'is_cap_indicator'                          , 'BOOLEAN'             ,   8, 1, 1, GETUTCDATE()),
  ( 643, 'InvestmentDetail'                          , 'FundStartDate'                             , 'fund_start_date'                           , 'TIMESTAMP'           ,   9, 1, 1, GETUTCDATE()),
  ( 644, 'InvestmentDetail'                          , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,  10, 0, 1, GETUTCDATE()),
  ( 645, 'InvestmentDetail'                          , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,  11, 0, 1, GETUTCDATE()),
  ( 646, 'InvestmentDetail'                          , 'N/A'                                       , 'source_system'                             , 'STRING'              ,  12, 0, 1, GETUTCDATE()),
  ( 647, 'InvestmentDetail'                          , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  13, 0, 1, GETUTCDATE()),
  ( 648, 'InvestmentDetail'                          , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  14, 0, 1, GETUTCDATE());

-- [47] Investment (13 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 649, 'Investment'                                , 'InvestmentPK'                              , 'investment_id'                             , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 650, 'Investment'                                , 'InvestmentKey'                             , 'investment_key'                            , 'INT'                 ,   2, 1, 1, GETUTCDATE()),
  ( 651, 'Investment'                                , 'InvestmentName'                            , 'investment_name'                           , 'STRING'              ,   3, 1, 1, GETUTCDATE()),
  ( 652, 'Investment'                                , 'InvestmentDescription'                     , 'investment_description'                    , 'STRING'              ,   4, 1, 1, GETUTCDATE()),
  ( 653, 'Investment'                                , 'EffectiveDate'                             , 'effective_date'                            , 'TIMESTAMP'           ,   5, 1, 1, GETUTCDATE()),
  ( 654, 'Investment'                                , 'Active'                                    , 'active_indicator'                          , 'BOOLEAN'             ,   6, 1, 1, GETUTCDATE()),
  ( 655, 'Investment'                                , 'StartDate'                                 , 'start_timestamp'                           , 'TIMESTAMP'           ,   7, 1, 1, GETUTCDATE()),
  ( 656, 'Investment'                                , 'EndDate'                                   , 'end_timestamp'                             , 'TIMESTAMP'           ,   8, 1, 1, GETUTCDATE()),
  ( 657, 'Investment'                                , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,   9, 0, 1, GETUTCDATE()),
  ( 658, 'Investment'                                , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,  10, 0, 1, GETUTCDATE()),
  ( 659, 'Investment'                                , 'N/A'                                       , 'source_system'                             , 'STRING'              ,  11, 0, 1, GETUTCDATE()),
  ( 660, 'Investment'                                , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  12, 0, 1, GETUTCDATE()),
  ( 661, 'Investment'                                , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  13, 0, 1, GETUTCDATE());

-- [48] Activity (27 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 662, 'Activity'                                  , 'ActivityPK'                                , 'activity_id'                               , 'BIGINT'              ,   1, 1, 1, GETUTCDATE()),
  ( 663, 'Activity'                                  , 'ActivityTypeFK'                            , 'activity_type_id'                          , 'INT'                 ,   2, 1, 1, GETUTCDATE()),
  ( 664, 'Activity'                                  , 'CompanyFK'                                 , 'company_id'                                , 'INT'                 ,   3, 1, 1, GETUTCDATE()),
  ( 665, 'Activity'                                  , 'ContractFK'                                , 'contract_id'                               , 'INT'                 ,   4, 1, 1, GETUTCDATE()),
  ( 666, 'Activity'                                  , 'ProductFK'                                 , 'product_id'                                , 'INT'                 ,   5, 1, 1, GETUTCDATE()),
  ( 667, 'Activity'                                  , 'InvestmentFK'                              , 'investment_id'                             , 'INT'                 ,   6, 1, 1, GETUTCDATE()),
  ( 668, 'Activity'                                  , 'AccountingFK'                              , 'accounting_id'                             , 'INT'                 ,   7, 1, 1, GETUTCDATE()),
  ( 669, 'Activity'                                  , 'AccountingAccountFK'                       , 'accounting_account_id'                     , 'INT'                 ,   8, 1, 1, GETUTCDATE()),
  ( 670, 'Activity'                                  , 'CAPRepaymentFK'                            , 'cap_repayment_id'                          , 'INT'                 ,   9, 1, 1, GETUTCDATE()),
  ( 671, 'Activity'                                  , 'HierarchySetKey'                           , 'hierarchy_set_id'                          , 'INT'                 ,  10, 1, 1, GETUTCDATE()),
  ( 672, 'Activity'                                  , 'AgentFK'                                   , 'agent_id'                                  , 'INT'                 ,  11, 1, 1, GETUTCDATE()),
  ( 673, 'Activity'                                  , 'ActivityClientFK'                          , 'activity_client_id'                        , 'INT'                 ,  12, 1, 1, GETUTCDATE()),
  ( 674, 'Activity'                                  , 'ActivityPayeeFK'                           , 'activity_payee_id'                         , 'INT'                 ,  13, 1, 1, GETUTCDATE()),
  ( 675, 'Activity'                                  , 'EffectiveDateFK'                           , 'effective_date_id'                         , 'INT'                 ,  14, 1, 1, GETUTCDATE()),
  ( 676, 'Activity'                                  , 'ProcessDateFK'                             , 'process_date_id'                           , 'INT'                 ,  15, 1, 1, GETUTCDATE()),
  ( 677, 'Activity'                                  , 'ReleaseDate'                               , 'release_date'                              , 'TIMESTAMP'           ,  16, 1, 1, GETUTCDATE()),
  ( 678, 'Activity'                                  , 'PeriodDate'                                , 'period_date'                               , 'TIMESTAMP'           ,  17, 1, 1, GETUTCDATE()),
  ( 679, 'Activity'                                  , 'GrossAmount'                               , 'gross_amount'                              , 'DECIMAL(18,4)'       ,  18, 1, 1, GETUTCDATE()),
  ( 680, 'Activity'                                  , 'NetAmount'                                 , 'net_amount'                                , 'DECIMAL(18,4)'       ,  19, 1, 1, GETUTCDATE()),
  ( 681, 'Activity'                                  , 'CheckAmount'                               , 'check_amount'                              , 'DECIMAL(18,4)'       ,  20, 1, 1, GETUTCDATE()),
  ( 682, 'Activity'                                  , 'DistributionType'                          , 'distribution_type'                         , 'STRING'              ,  21, 1, 1, GETUTCDATE()),
  ( 683, 'Activity'                                  , 'TextValue'                                 , 'activity_notes'                            , 'STRING'              ,  22, 1, 1, GETUTCDATE()),
  ( 684, 'Activity'                                  , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,  23, 0, 1, GETUTCDATE()),
  ( 685, 'Activity'                                  , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,  24, 0, 1, GETUTCDATE()),
  ( 686, 'Activity'                                  , 'N/A'                                       , 'source_system'                             , 'STRING'              ,  25, 0, 1, GETUTCDATE()),
  ( 687, 'Activity'                                  , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  26, 0, 1, GETUTCDATE()),
  ( 688, 'Activity'                                  , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  27, 0, 1, GETUTCDATE());

-- [49] AccountValue (16 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 689, 'AccountValue'                              , 'AccountValuePK'                            , 'account_value_id'                          , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 690, 'AccountValue'                              , 'ContractFK'                                , 'contract_id'                               , 'INT'                 ,   2, 1, 1, GETUTCDATE()),
  ( 691, 'AccountValue'                              , 'InvestmentFK'                              , 'investment_id'                             , 'INT'                 ,   3, 1, 1, GETUTCDATE()),
  ( 692, 'AccountValue'                              , 'Value'                                     , 'account_value_amount'                      , 'DECIMAL(18,4)'       ,   4, 1, 1, GETUTCDATE()),
  ( 693, 'AccountValue'                              , 'CurrentInterestRate'                       , 'current_interest_rate'                     , 'DECIMAL(18,4)'       ,   5, 1, 1, GETUTCDATE()),
  ( 694, 'AccountValue'                              , 'AllocationPercent'                         , 'allocation_percentage'                     , 'DECIMAL(18,4)'       ,   6, 1, 1, GETUTCDATE()),
  ( 695, 'AccountValue'                              , 'DepositDate'                               , 'deposit_date'                              , 'TIMESTAMP'           ,   7, 1, 1, GETUTCDATE()),
  ( 696, 'AccountValue'                              , 'RenewalDate'                               , 'renewal_date'                              , 'TIMESTAMP'           ,   8, 1, 1, GETUTCDATE()),
  ( 697, 'AccountValue'                              , 'ValuationDate'                             , 'valuation_date'                            , 'TIMESTAMP'           ,   9, 1, 1, GETUTCDATE()),
  ( 698, 'AccountValue'                              , 'StartDate'                                 , 'start_timestamp'                           , 'TIMESTAMP'           ,  10, 1, 1, GETUTCDATE()),
  ( 699, 'AccountValue'                              , 'EndDate'                                   , 'end_timestamp'                             , 'TIMESTAMP'           ,  11, 1, 1, GETUTCDATE()),
  ( 700, 'AccountValue'                              , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,  12, 0, 1, GETUTCDATE()),
  ( 701, 'AccountValue'                              , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,  13, 0, 1, GETUTCDATE()),
  ( 702, 'AccountValue'                              , 'N/A'                                       , 'source_system'                             , 'STRING'              ,  14, 0, 1, GETUTCDATE()),
  ( 703, 'AccountValue'                              , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  15, 0, 1, GETUTCDATE()),
  ( 704, 'AccountValue'                              , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  16, 0, 1, GETUTCDATE());

-- [50] Product (14 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 705, 'Product'                                   , 'ProductPK'                                 , 'product_id'                                , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 706, 'Product'                                   , 'ProductName'                               , 'product_name'                              , 'STRING'              ,   2, 1, 1, GETUTCDATE()),
  ( 707, 'Product'                                   , 'MarketingName'                             , 'marketing_name'                            , 'STRING'              ,   3, 1, 1, GETUTCDATE()),
  ( 708, 'Product'                                   , 'ProductType'                               , 'product_type'                              , 'STRING'              ,   4, 1, 1, GETUTCDATE()),
  ( 709, 'Product'                                   , 'CUSIPNumber'                               , 'cusip_number'                              , 'STRING'              ,   5, 1, 1, GETUTCDATE()),
  ( 710, 'Product'                                   , 'Context'                                   , 'product_context'                           , 'STRING'              ,   6, 1, 1, GETUTCDATE()),
  ( 711, 'Product'                                   , 'GLLOB'                                     , 'gl_line_of_business'                       , 'STRING'              ,   7, 1, 1, GETUTCDATE()),
  ( 712, 'Product'                                   , 'Status'                                    , 'status'                                    , 'STRING'              ,   8, 1, 1, GETUTCDATE()),
  ( 713, 'Product'                                   , 'EffectiveDate'                             , 'effective_date'                            , 'TIMESTAMP'           ,   9, 1, 1, GETUTCDATE()),
  ( 714, 'Product'                                   , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,  10, 0, 1, GETUTCDATE()),
  ( 715, 'Product'                                   , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,  11, 0, 1, GETUTCDATE()),
  ( 716, 'Product'                                   , 'N/A'                                       , 'source_system'                             , 'STRING'              ,  12, 0, 1, GETUTCDATE()),
  ( 717, 'Product'                                   , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  13, 0, 1, GETUTCDATE()),
  ( 718, 'Product'                                   , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  14, 0, 1, GETUTCDATE());

-- [51] Agent (20 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 719, 'Agent'                                     , 'AgentPK'                                   , 'agent_id'                                  , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 720, 'Agent'                                     , 'AgentNumber'                               , 'agent_number'                              , 'STRING'              ,   2, 1, 1, GETUTCDATE()),
  ( 721, 'Agent'                                     , 'DisplayName'                               , 'display_name'                              , 'STRING'              ,   3, 1, 1, GETUTCDATE()),
  ( 722, 'Agent'                                     , 'NPN'                                       , 'national_producer_number'                  , 'STRING'              ,   4, 1, 1, GETUTCDATE()),
  ( 723, 'Agent'                                     , 'NASD'                                      , 'nasd_finra_number'                         , 'STRING'              ,   5, 1, 1, GETUTCDATE()),
  ( 724, 'Agent'                                     , 'AgentType'                                 , 'agent_type'                                , 'STRING'              ,   6, 1, 1, GETUTCDATE()),
  ( 725, 'Agent'                                     , 'Status'                                    , 'status'                                    , 'STRING'              ,   7, 1, 1, GETUTCDATE()),
  ( 726, 'Agent'                                     , 'HireDate'                                  , 'hire_date'                                 , 'TIMESTAMP'           ,   8, 1, 1, GETUTCDATE()),
  ( 727, 'Agent'                                     , 'TerminationDate'                           , 'termination_date'                          , 'TIMESTAMP'           ,   9, 1, 1, GETUTCDATE()),
  ( 728, 'Agent'                                     , 'ClientFK'                                  , 'client_id'                                 , 'INT'                 ,  10, 1, 1, GETUTCDATE()),
  ( 729, 'Agent'                                     , 'AddressGroupFK'                            , 'address_group_id'                          , 'INT'                 ,  11, 1, 1, GETUTCDATE()),
  ( 730, 'Agent'                                     , 'AdditionalInfoGroupFK'                     , 'additional_info_group_id'                  , 'INT'                 ,  12, 1, 1, GETUTCDATE()),
  ( 731, 'Agent'                                     , 'EffectiveDate'                             , 'effective_date'                            , 'TIMESTAMP'           ,  13, 1, 1, GETUTCDATE()),
  ( 732, 'Agent'                                     , 'StartTimestamp'                            , 'start_timestamp'                           , 'TIMESTAMP'           ,  14, 1, 1, GETUTCDATE()),
  ( 733, 'Agent'                                     , 'EndTimestamp'                              , 'end_timestamp'                             , 'TIMESTAMP'           ,  15, 1, 1, GETUTCDATE()),
  ( 734, 'Agent'                                     , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,  16, 0, 1, GETUTCDATE()),
  ( 735, 'Agent'                                     , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,  17, 0, 1, GETUTCDATE()),
  ( 736, 'Agent'                                     , 'N/A'                                       , 'source_system'                             , 'STRING'              ,  18, 0, 1, GETUTCDATE()),
  ( 737, 'Agent'                                     , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  19, 0, 1, GETUTCDATE()),
  ( 738, 'Agent'                                     , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  20, 0, 1, GETUTCDATE());

-- [52] Client (39 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 739, 'Client'                                    , 'ClientPK'                                  , 'client_id'                                 , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 740, 'Client'                                    , 'SourceKey'                                 , 'source_key'                                , 'BIGINT'              ,   2, 1, 1, GETUTCDATE()),
  ( 741, 'Client'                                    , 'TaxIDHash'                                 , 'tax_id_hash'                               , 'BINARY'              ,   3, 1, 1, GETUTCDATE()),
  ( 742, 'Client'                                    , 'Last4Hash'                                 , 'last_4_hash'                               , 'BINARY'              ,   4, 1, 1, GETUTCDATE()),
  ( 743, 'Client'                                    , 'Last4Token'                                , 'last_4_token'                              , 'STRING'              ,   5, 1, 1, GETUTCDATE()),
  ( 744, 'Client'                                    , 'DisplayName'                               , 'display_name'                              , 'STRING'              ,   6, 1, 1, GETUTCDATE()),
  ( 745, 'Client'                                    , 'FirstName'                                 , 'first_name'                                , 'STRING'              ,   7, 1, 1, GETUTCDATE()),
  ( 746, 'Client'                                    , 'MiddleName'                                , 'middle_name'                               , 'STRING'              ,   8, 1, 1, GETUTCDATE()),
  ( 747, 'Client'                                    , 'LastName'                                  , 'last_name'                                 , 'STRING'              ,   9, 1, 1, GETUTCDATE()),
  ( 748, 'Client'                                    , 'Prefix'                                    , 'prefix'                                    , 'STRING'              ,  10, 1, 1, GETUTCDATE()),
  ( 749, 'Client'                                    , 'Suffix'                                    , 'suffix'                                    , 'STRING'              ,  11, 1, 1, GETUTCDATE()),
  ( 750, 'Client'                                    , 'CorporateName'                             , 'corporate_name'                            , 'STRING'              ,  12, 1, 1, GETUTCDATE()),
  ( 751, 'Client'                                    , 'Gender'                                    , 'gender'                                    , 'STRING'              ,  13, 1, 1, GETUTCDATE()),
  ( 752, 'Client'                                    , 'Phone'                                     , 'phone_number'                              , 'STRING'              ,  14, 1, 1, GETUTCDATE()),
  ( 753, 'Client'                                    , 'Email'                                     , 'email_address'                             , 'STRING'              ,  15, 1, 1, GETUTCDATE()),
  ( 754, 'Client'                                    , 'Fax'                                       , 'fax_number'                                , 'STRING'              ,  16, 1, 1, GETUTCDATE()),
  ( 755, 'Client'                                    , 'BirthDate'                                 , 'birth_date'                                , 'TIMESTAMP'           ,  17, 1, 1, GETUTCDATE()),
  ( 756, 'Client'                                    , 'DeathDate'                                 , 'death_date'                                , 'TIMESTAMP'           ,  18, 1, 1, GETUTCDATE()),
  ( 757, 'Client'                                    , 'Status'                                    , 'status'                                    , 'STRING'              ,  19, 1, 1, GETUTCDATE()),
  ( 758, 'Client'                                    , 'PayPreference'                             , 'pay_preference'                            , 'STRING'              ,  20, 1, 1, GETUTCDATE()),
  ( 759, 'Client'                                    , 'ExternalAccountGroupFK'                    , 'external_account_group_id'                 , 'INT'                 ,  21, 1, 1, GETUTCDATE()),
  ( 760, 'Client'                                    , 'Address1'                                  , 'address_line_1'                            , 'STRING'              ,  22, 1, 1, GETUTCDATE()),
  ( 761, 'Client'                                    , 'Address2'                                  , 'address_line_2'                            , 'STRING'              ,  23, 1, 1, GETUTCDATE()),
  ( 762, 'Client'                                    , 'City'                                      , 'city'                                      , 'STRING'              ,  24, 1, 1, GETUTCDATE()),
  ( 763, 'Client'                                    , 'State'                                     , 'state_code'                                , 'STRING'              ,  25, 1, 1, GETUTCDATE()),
  ( 764, 'Client'                                    , 'ZipCode'                                   , 'zip_code'                                  , 'STRING'              ,  26, 1, 1, GETUTCDATE()),
  ( 765, 'Client'                                    , 'County'                                    , 'county'                                    , 'STRING'              ,  27, 1, 1, GETUTCDATE()),
  ( 766, 'Client'                                    , 'CountryCode'                               , 'country_code'                              , 'STRING'              ,  28, 1, 1, GETUTCDATE()),
  ( 767, 'Client'                                    , 'AdditionalInfoGroupFK'                     , 'additional_info_group_id'                  , 'INT'                 ,  29, 1, 1, GETUTCDATE()),
  ( 768, 'Client'                                    , 'VerificationDetails'                       , 'verification_details'                      , 'STRING'              ,  30, 1, 1, GETUTCDATE()),
  ( 769, 'Client'                                    , 'NoNewBusiness'                             , 'no_new_business_indicator'                 , 'BOOLEAN'             ,  31, 1, 1, GETUTCDATE()),
  ( 770, 'Client'                                    , 'EffectiveDate'                             , 'effective_date'                            , 'TIMESTAMP'           ,  32, 1, 1, GETUTCDATE()),
  ( 771, 'Client'                                    , 'StartTimestamp'                            , 'start_timestamp'                           , 'TIMESTAMP'           ,  33, 1, 1, GETUTCDATE()),
  ( 772, 'Client'                                    , 'EndTimestamp'                              , 'end_timestamp'                             , 'TIMESTAMP'           ,  34, 1, 1, GETUTCDATE()),
  ( 773, 'Client'                                    , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,  35, 0, 1, GETUTCDATE()),
  ( 774, 'Client'                                    , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,  36, 0, 1, GETUTCDATE()),
  ( 775, 'Client'                                    , 'N/A'                                       , 'source_system'                             , 'STRING'              ,  37, 0, 1, GETUTCDATE()),
  ( 776, 'Client'                                    , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  38, 0, 1, GETUTCDATE()),
  ( 777, 'Client'                                    , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  39, 0, 1, GETUTCDATE());

-- [53] Contract (14 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 778, 'Contract'                                  , 'ContractPK'                                , 'contract_id'                               , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 779, 'Contract'                                  , 'ContractNumber'                            , 'contract_number'                           , 'STRING'              ,   2, 1, 1, GETUTCDATE()),
  ( 780, 'Contract'                                  , 'ProductFK'                                 , 'product_id'                                , 'INT'                 ,   3, 1, 1, GETUTCDATE()),
  ( 781, 'Contract'                                  , 'AgentFK'                                   , 'agent_id'                                  , 'INT'                 ,   4, 1, 1, GETUTCDATE()),
  ( 782, 'Contract'                                  , 'IssueDate'                                 , 'issue_date'                                , 'TIMESTAMP'           ,   5, 1, 1, GETUTCDATE()),
  ( 783, 'Contract'                                  , 'Status'                                    , 'status_code'                               , 'STRING'              ,   6, 1, 1, GETUTCDATE()),
  ( 784, 'Contract'                                  , 'StatusDate'                                , 'status_date'                               , 'TIMESTAMP'           ,   7, 1, 1, GETUTCDATE()),
  ( 785, 'Contract'                                  , 'PlanCode'                                  , 'plan_code'                                 , 'STRING'              ,   8, 1, 1, GETUTCDATE()),
  ( 786, 'Contract'                                  , 'StateCode'                                 , 'issue_state_code'                          , 'STRING'              ,   9, 1, 1, GETUTCDATE()),
  ( 787, 'Contract'                                  , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,  10, 0, 1, GETUTCDATE()),
  ( 788, 'Contract'                                  , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,  11, 0, 1, GETUTCDATE()),
  ( 789, 'Contract'                                  , 'N/A'                                       , 'source_system'                             , 'STRING'              ,  12, 0, 1, GETUTCDATE()),
  ( 790, 'Contract'                                  , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  13, 0, 1, GETUTCDATE()),
  ( 791, 'Contract'                                  , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  14, 0, 1, GETUTCDATE());

-- [54] vw_SEG_ContractClient (12 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 792, 'vw_SEG_ContractClient'                     , 'Source Column Name'                        , 'Target Column Name'                        , 'TARGET DATA TYPE (FABRIC)',   1, 1, 1, GETUTCDATE()),
  ( 793, 'vw_SEG_ContractClient'                     , 'ContractPK'                                , 'contract_id'                               , 'INT'                 ,   2, 1, 1, GETUTCDATE()),
  ( 794, 'vw_SEG_ContractClient'                     , 'ClientFK'                                  , 'client_id'                                 , 'INT'                 ,   3, 1, 1, GETUTCDATE()),
  ( 795, 'vw_SEG_ContractClient'                     , 'RoleName'                                  , 'client_role_name'                          , 'STRING'              ,   4, 1, 1, GETUTCDATE()),
  ( 796, 'vw_SEG_ContractClient'                     , 'Relationship'                              , 'relationship_to_insured'                   , 'STRING'              ,   5, 1, 1, GETUTCDATE()),
  ( 797, 'vw_SEG_ContractClient'                     , 'AllocationPercent'                         , 'share_percentage'                          , 'DECIMAL(18,4)'       ,   6, 1, 1, GETUTCDATE()),
  ( 798, 'vw_SEG_ContractClient'                     , 'Status'                                    , 'status'                                    , 'STRING'              ,   7, 1, 1, GETUTCDATE()),
  ( 799, 'vw_SEG_ContractClient'                     , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,   8, 0, 1, GETUTCDATE()),
  ( 800, 'vw_SEG_ContractClient'                     , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,   9, 0, 1, GETUTCDATE()),
  ( 801, 'vw_SEG_ContractClient'                     , 'N/A'                                       , 'source_system'                             , 'STRING'              ,  10, 0, 1, GETUTCDATE()),
  ( 802, 'vw_SEG_ContractClient'                     , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  11, 0, 1, GETUTCDATE()),
  ( 803, 'vw_SEG_ContractClient'                     , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  12, 0, 1, GETUTCDATE());

-- [55] vw_SEG_ContractTreaty (12 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 804, 'vw_SEG_ContractTreaty'                     , 'ContractPK'                                , 'contract_id'                               , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 805, 'vw_SEG_ContractTreaty'                     , 'TreatyPK'                                  , 'treaty_id'                                 , 'INT'                 ,   2, 1, 1, GETUTCDATE()),
  ( 806, 'vw_SEG_ContractTreaty'                     , 'ContractNumber'                            , 'contract_number'                           , 'STRING'              ,   3, 1, 1, GETUTCDATE()),
  ( 807, 'vw_SEG_ContractTreaty'                     , 'TreatyName'                                , 'treaty_name'                               , 'STRING'              ,   4, 1, 1, GETUTCDATE()),
  ( 808, 'vw_SEG_ContractTreaty'                     , 'TreatyDescription'                         , 'treaty_description'                        , 'STRING'              ,   5, 1, 1, GETUTCDATE()),
  ( 809, 'vw_SEG_ContractTreaty'                     , 'EffectiveDate'                             , 'effective_date'                            , 'TIMESTAMP'           ,   6, 1, 1, GETUTCDATE()),
  ( 810, 'vw_SEG_ContractTreaty'                     , 'Status'                                    , 'status'                                    , 'STRING'              ,   7, 1, 1, GETUTCDATE()),
  ( 811, 'vw_SEG_ContractTreaty'                     , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,   8, 0, 1, GETUTCDATE()),
  ( 812, 'vw_SEG_ContractTreaty'                     , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,   9, 0, 1, GETUTCDATE()),
  ( 813, 'vw_SEG_ContractTreaty'                     , 'N/A'                                       , 'source_system'                             , 'STRING'              ,  10, 0, 1, GETUTCDATE()),
  ( 814, 'vw_SEG_ContractTreaty'                     , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  11, 0, 1, GETUTCDATE()),
  ( 815, 'vw_SEG_ContractTreaty'                     , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  12, 0, 1, GETUTCDATE());

-- [56] vw_SEG_ContractRider (28 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 816, 'vw_SEG_ContractRider'                      , 'RiderGroupKey'                             , 'rider_group_id'                            , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 817, 'vw_SEG_ContractRider'                      , 'IBREligibilityDate'                        , 'ibr_eligibility_date'                      , 'TIMESTAMP'           ,   2, 1, 1, GETUTCDATE()),
  ( 818, 'vw_SEG_ContractRider'                      , 'IBRStartDate'                              , 'ibr_start_date'                            , 'TIMESTAMP'           ,   3, 1, 1, GETUTCDATE()),
  ( 819, 'vw_SEG_ContractRider'                      , 'ABR'                                       , 'abr_stop_date'                             , 'TIMESTAMP'           ,   4, 1, 1, GETUTCDATE()),
  ( 820, 'vw_SEG_ContractRider'                      , 'ABR-TI'                                    , 'abr_ti_stop_date'                          , 'TIMESTAMP'           ,   5, 1, 1, GETUTCDATE()),
  ( 821, 'vw_SEG_ContractRider'                      , 'AVGuarRider'                               , 'av_guar_rider_stop_date'                   , 'TIMESTAMP'           ,   6, 1, 1, GETUTCDATE()),
  ( 822, 'vw_SEG_ContractRider'                      , 'IBR'                                       , 'ibr_stop_date'                             , 'TIMESTAMP'           ,   7, 1, 1, GETUTCDATE()),
  ( 823, 'vw_SEG_ContractRider'                      , 'IBR-SD'                                    , 'ibr_sd_stop_date'                          , 'TIMESTAMP'           ,   8, 1, 1, GETUTCDATE()),
  ( 824, 'vw_SEG_ContractRider'                      , 'IBR-ST'                                    , 'ibr_st_stop_date'                          , 'TIMESTAMP'           ,   9, 1, 1, GETUTCDATE()),
  ( 825, 'vw_SEG_ContractRider'                      , 'InflationRider'                            , 'inflation_rider_stop_date'                 , 'TIMESTAMP'           ,  10, 1, 1, GETUTCDATE()),
  ( 826, 'vw_SEG_ContractRider'                      , 'LIQ'                                       , 'liq_stop_date'                             , 'TIMESTAMP'           ,  11, 1, 1, GETUTCDATE()),
  ( 827, 'vw_SEG_ContractRider'                      , 'LongevityRider'                            , 'longevity_rider_stop_date'                 , 'TIMESTAMP'           ,  12, 1, 1, GETUTCDATE()),
  ( 828, 'vw_SEG_ContractRider'                      , 'LTCRider'                                  , 'ltc_rider_stop_date'                       , 'TIMESTAMP'           ,  13, 1, 1, GETUTCDATE()),
  ( 829, 'vw_SEG_ContractRider'                      , 'MVA'                                       , 'mva_stop_date'                             , 'TIMESTAMP'           ,  14, 1, 1, GETUTCDATE()),
  ( 830, 'vw_SEG_ContractRider'                      , 'NFRider'                                   , 'nf_rider_stop_date'                        , 'TIMESTAMP'           ,  15, 1, 1, GETUTCDATE()),
  ( 831, 'vw_SEG_ContractRider'                      , 'NursingHomeWaiver'                         , 'nursing_home_waiver_stop_date'             , 'TIMESTAMP'           ,  16, 1, 1, GETUTCDATE()),
  ( 832, 'vw_SEG_ContractRider'                      , 'OP'                                        , 'op_stop_date'                              , 'TIMESTAMP'           ,  17, 1, 1, GETUTCDATE()),
  ( 833, 'vw_SEG_ContractRider'                      , 'ROP'                                       , 'rop_stop_date'                             , 'TIMESTAMP'           ,  18, 1, 1, GETUTCDATE()),
  ( 834, 'vw_SEG_ContractRider'                      , 'SR'                                        , 'sr_stop_date'                              , 'TIMESTAMP'           ,  19, 1, 1, GETUTCDATE()),
  ( 835, 'vw_SEG_ContractRider'                      , 'TIR'                                       , 'tir_stop_date'                             , 'TIMESTAMP'           ,  20, 1, 1, GETUTCDATE()),
  ( 836, 'vw_SEG_ContractRider'                      , 'WellnessCredits'                           , 'wellness_credits_stop_date'                , 'TIMESTAMP'           ,  21, 1, 1, GETUTCDATE()),
  ( 837, 'vw_SEG_ContractRider'                      , 'WellnessRider'                             , 'wellness_rider_stop_date'                  , 'TIMESTAMP'           ,  22, 1, 1, GETUTCDATE()),
  ( 838, 'vw_SEG_ContractRider'                      , 'WSC'                                       , 'wsc_stop_date'                             , 'TIMESTAMP'           ,  23, 1, 1, GETUTCDATE()),
  ( 839, 'vw_SEG_ContractRider'                      , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,  24, 0, 1, GETUTCDATE()),
  ( 840, 'vw_SEG_ContractRider'                      , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,  25, 0, 1, GETUTCDATE()),
  ( 841, 'vw_SEG_ContractRider'                      , 'N/A'                                       , 'source_system'                             , 'STRING'              ,  26, 0, 1, GETUTCDATE()),
  ( 842, 'vw_SEG_ContractRider'                      , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  27, 0, 1, GETUTCDATE()),
  ( 843, 'vw_SEG_ContractRider'                      , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  28, 0, 1, GETUTCDATE());

-- [57] ref_Product (15 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 844, 'ref_Product'                               , 'Source Column Name'                        , 'Target Column Name'                        , 'TARGET DATA TYPE (FABRIC)',   1, 1, 1, GETUTCDATE()),
  ( 845, 'ref_Product'                               , 'ProductPK'                                 , 'product_id'                                , 'INT'                 ,   2, 1, 1, GETUTCDATE()),
  ( 846, 'ref_Product'                               , 'ProductName'                               , 'product_name'                              , 'STRING'              ,   3, 1, 1, GETUTCDATE()),
  ( 847, 'ref_Product'                               , 'MarketingName'                             , 'marketing_name'                            , 'STRING'              ,   4, 1, 1, GETUTCDATE()),
  ( 848, 'ref_Product'                               , 'ProductType'                               , 'product_type'                              , 'STRING'              ,   5, 1, 1, GETUTCDATE()),
  ( 849, 'ref_Product'                               , 'CUSIPNumber'                               , 'cusip_number'                              , 'STRING'              ,   6, 1, 1, GETUTCDATE()),
  ( 850, 'ref_Product'                               , 'Context'                                   , 'product_context'                           , 'STRING'              ,   7, 1, 1, GETUTCDATE()),
  ( 851, 'ref_Product'                               , 'GLLOB'                                     , 'gl_line_of_business'                       , 'STRING'              ,   8, 1, 1, GETUTCDATE()),
  ( 852, 'ref_Product'                               , 'Status'                                    , 'status'                                    , 'STRING'              ,   9, 1, 1, GETUTCDATE()),
  ( 853, 'ref_Product'                               , 'EffectiveDate'                             , 'effective_date'                            , 'TIMESTAMP'           ,  10, 1, 1, GETUTCDATE()),
  ( 854, 'ref_Product'                               , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,  11, 0, 1, GETUTCDATE()),
  ( 855, 'ref_Product'                               , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,  12, 0, 1, GETUTCDATE()),
  ( 856, 'ref_Product'                               , 'N/A'                                       , 'source_system'                             , 'STRING'              ,  13, 0, 1, GETUTCDATE()),
  ( 857, 'ref_Product'                               , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  14, 0, 1, GETUTCDATE()),
  ( 858, 'ref_Product'                               , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  15, 0, 1, GETUTCDATE());

-- [58] vw_SEG_ContractTrx (14 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 859, 'vw_SEG_ContractTrx'                        , 'TrxPK'                                     , 'trx_id'                                    , 'BIGINT'              ,   1, 1, 1, GETUTCDATE()),
  ( 860, 'vw_SEG_ContractTrx'                        , 'ContractPK'                                , 'contract_id'                               , 'INT'                 ,   2, 1, 1, GETUTCDATE()),
  ( 861, 'vw_SEG_ContractTrx'                        , 'ContractNumber'                            , 'contract_number'                           , 'STRING'              ,   3, 1, 1, GETUTCDATE()),
  ( 862, 'vw_SEG_ContractTrx'                        , 'TrxType'                                   , 'trx_type_code'                             , 'STRING'              ,   4, 1, 1, GETUTCDATE()),
  ( 863, 'vw_SEG_ContractTrx'                        , 'TrxDescription'                            , 'trx_description'                           , 'STRING'              ,   5, 1, 1, GETUTCDATE()),
  ( 864, 'vw_SEG_ContractTrx'                        , 'EffectiveDate'                             , 'effective_date'                            , 'TIMESTAMP'           ,   6, 1, 1, GETUTCDATE()),
  ( 865, 'vw_SEG_ContractTrx'                        , 'ProcessDate'                               , 'process_date'                              , 'TIMESTAMP'           ,   7, 1, 1, GETUTCDATE()),
  ( 866, 'vw_SEG_ContractTrx'                        , 'Amount'                                    , 'trx_amount'                                , 'DECIMAL(18,4)'       ,   8, 1, 1, GETUTCDATE()),
  ( 867, 'vw_SEG_ContractTrx'                        , 'Status'                                    , 'trx_status'                                , 'STRING'              ,   9, 1, 1, GETUTCDATE()),
  ( 868, 'vw_SEG_ContractTrx'                        , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,  10, 0, 1, GETUTCDATE()),
  ( 869, 'vw_SEG_ContractTrx'                        , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,  11, 0, 1, GETUTCDATE()),
  ( 870, 'vw_SEG_ContractTrx'                        , 'N/A'                                       , 'source_system'                             , 'STRING'              ,  12, 0, 1, GETUTCDATE()),
  ( 871, 'vw_SEG_ContractTrx'                        , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  13, 0, 1, GETUTCDATE()),
  ( 872, 'vw_SEG_ContractTrx'                        , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  14, 0, 1, GETUTCDATE());

-- [59] vw_SEG_ContractPrimarySegment (12 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 873, 'vw_SEG_ContractPrimarySegment'             , 'ContractPK'                                , 'contract_id'                               , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 874, 'vw_SEG_ContractPrimarySegment'             , 'SegmentPK'                                 , 'segment_id'                                , 'INT'                 ,   2, 1, 1, GETUTCDATE()),
  ( 875, 'vw_SEG_ContractPrimarySegment'             , 'ContractNumber'                            , 'contract_number'                           , 'STRING'              ,   3, 1, 1, GETUTCDATE()),
  ( 876, 'vw_SEG_ContractPrimarySegment'             , 'SegmentNumber'                             , 'segment_number'                            , 'INT'                 ,   4, 1, 1, GETUTCDATE()),
  ( 877, 'vw_SEG_ContractPrimarySegment'             , 'EffectiveDate'                             , 'effective_date'                            , 'TIMESTAMP'           ,   5, 1, 1, GETUTCDATE()),
  ( 878, 'vw_SEG_ContractPrimarySegment'             , 'CostBasis'                                 , 'cost_basis'                                , 'DECIMAL(18,4)'       ,   6, 1, 1, GETUTCDATE()),
  ( 879, 'vw_SEG_ContractPrimarySegment'             , 'FreeAmount'                                , 'free_amount'                               , 'DECIMAL(18,4)'       ,   7, 1, 1, GETUTCDATE()),
  ( 880, 'vw_SEG_ContractPrimarySegment'             , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,   8, 0, 1, GETUTCDATE()),
  ( 881, 'vw_SEG_ContractPrimarySegment'             , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,   9, 0, 1, GETUTCDATE()),
  ( 882, 'vw_SEG_ContractPrimarySegment'             , 'N/A'                                       , 'source_system'                             , 'STRING'              ,  10, 0, 1, GETUTCDATE()),
  ( 883, 'vw_SEG_ContractPrimarySegment'             , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  11, 0, 1, GETUTCDATE()),
  ( 884, 'vw_SEG_ContractPrimarySegment'             , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  12, 0, 1, GETUTCDATE());

-- [60] vw_SEG_Agent (15 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 885, 'vw_SEG_Agent'                              , 'AgentPK'                                   , 'agent_id'                                  , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 886, 'vw_SEG_Agent'                              , 'AgentNumber'                               , 'agent_number'                              , 'STRING'              ,   2, 1, 1, GETUTCDATE()),
  ( 887, 'vw_SEG_Agent'                              , 'DisplayName'                               , 'display_name'                              , 'STRING'              ,   3, 1, 1, GETUTCDATE()),
  ( 888, 'vw_SEG_Agent'                              , 'NPN'                                       , 'npn_number'                                , 'STRING'              ,   4, 1, 1, GETUTCDATE()),
  ( 889, 'vw_SEG_Agent'                              , 'NASD'                                      , 'nasd_number'                               , 'STRING'              ,   5, 1, 1, GETUTCDATE()),
  ( 890, 'vw_SEG_Agent'                              , 'AgentType'                                 , 'agent_type'                                , 'STRING'              ,   6, 1, 1, GETUTCDATE()),
  ( 891, 'vw_SEG_Agent'                              , 'Status'                                    , 'status'                                    , 'STRING'              ,   7, 1, 1, GETUTCDATE()),
  ( 892, 'vw_SEG_Agent'                              , 'HireDate'                                  , 'hire_date'                                 , 'TIMESTAMP'           ,   8, 1, 1, GETUTCDATE()),
  ( 893, 'vw_SEG_Agent'                              , 'TerminationDate'                           , 'termination_date'                          , 'TIMESTAMP'           ,   9, 1, 1, GETUTCDATE()),
  ( 894, 'vw_SEG_Agent'                              , 'ClientFK'                                  , 'client_id'                                 , 'INT'                 ,  10, 1, 1, GETUTCDATE()),
  ( 895, 'vw_SEG_Agent'                              , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,  11, 0, 1, GETUTCDATE()),
  ( 896, 'vw_SEG_Agent'                              , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,  12, 0, 1, GETUTCDATE()),
  ( 897, 'vw_SEG_Agent'                              , 'N/A'                                       , 'source_system'                             , 'STRING'              ,  13, 0, 1, GETUTCDATE()),
  ( 898, 'vw_SEG_Agent'                              , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  14, 0, 1, GETUTCDATE()),
  ( 899, 'vw_SEG_Agent'                              , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  15, 0, 1, GETUTCDATE());

-- [61] vw_SEG_Client (16 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 900, 'vw_SEG_Client'                             , 'ClientPK'                                  , 'client_id'                                 , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 901, 'vw_SEG_Client'                             , 'SourceKey'                                 , 'source_key'                                , 'BIGINT'              ,   2, 1, 1, GETUTCDATE()),
  ( 902, 'vw_SEG_Client'                             , 'DisplayName'                               , 'display_name'                              , 'STRING'              ,   3, 1, 1, GETUTCDATE()),
  ( 903, 'vw_SEG_Client'                             , 'FirstName'                                 , 'first_name'                                , 'STRING'              ,   4, 1, 1, GETUTCDATE()),
  ( 904, 'vw_SEG_Client'                             , 'LastName'                                  , 'last_name'                                 , 'STRING'              ,   5, 1, 1, GETUTCDATE()),
  ( 905, 'vw_SEG_Client'                             , 'Email'                                     , 'email_address'                             , 'STRING'              ,   6, 1, 1, GETUTCDATE()),
  ( 906, 'vw_SEG_Client'                             , 'Phone'                                     , 'phone_number'                              , 'STRING'              ,   7, 1, 1, GETUTCDATE()),
  ( 907, 'vw_SEG_Client'                             , 'BirthDate'                                 , 'birth_date'                                , 'TIMESTAMP'           ,   8, 1, 1, GETUTCDATE()),
  ( 908, 'vw_SEG_Client'                             , 'Status'                                    , 'status'                                    , 'STRING'              ,   9, 1, 1, GETUTCDATE()),
  ( 909, 'vw_SEG_Client'                             , 'State'                                     , 'state_code'                                , 'STRING'              ,  10, 1, 1, GETUTCDATE()),
  ( 910, 'vw_SEG_Client'                             , 'ZipCode'                                   , 'zip_code'                                  , 'STRING'              ,  11, 1, 1, GETUTCDATE()),
  ( 911, 'vw_SEG_Client'                             , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,  12, 0, 1, GETUTCDATE()),
  ( 912, 'vw_SEG_Client'                             , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,  13, 0, 1, GETUTCDATE()),
  ( 913, 'vw_SEG_Client'                             , 'N/A'                                       , 'source_system'                             , 'STRING'              ,  14, 0, 1, GETUTCDATE()),
  ( 914, 'vw_SEG_Client'                             , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  15, 0, 1, GETUTCDATE()),
  ( 915, 'vw_SEG_Client'                             , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  16, 0, 1, GETUTCDATE());

-- Total: 915 column mappings across 61 source tables