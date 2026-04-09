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
  (   1, 'Territory'                                 , 'TerritoryPK'                               , 'territory_id'                              , 'INT'                 ,   1, true, true, current_timestamp()),
  (   2, 'Territory'                                 , 'TerritoryName'                             , 'territory_name'                            , 'STRING'              ,   2, true, true, current_timestamp()),
  (   3, 'Territory'                                 , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,   3, false, true, current_timestamp()),
  (   4, 'Territory'                                 , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,   4, false, true, current_timestamp()),
  (   5, 'Territory'                                 , 'N/A'                                       , 'source_system'                             , 'STRING'              ,   5, false, true, current_timestamp()),
  (   6, 'Territory'                                 , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,   6, false, true, current_timestamp()),
  (   7, 'Territory'                                 , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,   7, false, true, current_timestamp());

-- [02] HierarchyTerritory (8 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  (   8, 'HierarchyTerritory'                        , 'HierarchyTerritoryPK'                      , 'hierarchy_territory_id'                    , 'INT'                 ,   1, true, true, current_timestamp()),
  (   9, 'HierarchyTerritory'                        , 'HierarchySetKey'                           , 'hierarchy_set_key'                         , 'INT'                 ,   2, true, true, current_timestamp()),
  (  10, 'HierarchyTerritory'                        , 'TerritoryFK'                               , 'territory_id'                              , 'INT'                 ,   3, true, true, current_timestamp()),
  (  11, 'HierarchyTerritory'                        , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,   4, false, true, current_timestamp()),
  (  12, 'HierarchyTerritory'                        , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,   5, false, true, current_timestamp()),
  (  13, 'HierarchyTerritory'                        , 'N/A'                                       , 'source_system'                             , 'STRING'              ,   6, false, true, current_timestamp()),
  (  14, 'HierarchyTerritory'                        , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,   7, false, true, current_timestamp()),
  (  15, 'HierarchyTerritory'                        , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,   8, false, true, current_timestamp());

-- [03] Hierarchy_SuperHierarchy (10 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  (  16, 'Hierarchy_SuperHierarchy'                  , 'SuperHierarchyPK'                          , 'super_hierarchy_id'                        , 'INT'                 ,   1, true, true, current_timestamp()),
  (  17, 'Hierarchy_SuperHierarchy'                  , 'AgentContractFK'                           , 'agent_contract_id'                         , 'INT'                 ,   2, true, true, current_timestamp()),
  (  18, 'Hierarchy_SuperHierarchy'                  , 'HierarchySetKey'                           , 'hierarchy_set_key'                         , 'INT'                 ,   3, true, true, current_timestamp()),
  (  19, 'Hierarchy_SuperHierarchy'                  , 'ReverseLevel'                              , 'reverse_level'                             , 'DECIMAL(18,4)'       ,   4, true, true, current_timestamp()),
  (  20, 'Hierarchy_SuperHierarchy'                  , 'DisplayName'                               , 'display_name'                              , 'STRING'              ,   5, true, true, current_timestamp()),
  (  21, 'Hierarchy_SuperHierarchy'                  , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,   6, false, true, current_timestamp()),
  (  22, 'Hierarchy_SuperHierarchy'                  , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,   7, false, true, current_timestamp()),
  (  23, 'Hierarchy_SuperHierarchy'                  , 'N/A'                                       , 'source_system'                             , 'STRING'              ,   8, false, true, current_timestamp()),
  (  24, 'Hierarchy_SuperHierarchy'                  , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,   9, false, true, current_timestamp()),
  (  25, 'Hierarchy_SuperHierarchy'                  , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  10, false, true, current_timestamp());

-- [04] Hierarchy_Option (9 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  (  26, 'Hierarchy_Option'                          , 'HierarchyOptionPK'                         , 'hierarchy_option_id'                       , 'INT'                 ,   1, true, true, current_timestamp()),
  (  27, 'Hierarchy_Option'                          , 'HierarchyBridgeFK'                         , 'hierarchy_bridge_id'                       , 'INT'                 ,   2, true, true, current_timestamp()),
  (  28, 'Hierarchy_Option'                          , 'AgentContractFK'                           , 'agent_contract_id'                         , 'INT'                 ,   3, true, true, current_timestamp()),
  (  29, 'Hierarchy_Option'                          , 'AccessRemovedInd'                          , 'is_access_removed'                         , 'BOOLEAN'             ,   4, true, true, current_timestamp()),
  (  30, 'Hierarchy_Option'                          , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,   5, false, true, current_timestamp()),
  (  31, 'Hierarchy_Option'                          , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,   6, false, true, current_timestamp()),
  (  32, 'Hierarchy_Option'                          , 'N/A'                                       , 'source_system'                             , 'STRING'              ,   7, false, true, current_timestamp()),
  (  33, 'Hierarchy_Option'                          , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,   8, false, true, current_timestamp()),
  (  34, 'Hierarchy_Option'                          , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,   9, false, true, current_timestamp());

-- [05] Hierarchy_Bridge (15 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  (  35, 'Hierarchy_Bridge'                          , 'HierarchyBridgePK'                         , 'hierarchy_bridge_id'                       , 'INT'                 ,   1, true, true, current_timestamp()),
  (  36, 'Hierarchy_Bridge'                          , 'HierarchyGroupKey'                         , 'hierarchy_group_key'                       , 'INT'                 ,   2, true, true, current_timestamp()),
  (  37, 'Hierarchy_Bridge'                          , 'HierarchySetKey'                           , 'hierarchy_set_key'                         , 'INT'                 ,   3, true, true, current_timestamp()),
  (  38, 'Hierarchy_Bridge'                          , 'SplitPercent'                              , 'split_percent'                             , 'DECIMAL(18,4)'       ,   4, true, true, current_timestamp()),
  (  39, 'Hierarchy_Bridge'                          , 'ServicingAgentIndicator'                   , 'servicing_agent_indicator'                 , 'STRING'              ,   5, true, true, current_timestamp()),
  (  40, 'Hierarchy_Bridge'                          , 'CommissionOnlyIndicator'                   , 'commission_only_indicator'                 , 'STRING'              ,   6, true, true, current_timestamp()),
  (  41, 'Hierarchy_Bridge'                          , 'CommissionOption'                          , 'commission_option'                         , 'STRING'              ,   7, true, true, current_timestamp()),
  (  42, 'Hierarchy_Bridge'                          , 'HierarchyOrder'                            , 'hierarchy_order'                           , 'INT'                 ,   8, true, true, current_timestamp()),
  (  43, 'Hierarchy_Bridge'                          , 'StartDate'                                 , 'start_timestamp'                           , 'TIMESTAMP'           ,   9, true, true, current_timestamp()),
  (  44, 'Hierarchy_Bridge'                          , 'StopDate'                                  , 'stop_timestamp'                            , 'TIMESTAMP'           ,  10, true, true, current_timestamp()),
  (  45, 'Hierarchy_Bridge'                          , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,  11, false, true, current_timestamp()),
  (  46, 'Hierarchy_Bridge'                          , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,  12, false, true, current_timestamp()),
  (  47, 'Hierarchy_Bridge'                          , 'N/A'                                       , 'source_system'                             , 'STRING'              ,  13, false, true, current_timestamp()),
  (  48, 'Hierarchy_Bridge'                          , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  14, false, true, current_timestamp()),
  (  49, 'Hierarchy_Bridge'                          , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  15, false, true, current_timestamp());

-- [06] Hierarchy (10 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  (  50, 'Hierarchy'                                 , 'Source Column Name'                        , 'Target Column Name'                        , 'TARGET DATA TYPE'    ,   1, true, true, current_timestamp()),
  (  51, 'Hierarchy'                                 , 'HierarchyPK'                               , 'hierarchy_id'                              , 'INT'                 ,   2, true, true, current_timestamp()),
  (  52, 'Hierarchy'                                 , 'HierarchySetKey'                           , 'hierarchy_set_key'                         , 'INT'                 ,   3, true, true, current_timestamp()),
  (  53, 'Hierarchy'                                 , 'AgentContractFK'                           , 'agent_contract_id'                         , 'INT'                 ,   4, true, true, current_timestamp()),
  (  54, 'Hierarchy'                                 , 'ReverseLevel'                              , 'reverse_level'                             , 'INT'                 ,   5, true, true, current_timestamp()),
  (  55, 'Hierarchy'                                 , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,   6, false, true, current_timestamp()),
  (  56, 'Hierarchy'                                 , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,   7, false, true, current_timestamp()),
  (  57, 'Hierarchy'                                 , 'N/A'                                       , 'source_system'                             , 'STRING'              ,   8, false, true, current_timestamp()),
  (  58, 'Hierarchy'                                 , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,   9, false, true, current_timestamp()),
  (  59, 'Hierarchy'                                 , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  10, false, true, current_timestamp());

-- [07] CommissionLevelRank (8 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  (  60, 'CommissionLevelRank'                       , 'CommissionLevelRankPK'                     , 'commission_level_rank_id'                  , 'INT'                 ,   1, true, true, current_timestamp()),
  (  61, 'CommissionLevelRank'                       , 'CommissionLevel'                           , 'commission_level'                          , 'STRING'              ,   2, true, true, current_timestamp()),
  (  62, 'CommissionLevelRank'                       , 'Rank'                                      , 'rank'                                      , 'INT'                 ,   3, true, true, current_timestamp()),
  (  63, 'CommissionLevelRank'                       , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,   4, false, true, current_timestamp()),
  (  64, 'CommissionLevelRank'                       , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,   5, false, true, current_timestamp()),
  (  65, 'CommissionLevelRank'                       , 'N/A'                                       , 'source_system'                             , 'STRING'              ,   6, false, true, current_timestamp()),
  (  66, 'CommissionLevelRank'                       , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,   7, false, true, current_timestamp()),
  (  67, 'CommissionLevelRank'                       , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,   8, false, true, current_timestamp());

-- [08] AgentContract (16 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  (  68, 'AgentContract'                             , 'AgentContractPK'                           , 'agent_contract_id'                         , 'INT'                 ,   1, true, true, current_timestamp()),
  (  69, 'AgentContract'                             , 'AgentNumber'                               , 'agent_number'                              , 'STRING'              ,   2, true, true, current_timestamp()),
  (  70, 'AgentContract'                             , 'AgentFK'                                   , 'agent_id'                                  , 'INT'                 ,   3, true, true, current_timestamp()),
  (  71, 'AgentContract'                             , 'Context'                                   , 'context'                                   , 'STRING'              ,   4, true, true, current_timestamp()),
  (  72, 'AgentContract'                             , 'Status'                                    , 'status'                                    , 'STRING'              ,   5, true, true, current_timestamp()),
  (  73, 'AgentContract'                             , 'CommissionLevel'                           , 'commission_level'                          , 'STRING'              ,   6, true, true, current_timestamp()),
  (  74, 'AgentContract'                             , 'SituationCode'                             , 'situation_code'                            , 'STRING'              ,   7, true, true, current_timestamp()),
  (  75, 'AgentContract'                             , 'ContractEffectiveDate'                     , 'contract_effective_timestamp'              , 'TIMESTAMP'           ,   8, true, true, current_timestamp()),
  (  76, 'AgentContract'                             , 'ContractTerminationDate'                   , 'contract_termination_timestamp'            , 'TIMESTAMP'           ,   9, true, true, current_timestamp()),
  (  77, 'AgentContract'                             , 'CurrentRecord'                             , 'is_current_record'                         , 'STRING'              ,  10, true, true, current_timestamp()),
  (  78, 'AgentContract'                             , 'SetToCurrentDate'                          , 'set_to_current_timestamp'                  , 'TIMESTAMP'           ,  11, true, true, current_timestamp()),
  (  79, 'AgentContract'                             , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,  12, false, true, current_timestamp()),
  (  80, 'AgentContract'                             , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,  13, false, true, current_timestamp()),
  (  81, 'AgentContract'                             , 'N/A'                                       , 'source_system'                             , 'STRING'              ,  14, false, true, current_timestamp()),
  (  82, 'AgentContract'                             , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  15, false, true, current_timestamp()),
  (  83, 'AgentContract'                             , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  16, false, true, current_timestamp());

-- [09] TrainingState_Group (10 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  (  84, 'TrainingState_Group'                       , 'TrainingStateGroupPK'                      , 'training_state_group_id'                   , 'INT'                 ,   1, true, true, current_timestamp()),
  (  85, 'TrainingState_Group'                       , 'TrainingStateGroupKey'                     , 'training_state_group_key'                  , 'INT'                 ,   2, true, true, current_timestamp()),
  (  86, 'TrainingState_Group'                       , 'State'                                     , 'state_code'                                , 'STRING'              ,   3, true, true, current_timestamp()),
  (  87, 'TrainingState_Group'                       , 'Required'                                  , 'is_required'                               , 'BOOLEAN'             ,   4, true, true, current_timestamp()),
  (  88, 'TrainingState_Group'                       , 'EffectiveDate'                             , 'effective_timestamp'                       , 'TIMESTAMP'           ,   5, true, true, current_timestamp()),
  (  89, 'TrainingState_Group'                       , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,   6, false, true, current_timestamp()),
  (  90, 'TrainingState_Group'                       , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,   7, false, true, current_timestamp()),
  (  91, 'TrainingState_Group'                       , 'N/A'                                       , 'source_system'                             , 'STRING'              ,   8, false, true, current_timestamp()),
  (  92, 'TrainingState_Group'                       , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,   9, false, true, current_timestamp()),
  (  93, 'TrainingState_Group'                       , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  10, false, true, current_timestamp());

-- [10] TrainingProduct_Group (9 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  (  94, 'TrainingProduct_Group'                     , 'TrainingProductGroupPK'                    , 'training_product_group_id'                 , 'INT'                 ,   1, true, true, current_timestamp()),
  (  95, 'TrainingProduct_Group'                     , 'TrainingProductGroupKey'                   , 'training_product_group_key'                , 'INT'                 ,   2, true, true, current_timestamp()),
  (  96, 'TrainingProduct_Group'                     , 'ProductFK'                                 , 'product_id'                                , 'INT'                 ,   3, true, true, current_timestamp()),
  (  97, 'TrainingProduct_Group'                     , 'Required'                                  , 'is_required'                               , 'BOOLEAN'             ,   4, true, true, current_timestamp()),
  (  98, 'TrainingProduct_Group'                     , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,   5, false, true, current_timestamp()),
  (  99, 'TrainingProduct_Group'                     , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,   6, false, true, current_timestamp()),
  ( 100, 'TrainingProduct_Group'                     , 'N/A'                                       , 'source_system'                             , 'STRING'              ,   7, false, true, current_timestamp()),
  ( 101, 'TrainingProduct_Group'                     , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,   8, false, true, current_timestamp()),
  ( 102, 'TrainingProduct_Group'                     , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,   9, false, true, current_timestamp());

-- [11] Rider_Group (20 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 103, 'Rider_Group'                               , 'RiderGroupPK'                              , 'rider_group_id'                            , 'INT'                 ,   1, true, true, current_timestamp()),
  ( 104, 'Rider_Group'                               , 'RiderGroupKey'                             , 'rider_group_key'                           , 'INT'                 ,   2, true, true, current_timestamp()),
  ( 105, 'Rider_Group'                               , 'Code'                                      , 'rider_code'                                , 'STRING'              ,   3, true, true, current_timestamp()),
  ( 106, 'Rider_Group'                               , 'Description'                               , 'description'                               , 'STRING'              ,   4, true, true, current_timestamp()),
  ( 107, 'Rider_Group'                               , 'BaseValue'                                 , 'base_value'                                , 'DECIMAL(18,4)'       ,   5, true, true, current_timestamp()),
  ( 108, 'Rider_Group'                               , 'EligibilityDate'                           , 'eligibility_timestamp'                     , 'TIMESTAMP'           ,   6, true, true, current_timestamp()),
  ( 109, 'Rider_Group'                               , 'FeePercent'                                , 'fee_percent'                               , 'DECIMAL(18,4)'       ,   7, true, true, current_timestamp()),
  ( 110, 'Rider_Group'                               , 'Lives'                                     , 'lives'                                     , 'STRING'              ,   8, true, true, current_timestamp()),
  ( 111, 'Rider_Group'                               , 'PayValue'                                  , 'pay_value'                                 , 'DECIMAL(18,4)'       ,   9, true, true, current_timestamp()),
  ( 112, 'Rider_Group'                               , 'Frequency'                                 , 'frequency'                                 , 'STRING'              ,  10, true, true, current_timestamp()),
  ( 113, 'Rider_Group'                               , 'WellnessEnrollment'                        , 'is_wellness_enrollment'                    , 'BOOLEAN'             ,  11, true, true, current_timestamp()),
  ( 114, 'Rider_Group'                               , 'WellnessCredits'                           , 'wellness_credits'                          , 'DECIMAL(18,4)'       ,  12, true, true, current_timestamp()),
  ( 115, 'Rider_Group'                               , 'StartAge'                                  , 'start_age'                                 , 'INT'                 ,  13, true, true, current_timestamp()),
  ( 116, 'Rider_Group'                               , 'StartDate'                                 , 'start_timestamp'                           , 'TIMESTAMP'           ,  14, true, true, current_timestamp()),
  ( 117, 'Rider_Group'                               , 'StopDate'                                  , 'stop_timestamp'                            , 'TIMESTAMP'           ,  15, true, true, current_timestamp()),
  ( 118, 'Rider_Group'                               , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,  16, false, true, current_timestamp()),
  ( 119, 'Rider_Group'                               , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,  17, false, true, current_timestamp()),
  ( 120, 'Rider_Group'                               , 'N/A'                                       , 'source_system'                             , 'STRING'              ,  18, false, true, current_timestamp()),
  ( 121, 'Rider_Group'                               , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  19, false, true, current_timestamp()),
  ( 122, 'Rider_Group'                               , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  20, false, true, current_timestamp());

-- [12] Requirement_Group (14 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 123, 'Requirement_Group'                         , 'RequirementGroupPK'                        , 'requirement_group_id'                      , 'INT'                 ,   1, true, true, current_timestamp()),
  ( 124, 'Requirement_Group'                         , 'RequirementGroupKey'                       , 'requirement_group_key'                     , 'INT'                 ,   2, true, true, current_timestamp()),
  ( 125, 'Requirement_Group'                         , 'Code'                                      , 'requirement_code'                          , 'STRING'              ,   3, true, true, current_timestamp()),
  ( 126, 'Requirement_Group'                         , 'Description'                               , 'description'                               , 'STRING'              ,   4, true, true, current_timestamp()),
  ( 127, 'Requirement_Group'                         , 'Status'                                    , 'status'                                    , 'STRING'              ,   5, true, true, current_timestamp()),
  ( 128, 'Requirement_Group'                         , 'EffectiveDate'                             , 'effective_timestamp'                       , 'TIMESTAMP'           ,   6, true, true, current_timestamp()),
  ( 129, 'Requirement_Group'                         , 'FollowUpDate'                              , 'follow_up_timestamp'                       , 'TIMESTAMP'           ,   7, true, true, current_timestamp()),
  ( 130, 'Requirement_Group'                         , 'ReceivedDate'                              , 'received_timestamp'                        , 'TIMESTAMP'           ,   8, true, true, current_timestamp()),
  ( 131, 'Requirement_Group'                         , 'ExecutedDate'                              , 'executed_timestamp'                        , 'TIMESTAMP'           ,   9, true, true, current_timestamp()),
  ( 132, 'Requirement_Group'                         , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,  10, false, true, current_timestamp()),
  ( 133, 'Requirement_Group'                         , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,  11, false, true, current_timestamp()),
  ( 134, 'Requirement_Group'                         , 'N/A'                                       , 'source_system'                             , 'STRING'              ,  12, false, true, current_timestamp()),
  ( 135, 'Requirement_Group'                         , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  13, false, true, current_timestamp()),
  ( 136, 'Requirement_Group'                         , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  14, false, true, current_timestamp());

-- [13] RenewalRate_Group (11 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 137, 'RenewalRate_Group'                         , 'RenewalRateGroupPK'                        , 'renewal_rate_group_id'                     , 'INT'                 ,   1, true, true, current_timestamp()),
  ( 138, 'RenewalRate_Group'                         , 'RenewalRateGroupKey'                       , 'renewal_rate_group_key'                    , 'INT'                 ,   2, true, true, current_timestamp()),
  ( 139, 'RenewalRate_Group'                         , 'EffectiveDate'                             , 'effective_timestamp'                       , 'TIMESTAMP'           ,   3, true, true, current_timestamp()),
  ( 140, 'RenewalRate_Group'                         , 'Year'                                      , 'year'                                      , 'INT'                 ,   4, true, true, current_timestamp()),
  ( 141, 'RenewalRate_Group'                         , 'YearDisplay'                               , 'year_display'                              , 'STRING'              ,   5, true, true, current_timestamp()),
  ( 142, 'RenewalRate_Group'                         , 'Rate'                                      , 'rate'                                      , 'DECIMAL(18,4)'       ,   6, true, true, current_timestamp()),
  ( 143, 'RenewalRate_Group'                         , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,   7, false, true, current_timestamp()),
  ( 144, 'RenewalRate_Group'                         , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,   8, false, true, current_timestamp()),
  ( 145, 'RenewalRate_Group'                         , 'N/A'                                       , 'source_system'                             , 'STRING'              ,   9, false, true, current_timestamp()),
  ( 146, 'RenewalRate_Group'                         , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  10, false, true, current_timestamp()),
  ( 147, 'RenewalRate_Group'                         , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  11, false, true, current_timestamp());

-- [14] Reinsurance_Group (9 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 148, 'Reinsurance_Group'                         , 'ReinsuranceGroupPK'                        , 'reinsurance_group_id'                      , 'INT'                 ,   1, true, true, current_timestamp()),
  ( 149, 'Reinsurance_Group'                         , 'ReinsuranceGroupKey'                       , 'reinsurance_group_key'                     , 'INT'                 ,   2, true, true, current_timestamp()),
  ( 150, 'Reinsurance_Group'                         , 'TreatyCode'                                , 'treaty_code'                               , 'STRING'              ,   3, true, true, current_timestamp()),
  ( 151, 'Reinsurance_Group'                         , 'CoinsurancePercentage'                     , 'coinsurance_percentage'                    , 'DECIMAL(18,4)'       ,   4, true, true, current_timestamp()),
  ( 152, 'Reinsurance_Group'                         , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,   5, false, true, current_timestamp()),
  ( 153, 'Reinsurance_Group'                         , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,   6, false, true, current_timestamp()),
  ( 154, 'Reinsurance_Group'                         , 'N/A'                                       , 'source_system'                             , 'STRING'              ,   7, false, true, current_timestamp()),
  ( 155, 'Reinsurance_Group'                         , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,   8, false, true, current_timestamp()),
  ( 156, 'Reinsurance_Group'                         , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,   9, false, true, current_timestamp());

-- [15] RecurringPayment_Group (21 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 157, 'RecurringPayment_Group'                    , 'RecurringPaymentGroupPK'                   , 'recurring_payment_group_id'                , 'INT'                 ,   1, true, true, current_timestamp()),
  ( 158, 'RecurringPayment_Group'                    , 'RecurringPaymentGroupKey'                  , 'recurring_payment_group_key'               , 'INT'                 ,   2, true, true, current_timestamp()),
  ( 159, 'RecurringPayment_Group'                    , 'ActivityTypeFK'                            , 'activity_type_id'                          , 'INT'                 ,   3, true, true, current_timestamp()),
  ( 160, 'RecurringPayment_Group'                    , 'PayeeFK'                                   , 'payee_id'                                  , 'INT'                 ,   4, true, true, current_timestamp()),
  ( 161, 'RecurringPayment_Group'                    , 'NextEffectiveDate'                         , 'next_effective_timestamp'                  , 'TIMESTAMP'           ,   5, true, true, current_timestamp()),
  ( 162, 'RecurringPayment_Group'                    , 'PausedInd'                                 , 'is_paused'                                 , 'BOOLEAN'             ,   6, true, true, current_timestamp()),
  ( 163, 'RecurringPayment_Group'                    , 'DistributionType'                          , 'distribution_type'                         , 'STRING'              ,   7, true, true, current_timestamp()),
  ( 164, 'RecurringPayment_Group'                    , 'Lives'                                     , 'lives'                                     , 'STRING'              ,   8, true, true, current_timestamp()),
  ( 165, 'RecurringPayment_Group'                    , 'Frequency'                                 , 'frequency'                                 , 'STRING'              ,   9, true, true, current_timestamp()),
  ( 166, 'RecurringPayment_Group'                    , 'WithdrawalType'                            , 'withdrawal_type'                           , 'STRING'              ,  10, true, true, current_timestamp()),
  ( 167, 'RecurringPayment_Group'                    , 'FirstDate'                                 , 'first_timestamp'                           , 'TIMESTAMP'           ,  11, true, true, current_timestamp()),
  ( 168, 'RecurringPayment_Group'                    , 'PriorDate'                                 , 'prior_timestamp'                           , 'TIMESTAMP'           ,  12, true, true, current_timestamp()),
  ( 169, 'RecurringPayment_Group'                    , 'PriorActivityFK'                           , 'prior_activity_id'                         , 'INT'                 ,  13, true, true, current_timestamp()),
  ( 170, 'RecurringPayment_Group'                    , 'EligibleRMDDate'                           , 'eligible_rmd_timestamp'                    , 'TIMESTAMP'           ,  14, true, true, current_timestamp()),
  ( 171, 'RecurringPayment_Group'                    , 'CalculatedAmount'                          , 'calculated_amount'                         , 'DECIMAL(18,4)'       ,  15, true, true, current_timestamp()),
  ( 172, 'RecurringPayment_Group'                    , 'GrossNet'                                  , 'gross_net'                                 , 'STRING'              ,  16, true, true, current_timestamp()),
  ( 173, 'RecurringPayment_Group'                    , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,  17, false, true, current_timestamp()),
  ( 174, 'RecurringPayment_Group'                    , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,  18, false, true, current_timestamp()),
  ( 175, 'RecurringPayment_Group'                    , 'N/A'                                       , 'source_system'                             , 'STRING'              ,  19, false, true, current_timestamp()),
  ( 176, 'RecurringPayment_Group'                    , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  20, false, true, current_timestamp()),
  ( 177, 'RecurringPayment_Group'                    , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  21, false, true, current_timestamp());

-- [16] Note_Group (21 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 178, 'Note_Group'                                , 'NoteGroupPK'                               , 'note_group_id'                             , 'INT'                 ,   1, true, true, current_timestamp()),
  ( 179, 'Note_Group'                                , 'SourceKey'                                 , 'source_key'                                , 'BIGINT'              ,   2, true, true, current_timestamp()),
  ( 180, 'Note_Group'                                , 'NoteGroupKey'                              , 'note_group_key'                            , 'INT'                 ,   3, true, true, current_timestamp()),
  ( 181, 'Note_Group'                                , 'Order'                                     , 'sort_order'                                , 'INT'                 ,   4, true, true, current_timestamp()),
  ( 182, 'Note_Group'                                , 'Text'                                      , 'note_text'                                 , 'STRING'              ,   5, true, true, current_timestamp()),
  ( 183, 'Note_Group'                                , 'Type'                                      , 'note_type'                                 , 'STRING'              ,   6, true, true, current_timestamp()),
  ( 184, 'Note_Group'                                , 'Role'                                      , 'role'                                      , 'STRING'              ,   7, true, true, current_timestamp()),
  ( 185, 'Note_Group'                                , 'MaintDate'                                 , 'maint_timestamp'                           , 'TIMESTAMP'           ,   8, true, true, current_timestamp()),
  ( 186, 'Note_Group'                                , 'MaintBy'                                   , 'maint_by'                                  , 'STRING'              ,   9, true, true, current_timestamp()),
  ( 187, 'Note_Group'                                , 'Call_ID'                                   , 'call_id'                                   , 'INT'                 ,  10, true, true, current_timestamp()),
  ( 188, 'Note_Group'                                , 'Call_Length'                               , 'call_length'                               , 'INT'                 ,  11, true, true, current_timestamp()),
  ( 189, 'Note_Group'                                , 'Call_StartDate'                            , 'call_start_timestamp'                      , 'TIMESTAMP'           ,  12, true, true, current_timestamp()),
  ( 190, 'Note_Group'                                , 'Call_InOut'                                , 'call_direction'                            , 'STRING'              ,  13, true, true, current_timestamp()),
  ( 191, 'Note_Group'                                , 'Call_Operators'                            , 'call_operators'                            , 'STRING'              ,  14, true, true, current_timestamp()),
  ( 192, 'Note_Group'                                , 'Call_FilePath'                             , 'call_file_path'                            , 'STRING'              ,  15, true, true, current_timestamp()),
  ( 193, 'Note_Group'                                , 'Call_EncryptKey'                           , 'call_encrypt_key'                          , 'STRING'              ,  16, true, true, current_timestamp()),
  ( 194, 'Note_Group'                                , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,  17, false, true, current_timestamp()),
  ( 195, 'Note_Group'                                , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,  18, false, true, current_timestamp()),
  ( 196, 'Note_Group'                                , 'N/A'                                       , 'source_system'                             , 'STRING'              ,  19, false, true, current_timestamp()),
  ( 197, 'Note_Group'                                , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  20, false, true, current_timestamp()),
  ( 198, 'Note_Group'                                , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  21, false, true, current_timestamp());

-- [17] IndexValue_Group (12 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 199, 'IndexValue_Group'                          , 'IndexValueGroupPK'                         , 'index_value_group_id'                      , 'INT'                 ,   1, true, true, current_timestamp()),
  ( 200, 'IndexValue_Group'                          , 'IndexValueGroupKey'                        , 'index_value_group_key'                     , 'INT'                 ,   2, true, true, current_timestamp()),
  ( 201, 'IndexValue_Group'                          , 'Ticker'                                    , 'ticker'                                    , 'STRING'              ,   3, true, true, current_timestamp()),
  ( 202, 'IndexValue_Group'                          , 'IndexName'                                 , 'index_name'                                , 'STRING'              ,   4, true, true, current_timestamp()),
  ( 203, 'IndexValue_Group'                          , 'EffectiveDate'                             , 'effective_timestamp'                       , 'TIMESTAMP'           ,   5, true, true, current_timestamp()),
  ( 204, 'IndexValue_Group'                          , 'IndexValue'                                , 'index_value'                               , 'DECIMAL(18,4)'       ,   6, true, true, current_timestamp()),
  ( 205, 'IndexValue_Group'                          , 'Change'                                    , 'change_amount'                             , 'DECIMAL(18,4)'       ,   7, true, true, current_timestamp()),
  ( 206, 'IndexValue_Group'                          , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,   8, false, true, current_timestamp()),
  ( 207, 'IndexValue_Group'                          , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,   9, false, true, current_timestamp()),
  ( 208, 'IndexValue_Group'                          , 'N/A'                                       , 'source_system'                             , 'STRING'              ,  10, false, true, current_timestamp()),
  ( 209, 'IndexValue_Group'                          , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  11, false, true, current_timestamp()),
  ( 210, 'IndexValue_Group'                          , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  12, false, true, current_timestamp());

-- [18] ExternalAccount_Group (14 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 211, 'ExternalAccount_Group'                     , 'ExternalAccountGroupPK'                    , 'external_account_group_id'                 , 'INT'                 ,   1, true, true, current_timestamp()),
  ( 212, 'ExternalAccount_Group'                     , 'ExternalAccountGroupKey'                   , 'external_account_group_key'                , 'INT'                 ,   2, true, true, current_timestamp()),
  ( 213, 'ExternalAccount_Group'                     , 'ExternalCompanyName'                       , 'external_company_name'                     , 'STRING'              ,   3, true, true, current_timestamp()),
  ( 214, 'ExternalAccount_Group'                     , 'AccountType'                               , 'account_type'                              , 'STRING'              ,   4, true, true, current_timestamp()),
  ( 215, 'ExternalAccount_Group'                     , 'AccountNumber'                             , 'account_number'                            , 'STRING'              ,   5, true, true, current_timestamp()),
  ( 216, 'ExternalAccount_Group'                     , 'Status'                                    , 'status'                                    , 'STRING'              ,   6, true, true, current_timestamp()),
  ( 217, 'ExternalAccount_Group'                     , 'Active'                                    , 'is_active'                                 , 'BOOLEAN'             ,   7, true, true, current_timestamp()),
  ( 218, 'ExternalAccount_Group'                     , 'StartDate'                                 , 'start_timestamp'                           , 'TIMESTAMP'           ,   8, true, true, current_timestamp()),
  ( 219, 'ExternalAccount_Group'                     , 'EndDate'                                   , 'end_timestamp'                             , 'TIMESTAMP'           ,   9, true, true, current_timestamp()),
  ( 220, 'ExternalAccount_Group'                     , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,  10, false, true, current_timestamp()),
  ( 221, 'ExternalAccount_Group'                     , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,  11, false, true, current_timestamp()),
  ( 222, 'ExternalAccount_Group'                     , 'N/A'                                       , 'source_system'                             , 'STRING'              ,  12, false, true, current_timestamp()),
  ( 223, 'ExternalAccount_Group'                     , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  13, false, true, current_timestamp()),
  ( 224, 'ExternalAccount_Group'                     , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  14, false, true, current_timestamp());

-- [19] ContractValue_Group (13 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 225, 'ContractValue_Group'                       , 'ContractValueGroupPK'                      , 'contract_value_group_id'                   , 'INT'                 ,   1, true, true, current_timestamp()),
  ( 226, 'ContractValue_Group'                       , 'ContractValueGroupKey'                     , 'contract_value_group_key'                  , 'INT'                 ,   2, true, true, current_timestamp()),
  ( 227, 'ContractValue_Group'                       , 'ValueType'                                 , 'value_type'                                , 'STRING'              ,   3, true, true, current_timestamp()),
  ( 228, 'ContractValue_Group'                       , 'ValueDate'                                 , 'value_timestamp'                           , 'TIMESTAMP'           ,   4, true, true, current_timestamp()),
  ( 229, 'ContractValue_Group'                       , 'Value'                                     , 'value'                                     , 'DECIMAL(18,4)'       ,   5, true, true, current_timestamp()),
  ( 230, 'ContractValue_Group'                       , 'ValueAsDate'                               , 'value_as_timestamp'                        , 'TIMESTAMP'           ,   6, true, true, current_timestamp()),
  ( 231, 'ContractValue_Group'                       , 'StartDate'                                 , 'start_timestamp'                           , 'TIMESTAMP'           ,   7, true, true, current_timestamp()),
  ( 232, 'ContractValue_Group'                       , 'EndDate'                                   , 'end_timestamp'                             , 'TIMESTAMP'           ,   8, true, true, current_timestamp()),
  ( 233, 'ContractValue_Group'                       , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,   9, false, true, current_timestamp()),
  ( 234, 'ContractValue_Group'                       , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,  10, false, true, current_timestamp()),
  ( 235, 'ContractValue_Group'                       , 'N/A'                                       , 'source_system'                             , 'STRING'              ,  11, false, true, current_timestamp()),
  ( 236, 'ContractValue_Group'                       , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  12, false, true, current_timestamp()),
  ( 237, 'ContractValue_Group'                       , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  13, false, true, current_timestamp());

-- [20] ContractDeposit_Group (22 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 238, 'ContractDeposit_Group'                     , 'ContractDepositGroupPK'                    , 'contract_deposit_group_id'                 , 'INT'                 ,   1, true, true, current_timestamp()),
  ( 239, 'ContractDeposit_Group'                     , 'SourceKey'                                 , 'source_key'                                , 'BIGINT'              ,   2, true, true, current_timestamp()),
  ( 240, 'ContractDeposit_Group'                     , 'ContractDepositGroupKey'                   , 'contract_deposit_group_key'                , 'INT'                 ,   3, true, true, current_timestamp()),
  ( 241, 'ContractDeposit_Group'                     , 'DepositType'                               , 'deposit_type'                              , 'STRING'              ,   4, true, true, current_timestamp()),
  ( 242, 'ContractDeposit_Group'                     , 'DepositSource'                             , 'deposit_source'                            , 'STRING'              ,   5, true, true, current_timestamp()),
  ( 243, 'ContractDeposit_Group'                     , 'OriginalContract'                          , 'original_contract'                         , 'STRING'              ,   6, true, true, current_timestamp()),
  ( 244, 'ContractDeposit_Group'                     , 'DateReceived'                              , 'date_received_timestamp'                   , 'TIMESTAMP'           ,   7, true, true, current_timestamp()),
  ( 245, 'ContractDeposit_Group'                     , 'ProcessDate'                               , 'process_timestamp'                         , 'TIMESTAMP'           ,   8, true, true, current_timestamp()),
  ( 246, 'ContractDeposit_Group'                     , 'TaxYear'                                   , 'tax_year'                                  , 'INT'                 ,   9, true, true, current_timestamp()),
  ( 247, 'ContractDeposit_Group'                     , 'ReplacementType'                           , 'replacement_type'                          , 'STRING'              ,  10, true, true, current_timestamp()),
  ( 248, 'ContractDeposit_Group'                     , 'PremiumType'                               , 'premium_type'                              , 'STRING'              ,  11, true, true, current_timestamp()),
  ( 249, 'ContractDeposit_Group'                     , 'PlannedIndicator'                          , 'planned_indicator'                         , 'STRING'              ,  12, true, true, current_timestamp()),
  ( 250, 'ContractDeposit_Group'                     , 'Reference'                                 , 'reference'                                 , 'STRING'              ,  13, true, true, current_timestamp()),
  ( 251, 'ContractDeposit_Group'                     , 'AnticipatedAmount'                         , 'anticipated_amount'                        , 'DECIMAL(18,4)'       ,  14, true, true, current_timestamp()),
  ( 252, 'ContractDeposit_Group'                     , 'ActualAmount'                              , 'actual_amount'                             , 'DECIMAL(18,4)'       ,  15, true, true, current_timestamp()),
  ( 253, 'ContractDeposit_Group'                     , 'CostBasis'                                 , 'cost_basis'                                , 'DECIMAL(18,4)'       ,  16, true, true, current_timestamp()),
  ( 254, 'ContractDeposit_Group'                     , 'RefundAmount'                              , 'refund_amount'                             , 'DECIMAL(18,4)'       ,  17, true, true, current_timestamp()),
  ( 255, 'ContractDeposit_Group'                     , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,  18, false, true, current_timestamp()),
  ( 256, 'ContractDeposit_Group'                     , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,  19, false, true, current_timestamp()),
  ( 257, 'ContractDeposit_Group'                     , 'N/A'                                       , 'source_system'                             , 'STRING'              ,  20, false, true, current_timestamp()),
  ( 258, 'ContractDeposit_Group'                     , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  21, false, true, current_timestamp()),
  ( 259, 'ContractDeposit_Group'                     , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  22, false, true, current_timestamp());

-- [21] AgentSummary_Group (10 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 260, 'AgentSummary_Group'                        , 'AgentSummaryGroupPK'                       , 'agent_summary_group_id'                    , 'INT'                 ,   1, true, true, current_timestamp()),
  ( 261, 'AgentSummary_Group'                        , 'AgentSummaryGroupKey'                      , 'agent_summary_group_key'                   , 'INT'                 ,   2, true, true, current_timestamp()),
  ( 262, 'AgentSummary_Group'                        , 'SummaryType'                               , 'summary_type'                              , 'STRING'              ,   3, true, true, current_timestamp()),
  ( 263, 'AgentSummary_Group'                        , 'SummaryDate'                               , 'summary_timestamp'                         , 'TIMESTAMP'           ,   4, true, true, current_timestamp()),
  ( 264, 'AgentSummary_Group'                        , 'SummaryValue'                              , 'summary_value'                             , 'DECIMAL(18,4)'       ,   5, true, true, current_timestamp()),
  ( 265, 'AgentSummary_Group'                        , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,   6, false, true, current_timestamp()),
  ( 266, 'AgentSummary_Group'                        , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,   7, false, true, current_timestamp()),
  ( 267, 'AgentSummary_Group'                        , 'N/A'                                       , 'source_system'                             , 'STRING'              ,   8, false, true, current_timestamp()),
  ( 268, 'AgentSummary_Group'                        , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,   9, false, true, current_timestamp()),
  ( 269, 'AgentSummary_Group'                        , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  10, false, true, current_timestamp());

-- [22] AgentPrincipal_Group (10 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 270, 'AgentPrincipal_Group'                      , 'AgentPrincipalGroupPK'                     , 'agent_principal_group_id'                  , 'INT'                 ,   1, true, true, current_timestamp()),
  ( 271, 'AgentPrincipal_Group'                      , 'AgentPrincipalGroupKey'                    , 'agent_principal_group_key'                 , 'INT'                 ,   2, true, true, current_timestamp()),
  ( 272, 'AgentPrincipal_Group'                      , 'PrincipalAgentFK'                          , 'principal_agent_id'                        , 'INT'                 ,   3, true, true, current_timestamp()),
  ( 273, 'AgentPrincipal_Group'                      , 'StartDate'                                 , 'start_timestamp'                           , 'TIMESTAMP'           ,   4, true, true, current_timestamp()),
  ( 274, 'AgentPrincipal_Group'                      , 'EndDate'                                   , 'end_timestamp'                             , 'TIMESTAMP'           ,   5, true, true, current_timestamp()),
  ( 275, 'AgentPrincipal_Group'                      , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,   6, false, true, current_timestamp()),
  ( 276, 'AgentPrincipal_Group'                      , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,   7, false, true, current_timestamp()),
  ( 277, 'AgentPrincipal_Group'                      , 'N/A'                                       , 'source_system'                             , 'STRING'              ,   8, false, true, current_timestamp()),
  ( 278, 'AgentPrincipal_Group'                      , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,   9, false, true, current_timestamp()),
  ( 279, 'AgentPrincipal_Group'                      , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  10, false, true, current_timestamp());

-- [23] AgentLicense_Group (16 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 280, 'AgentLicense_Group'                        , 'AgentLicenseGroupPK'                       , 'agent_license_group_id'                    , 'INT'                 ,   1, true, true, current_timestamp()),
  ( 281, 'AgentLicense_Group'                        , 'SourceKey'                                 , 'source_key'                                , 'BIGINT'              ,   2, true, true, current_timestamp()),
  ( 282, 'AgentLicense_Group'                        , 'AgentLicenseGroupKey'                      , 'agent_license_group_key'                   , 'INT'                 ,   3, true, true, current_timestamp()),
  ( 283, 'AgentLicense_Group'                        , 'LicenseType'                               , 'license_type'                              , 'STRING'              ,   4, true, true, current_timestamp()),
  ( 284, 'AgentLicense_Group'                        , 'LicenseState'                              , 'license_state'                             , 'STRING'              ,   5, true, true, current_timestamp()),
  ( 285, 'AgentLicense_Group'                        , 'Resident'                                  , 'resident'                                  , 'STRING'              ,   6, true, true, current_timestamp()),
  ( 286, 'AgentLicense_Group'                        , 'LicenseNumber'                             , 'license_number'                            , 'STRING'              ,   7, true, true, current_timestamp()),
  ( 287, 'AgentLicense_Group'                        , 'Status'                                    , 'status'                                    , 'STRING'              ,   8, true, true, current_timestamp()),
  ( 288, 'AgentLicense_Group'                        , 'EffectiveDate'                             , 'effective_timestamp'                       , 'TIMESTAMP'           ,   9, true, true, current_timestamp()),
  ( 289, 'AgentLicense_Group'                        , 'ExpirationDate'                            , 'expiration_timestamp'                      , 'TIMESTAMP'           ,  10, true, true, current_timestamp()),
  ( 290, 'AgentLicense_Group'                        , 'TerminationDate'                           , 'termination_timestamp'                     , 'TIMESTAMP'           ,  11, true, true, current_timestamp()),
  ( 291, 'AgentLicense_Group'                        , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,  12, false, true, current_timestamp()),
  ( 292, 'AgentLicense_Group'                        , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,  13, false, true, current_timestamp()),
  ( 293, 'AgentLicense_Group'                        , 'N/A'                                       , 'source_system'                             , 'STRING'              ,  14, false, true, current_timestamp()),
  ( 294, 'AgentLicense_Group'                        , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  15, false, true, current_timestamp()),
  ( 295, 'AgentLicense_Group'                        , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  16, false, true, current_timestamp());

-- [24] AdditionalInfo_Group (19 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 296, 'AdditionalInfo_Group'                      , 'AdditionalInfoGroupPK'                     , 'additional_info_group_id'                  , 'INT'                 ,   1, true, true, current_timestamp()),
  ( 297, 'AdditionalInfo_Group'                      , 'AdditionalInfoGroupKey'                    , 'additional_info_group_key'                 , 'INT'                 ,   2, true, true, current_timestamp()),
  ( 298, 'AdditionalInfo_Group'                      , 'AdditionalInfoSource'                      , 'additional_info_source'                    , 'STRING'              ,   3, true, true, current_timestamp()),
  ( 299, 'AdditionalInfo_Group'                      , 'AdditionalInfoType'                        , 'additional_info_type'                      , 'STRING'              ,   4, true, true, current_timestamp()),
  ( 300, 'AdditionalInfo_Group'                      , 'AdditionalInfoDescription'                 , 'additional_info_description'               , 'STRING'              ,   5, true, true, current_timestamp()),
  ( 301, 'AdditionalInfo_Group'                      , 'AdditionalInfoValue'                       , 'additional_info_value'                     , 'STRING'              ,   6, true, true, current_timestamp()),
  ( 302, 'AdditionalInfo_Group'                      , 'AddressLine1'                              , 'address_line_1'                            , 'STRING'              ,   7, true, true, current_timestamp()),
  ( 303, 'AdditionalInfo_Group'                      , 'AddressLine2'                              , 'address_line_2'                            , 'STRING'              ,   8, true, true, current_timestamp()),
  ( 304, 'AdditionalInfo_Group'                      , 'AddressLine3'                              , 'address_line_3'                            , 'STRING'              ,   9, true, true, current_timestamp()),
  ( 305, 'AdditionalInfo_Group'                      , 'AddressLine4'                              , 'address_line_4'                            , 'STRING'              ,  10, true, true, current_timestamp()),
  ( 306, 'AdditionalInfo_Group'                      , 'City'                                      , 'city'                                      , 'STRING'              ,  11, true, true, current_timestamp()),
  ( 307, 'AdditionalInfo_Group'                      , 'State'                                     , 'state'                                     , 'STRING'              ,  12, true, true, current_timestamp()),
  ( 308, 'AdditionalInfo_Group'                      , 'ZipCode'                                   , 'zip_code'                                  , 'STRING'              ,  13, true, true, current_timestamp()),
  ( 309, 'AdditionalInfo_Group'                      , 'EffectiveDate'                             , 'effective_timestamp'                       , 'TIMESTAMP'           ,  14, true, true, current_timestamp()),
  ( 310, 'AdditionalInfo_Group'                      , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,  15, false, true, current_timestamp()),
  ( 311, 'AdditionalInfo_Group'                      , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,  16, false, true, current_timestamp()),
  ( 312, 'AdditionalInfo_Group'                      , 'N/A'                                       , 'source_system'                             , 'STRING'              ,  17, false, true, current_timestamp()),
  ( 313, 'AdditionalInfo_Group'                      , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  18, false, true, current_timestamp()),
  ( 314, 'AdditionalInfo_Group'                      , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  19, false, true, current_timestamp());

-- [25] AdditionalClient_Group (12 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 315, 'AdditionalClient_Group'                    , 'AdditionalClientGroupPK'                   , 'additional_client_group_id'                , 'INT'                 ,   1, true, true, current_timestamp()),
  ( 316, 'AdditionalClient_Group'                    , 'AdditionalClientGroupKey'                  , 'additional_client_group_key'               , 'INT'                 ,   2, true, true, current_timestamp()),
  ( 317, 'AdditionalClient_Group'                    , 'ClientFK'                                  , 'client_id'                                 , 'INT'                 ,   3, true, true, current_timestamp()),
  ( 318, 'AdditionalClient_Group'                    , 'AdditionalType'                            , 'additional_type'                           , 'STRING'              ,   4, true, true, current_timestamp()),
  ( 319, 'AdditionalClient_Group'                    , 'Relation'                                  , 'relation'                                  , 'STRING'              ,   5, true, true, current_timestamp()),
  ( 320, 'AdditionalClient_Group'                    , 'AllocationPercent'                         , 'allocation_percent'                        , 'DECIMAL(18,4)'       ,   6, true, true, current_timestamp()),
  ( 321, 'AdditionalClient_Group'                    , 'Active'                                    , 'is_active'                                 , 'BOOLEAN'             ,   7, true, true, current_timestamp()),
  ( 322, 'AdditionalClient_Group'                    , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,   8, false, true, current_timestamp()),
  ( 323, 'AdditionalClient_Group'                    , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,   9, false, true, current_timestamp()),
  ( 324, 'AdditionalClient_Group'                    , 'N/A'                                       , 'source_system'                             , 'STRING'              ,  10, false, true, current_timestamp()),
  ( 325, 'AdditionalClient_Group'                    , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  11, false, true, current_timestamp()),
  ( 326, 'AdditionalClient_Group'                    , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  12, false, true, current_timestamp());

-- [26] AccountingReporting_Group (10 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 327, 'AccountingReporting_Group'                 , 'AccountingReportingGroupPK'                , 'accounting_reporting_group_id'             , 'INT'                 ,   1, true, true, current_timestamp()),
  ( 328, 'AccountingReporting_Group'                 , 'AccountingReportingGroupKey'               , 'accounting_reporting_group_key'            , 'INT'                 ,   2, true, true, current_timestamp()),
  ( 329, 'AccountingReporting_Group'                 , 'ReportingCode'                             , 'reporting_code'                            , 'STRING'              ,   3, true, true, current_timestamp()),
  ( 330, 'AccountingReporting_Group'                 , 'ReportingClassCode'                        , 'reporting_class_code'                      , 'STRING'              ,   4, true, true, current_timestamp()),
  ( 331, 'AccountingReporting_Group'                 , 'ReportingDescription'                      , 'reporting_description'                     , 'STRING'              ,   5, true, true, current_timestamp()),
  ( 332, 'AccountingReporting_Group'                 , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,   6, false, true, current_timestamp()),
  ( 333, 'AccountingReporting_Group'                 , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,   7, false, true, current_timestamp()),
  ( 334, 'AccountingReporting_Group'                 , 'N/A'                                       , 'source_system'                             , 'STRING'              ,   8, false, true, current_timestamp()),
  ( 335, 'AccountingReporting_Group'                 , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,   9, false, true, current_timestamp()),
  ( 336, 'AccountingReporting_Group'                 , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  10, false, true, current_timestamp());

-- [27] ProductVariationDetail (9 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 337, 'ProductVariationDetail'                    , 'ProductVariationDetailPK'                  , 'product_variation_detail_id'               , 'INT'                 ,   1, true, true, current_timestamp()),
  ( 338, 'ProductVariationDetail'                    , 'DisclosureText'                            , 'disclosure_text'                           , 'STRING'              ,   2, true, true, current_timestamp()),
  ( 339, 'ProductVariationDetail'                    , 'SortOrder'                                 , 'sort_order'                                , 'INT'                 ,   3, true, true, current_timestamp()),
  ( 340, 'ProductVariationDetail'                    , 'Type'                                      , 'type'                                      , 'STRING'              ,   4, true, true, current_timestamp()),
  ( 341, 'ProductVariationDetail'                    , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,   5, false, true, current_timestamp()),
  ( 342, 'ProductVariationDetail'                    , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,   6, false, true, current_timestamp()),
  ( 343, 'ProductVariationDetail'                    , 'N/A'                                       , 'source_system'                             , 'STRING'              ,   7, false, true, current_timestamp()),
  ( 344, 'ProductVariationDetail'                    , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,   8, false, true, current_timestamp()),
  ( 345, 'ProductVariationDetail'                    , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,   9, false, true, current_timestamp());

-- [28] ProductStateVariation (9 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 346, 'ProductStateVariation'                     , 'ProductStateVariationPK'                   , 'product_state_variation_id'                , 'INT'                 ,   1, true, true, current_timestamp()),
  ( 347, 'ProductStateVariation'                     , 'ProductFK'                                 , 'product_id'                                , 'INT'                 ,   2, true, true, current_timestamp()),
  ( 348, 'ProductStateVariation'                     , 'StateCode'                                 , 'state_code'                                , 'STRING'              ,   3, true, true, current_timestamp()),
  ( 349, 'ProductStateVariation'                     , 'ProductVariationDetailFK'                  , 'product_variation_detail_id'               , 'INT'                 ,   4, true, true, current_timestamp()),
  ( 350, 'ProductStateVariation'                     , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,   5, false, true, current_timestamp()),
  ( 351, 'ProductStateVariation'                     , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,   6, false, true, current_timestamp()),
  ( 352, 'ProductStateVariation'                     , 'N/A'                                       , 'source_system'                             , 'STRING'              ,   7, false, true, current_timestamp()),
  ( 353, 'ProductStateVariation'                     , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,   8, false, true, current_timestamp()),
  ( 354, 'ProductStateVariation'                     , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,   9, false, true, current_timestamp());

-- [29] ProductStateApprovalDisclosure (10 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 355, 'ProductStateApprovalDisclosure'            , 'PSADisclosurePK'                           , 'product_state_approval_disclosure_id'      , 'INT'                 ,   1, true, true, current_timestamp()),
  ( 356, 'ProductStateApprovalDisclosure'            , 'ProductStateApprovalFK'                    , 'product_state_approval_id'                 , 'INT'                 ,   2, true, true, current_timestamp()),
  ( 357, 'ProductStateApprovalDisclosure'            , 'MarketingNameOverride'                     , 'marketing_name_override'                   , 'STRING'              ,   3, true, true, current_timestamp()),
  ( 358, 'ProductStateApprovalDisclosure'            , 'DisclosureText'                            , 'disclosure_text'                           , 'STRING'              ,   4, true, true, current_timestamp()),
  ( 359, 'ProductStateApprovalDisclosure'            , 'SortOrder'                                 , 'sort_order'                                , 'INT'                 ,   5, true, true, current_timestamp()),
  ( 360, 'ProductStateApprovalDisclosure'            , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,   6, false, true, current_timestamp()),
  ( 361, 'ProductStateApprovalDisclosure'            , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,   7, false, true, current_timestamp()),
  ( 362, 'ProductStateApprovalDisclosure'            , 'N/A'                                       , 'source_system'                             , 'STRING'              ,   8, false, true, current_timestamp()),
  ( 363, 'ProductStateApprovalDisclosure'            , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,   9, false, true, current_timestamp()),
  ( 364, 'ProductStateApprovalDisclosure'            , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  10, false, true, current_timestamp());

-- [30] ProductStateApproval (11 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 365, 'ProductStateApproval'                      , 'ProductStateApprovalPK'                    , 'product_state_approval_id'                 , 'INT'                 ,   1, true, true, current_timestamp()),
  ( 366, 'ProductStateApproval'                      , 'ProductFK'                                 , 'product_id'                                , 'INT'                 ,   2, true, true, current_timestamp()),
  ( 367, 'ProductStateApproval'                      , 'StateCode'                                 , 'state_code'                                , 'STRING'              ,   3, true, true, current_timestamp()),
  ( 368, 'ProductStateApproval'                      , 'ApprovedInd'                               , 'is_approved'                               , 'BOOLEAN'             ,   4, true, true, current_timestamp()),
  ( 369, 'ProductStateApproval'                      , 'StartDate'                                 , 'start_timestamp'                           , 'TIMESTAMP'           ,   5, true, true, current_timestamp()),
  ( 370, 'ProductStateApproval'                      , 'EndDate'                                   , 'end_timestamp'                             , 'TIMESTAMP'           ,   6, true, true, current_timestamp()),
  ( 371, 'ProductStateApproval'                      , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,   7, false, true, current_timestamp()),
  ( 372, 'ProductStateApproval'                      , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,   8, false, true, current_timestamp()),
  ( 373, 'ProductStateApproval'                      , 'N/A'                                       , 'source_system'                             , 'STRING'              ,   9, false, true, current_timestamp()),
  ( 374, 'ProductStateApproval'                      , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  10, false, true, current_timestamp()),
  ( 375, 'ProductStateApproval'                      , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  11, false, true, current_timestamp());

-- [31] hedge.Ratios (12 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 376, 'hedge.Ratios'                              , 'RatiosPK'                                  , 'ratios_id'                                 , 'INT'                 ,   1, true, true, current_timestamp()),
  ( 377, 'hedge.Ratios'                              , 'ContractFK'                                , 'contract_id'                               , 'INT'                 ,   2, true, true, current_timestamp()),
  ( 378, 'hedge.Ratios'                              , 'ValueDate'                                 , 'value_timestamp'                           , 'TIMESTAMP'           ,   3, true, true, current_timestamp()),
  ( 379, 'hedge.Ratios'                              , 'BaseHedgeRatio'                            , 'base_hedge_ratio'                          , 'DECIMAL(18,4)'       ,   4, true, true, current_timestamp()),
  ( 380, 'hedge.Ratios'                              , 'BaseSurvivalRatio'                         , 'base_survival_ratio'                       , 'DECIMAL(18,4)'       ,   5, true, true, current_timestamp()),
  ( 381, 'hedge.Ratios'                              , 'StartDate'                                 , 'start_timestamp'                           , 'TIMESTAMP'           ,   6, true, true, current_timestamp()),
  ( 382, 'hedge.Ratios'                              , 'EndDate'                                   , 'end_timestamp'                             , 'TIMESTAMP'           ,   7, true, true, current_timestamp()),
  ( 383, 'hedge.Ratios'                              , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,   8, false, true, current_timestamp()),
  ( 384, 'hedge.Ratios'                              , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,   9, false, true, current_timestamp()),
  ( 385, 'hedge.Ratios'                              , 'N/A'                                       , 'source_system'                             , 'STRING'              ,  10, false, true, current_timestamp()),
  ( 386, 'hedge.Ratios'                              , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  11, false, true, current_timestamp()),
  ( 387, 'hedge.Ratios'                              , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  12, false, true, current_timestamp());

-- [32] hedge.Options (26 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 388, 'hedge.Options'                             , 'OptionsPK'                                 , 'options_id'                                , 'INT'                 ,   1, true, true, current_timestamp()),
  ( 389, 'hedge.Options'                             , 'ContractFK'                                , 'contract_id'                               , 'INT'                 ,   2, true, true, current_timestamp()),
  ( 390, 'hedge.Options'                             , 'InvestmentFK'                              , 'investment_id'                             , 'INT'                 ,   3, true, true, current_timestamp()),
  ( 391, 'hedge.Options'                             , 'RenewalDate'                               , 'renewal_timestamp'                         , 'TIMESTAMP'           ,   4, true, true, current_timestamp()),
  ( 392, 'hedge.Options'                             , 'IndexValue'                                , 'index_value'                               , 'DECIMAL(18,4)'       ,   5, true, true, current_timestamp()),
  ( 393, 'hedge.Options'                             , 'HedgingPercentage'                         , 'hedging_percentage'                        , 'DECIMAL(18,4)'       ,   6, true, true, current_timestamp()),
  ( 394, 'hedge.Options'                             , 'HedgeID1'                                  , 'hedge_id_1'                                , 'STRING'              ,   7, true, true, current_timestamp()),
  ( 395, 'hedge.Options'                             , 'HedgeID2'                                  , 'hedge_id_2'                                , 'STRING'              ,   8, true, true, current_timestamp()),
  ( 396, 'hedge.Options'                             , 'HedgeRenewalDate'                          , 'hedge_renewal_timestamp'                   , 'TIMESTAMP'           ,   9, true, true, current_timestamp()),
  ( 397, 'hedge.Options'                             , 'ValueDate'                                 , 'value_timestamp'                           , 'TIMESTAMP'           ,  10, true, true, current_timestamp()),
  ( 398, 'hedge.Options'                             , 'SeriatimHedgeRatio'                        , 'seriatim_hedge_ratio'                      , 'DECIMAL(18,4)'       ,  11, true, true, current_timestamp()),
  ( 399, 'hedge.Options'                             , 'PresentValue'                              , 'present_value'                             , 'DECIMAL(18,4)'       ,  12, true, true, current_timestamp()),
  ( 400, 'hedge.Options'                             , 'Delta'                                     , 'delta'                                     , 'DECIMAL(18,4)'       ,  13, true, true, current_timestamp()),
  ( 401, 'hedge.Options'                             , 'Gamma'                                     , 'gamma'                                     , 'DECIMAL(18,4)'       ,  14, true, true, current_timestamp()),
  ( 402, 'hedge.Options'                             , 'Vega'                                      , 'vega'                                      , 'DECIMAL(18,4)'       ,  15, true, true, current_timestamp()),
  ( 403, 'hedge.Options'                             , 'Rho'                                       , 'rho'                                       , 'DECIMAL(18,4)'       ,  16, true, true, current_timestamp()),
  ( 404, 'hedge.Options'                             , 'Theta'                                     , 'theta'                                     , 'DECIMAL(18,4)'       ,  17, true, true, current_timestamp()),
  ( 405, 'hedge.Options'                             , 'NeedsHedged'                               , 'needs_hedged'                              , 'BOOLEAN'             ,  18, true, true, current_timestamp()),
  ( 406, 'hedge.Options'                             , 'IsHedged'                                  , 'is_hedged'                                 , 'BOOLEAN'             ,  19, true, true, current_timestamp()),
  ( 407, 'hedge.Options'                             , 'StartDate'                                 , 'start_timestamp'                           , 'TIMESTAMP'           ,  20, true, true, current_timestamp()),
  ( 408, 'hedge.Options'                             , 'EndDate'                                   , 'end_timestamp'                             , 'TIMESTAMP'           ,  21, true, true, current_timestamp()),
  ( 409, 'hedge.Options'                             , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,  22, false, true, current_timestamp()),
  ( 410, 'hedge.Options'                             , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,  23, false, true, current_timestamp()),
  ( 411, 'hedge.Options'                             , 'N/A'                                       , 'source_system'                             , 'STRING'              ,  24, false, true, current_timestamp()),
  ( 412, 'hedge.Options'                             , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  25, false, true, current_timestamp()),
  ( 413, 'hedge.Options'                             , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  26, false, true, current_timestamp());

-- [33] State (8 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 414, 'State'                                     , 'StateCode'                                 , 'state_code'                                , 'STRING'              ,   1, true, true, current_timestamp()),
  ( 415, 'State'                                     , 'StateName'                                 , 'state_name'                                , 'STRING'              ,   2, true, true, current_timestamp()),
  ( 416, 'State'                                     , 'DisplayOrder'                              , 'display_order'                             , 'INT'                 ,   3, true, true, current_timestamp()),
  ( 417, 'State'                                     , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,   4, false, true, current_timestamp()),
  ( 418, 'State'                                     , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,   5, false, true, current_timestamp()),
  ( 419, 'State'                                     , 'N/A'                                       , 'source_system'                             , 'STRING'              ,   6, false, true, current_timestamp()),
  ( 420, 'State'                                     , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,   7, false, true, current_timestamp()),
  ( 421, 'State'                                     , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,   8, false, true, current_timestamp());

-- [34] Date (37 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 422, 'Date'                                      , 'DatePK'                                    , 'date_id'                                   , 'INT'                 ,   1, true, true, current_timestamp()),
  ( 423, 'Date'                                      , 'Date'                                      , 'calendar_timestamp'                        , 'TIMESTAMP'           ,   2, true, true, current_timestamp()),
  ( 424, 'Date'                                      , 'DateDisplay'                               , 'date_display'                              , 'STRING'              ,   3, true, true, current_timestamp()),
  ( 425, 'Date'                                      , 'DayOfMonth'                                , 'day_of_month'                              , 'STRING'              ,   4, true, true, current_timestamp()),
  ( 426, 'Date'                                      , 'DaySuffix'                                 , 'day_suffix'                                , 'STRING'              ,   5, true, true, current_timestamp()),
  ( 427, 'Date'                                      , 'DayName'                                   , 'day_name'                                  , 'STRING'              ,   6, true, true, current_timestamp()),
  ( 428, 'Date'                                      , 'DayOfWeek'                                 , 'day_of_week'                               , 'STRING'              ,   7, true, true, current_timestamp()),
  ( 429, 'Date'                                      , 'DayOfWeekInMonth'                          , 'day_of_week_in_month'                      , 'STRING'              ,   8, true, true, current_timestamp()),
  ( 430, 'Date'                                      , 'DayOfWeekInYear'                           , 'day_of_week_in_year'                       , 'STRING'              ,   9, true, true, current_timestamp()),
  ( 431, 'Date'                                      , 'DayOfYear'                                 , 'day_of_year'                               , 'STRING'              ,  10, true, true, current_timestamp()),
  ( 432, 'Date'                                      , 'WeekOfMonth'                               , 'week_of_month'                             , 'STRING'              ,  11, true, true, current_timestamp()),
  ( 433, 'Date'                                      , 'WeekOfQuarter'                             , 'week_of_quarter'                           , 'STRING'              ,  12, true, true, current_timestamp()),
  ( 434, 'Date'                                      , 'WeekOfYear'                                , 'week_of_year'                              , 'STRING'              ,  13, true, true, current_timestamp()),
  ( 435, 'Date'                                      , 'Month'                                     , 'month'                                     , 'STRING'              ,  14, true, true, current_timestamp()),
  ( 436, 'Date'                                      , 'MonthName'                                 , 'month_name'                                , 'STRING'              ,  15, true, true, current_timestamp()),
  ( 437, 'Date'                                      , 'MonthOfQuarter'                            , 'month_of_quarter'                          , 'STRING'              ,  16, true, true, current_timestamp()),
  ( 438, 'Date'                                      , 'Quarter'                                   , 'quarter'                                   , 'STRING'              ,  17, true, true, current_timestamp()),
  ( 439, 'Date'                                      , 'QuarterName'                               , 'quarter_name'                              , 'STRING'              ,  18, true, true, current_timestamp()),
  ( 440, 'Date'                                      , 'Year'                                      , 'year'                                      , 'STRING'              ,  19, true, true, current_timestamp()),
  ( 441, 'Date'                                      , 'YearName'                                  , 'year_name'                                 , 'STRING'              ,  20, true, true, current_timestamp()),
  ( 442, 'Date'                                      , 'MonthYear'                                 , 'month_year'                                , 'STRING'              ,  21, true, true, current_timestamp()),
  ( 443, 'Date'                                      , 'MMYYYY'                                    , 'mmyyyy'                                    , 'STRING'              ,  22, true, true, current_timestamp()),
  ( 444, 'Date'                                      , 'FirstDayOfMonth'                           , 'first_day_of_month'                        , 'DATE'                ,  23, true, true, current_timestamp()),
  ( 445, 'Date'                                      , 'LastDayOfMonth'                            , 'last_day_of_month'                         , 'DATE'                ,  24, true, true, current_timestamp()),
  ( 446, 'Date'                                      , 'FirstDayOfQuarter'                         , 'first_day_of_quarter'                      , 'DATE'                ,  25, true, true, current_timestamp()),
  ( 447, 'Date'                                      , 'LastDayOfQuarter'                          , 'last_day_of_quarter'                       , 'DATE'                ,  26, true, true, current_timestamp()),
  ( 448, 'Date'                                      , 'FirstDayOfYear'                            , 'first_day_of_year'                         , 'DATE'                ,  27, true, true, current_timestamp()),
  ( 449, 'Date'                                      , 'LastDayOfYear'                             , 'last_day_of_year'                          , 'DATE'                ,  28, true, true, current_timestamp()),
  ( 450, 'Date'                                      , 'IsWeekday'                                 , 'is_weekday'                                , 'BOOLEAN'             ,  29, true, true, current_timestamp()),
  ( 451, 'Date'                                      , 'IsHoliday'                                 , 'is_holiday'                                , 'BOOLEAN'             ,  30, true, true, current_timestamp()),
  ( 452, 'Date'                                      , 'HolidayName'                               , 'holiday_name'                              , 'STRING'              ,  31, true, true, current_timestamp()),
  ( 453, 'Date'                                      , 'IsLastDayOfMonth'                          , 'is_last_day_of_month'                      , 'BOOLEAN'             ,  32, true, true, current_timestamp()),
  ( 454, 'Date'                                      , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,  33, false, true, current_timestamp()),
  ( 455, 'Date'                                      , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,  34, false, true, current_timestamp()),
  ( 456, 'Date'                                      , 'N/A'                                       , 'source_system'                             , 'STRING'              ,  35, false, true, current_timestamp()),
  ( 457, 'Date'                                      , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  36, false, true, current_timestamp()),
  ( 458, 'Date'                                      , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  37, false, true, current_timestamp());

-- [35] TrainingCourse (11 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 459, 'TrainingCourse'                            , 'TrainingCoursePK'                          , 'training_course_id'                        , 'INT'                 ,   1, true, true, current_timestamp()),
  ( 460, 'TrainingCourse'                            , 'CourseName'                                , 'course_name'                               , 'STRING'              ,   2, true, true, current_timestamp()),
  ( 461, 'TrainingCourse'                            , 'Context'                                   , 'context'                                   , 'STRING'              ,   3, true, true, current_timestamp()),
  ( 462, 'TrainingCourse'                            , 'TrainingProductGroupKey'                   , 'training_product_group_key'                , 'INT'                 ,   4, true, true, current_timestamp()),
  ( 463, 'TrainingCourse'                            , 'TrainingStateGroupKey'                     , 'training_state_group_key'                  , 'INT'                 ,   5, true, true, current_timestamp()),
  ( 464, 'TrainingCourse'                            , 'Description'                               , 'description'                               , 'STRING'              ,   6, true, true, current_timestamp()),
  ( 465, 'TrainingCourse'                            , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,   7, false, true, current_timestamp()),
  ( 466, 'TrainingCourse'                            , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,   8, false, true, current_timestamp()),
  ( 467, 'TrainingCourse'                            , 'N/A'                                       , 'source_system'                             , 'STRING'              ,   9, false, true, current_timestamp()),
  ( 468, 'TrainingCourse'                            , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  10, false, true, current_timestamp()),
  ( 469, 'TrainingCourse'                            , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  11, false, true, current_timestamp());

-- [36] AgentTraining (10 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 470, 'AgentTraining'                             , 'AgentTrainingPK'                           , 'agent_training_id'                         , 'INT'                 ,   1, true, true, current_timestamp()),
  ( 471, 'AgentTraining'                             , 'AgentFK'                                   , 'agent_id'                                  , 'INT'                 ,   2, true, true, current_timestamp()),
  ( 472, 'AgentTraining'                             , 'TrainingCourseFK'                          , 'training_course_id'                        , 'INT'                 ,   3, true, true, current_timestamp()),
  ( 473, 'AgentTraining'                             , 'CompletionDate'                            , 'completion_timestamp'                      , 'TIMESTAMP'           ,   4, true, true, current_timestamp()),
  ( 474, 'AgentTraining'                             , 'ExpirationDate'                            , 'expiration_timestamp'                      , 'TIMESTAMP'           ,   5, true, true, current_timestamp()),
  ( 475, 'AgentTraining'                             , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,   6, false, true, current_timestamp()),
  ( 476, 'AgentTraining'                             , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,   7, false, true, current_timestamp()),
  ( 477, 'AgentTraining'                             , 'N/A'                                       , 'source_system'                             , 'STRING'              ,   8, false, true, current_timestamp()),
  ( 478, 'AgentTraining'                             , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,   9, false, true, current_timestamp()),
  ( 479, 'AgentTraining'                             , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  10, false, true, current_timestamp());

-- [37] Company (17 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 480, 'Company'                                   , 'CompanyPK'                                 , 'company_id'                                , 'INT'                 ,   1, true, true, current_timestamp()),
  ( 481, 'Company'                                   , 'CompanyCode'                               , 'company_code'                              , 'STRING'              ,   2, true, true, current_timestamp()),
  ( 482, 'Company'                                   , 'AgentFK'                                   , 'agent_id'                                  , 'INT'                 ,   3, true, true, current_timestamp()),
  ( 483, 'Company'                                   , 'Name'                                      , 'name'                                      , 'STRING'              ,   4, true, true, current_timestamp()),
  ( 484, 'Company'                                   , 'DisplayName'                               , 'display_name'                              , 'STRING'              ,   5, true, true, current_timestamp()),
  ( 485, 'Company'                                   , 'AddressLine1'                              , 'address_line_1'                            , 'STRING'              ,   6, true, true, current_timestamp()),
  ( 486, 'Company'                                   , 'AddressLine2'                              , 'address_line_2'                            , 'STRING'              ,   7, true, true, current_timestamp()),
  ( 487, 'Company'                                   , 'City'                                      , 'city'                                      , 'STRING'              ,   8, true, true, current_timestamp()),
  ( 488, 'Company'                                   , 'State'                                     , 'state'                                     , 'STRING'              ,   9, true, true, current_timestamp()),
  ( 489, 'Company'                                   , 'ZipCode'                                   , 'zip_code'                                  , 'STRING'              ,  10, true, true, current_timestamp()),
  ( 490, 'Company'                                   , 'Phone'                                     , 'phone'                                     , 'STRING'              ,  11, true, true, current_timestamp()),
  ( 491, 'Company'                                   , 'Footer'                                    , 'footer'                                    , 'STRING'              ,  12, true, true, current_timestamp()),
  ( 492, 'Company'                                   , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,  13, false, true, current_timestamp()),
  ( 493, 'Company'                                   , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,  14, false, true, current_timestamp()),
  ( 494, 'Company'                                   , 'N/A'                                       , 'source_system'                             , 'STRING'              ,  15, false, true, current_timestamp()),
  ( 495, 'Company'                                   , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  16, false, true, current_timestamp()),
  ( 496, 'Company'                                   , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  17, false, true, current_timestamp());

-- [38] CAPStatusChange (12 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 497, 'CAPStatusChange'                           , 'CAPStatusChangePK'                         , 'cap_status_change_id'                      , 'INT'                 ,   1, true, true, current_timestamp()),
  ( 498, 'CAPStatusChange'                           , 'ContractFK'                                , 'contract_id'                               , 'INT'                 ,   2, true, true, current_timestamp()),
  ( 499, 'CAPStatusChange'                           , 'SourceCompanyFK'                           , 'source_company_id'                         , 'INT'                 ,   3, true, true, current_timestamp()),
  ( 500, 'CAPStatusChange'                           , 'StatusChangeDate'                          , 'status_change_date'                        , 'TIMESTAMP'           ,   4, true, true, current_timestamp()),
  ( 501, 'CAPStatusChange'                           , 'StatusChangeCode'                          , 'status_change_code'                        , 'STRING'              ,   5, true, true, current_timestamp()),
  ( 502, 'CAPStatusChange'                           , 'ProcessDate'                               , 'process_date'                              , 'TIMESTAMP'           ,   6, true, true, current_timestamp()),
  ( 503, 'CAPStatusChange'                           , 'RenewalPeriod'                             , 'renewal_period'                            , 'INT'                 ,   7, true, true, current_timestamp()),
  ( 504, 'CAPStatusChange'                           , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,   8, false, true, current_timestamp()),
  ( 505, 'CAPStatusChange'                           , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,   9, false, true, current_timestamp()),
  ( 506, 'CAPStatusChange'                           , 'N/A'                                       , 'source_system'                             , 'STRING'              ,  10, false, true, current_timestamp()),
  ( 507, 'CAPStatusChange'                           , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  11, false, true, current_timestamp()),
  ( 508, 'CAPStatusChange'                           , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  12, false, true, current_timestamp());

-- [39] CAPRepayment (16 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 509, 'CAPRepayment'                              , 'CAPRepaymentPK'                            , 'cap_repayment_id'                          , 'INT'                 ,   1, true, true, current_timestamp()),
  ( 510, 'CAPRepayment'                              , 'SourceKey'                                 , 'source_key'                                , 'BIGINT'              ,   2, true, true, current_timestamp()),
  ( 511, 'CAPRepayment'                              , 'SourceCompanyFK'                           , 'source_company_id'                         , 'INT'                 ,   3, true, true, current_timestamp()),
  ( 512, 'CAPRepayment'                              , 'PlanCode'                                  , 'plan_code'                                 , 'STRING'              ,   4, true, true, current_timestamp()),
  ( 513, 'CAPRepayment'                              , 'PlanCode2'                                 , 'plan_code_2'                               , 'STRING'              ,   5, true, true, current_timestamp()),
  ( 514, 'CAPRepayment'                              , 'OwnerResState'                             , 'owner_res_state'                           , 'STRING'              ,   6, true, true, current_timestamp()),
  ( 515, 'CAPRepayment'                              , 'OwnerCountry'                              , 'owner_country'                             , 'STRING'              ,   7, true, true, current_timestamp()),
  ( 516, 'CAPRepayment'                              , 'TerminationDate'                           , 'termination_date'                          , 'TIMESTAMP'           ,   8, true, true, current_timestamp()),
  ( 517, 'CAPRepayment'                              , 'FactorTrail'                               , 'factor_trail'                              , 'DECIMAL(18,4)'       ,   9, true, true, current_timestamp()),
  ( 518, 'CAPRepayment'                              , 'RenewalPeriod'                             , 'renewal_period'                            , 'INT'                 ,  10, true, true, current_timestamp()),
  ( 519, 'CAPRepayment'                              , 'CommissionableAmount'                      , 'commissionable_amount'                     , 'DECIMAL(18,4)'       ,  11, true, true, current_timestamp()),
  ( 520, 'CAPRepayment'                              , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,  12, false, true, current_timestamp()),
  ( 521, 'CAPRepayment'                              , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,  13, false, true, current_timestamp()),
  ( 522, 'CAPRepayment'                              , 'N/A'                                       , 'source_system'                             , 'STRING'              ,  14, false, true, current_timestamp()),
  ( 523, 'CAPRepayment'                              , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  15, false, true, current_timestamp()),
  ( 524, 'CAPRepayment'                              , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  16, false, true, current_timestamp());

-- [40] ActivityType (11 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 525, 'ActivityType'                              , 'ActivityTypePK'                            , 'activity_type_id'                          , 'INT'                 ,   1, true, true, current_timestamp()),
  ( 526, 'ActivityType'                              , 'ActivityTypeName'                          , 'activity_type_name'                        , 'STRING'              ,   2, true, true, current_timestamp()),
  ( 527, 'ActivityType'                              , 'ActivityTypeQualifier'                     , 'activity_type_qualifier'                   , 'STRING'              ,   3, true, true, current_timestamp()),
  ( 528, 'ActivityType'                              , 'Source'                                    , 'source'                                    , 'STRING'              ,   4, true, true, current_timestamp()),
  ( 529, 'ActivityType'                              , 'ValueType'                                 , 'value_type'                                , 'STRING'              ,   5, true, true, current_timestamp()),
  ( 530, 'ActivityType'                              , 'SortOrder'                                 , 'sort_order'                                , 'INT'                 ,   6, true, true, current_timestamp()),
  ( 531, 'ActivityType'                              , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,   7, false, true, current_timestamp()),
  ( 532, 'ActivityType'                              , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,   8, false, true, current_timestamp()),
  ( 533, 'ActivityType'                              , 'N/A'                                       , 'source_system'                             , 'STRING'              ,   9, false, true, current_timestamp()),
  ( 534, 'ActivityType'                              , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  10, false, true, current_timestamp()),
  ( 535, 'ActivityType'                              , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  11, false, true, current_timestamp());

-- [41] ActivityFinancial (18 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 536, 'ActivityFinancial'                         , 'ActivityPK'                                , 'activity_id'                               , 'BIGINT'              ,   1, true, true, current_timestamp()),
  ( 537, 'ActivityFinancial'                         , 'FreeAmount'                                , 'free_amount'                               , 'DECIMAL(18,4)'       ,   2, true, true, current_timestamp()),
  ( 538, 'ActivityFinancial'                         , 'SurrenderCharge'                           , 'surrender_charge'                          , 'DECIMAL(18,4)'       ,   3, true, true, current_timestamp()),
  ( 539, 'ActivityFinancial'                         , 'MVA'                                       , 'mva'                                       , 'DECIMAL(18,4)'       ,   4, true, true, current_timestamp()),
  ( 540, 'ActivityFinancial'                         , 'PolicyFee'                                 , 'policy_fee'                                , 'DECIMAL(18,4)'       ,   5, true, true, current_timestamp()),
  ( 541, 'ActivityFinancial'                         , 'COIRefund'                                 , 'coi_refund'                                , 'DECIMAL(18,4)'       ,   6, true, true, current_timestamp()),
  ( 542, 'ActivityFinancial'                         , 'ABRDiscountCharge'                         , 'abr_discount_charge'                       , 'DECIMAL(18,4)'       ,   7, true, true, current_timestamp()),
  ( 543, 'ActivityFinancial'                         , 'AdminCharge'                               , 'admin_charge'                              , 'DECIMAL(18,4)'       ,   8, true, true, current_timestamp()),
  ( 544, 'ActivityFinancial'                         , 'FederalTax'                                , 'federal_tax'                               , 'DECIMAL(18,4)'       ,   9, true, true, current_timestamp()),
  ( 545, 'ActivityFinancial'                         , 'StateTax'                                  , 'state_tax'                                 , 'DECIMAL(18,4)'       ,  10, true, true, current_timestamp()),
  ( 546, 'ActivityFinancial'                         , 'Rate'                                      , 'rate'                                      , 'DECIMAL(18,4)'       ,  11, true, true, current_timestamp()),
  ( 547, 'ActivityFinancial'                         , 'BaseAmount'                                , 'base_amount'                               , 'DECIMAL(18,4)'       ,  12, true, true, current_timestamp()),
  ( 548, 'ActivityFinancial'                         , 'TaxableBenefit'                            , 'taxable_benefit'                           , 'DECIMAL(18,4)'       ,  13, true, true, current_timestamp()),
  ( 549, 'ActivityFinancial'                         , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,  14, false, true, current_timestamp()),
  ( 550, 'ActivityFinancial'                         , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,  15, false, true, current_timestamp()),
  ( 551, 'ActivityFinancial'                         , 'N/A'                                       , 'source_system'                             , 'STRING'              ,  16, false, true, current_timestamp()),
  ( 552, 'ActivityFinancial'                         , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  17, false, true, current_timestamp()),
  ( 553, 'ActivityFinancial'                         , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  18, false, true, current_timestamp());

-- [42] AccountingDetail (23 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 554, 'AccountingDetail'                          , 'AccountingPK'                              , 'accounting_id'                             , 'BIGINT'              ,   1, true, true, current_timestamp()),
  ( 555, 'AccountingDetail'                          , 'SourceCode'                                , 'source_code'                               , 'STRING'              ,   2, true, true, current_timestamp()),
  ( 556, 'AccountingDetail'                          , 'ReferenceData'                             , 'reference_data'                            , 'STRING'              ,   3, true, true, current_timestamp()),
  ( 557, 'AccountingDetail'                          , 'Approval'                                  , 'approval'                                  , 'STRING'              ,   4, true, true, current_timestamp()),
  ( 558, 'AccountingDetail'                          , 'Description'                               , 'description'                               , 'STRING'              ,   5, true, true, current_timestamp()),
  ( 559, 'AccountingDetail'                          , 'CompanyCode'                               , 'company_code'                              , 'STRING'              ,   6, true, true, current_timestamp()),
  ( 560, 'AccountingDetail'                          , 'DCIndicator'                               , 'dc_indicator'                              , 'STRING'              ,   7, true, true, current_timestamp()),
  ( 561, 'AccountingDetail'                          , 'EntryOperator'                             , 'entry_operator'                            , 'STRING'              ,   8, true, true, current_timestamp()),
  ( 562, 'AccountingDetail'                          , 'ApprovalOperator'                          , 'approval_operator'                         , 'STRING'              ,   9, true, true, current_timestamp()),
  ( 563, 'AccountingDetail'                          , 'APEXTIndicator'                            , 'apext_indicator'                           , 'STRING'              ,  10, true, true, current_timestamp()),
  ( 564, 'AccountingDetail'                          , 'SuspenseEXTIndicator'                      , 'suspense_ext_indicator'                    , 'STRING'              ,  11, true, true, current_timestamp()),
  ( 565, 'AccountingDetail'                          , 'EntryGenIndicator'                         , 'entry_gen_indicator'                       , 'STRING'              ,  12, true, true, current_timestamp()),
  ( 566, 'AccountingDetail'                          , 'Treaty'                                    , 'treaty'                                    , 'STRING'              ,  13, true, true, current_timestamp()),
  ( 567, 'AccountingDetail'                          , 'QualType'                                  , 'qual_type'                                 , 'STRING'              ,  14, true, true, current_timestamp()),
  ( 568, 'AccountingDetail'                          , 'SEG_EDITTrxPK'                             , 'seg_edit_trx_id'                           , 'BIGINT'              ,  15, true, true, current_timestamp()),
  ( 569, 'AccountingDetail'                          , 'SEG_PlacedAgentPK'                         , 'seg_placed_agent_id'                       , 'BIGINT'              ,  16, true, true, current_timestamp()),
  ( 570, 'AccountingDetail'                          , 'CostCenter'                                , 'cost_center'                               , 'STRING'              ,  17, true, true, current_timestamp()),
  ( 571, 'AccountingDetail'                          , 'SuspenseCode'                              , 'suspense_code'                             , 'STRING'              ,  18, true, true, current_timestamp()),
  ( 572, 'AccountingDetail'                          , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,  19, false, true, current_timestamp()),
  ( 573, 'AccountingDetail'                          , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,  20, false, true, current_timestamp()),
  ( 574, 'AccountingDetail'                          , 'N/A'                                       , 'source_system'                             , 'STRING'              ,  21, false, true, current_timestamp()),
  ( 575, 'AccountingDetail'                          , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  22, false, true, current_timestamp()),
  ( 576, 'AccountingDetail'                          , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  23, false, true, current_timestamp());

-- [43] AccountingAccount (16 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 577, 'AccountingAccount'                         , 'AccountingAccountPK'                       , 'accounting_account_id'                     , 'INT'                 ,   1, true, true, current_timestamp()),
  ( 578, 'AccountingAccount'                         , 'AccountNumber'                             , 'account_number'                            , 'STRING'              ,   2, true, true, current_timestamp()),
  ( 579, 'AccountingAccount'                         , 'AccountSource'                             , 'account_source'                            , 'STRING'              ,   3, true, true, current_timestamp()),
  ( 580, 'AccountingAccount'                         , 'ClassCode'                                 , 'class_code'                                , 'STRING'              ,   4, true, true, current_timestamp()),
  ( 581, 'AccountingAccount'                         , 'CubeDescription'                           , 'cube_description'                          , 'STRING'              ,   5, true, true, current_timestamp()),
  ( 582, 'AccountingAccount'                         , 'GroupIndicator'                            , 'group_indicator'                           , 'BOOLEAN'             ,   6, true, true, current_timestamp()),
  ( 583, 'AccountingAccount'                         , 'CededIndicator'                            , 'ceded_indicator'                           , 'BOOLEAN'             ,   7, true, true, current_timestamp()),
  ( 584, 'AccountingAccount'                         , 'Context'                                   , 'context'                                   , 'STRING'              ,   8, true, true, current_timestamp()),
  ( 585, 'AccountingAccount'                         , 'ActuarialGrouping'                         , 'actuarial_grouping'                        , 'STRING'              ,   9, true, true, current_timestamp()),
  ( 586, 'AccountingAccount'                         , 'AccountDescription'                        , 'account_description'                       , 'STRING'              ,  10, true, true, current_timestamp()),
  ( 587, 'AccountingAccount'                         , 'AccountingReportingGroupKey'               , 'accounting_reporting_group_key'            , 'INT'                 ,  11, true, true, current_timestamp()),
  ( 588, 'AccountingAccount'                         , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,  12, false, true, current_timestamp()),
  ( 589, 'AccountingAccount'                         , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,  13, false, true, current_timestamp()),
  ( 590, 'AccountingAccount'                         , 'N/A'                                       , 'source_system'                             , 'STRING'              ,  14, false, true, current_timestamp()),
  ( 591, 'AccountingAccount'                         , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  15, false, true, current_timestamp()),
  ( 592, 'AccountingAccount'                         , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  16, false, true, current_timestamp());

-- [44] Accounting (24 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 593, 'Accounting'                                , 'AccountingPK'                              , 'accounting_id'                             , 'BIGINT'              ,   1, true, true, current_timestamp()),
  ( 594, 'Accounting'                                , 'SourceSystem'                              , 'source_system_code'                        , 'STRING'              ,   2, true, true, current_timestamp()),
  ( 595, 'Accounting'                                , 'TranID'                                    , 'transaction_id'                            , 'INT'                 ,   3, true, true, current_timestamp()),
  ( 596, 'Accounting'                                , 'TranDetailID'                              , 'transaction_detail_id'                     , 'BIGINT'              ,   4, true, true, current_timestamp()),
  ( 597, 'Accounting'                                , 'StatusCode'                                , 'status_code'                               , 'STRING'              ,   5, true, true, current_timestamp()),
  ( 598, 'Accounting'                                , 'StatusIndicator'                           , 'status_indicator'                          , 'STRING'              ,   6, true, true, current_timestamp()),
  ( 599, 'Accounting'                                , 'BasisCode'                                 , 'basis_code'                                , 'STRING'              ,   7, true, true, current_timestamp()),
  ( 600, 'Accounting'                                , 'State'                                     , 'state_code'                                , 'STRING'              ,   8, true, true, current_timestamp()),
  ( 601, 'Accounting'                                , 'EffectiveDateFK'                           , 'effective_date_id'                         , 'INT'                 ,   9, true, true, current_timestamp()),
  ( 602, 'Accounting'                                , 'PeriodDateFK'                              , 'period_date_id'                            , 'INT'                 ,  10, true, true, current_timestamp()),
  ( 603, 'Accounting'                                , 'AccountingAccountFK'                       , 'accounting_account_id'                     , 'INT'                 ,  11, true, true, current_timestamp()),
  ( 604, 'Accounting'                                , 'EntryDate'                                 , 'entry_date'                                , 'DATE'                ,  12, true, true, current_timestamp()),
  ( 605, 'Accounting'                                , 'EntryUpdateDate'                           , 'entry_update_date'                         , 'DATE'                ,  13, true, true, current_timestamp()),
  ( 606, 'Accounting'                                , 'ContractFK'                                , 'contract_id'                               , 'INT'                 ,  14, true, true, current_timestamp()),
  ( 607, 'Accounting'                                , 'InvestmentFK'                              , 'investment_id'                             , 'INT'                 ,  15, true, true, current_timestamp()),
  ( 608, 'Accounting'                                , 'ProductFK'                                 , 'product_id'                                , 'INT'                 ,  16, true, true, current_timestamp()),
  ( 609, 'Accounting'                                , 'AgentFK'                                   , 'agent_id'                                  , 'INT'                 ,  17, true, true, current_timestamp()),
  ( 610, 'Accounting'                                , 'Amount'                                    , 'amount'                                    , 'DECIMAL(18,4)'       ,  18, true, true, current_timestamp()),
  ( 611, 'Accounting'                                , 'Block'                                     , 'block_code'                                , 'STRING'              ,  19, true, true, current_timestamp()),
  ( 612, 'Accounting'                                , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,  20, false, true, current_timestamp()),
  ( 613, 'Accounting'                                , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,  21, false, true, current_timestamp()),
  ( 614, 'Accounting'                                , 'N/A'                                       , 'source_system'                             , 'STRING'              ,  22, false, true, current_timestamp()),
  ( 615, 'Accounting'                                , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  23, false, true, current_timestamp()),
  ( 616, 'Accounting'                                , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  24, false, true, current_timestamp());

-- [45] Surrender (18 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 617, 'Surrender'                                 , 'SurrenderPK'                               , 'surrender_id'                              , 'INT'                 ,   1, true, true, current_timestamp()),
  ( 618, 'Surrender'                                 , 'ProductFK'                                 , 'product_id'                                , 'INT'                 ,   2, true, true, current_timestamp()),
  ( 619, 'Surrender'                                 , 'FundNumber'                                , 'fund_number'                               , 'STRING'              ,   3, true, true, current_timestamp()),
  ( 620, 'Surrender'                                 , 'State'                                     , 'state_code'                                , 'STRING'              ,   4, true, true, current_timestamp()),
  ( 621, 'Surrender'                                 , 'Gender'                                    , 'gender'                                    , 'STRING'              ,   5, true, true, current_timestamp()),
  ( 622, 'Surrender'                                 , 'Class'                                     , 'risk_class'                                , 'STRING'              ,   6, true, true, current_timestamp()),
  ( 623, 'Surrender'                                 , 'Age'                                       , 'customer_age'                              , 'INT'                 ,   7, true, true, current_timestamp()),
  ( 624, 'Surrender'                                 , 'ContractYear'                              , 'policy_year'                               , 'INT'                 ,   8, true, true, current_timestamp()),
  ( 625, 'Surrender'                                 , 'SurrenderLength'                           , 'penalty_duration_years'                    , 'INT'                 ,   9, true, true, current_timestamp()),
  ( 626, 'Surrender'                                 , 'Rate'                                      , 'penalty_percentage'                        , 'DECIMAL(18,4)'       ,  10, true, true, current_timestamp()),
  ( 627, 'Surrender'                                 , 'RateAppliedTo'                             , 'rate_calculation_basis'                    , 'STRING'              ,  11, true, true, current_timestamp()),
  ( 628, 'Surrender'                                 , 'EffectiveDate'                             , 'rule_start_date'                           , 'TIMESTAMP'           ,  12, true, true, current_timestamp()),
  ( 629, 'Surrender'                                 , 'EndDate'                                   , 'rule_end_date'                             , 'TIMESTAMP'           ,  13, true, true, current_timestamp()),
  ( 630, 'Surrender'                                 , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,  14, false, true, current_timestamp()),
  ( 631, 'Surrender'                                 , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,  15, false, true, current_timestamp()),
  ( 632, 'Surrender'                                 , 'N/A'                                       , 'source_system'                             , 'STRING'              ,  16, false, true, current_timestamp()),
  ( 633, 'Surrender'                                 , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  17, false, true, current_timestamp()),
  ( 634, 'Surrender'                                 , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  18, false, true, current_timestamp());

-- [46] InvestmentDetail (14 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 635, 'InvestmentDetail'                          , 'InvestmentDetailPK'                        , 'investment_detail_id'                      , 'INT'                 ,   1, true, true, current_timestamp()),
  ( 636, 'InvestmentDetail'                          , 'Name'                                      , 'investment_detail_name'                    , 'STRING'              ,   2, true, true, current_timestamp()),
  ( 637, 'InvestmentDetail'                          , 'FundType'                                  , 'fund_type'                                 , 'STRING'              ,   3, true, true, current_timestamp()),
  ( 638, 'InvestmentDetail'                          , 'GroupingName'                              , 'grouping_name'                             , 'STRING'              ,   4, true, true, current_timestamp()),
  ( 639, 'InvestmentDetail'                          , 'MarketingName'                             , 'marketing_name'                            , 'STRING'              ,   5, true, true, current_timestamp()),
  ( 640, 'InvestmentDetail'                          , 'AltMarketingName'                          , 'alt_marketing_name'                        , 'STRING'              ,   6, true, true, current_timestamp()),
  ( 641, 'InvestmentDetail'                          , 'SortOrder'                                 , 'sort_order'                                , 'STRING'              ,   7, true, true, current_timestamp()),
  ( 642, 'InvestmentDetail'                          , 'IsCap'                                     , 'is_cap_indicator'                          , 'BOOLEAN'             ,   8, true, true, current_timestamp()),
  ( 643, 'InvestmentDetail'                          , 'FundStartDate'                             , 'fund_start_date'                           , 'TIMESTAMP'           ,   9, true, true, current_timestamp()),
  ( 644, 'InvestmentDetail'                          , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,  10, false, true, current_timestamp()),
  ( 645, 'InvestmentDetail'                          , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,  11, false, true, current_timestamp()),
  ( 646, 'InvestmentDetail'                          , 'N/A'                                       , 'source_system'                             , 'STRING'              ,  12, false, true, current_timestamp()),
  ( 647, 'InvestmentDetail'                          , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  13, false, true, current_timestamp()),
  ( 648, 'InvestmentDetail'                          , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  14, false, true, current_timestamp());

-- [47] Investment (13 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 649, 'Investment'                                , 'InvestmentPK'                              , 'investment_id'                             , 'INT'                 ,   1, true, true, current_timestamp()),
  ( 650, 'Investment'                                , 'InvestmentKey'                             , 'investment_key'                            , 'INT'                 ,   2, true, true, current_timestamp()),
  ( 651, 'Investment'                                , 'InvestmentName'                            , 'investment_name'                           , 'STRING'              ,   3, true, true, current_timestamp()),
  ( 652, 'Investment'                                , 'InvestmentDescription'                     , 'investment_description'                    , 'STRING'              ,   4, true, true, current_timestamp()),
  ( 653, 'Investment'                                , 'EffectiveDate'                             , 'effective_date'                            , 'TIMESTAMP'           ,   5, true, true, current_timestamp()),
  ( 654, 'Investment'                                , 'Active'                                    , 'active_indicator'                          , 'BOOLEAN'             ,   6, true, true, current_timestamp()),
  ( 655, 'Investment'                                , 'StartDate'                                 , 'start_timestamp'                           , 'TIMESTAMP'           ,   7, true, true, current_timestamp()),
  ( 656, 'Investment'                                , 'EndDate'                                   , 'end_timestamp'                             , 'TIMESTAMP'           ,   8, true, true, current_timestamp()),
  ( 657, 'Investment'                                , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,   9, false, true, current_timestamp()),
  ( 658, 'Investment'                                , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,  10, false, true, current_timestamp()),
  ( 659, 'Investment'                                , 'N/A'                                       , 'source_system'                             , 'STRING'              ,  11, false, true, current_timestamp()),
  ( 660, 'Investment'                                , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  12, false, true, current_timestamp()),
  ( 661, 'Investment'                                , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  13, false, true, current_timestamp());

-- [48] Activity (27 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 662, 'Activity'                                  , 'ActivityPK'                                , 'activity_id'                               , 'BIGINT'              ,   1, true, true, current_timestamp()),
  ( 663, 'Activity'                                  , 'ActivityTypeFK'                            , 'activity_type_id'                          , 'INT'                 ,   2, true, true, current_timestamp()),
  ( 664, 'Activity'                                  , 'CompanyFK'                                 , 'company_id'                                , 'INT'                 ,   3, true, true, current_timestamp()),
  ( 665, 'Activity'                                  , 'ContractFK'                                , 'contract_id'                               , 'INT'                 ,   4, true, true, current_timestamp()),
  ( 666, 'Activity'                                  , 'ProductFK'                                 , 'product_id'                                , 'INT'                 ,   5, true, true, current_timestamp()),
  ( 667, 'Activity'                                  , 'InvestmentFK'                              , 'investment_id'                             , 'INT'                 ,   6, true, true, current_timestamp()),
  ( 668, 'Activity'                                  , 'AccountingFK'                              , 'accounting_id'                             , 'INT'                 ,   7, true, true, current_timestamp()),
  ( 669, 'Activity'                                  , 'AccountingAccountFK'                       , 'accounting_account_id'                     , 'INT'                 ,   8, true, true, current_timestamp()),
  ( 670, 'Activity'                                  , 'CAPRepaymentFK'                            , 'cap_repayment_id'                          , 'INT'                 ,   9, true, true, current_timestamp()),
  ( 671, 'Activity'                                  , 'HierarchySetKey'                           , 'hierarchy_set_id'                          , 'INT'                 ,  10, true, true, current_timestamp()),
  ( 672, 'Activity'                                  , 'AgentFK'                                   , 'agent_id'                                  , 'INT'                 ,  11, true, true, current_timestamp()),
  ( 673, 'Activity'                                  , 'ActivityClientFK'                          , 'activity_client_id'                        , 'INT'                 ,  12, true, true, current_timestamp()),
  ( 674, 'Activity'                                  , 'ActivityPayeeFK'                           , 'activity_payee_id'                         , 'INT'                 ,  13, true, true, current_timestamp()),
  ( 675, 'Activity'                                  , 'EffectiveDateFK'                           , 'effective_date_id'                         , 'INT'                 ,  14, true, true, current_timestamp()),
  ( 676, 'Activity'                                  , 'ProcessDateFK'                             , 'process_date_id'                           , 'INT'                 ,  15, true, true, current_timestamp()),
  ( 677, 'Activity'                                  , 'ReleaseDate'                               , 'release_date'                              , 'TIMESTAMP'           ,  16, true, true, current_timestamp()),
  ( 678, 'Activity'                                  , 'PeriodDate'                                , 'period_date'                               , 'TIMESTAMP'           ,  17, true, true, current_timestamp()),
  ( 679, 'Activity'                                  , 'GrossAmount'                               , 'gross_amount'                              , 'DECIMAL(18,4)'       ,  18, true, true, current_timestamp()),
  ( 680, 'Activity'                                  , 'NetAmount'                                 , 'net_amount'                                , 'DECIMAL(18,4)'       ,  19, true, true, current_timestamp()),
  ( 681, 'Activity'                                  , 'CheckAmount'                               , 'check_amount'                              , 'DECIMAL(18,4)'       ,  20, true, true, current_timestamp()),
  ( 682, 'Activity'                                  , 'DistributionType'                          , 'distribution_type'                         , 'STRING'              ,  21, true, true, current_timestamp()),
  ( 683, 'Activity'                                  , 'TextValue'                                 , 'activity_notes'                            , 'STRING'              ,  22, true, true, current_timestamp()),
  ( 684, 'Activity'                                  , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,  23, false, true, current_timestamp()),
  ( 685, 'Activity'                                  , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,  24, false, true, current_timestamp()),
  ( 686, 'Activity'                                  , 'N/A'                                       , 'source_system'                             , 'STRING'              ,  25, false, true, current_timestamp()),
  ( 687, 'Activity'                                  , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  26, false, true, current_timestamp()),
  ( 688, 'Activity'                                  , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  27, false, true, current_timestamp());

-- [49] AccountValue (16 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 689, 'AccountValue'                              , 'AccountValuePK'                            , 'account_value_id'                          , 'INT'                 ,   1, true, true, current_timestamp()),
  ( 690, 'AccountValue'                              , 'ContractFK'                                , 'contract_id'                               , 'INT'                 ,   2, true, true, current_timestamp()),
  ( 691, 'AccountValue'                              , 'InvestmentFK'                              , 'investment_id'                             , 'INT'                 ,   3, true, true, current_timestamp()),
  ( 692, 'AccountValue'                              , 'Value'                                     , 'account_value_amount'                      , 'DECIMAL(18,4)'       ,   4, true, true, current_timestamp()),
  ( 693, 'AccountValue'                              , 'CurrentInterestRate'                       , 'current_interest_rate'                     , 'DECIMAL(18,4)'       ,   5, true, true, current_timestamp()),
  ( 694, 'AccountValue'                              , 'AllocationPercent'                         , 'allocation_percentage'                     , 'DECIMAL(18,4)'       ,   6, true, true, current_timestamp()),
  ( 695, 'AccountValue'                              , 'DepositDate'                               , 'deposit_date'                              , 'TIMESTAMP'           ,   7, true, true, current_timestamp()),
  ( 696, 'AccountValue'                              , 'RenewalDate'                               , 'renewal_date'                              , 'TIMESTAMP'           ,   8, true, true, current_timestamp()),
  ( 697, 'AccountValue'                              , 'ValuationDate'                             , 'valuation_date'                            , 'TIMESTAMP'           ,   9, true, true, current_timestamp()),
  ( 698, 'AccountValue'                              , 'StartDate'                                 , 'start_timestamp'                           , 'TIMESTAMP'           ,  10, true, true, current_timestamp()),
  ( 699, 'AccountValue'                              , 'EndDate'                                   , 'end_timestamp'                             , 'TIMESTAMP'           ,  11, true, true, current_timestamp()),
  ( 700, 'AccountValue'                              , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,  12, false, true, current_timestamp()),
  ( 701, 'AccountValue'                              , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,  13, false, true, current_timestamp()),
  ( 702, 'AccountValue'                              , 'N/A'                                       , 'source_system'                             , 'STRING'              ,  14, false, true, current_timestamp()),
  ( 703, 'AccountValue'                              , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  15, false, true, current_timestamp()),
  ( 704, 'AccountValue'                              , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  16, false, true, current_timestamp());

-- [50] Product (14 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 705, 'Product'                                   , 'ProductPK'                                 , 'product_id'                                , 'INT'                 ,   1, true, true, current_timestamp()),
  ( 706, 'Product'                                   , 'ProductName'                               , 'product_name'                              , 'STRING'              ,   2, true, true, current_timestamp()),
  ( 707, 'Product'                                   , 'MarketingName'                             , 'marketing_name'                            , 'STRING'              ,   3, true, true, current_timestamp()),
  ( 708, 'Product'                                   , 'ProductType'                               , 'product_type'                              , 'STRING'              ,   4, true, true, current_timestamp()),
  ( 709, 'Product'                                   , 'CUSIPNumber'                               , 'cusip_number'                              , 'STRING'              ,   5, true, true, current_timestamp()),
  ( 710, 'Product'                                   , 'Context'                                   , 'product_context'                           , 'STRING'              ,   6, true, true, current_timestamp()),
  ( 711, 'Product'                                   , 'GLLOB'                                     , 'gl_line_of_business'                       , 'STRING'              ,   7, true, true, current_timestamp()),
  ( 712, 'Product'                                   , 'Status'                                    , 'status'                                    , 'STRING'              ,   8, true, true, current_timestamp()),
  ( 713, 'Product'                                   , 'EffectiveDate'                             , 'effective_date'                            , 'TIMESTAMP'           ,   9, true, true, current_timestamp()),
  ( 714, 'Product'                                   , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,  10, false, true, current_timestamp()),
  ( 715, 'Product'                                   , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,  11, false, true, current_timestamp()),
  ( 716, 'Product'                                   , 'N/A'                                       , 'source_system'                             , 'STRING'              ,  12, false, true, current_timestamp()),
  ( 717, 'Product'                                   , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  13, false, true, current_timestamp()),
  ( 718, 'Product'                                   , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  14, false, true, current_timestamp());

-- [51] Agent (20 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 719, 'Agent'                                     , 'AgentPK'                                   , 'agent_id'                                  , 'INT'                 ,   1, true, true, current_timestamp()),
  ( 720, 'Agent'                                     , 'AgentNumber'                               , 'agent_number'                              , 'STRING'              ,   2, true, true, current_timestamp()),
  ( 721, 'Agent'                                     , 'DisplayName'                               , 'display_name'                              , 'STRING'              ,   3, true, true, current_timestamp()),
  ( 722, 'Agent'                                     , 'NPN'                                       , 'national_producer_number'                  , 'STRING'              ,   4, true, true, current_timestamp()),
  ( 723, 'Agent'                                     , 'NASD'                                      , 'nasd_finra_number'                         , 'STRING'              ,   5, true, true, current_timestamp()),
  ( 724, 'Agent'                                     , 'AgentType'                                 , 'agent_type'                                , 'STRING'              ,   6, true, true, current_timestamp()),
  ( 725, 'Agent'                                     , 'Status'                                    , 'status'                                    , 'STRING'              ,   7, true, true, current_timestamp()),
  ( 726, 'Agent'                                     , 'HireDate'                                  , 'hire_date'                                 , 'TIMESTAMP'           ,   8, true, true, current_timestamp()),
  ( 727, 'Agent'                                     , 'TerminationDate'                           , 'termination_date'                          , 'TIMESTAMP'           ,   9, true, true, current_timestamp()),
  ( 728, 'Agent'                                     , 'ClientFK'                                  , 'client_id'                                 , 'INT'                 ,  10, true, true, current_timestamp()),
  ( 729, 'Agent'                                     , 'AddressGroupFK'                            , 'address_group_id'                          , 'INT'                 ,  11, true, true, current_timestamp()),
  ( 730, 'Agent'                                     , 'AdditionalInfoGroupFK'                     , 'additional_info_group_id'                  , 'INT'                 ,  12, true, true, current_timestamp()),
  ( 731, 'Agent'                                     , 'EffectiveDate'                             , 'effective_date'                            , 'TIMESTAMP'           ,  13, true, true, current_timestamp()),
  ( 732, 'Agent'                                     , 'StartTimestamp'                            , 'start_timestamp'                           , 'TIMESTAMP'           ,  14, true, true, current_timestamp()),
  ( 733, 'Agent'                                     , 'EndTimestamp'                              , 'end_timestamp'                             , 'TIMESTAMP'           ,  15, true, true, current_timestamp()),
  ( 734, 'Agent'                                     , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,  16, false, true, current_timestamp()),
  ( 735, 'Agent'                                     , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,  17, false, true, current_timestamp()),
  ( 736, 'Agent'                                     , 'N/A'                                       , 'source_system'                             , 'STRING'              ,  18, false, true, current_timestamp()),
  ( 737, 'Agent'                                     , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  19, false, true, current_timestamp()),
  ( 738, 'Agent'                                     , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  20, false, true, current_timestamp());

-- [52] Client (39 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 739, 'Client'                                    , 'ClientPK'                                  , 'client_id'                                 , 'INT'                 ,   1, true, true, current_timestamp()),
  ( 740, 'Client'                                    , 'SourceKey'                                 , 'source_key'                                , 'BIGINT'              ,   2, true, true, current_timestamp()),
  ( 741, 'Client'                                    , 'TaxIDHash'                                 , 'tax_id_hash'                               , 'BINARY'              ,   3, true, true, current_timestamp()),
  ( 742, 'Client'                                    , 'Last4Hash'                                 , 'last_4_hash'                               , 'BINARY'              ,   4, true, true, current_timestamp()),
  ( 743, 'Client'                                    , 'Last4Token'                                , 'last_4_token'                              , 'STRING'              ,   5, true, true, current_timestamp()),
  ( 744, 'Client'                                    , 'DisplayName'                               , 'display_name'                              , 'STRING'              ,   6, true, true, current_timestamp()),
  ( 745, 'Client'                                    , 'FirstName'                                 , 'first_name'                                , 'STRING'              ,   7, true, true, current_timestamp()),
  ( 746, 'Client'                                    , 'MiddleName'                                , 'middle_name'                               , 'STRING'              ,   8, true, true, current_timestamp()),
  ( 747, 'Client'                                    , 'LastName'                                  , 'last_name'                                 , 'STRING'              ,   9, true, true, current_timestamp()),
  ( 748, 'Client'                                    , 'Prefix'                                    , 'prefix'                                    , 'STRING'              ,  10, true, true, current_timestamp()),
  ( 749, 'Client'                                    , 'Suffix'                                    , 'suffix'                                    , 'STRING'              ,  11, true, true, current_timestamp()),
  ( 750, 'Client'                                    , 'CorporateName'                             , 'corporate_name'                            , 'STRING'              ,  12, true, true, current_timestamp()),
  ( 751, 'Client'                                    , 'Gender'                                    , 'gender'                                    , 'STRING'              ,  13, true, true, current_timestamp()),
  ( 752, 'Client'                                    , 'Phone'                                     , 'phone_number'                              , 'STRING'              ,  14, true, true, current_timestamp()),
  ( 753, 'Client'                                    , 'Email'                                     , 'email_address'                             , 'STRING'              ,  15, true, true, current_timestamp()),
  ( 754, 'Client'                                    , 'Fax'                                       , 'fax_number'                                , 'STRING'              ,  16, true, true, current_timestamp()),
  ( 755, 'Client'                                    , 'BirthDate'                                 , 'birth_date'                                , 'TIMESTAMP'           ,  17, true, true, current_timestamp()),
  ( 756, 'Client'                                    , 'DeathDate'                                 , 'death_date'                                , 'TIMESTAMP'           ,  18, true, true, current_timestamp()),
  ( 757, 'Client'                                    , 'Status'                                    , 'status'                                    , 'STRING'              ,  19, true, true, current_timestamp()),
  ( 758, 'Client'                                    , 'PayPreference'                             , 'pay_preference'                            , 'STRING'              ,  20, true, true, current_timestamp()),
  ( 759, 'Client'                                    , 'ExternalAccountGroupFK'                    , 'external_account_group_id'                 , 'INT'                 ,  21, true, true, current_timestamp()),
  ( 760, 'Client'                                    , 'Address1'                                  , 'address_line_1'                            , 'STRING'              ,  22, true, true, current_timestamp()),
  ( 761, 'Client'                                    , 'Address2'                                  , 'address_line_2'                            , 'STRING'              ,  23, true, true, current_timestamp()),
  ( 762, 'Client'                                    , 'City'                                      , 'city'                                      , 'STRING'              ,  24, true, true, current_timestamp()),
  ( 763, 'Client'                                    , 'State'                                     , 'state_code'                                , 'STRING'              ,  25, true, true, current_timestamp()),
  ( 764, 'Client'                                    , 'ZipCode'                                   , 'zip_code'                                  , 'STRING'              ,  26, true, true, current_timestamp()),
  ( 765, 'Client'                                    , 'County'                                    , 'county'                                    , 'STRING'              ,  27, true, true, current_timestamp()),
  ( 766, 'Client'                                    , 'CountryCode'                               , 'country_code'                              , 'STRING'              ,  28, true, true, current_timestamp()),
  ( 767, 'Client'                                    , 'AdditionalInfoGroupFK'                     , 'additional_info_group_id'                  , 'INT'                 ,  29, true, true, current_timestamp()),
  ( 768, 'Client'                                    , 'VerificationDetails'                       , 'verification_details'                      , 'STRING'              ,  30, true, true, current_timestamp()),
  ( 769, 'Client'                                    , 'NoNewBusiness'                             , 'no_new_business_indicator'                 , 'BOOLEAN'             ,  31, true, true, current_timestamp()),
  ( 770, 'Client'                                    , 'EffectiveDate'                             , 'effective_date'                            , 'TIMESTAMP'           ,  32, true, true, current_timestamp()),
  ( 771, 'Client'                                    , 'StartTimestamp'                            , 'start_timestamp'                           , 'TIMESTAMP'           ,  33, true, true, current_timestamp()),
  ( 772, 'Client'                                    , 'EndTimestamp'                              , 'end_timestamp'                             , 'TIMESTAMP'           ,  34, true, true, current_timestamp()),
  ( 773, 'Client'                                    , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,  35, false, true, current_timestamp()),
  ( 774, 'Client'                                    , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,  36, false, true, current_timestamp()),
  ( 775, 'Client'                                    , 'N/A'                                       , 'source_system'                             , 'STRING'              ,  37, false, true, current_timestamp()),
  ( 776, 'Client'                                    , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  38, false, true, current_timestamp()),
  ( 777, 'Client'                                    , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  39, false, true, current_timestamp());

-- [53] Contract (14 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 778, 'Contract'                                  , 'ContractPK'                                , 'contract_id'                               , 'INT'                 ,   1, true, true, current_timestamp()),
  ( 779, 'Contract'                                  , 'ContractNumber'                            , 'contract_number'                           , 'STRING'              ,   2, true, true, current_timestamp()),
  ( 780, 'Contract'                                  , 'ProductFK'                                 , 'product_id'                                , 'INT'                 ,   3, true, true, current_timestamp()),
  ( 781, 'Contract'                                  , 'AgentFK'                                   , 'agent_id'                                  , 'INT'                 ,   4, true, true, current_timestamp()),
  ( 782, 'Contract'                                  , 'IssueDate'                                 , 'issue_date'                                , 'TIMESTAMP'           ,   5, true, true, current_timestamp()),
  ( 783, 'Contract'                                  , 'Status'                                    , 'status_code'                               , 'STRING'              ,   6, true, true, current_timestamp()),
  ( 784, 'Contract'                                  , 'StatusDate'                                , 'status_date'                               , 'TIMESTAMP'           ,   7, true, true, current_timestamp()),
  ( 785, 'Contract'                                  , 'PlanCode'                                  , 'plan_code'                                 , 'STRING'              ,   8, true, true, current_timestamp()),
  ( 786, 'Contract'                                  , 'StateCode'                                 , 'issue_state_code'                          , 'STRING'              ,   9, true, true, current_timestamp()),
  ( 787, 'Contract'                                  , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,  10, false, true, current_timestamp()),
  ( 788, 'Contract'                                  , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,  11, false, true, current_timestamp()),
  ( 789, 'Contract'                                  , 'N/A'                                       , 'source_system'                             , 'STRING'              ,  12, false, true, current_timestamp()),
  ( 790, 'Contract'                                  , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  13, false, true, current_timestamp()),
  ( 791, 'Contract'                                  , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  14, false, true, current_timestamp());

-- [54] vw_SEG_ContractClient (12 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 792, 'vw_SEG_ContractClient'                     , 'Source Column Name'                        , 'Target Column Name'                        , 'TARGET DATA TYPE (FABRIC)',   1, true, true, current_timestamp()),
  ( 793, 'vw_SEG_ContractClient'                     , 'ContractPK'                                , 'contract_id'                               , 'INT'                 ,   2, true, true, current_timestamp()),
  ( 794, 'vw_SEG_ContractClient'                     , 'ClientFK'                                  , 'client_id'                                 , 'INT'                 ,   3, true, true, current_timestamp()),
  ( 795, 'vw_SEG_ContractClient'                     , 'RoleName'                                  , 'client_role_name'                          , 'STRING'              ,   4, true, true, current_timestamp()),
  ( 796, 'vw_SEG_ContractClient'                     , 'Relationship'                              , 'relationship_to_insured'                   , 'STRING'              ,   5, true, true, current_timestamp()),
  ( 797, 'vw_SEG_ContractClient'                     , 'AllocationPercent'                         , 'share_percentage'                          , 'DECIMAL(18,4)'       ,   6, true, true, current_timestamp()),
  ( 798, 'vw_SEG_ContractClient'                     , 'Status'                                    , 'status'                                    , 'STRING'              ,   7, true, true, current_timestamp()),
  ( 799, 'vw_SEG_ContractClient'                     , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,   8, false, true, current_timestamp()),
  ( 800, 'vw_SEG_ContractClient'                     , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,   9, false, true, current_timestamp()),
  ( 801, 'vw_SEG_ContractClient'                     , 'N/A'                                       , 'source_system'                             , 'STRING'              ,  10, false, true, current_timestamp()),
  ( 802, 'vw_SEG_ContractClient'                     , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  11, false, true, current_timestamp()),
  ( 803, 'vw_SEG_ContractClient'                     , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  12, false, true, current_timestamp());

-- [55] vw_SEG_ContractTreaty (12 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 804, 'vw_SEG_ContractTreaty'                     , 'ContractPK'                                , 'contract_id'                               , 'INT'                 ,   1, true, true, current_timestamp()),
  ( 805, 'vw_SEG_ContractTreaty'                     , 'TreatyPK'                                  , 'treaty_id'                                 , 'INT'                 ,   2, true, true, current_timestamp()),
  ( 806, 'vw_SEG_ContractTreaty'                     , 'ContractNumber'                            , 'contract_number'                           , 'STRING'              ,   3, true, true, current_timestamp()),
  ( 807, 'vw_SEG_ContractTreaty'                     , 'TreatyName'                                , 'treaty_name'                               , 'STRING'              ,   4, true, true, current_timestamp()),
  ( 808, 'vw_SEG_ContractTreaty'                     , 'TreatyDescription'                         , 'treaty_description'                        , 'STRING'              ,   5, true, true, current_timestamp()),
  ( 809, 'vw_SEG_ContractTreaty'                     , 'EffectiveDate'                             , 'effective_date'                            , 'TIMESTAMP'           ,   6, true, true, current_timestamp()),
  ( 810, 'vw_SEG_ContractTreaty'                     , 'Status'                                    , 'status'                                    , 'STRING'              ,   7, true, true, current_timestamp()),
  ( 811, 'vw_SEG_ContractTreaty'                     , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,   8, false, true, current_timestamp()),
  ( 812, 'vw_SEG_ContractTreaty'                     , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,   9, false, true, current_timestamp()),
  ( 813, 'vw_SEG_ContractTreaty'                     , 'N/A'                                       , 'source_system'                             , 'STRING'              ,  10, false, true, current_timestamp()),
  ( 814, 'vw_SEG_ContractTreaty'                     , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  11, false, true, current_timestamp()),
  ( 815, 'vw_SEG_ContractTreaty'                     , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  12, false, true, current_timestamp());

-- [56] vw_SEG_ContractRider (28 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 816, 'vw_SEG_ContractRider'                      , 'RiderGroupKey'                             , 'rider_group_id'                            , 'INT'                 ,   1, true, true, current_timestamp()),
  ( 817, 'vw_SEG_ContractRider'                      , 'IBREligibilityDate'                        , 'ibr_eligibility_date'                      , 'TIMESTAMP'           ,   2, true, true, current_timestamp()),
  ( 818, 'vw_SEG_ContractRider'                      , 'IBRStartDate'                              , 'ibr_start_date'                            , 'TIMESTAMP'           ,   3, true, true, current_timestamp()),
  ( 819, 'vw_SEG_ContractRider'                      , 'ABR'                                       , 'abr_stop_date'                             , 'TIMESTAMP'           ,   4, true, true, current_timestamp()),
  ( 820, 'vw_SEG_ContractRider'                      , 'ABR-TI'                                    , 'abr_ti_stop_date'                          , 'TIMESTAMP'           ,   5, true, true, current_timestamp()),
  ( 821, 'vw_SEG_ContractRider'                      , 'AVGuarRider'                               , 'av_guar_rider_stop_date'                   , 'TIMESTAMP'           ,   6, true, true, current_timestamp()),
  ( 822, 'vw_SEG_ContractRider'                      , 'IBR'                                       , 'ibr_stop_date'                             , 'TIMESTAMP'           ,   7, true, true, current_timestamp()),
  ( 823, 'vw_SEG_ContractRider'                      , 'IBR-SD'                                    , 'ibr_sd_stop_date'                          , 'TIMESTAMP'           ,   8, true, true, current_timestamp()),
  ( 824, 'vw_SEG_ContractRider'                      , 'IBR-ST'                                    , 'ibr_st_stop_date'                          , 'TIMESTAMP'           ,   9, true, true, current_timestamp()),
  ( 825, 'vw_SEG_ContractRider'                      , 'InflationRider'                            , 'inflation_rider_stop_date'                 , 'TIMESTAMP'           ,  10, true, true, current_timestamp()),
  ( 826, 'vw_SEG_ContractRider'                      , 'LIQ'                                       , 'liq_stop_date'                             , 'TIMESTAMP'           ,  11, true, true, current_timestamp()),
  ( 827, 'vw_SEG_ContractRider'                      , 'LongevityRider'                            , 'longevity_rider_stop_date'                 , 'TIMESTAMP'           ,  12, true, true, current_timestamp()),
  ( 828, 'vw_SEG_ContractRider'                      , 'LTCRider'                                  , 'ltc_rider_stop_date'                       , 'TIMESTAMP'           ,  13, true, true, current_timestamp()),
  ( 829, 'vw_SEG_ContractRider'                      , 'MVA'                                       , 'mva_stop_date'                             , 'TIMESTAMP'           ,  14, true, true, current_timestamp()),
  ( 830, 'vw_SEG_ContractRider'                      , 'NFRider'                                   , 'nf_rider_stop_date'                        , 'TIMESTAMP'           ,  15, true, true, current_timestamp()),
  ( 831, 'vw_SEG_ContractRider'                      , 'NursingHomeWaiver'                         , 'nursing_home_waiver_stop_date'             , 'TIMESTAMP'           ,  16, true, true, current_timestamp()),
  ( 832, 'vw_SEG_ContractRider'                      , 'OP'                                        , 'op_stop_date'                              , 'TIMESTAMP'           ,  17, true, true, current_timestamp()),
  ( 833, 'vw_SEG_ContractRider'                      , 'ROP'                                       , 'rop_stop_date'                             , 'TIMESTAMP'           ,  18, true, true, current_timestamp()),
  ( 834, 'vw_SEG_ContractRider'                      , 'SR'                                        , 'sr_stop_date'                              , 'TIMESTAMP'           ,  19, true, true, current_timestamp()),
  ( 835, 'vw_SEG_ContractRider'                      , 'TIR'                                       , 'tir_stop_date'                             , 'TIMESTAMP'           ,  20, true, true, current_timestamp()),
  ( 836, 'vw_SEG_ContractRider'                      , 'WellnessCredits'                           , 'wellness_credits_stop_date'                , 'TIMESTAMP'           ,  21, true, true, current_timestamp()),
  ( 837, 'vw_SEG_ContractRider'                      , 'WellnessRider'                             , 'wellness_rider_stop_date'                  , 'TIMESTAMP'           ,  22, true, true, current_timestamp()),
  ( 838, 'vw_SEG_ContractRider'                      , 'WSC'                                       , 'wsc_stop_date'                             , 'TIMESTAMP'           ,  23, true, true, current_timestamp()),
  ( 839, 'vw_SEG_ContractRider'                      , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,  24, false, true, current_timestamp()),
  ( 840, 'vw_SEG_ContractRider'                      , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,  25, false, true, current_timestamp()),
  ( 841, 'vw_SEG_ContractRider'                      , 'N/A'                                       , 'source_system'                             , 'STRING'              ,  26, false, true, current_timestamp()),
  ( 842, 'vw_SEG_ContractRider'                      , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  27, false, true, current_timestamp()),
  ( 843, 'vw_SEG_ContractRider'                      , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  28, false, true, current_timestamp());

-- [57] ref_Product (15 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 844, 'ref_Product'                               , 'Source Column Name'                        , 'Target Column Name'                        , 'TARGET DATA TYPE (FABRIC)',   1, true, true, current_timestamp()),
  ( 845, 'ref_Product'                               , 'ProductPK'                                 , 'product_id'                                , 'INT'                 ,   2, true, true, current_timestamp()),
  ( 846, 'ref_Product'                               , 'ProductName'                               , 'product_name'                              , 'STRING'              ,   3, true, true, current_timestamp()),
  ( 847, 'ref_Product'                               , 'MarketingName'                             , 'marketing_name'                            , 'STRING'              ,   4, true, true, current_timestamp()),
  ( 848, 'ref_Product'                               , 'ProductType'                               , 'product_type'                              , 'STRING'              ,   5, true, true, current_timestamp()),
  ( 849, 'ref_Product'                               , 'CUSIPNumber'                               , 'cusip_number'                              , 'STRING'              ,   6, true, true, current_timestamp()),
  ( 850, 'ref_Product'                               , 'Context'                                   , 'product_context'                           , 'STRING'              ,   7, true, true, current_timestamp()),
  ( 851, 'ref_Product'                               , 'GLLOB'                                     , 'gl_line_of_business'                       , 'STRING'              ,   8, true, true, current_timestamp()),
  ( 852, 'ref_Product'                               , 'Status'                                    , 'status'                                    , 'STRING'              ,   9, true, true, current_timestamp()),
  ( 853, 'ref_Product'                               , 'EffectiveDate'                             , 'effective_date'                            , 'TIMESTAMP'           ,  10, true, true, current_timestamp()),
  ( 854, 'ref_Product'                               , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,  11, false, true, current_timestamp()),
  ( 855, 'ref_Product'                               , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,  12, false, true, current_timestamp()),
  ( 856, 'ref_Product'                               , 'N/A'                                       , 'source_system'                             , 'STRING'              ,  13, false, true, current_timestamp()),
  ( 857, 'ref_Product'                               , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  14, false, true, current_timestamp()),
  ( 858, 'ref_Product'                               , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  15, false, true, current_timestamp());

-- [58] vw_SEG_ContractTrx (14 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 859, 'vw_SEG_ContractTrx'                        , 'TrxPK'                                     , 'trx_id'                                    , 'BIGINT'              ,   1, true, true, current_timestamp()),
  ( 860, 'vw_SEG_ContractTrx'                        , 'ContractPK'                                , 'contract_id'                               , 'INT'                 ,   2, true, true, current_timestamp()),
  ( 861, 'vw_SEG_ContractTrx'                        , 'ContractNumber'                            , 'contract_number'                           , 'STRING'              ,   3, true, true, current_timestamp()),
  ( 862, 'vw_SEG_ContractTrx'                        , 'TrxType'                                   , 'trx_type_code'                             , 'STRING'              ,   4, true, true, current_timestamp()),
  ( 863, 'vw_SEG_ContractTrx'                        , 'TrxDescription'                            , 'trx_description'                           , 'STRING'              ,   5, true, true, current_timestamp()),
  ( 864, 'vw_SEG_ContractTrx'                        , 'EffectiveDate'                             , 'effective_date'                            , 'TIMESTAMP'           ,   6, true, true, current_timestamp()),
  ( 865, 'vw_SEG_ContractTrx'                        , 'ProcessDate'                               , 'process_date'                              , 'TIMESTAMP'           ,   7, true, true, current_timestamp()),
  ( 866, 'vw_SEG_ContractTrx'                        , 'Amount'                                    , 'trx_amount'                                , 'DECIMAL(18,4)'       ,   8, true, true, current_timestamp()),
  ( 867, 'vw_SEG_ContractTrx'                        , 'Status'                                    , 'trx_status'                                , 'STRING'              ,   9, true, true, current_timestamp()),
  ( 868, 'vw_SEG_ContractTrx'                        , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,  10, false, true, current_timestamp()),
  ( 869, 'vw_SEG_ContractTrx'                        , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,  11, false, true, current_timestamp()),
  ( 870, 'vw_SEG_ContractTrx'                        , 'N/A'                                       , 'source_system'                             , 'STRING'              ,  12, false, true, current_timestamp()),
  ( 871, 'vw_SEG_ContractTrx'                        , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  13, false, true, current_timestamp()),
  ( 872, 'vw_SEG_ContractTrx'                        , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  14, false, true, current_timestamp());

-- [59] vw_SEG_ContractPrimarySegment (12 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 873, 'vw_SEG_ContractPrimarySegment'             , 'ContractPK'                                , 'contract_id'                               , 'INT'                 ,   1, true, true, current_timestamp()),
  ( 874, 'vw_SEG_ContractPrimarySegment'             , 'SegmentPK'                                 , 'segment_id'                                , 'INT'                 ,   2, true, true, current_timestamp()),
  ( 875, 'vw_SEG_ContractPrimarySegment'             , 'ContractNumber'                            , 'contract_number'                           , 'STRING'              ,   3, true, true, current_timestamp()),
  ( 876, 'vw_SEG_ContractPrimarySegment'             , 'SegmentNumber'                             , 'segment_number'                            , 'INT'                 ,   4, true, true, current_timestamp()),
  ( 877, 'vw_SEG_ContractPrimarySegment'             , 'EffectiveDate'                             , 'effective_date'                            , 'TIMESTAMP'           ,   5, true, true, current_timestamp()),
  ( 878, 'vw_SEG_ContractPrimarySegment'             , 'CostBasis'                                 , 'cost_basis'                                , 'DECIMAL(18,4)'       ,   6, true, true, current_timestamp()),
  ( 879, 'vw_SEG_ContractPrimarySegment'             , 'FreeAmount'                                , 'free_amount'                               , 'DECIMAL(18,4)'       ,   7, true, true, current_timestamp()),
  ( 880, 'vw_SEG_ContractPrimarySegment'             , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,   8, false, true, current_timestamp()),
  ( 881, 'vw_SEG_ContractPrimarySegment'             , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,   9, false, true, current_timestamp()),
  ( 882, 'vw_SEG_ContractPrimarySegment'             , 'N/A'                                       , 'source_system'                             , 'STRING'              ,  10, false, true, current_timestamp()),
  ( 883, 'vw_SEG_ContractPrimarySegment'             , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  11, false, true, current_timestamp()),
  ( 884, 'vw_SEG_ContractPrimarySegment'             , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  12, false, true, current_timestamp());

-- [60] vw_SEG_Agent (15 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 885, 'vw_SEG_Agent'                              , 'AgentPK'                                   , 'agent_id'                                  , 'INT'                 ,   1, true, true, current_timestamp()),
  ( 886, 'vw_SEG_Agent'                              , 'AgentNumber'                               , 'agent_number'                              , 'STRING'              ,   2, true, true, current_timestamp()),
  ( 887, 'vw_SEG_Agent'                              , 'DisplayName'                               , 'display_name'                              , 'STRING'              ,   3, true, true, current_timestamp()),
  ( 888, 'vw_SEG_Agent'                              , 'NPN'                                       , 'npn_number'                                , 'STRING'              ,   4, true, true, current_timestamp()),
  ( 889, 'vw_SEG_Agent'                              , 'NASD'                                      , 'nasd_number'                               , 'STRING'              ,   5, true, true, current_timestamp()),
  ( 890, 'vw_SEG_Agent'                              , 'AgentType'                                 , 'agent_type'                                , 'STRING'              ,   6, true, true, current_timestamp()),
  ( 891, 'vw_SEG_Agent'                              , 'Status'                                    , 'status'                                    , 'STRING'              ,   7, true, true, current_timestamp()),
  ( 892, 'vw_SEG_Agent'                              , 'HireDate'                                  , 'hire_date'                                 , 'TIMESTAMP'           ,   8, true, true, current_timestamp()),
  ( 893, 'vw_SEG_Agent'                              , 'TerminationDate'                           , 'termination_date'                          , 'TIMESTAMP'           ,   9, true, true, current_timestamp()),
  ( 894, 'vw_SEG_Agent'                              , 'ClientFK'                                  , 'client_id'                                 , 'INT'                 ,  10, true, true, current_timestamp()),
  ( 895, 'vw_SEG_Agent'                              , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,  11, false, true, current_timestamp()),
  ( 896, 'vw_SEG_Agent'                              , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,  12, false, true, current_timestamp()),
  ( 897, 'vw_SEG_Agent'                              , 'N/A'                                       , 'source_system'                             , 'STRING'              ,  13, false, true, current_timestamp()),
  ( 898, 'vw_SEG_Agent'                              , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  14, false, true, current_timestamp()),
  ( 899, 'vw_SEG_Agent'                              , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  15, false, true, current_timestamp());

-- [61] vw_SEG_Client (16 columns)
INSERT INTO schema_config
    (id, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 900, 'vw_SEG_Client'                             , 'ClientPK'                                  , 'client_id'                                 , 'INT'                 ,   1, true, true, current_timestamp()),
  ( 901, 'vw_SEG_Client'                             , 'SourceKey'                                 , 'source_key'                                , 'BIGINT'              ,   2, true, true, current_timestamp()),
  ( 902, 'vw_SEG_Client'                             , 'DisplayName'                               , 'display_name'                              , 'STRING'              ,   3, true, true, current_timestamp()),
  ( 903, 'vw_SEG_Client'                             , 'FirstName'                                 , 'first_name'                                , 'STRING'              ,   4, true, true, current_timestamp()),
  ( 904, 'vw_SEG_Client'                             , 'LastName'                                  , 'last_name'                                 , 'STRING'              ,   5, true, true, current_timestamp()),
  ( 905, 'vw_SEG_Client'                             , 'Email'                                     , 'email_address'                             , 'STRING'              ,   6, true, true, current_timestamp()),
  ( 906, 'vw_SEG_Client'                             , 'Phone'                                     , 'phone_number'                              , 'STRING'              ,   7, true, true, current_timestamp()),
  ( 907, 'vw_SEG_Client'                             , 'BirthDate'                                 , 'birth_date'                                , 'TIMESTAMP'           ,   8, true, true, current_timestamp()),
  ( 908, 'vw_SEG_Client'                             , 'Status'                                    , 'status'                                    , 'STRING'              ,   9, true, true, current_timestamp()),
  ( 909, 'vw_SEG_Client'                             , 'State'                                     , 'state_code'                                , 'STRING'              ,  10, true, true, current_timestamp()),
  ( 910, 'vw_SEG_Client'                             , 'ZipCode'                                   , 'zip_code'                                  , 'STRING'              ,  11, true, true, current_timestamp()),
  ( 911, 'vw_SEG_Client'                             , 'N/A'                                       , 'ingestion_date'                            , 'DATE'                ,  12, false, true, current_timestamp()),
  ( 912, 'vw_SEG_Client'                             , 'N/A'                                       , 'data_date'                                 , 'DATE'                ,  13, false, true, current_timestamp()),
  ( 913, 'vw_SEG_Client'                             , 'N/A'                                       , 'source_system'                             , 'STRING'              ,  14, false, true, current_timestamp()),
  ( 914, 'vw_SEG_Client'                             , 'N/A'                                       , 'ingestion_run_id'                          , 'STRING'              ,  15, false, true, current_timestamp()),
  ( 915, 'vw_SEG_Client'                             , 'N/A'                                       , 'ingestion_timestamp'                       , 'TIMESTAMP'           ,  16, false, true, current_timestamp());

-- Total: 915 column mappings across 61 source tables