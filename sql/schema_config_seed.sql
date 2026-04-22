-- ============================================================
-- schema_config seed data — EQ_Warehouse source system
-- Generated from: EquiTrust_Data_Source_Intake_Template_eqWarehouse.xlsx
-- Target table  : control.schema_config
-- Columns       : id, source_name, source_table_name, target_table_name, source_column_name,
--                 target_column_name, target_data_type,
--                 ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at
-- ============================================================

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

-- [54] vw_SEG_ContractClient (12 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  ( 793, 'EQ_Warehouse', 'vw_SEG_ContractClient'                     , 'vw_seg_contract_client_base', 'ContractPK'                                , 'contract_id'                               , 'INT'                 ,   1, 1, 0, 1, GETUTCDATE()),
  ( 794, 'EQ_Warehouse', 'vw_SEG_ContractClient'                     , 'vw_seg_contract_client_base', 'ClientFK'                                  , 'client_id'                                 , 'INT'                 ,   2, 1, 0, 1, GETUTCDATE()),
  ( 795, 'EQ_Warehouse', 'vw_SEG_ContractClient'                     , 'vw_seg_contract_client_base', 'RoleName'                                  , 'client_role_name'                          , 'STRING'              ,   3, 1, 0, 1, GETUTCDATE()),
  ( 796, 'EQ_Warehouse', 'vw_SEG_ContractClient'                     , 'vw_seg_contract_client_base', 'Relationship'                              , 'relationship_to_insured'                   , 'STRING'              ,   4, 1, 0, 1, GETUTCDATE()),
  ( 797, 'EQ_Warehouse', 'vw_SEG_ContractClient'                     , 'vw_seg_contract_client_base', 'AllocationPercent'                         , 'share_percentage'                          , 'DECIMAL(18,4)'       ,   5, 1, 0, 1, GETUTCDATE()),
  ( 798, 'EQ_Warehouse', 'vw_SEG_ContractClient'                     , 'vw_seg_contract_client_base', 'Status'                                    , 'status'                                    , 'STRING'              ,   6, 1, 0, 1, GETUTCDATE());

-- [55] vw_SEG_ContractTreaty (12 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  ( 804, 'EQ_Warehouse', 'vw_SEG_ContractTreaty'                     , 'vw_seg_contract_treaty_base', 'ContractPK'                                , 'contract_id'                               , 'INT'                 ,   1, 1, 0, 1, GETUTCDATE()),
  ( 805, 'EQ_Warehouse', 'vw_SEG_ContractTreaty'                     , 'vw_seg_contract_treaty_base', 'TreatyPK'                                  , 'treaty_id'                                 , 'INT'                 ,   2, 1, 0, 1, GETUTCDATE()),
  ( 806, 'EQ_Warehouse', 'vw_SEG_ContractTreaty'                     , 'vw_seg_contract_treaty_base', 'ContractNumber'                            , 'contract_number'                           , 'STRING'              ,   3, 1, 0, 1, GETUTCDATE()),
  ( 807, 'EQ_Warehouse', 'vw_SEG_ContractTreaty'                     , 'vw_seg_contract_treaty_base', 'TreatyName'                                , 'treaty_name'                               , 'STRING'              ,   4, 1, 0, 1, GETUTCDATE()),
  ( 808, 'EQ_Warehouse', 'vw_SEG_ContractTreaty'                     , 'vw_seg_contract_treaty_base', 'TreatyDescription'                         , 'treaty_description'                        , 'STRING'              ,   5, 1, 0, 1, GETUTCDATE()),
  ( 809, 'EQ_Warehouse', 'vw_SEG_ContractTreaty'                     , 'vw_seg_contract_treaty_base', 'EffectiveDate'                             , 'effective_date'                            , 'TIMESTAMP'           ,   6, 1, 0, 1, GETUTCDATE()),
  ( 810, 'EQ_Warehouse', 'vw_SEG_ContractTreaty'                     , 'vw_seg_contract_treaty_base', 'Status'                                    , 'status'                                    , 'STRING'              ,   7, 1, 0, 1, GETUTCDATE());

-- [56] vw_SEG_ContractRider (28 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  ( 816, 'EQ_Warehouse', 'vw_SEG_ContractRider'                      , 'vw_seg_contract_rider_base', 'RiderGroupKey'                             , 'rider_group_id'                            , 'INT'                 ,   1, 1, 0, 1, GETUTCDATE()),
  ( 817, 'EQ_Warehouse', 'vw_SEG_ContractRider'                      , 'vw_seg_contract_rider_base', 'IBREligibilityDate'                        , 'ibr_eligibility_date'                      , 'TIMESTAMP'           ,   2, 1, 0, 1, GETUTCDATE()),
  ( 818, 'EQ_Warehouse', 'vw_SEG_ContractRider'                      , 'vw_seg_contract_rider_base', 'IBRStartDate'                              , 'ibr_start_date'                            , 'TIMESTAMP'           ,   3, 1, 0, 1, GETUTCDATE()),
  ( 819, 'EQ_Warehouse', 'vw_SEG_ContractRider'                      , 'vw_seg_contract_rider_base', 'ABR'                                       , 'abr_stop_date'                             , 'TIMESTAMP'           ,   4, 1, 0, 1, GETUTCDATE()),
  ( 820, 'EQ_Warehouse', 'vw_SEG_ContractRider'                      , 'vw_seg_contract_rider_base', 'ABR-TI'                                    , 'abr_ti_stop_date'                          , 'TIMESTAMP'           ,   5, 1, 0, 1, GETUTCDATE()),
  ( 821, 'EQ_Warehouse', 'vw_SEG_ContractRider'                      , 'vw_seg_contract_rider_base', 'AVGuarRider'                               , 'av_guar_rider_stop_date'                   , 'TIMESTAMP'           ,   6, 1, 0, 1, GETUTCDATE()),
  ( 822, 'EQ_Warehouse', 'vw_SEG_ContractRider'                      , 'vw_seg_contract_rider_base', 'IBR'                                       , 'ibr_stop_date'                             , 'TIMESTAMP'           ,   7, 1, 0, 1, GETUTCDATE()),
  ( 823, 'EQ_Warehouse', 'vw_SEG_ContractRider'                      , 'vw_seg_contract_rider_base', 'IBR-SD'                                    , 'ibr_sd_stop_date'                          , 'TIMESTAMP'           ,   8, 1, 0, 1, GETUTCDATE()),
  ( 824, 'EQ_Warehouse', 'vw_SEG_ContractRider'                      , 'vw_seg_contract_rider_base', 'IBR-ST'                                    , 'ibr_st_stop_date'                          , 'TIMESTAMP'           ,   9, 1, 0, 1, GETUTCDATE()),
  ( 825, 'EQ_Warehouse', 'vw_SEG_ContractRider'                      , 'vw_seg_contract_rider_base', 'InflationRider'                            , 'inflation_rider_stop_date'                 , 'TIMESTAMP'           ,  10, 1, 0, 1, GETUTCDATE()),
  ( 826, 'EQ_Warehouse', 'vw_SEG_ContractRider'                      , 'vw_seg_contract_rider_base', 'LIQ'                                       , 'liq_stop_date'                             , 'TIMESTAMP'           ,  11, 1, 0, 1, GETUTCDATE()),
  ( 827, 'EQ_Warehouse', 'vw_SEG_ContractRider'                      , 'vw_seg_contract_rider_base', 'LongevityRider'                            , 'longevity_rider_stop_date'                 , 'TIMESTAMP'           ,  12, 1, 0, 1, GETUTCDATE()),
  ( 828, 'EQ_Warehouse', 'vw_SEG_ContractRider'                      , 'vw_seg_contract_rider_base', 'LTCRider'                                  , 'ltc_rider_stop_date'                       , 'TIMESTAMP'           ,  13, 1, 0, 1, GETUTCDATE()),
  ( 829, 'EQ_Warehouse', 'vw_SEG_ContractRider'                      , 'vw_seg_contract_rider_base', 'MVA'                                       , 'mva_stop_date'                             , 'TIMESTAMP'           ,  14, 1, 0, 1, GETUTCDATE()),
  ( 830, 'EQ_Warehouse', 'vw_SEG_ContractRider'                      , 'vw_seg_contract_rider_base', 'NFRider'                                   , 'nf_rider_stop_date'                        , 'TIMESTAMP'           ,  15, 1, 0, 1, GETUTCDATE()),
  ( 831, 'EQ_Warehouse', 'vw_SEG_ContractRider'                      , 'vw_seg_contract_rider_base', 'NursingHomeWaiver'                         , 'nursing_home_waiver_stop_date'             , 'TIMESTAMP'           ,  16, 1, 0, 1, GETUTCDATE()),
  ( 832, 'EQ_Warehouse', 'vw_SEG_ContractRider'                      , 'vw_seg_contract_rider_base', 'OP'                                        , 'op_stop_date'                              , 'TIMESTAMP'           ,  17, 1, 0, 1, GETUTCDATE()),
  ( 833, 'EQ_Warehouse', 'vw_SEG_ContractRider'                      , 'vw_seg_contract_rider_base', 'ROP'                                       , 'rop_stop_date'                             , 'TIMESTAMP'           ,  18, 1, 0, 1, GETUTCDATE()),
  ( 834, 'EQ_Warehouse', 'vw_SEG_ContractRider'                      , 'vw_seg_contract_rider_base', 'SR'                                        , 'sr_stop_date'                              , 'TIMESTAMP'           ,  19, 1, 0, 1, GETUTCDATE()),
  ( 835, 'EQ_Warehouse', 'vw_SEG_ContractRider'                      , 'vw_seg_contract_rider_base', 'TIR'                                       , 'tir_stop_date'                             , 'TIMESTAMP'           ,  20, 1, 0, 1, GETUTCDATE()),
  ( 836, 'EQ_Warehouse', 'vw_SEG_ContractRider'                      , 'vw_seg_contract_rider_base', 'WellnessCredits'                           , 'wellness_credits_stop_date'                , 'TIMESTAMP'           ,  21, 1, 0, 1, GETUTCDATE()),
  ( 837, 'EQ_Warehouse', 'vw_SEG_ContractRider'                      , 'vw_seg_contract_rider_base', 'WellnessRider'                             , 'wellness_rider_stop_date'                  , 'TIMESTAMP'           ,  22, 1, 0, 1, GETUTCDATE()),
  ( 838, 'EQ_Warehouse', 'vw_SEG_ContractRider'                      , 'vw_seg_contract_rider_base', 'WSC'                                       , 'wsc_stop_date'                             , 'TIMESTAMP'           ,  23, 1, 0, 1, GETUTCDATE());

-- [57] ref_Product (15 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  ( 845, 'EQ_Warehouse', 'ref_Product'                               , 'ref_product_base', 'ProductPK'                                 , 'product_id'                                , 'INT'                 ,   1, 1, 1, 1, GETUTCDATE()),
  ( 846, 'EQ_Warehouse', 'ref_Product'                               , 'ref_product_base', 'ProductName'                               , 'product_name'                              , 'STRING'              ,   2, 1, 0, 1, GETUTCDATE()),
  ( 847, 'EQ_Warehouse', 'ref_Product'                               , 'ref_product_base', 'MarketingName'                             , 'marketing_name'                            , 'STRING'              ,   3, 1, 0, 1, GETUTCDATE()),
  ( 848, 'EQ_Warehouse', 'ref_Product'                               , 'ref_product_base', 'ProductType'                               , 'product_type'                              , 'STRING'              ,   4, 1, 0, 1, GETUTCDATE()),
  ( 849, 'EQ_Warehouse', 'ref_Product'                               , 'ref_product_base', 'CUSIPNumber'                               , 'cusip_number'                              , 'STRING'              ,   5, 1, 0, 1, GETUTCDATE()),
  ( 850, 'EQ_Warehouse', 'ref_Product'                               , 'ref_product_base', 'Context'                                   , 'product_context'                           , 'STRING'              ,   6, 1, 0, 1, GETUTCDATE()),
  ( 851, 'EQ_Warehouse', 'ref_Product'                               , 'ref_product_base', 'GLLOB'                                     , 'gl_line_of_business'                       , 'STRING'              ,   7, 1, 0, 1, GETUTCDATE()),
  ( 852, 'EQ_Warehouse', 'ref_Product'                               , 'ref_product_base', 'Status'                                    , 'status'                                    , 'STRING'              ,   8, 1, 0, 1, GETUTCDATE()),
  ( 853, 'EQ_Warehouse', 'ref_Product'                               , 'ref_product_base', 'EffectiveDate'                             , 'effective_date'                            , 'TIMESTAMP'           ,  9, 1, 0, 1, GETUTCDATE());

-- [58] vw_SEG_ContractTrx (14 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  ( 859, 'EQ_Warehouse', 'vw_SEG_ContractTrx'                        , 'vw_seg_contract_trx_base', 'TrxPK'                                     , 'trx_id'                                    , 'BIGINT'              ,   1, 1, 1, 1, GETUTCDATE()),
  ( 860, 'EQ_Warehouse', 'vw_SEG_ContractTrx'                        , 'vw_seg_contract_trx_base', 'ContractPK'                                , 'contract_id'                               , 'INT'                 ,   2, 1, 0, 1, GETUTCDATE()),
  ( 861, 'EQ_Warehouse', 'vw_SEG_ContractTrx'                        , 'vw_seg_contract_trx_base', 'ContractNumber'                            , 'contract_number'                           , 'STRING'              ,   3, 1, 0, 1, GETUTCDATE()),
  ( 862, 'EQ_Warehouse', 'vw_SEG_ContractTrx'                        , 'vw_seg_contract_trx_base', 'TrxType'                                   , 'trx_type_code'                             , 'STRING'              ,   4, 1, 0, 1, GETUTCDATE()),
  ( 863, 'EQ_Warehouse', 'vw_SEG_ContractTrx'                        , 'vw_seg_contract_trx_base', 'TrxDescription'                            , 'trx_description'                           , 'STRING'              ,   5, 1, 0, 1, GETUTCDATE()),
  ( 864, 'EQ_Warehouse', 'vw_SEG_ContractTrx'                        , 'vw_seg_contract_trx_base', 'EffectiveDate'                             , 'effective_date'                            , 'TIMESTAMP'           ,   6, 1, 0, 1, GETUTCDATE()),
  ( 865, 'EQ_Warehouse', 'vw_SEG_ContractTrx'                        , 'vw_seg_contract_trx_base', 'ProcessDate'                               , 'process_date'                              , 'TIMESTAMP'           ,   7, 1, 0, 1, GETUTCDATE()),
  ( 866, 'EQ_Warehouse', 'vw_SEG_ContractTrx'                        , 'vw_seg_contract_trx_base', 'Amount'                                    , 'trx_amount'                                , 'DECIMAL(18,4)'       ,   8, 1, 0, 1, GETUTCDATE()),
  ( 867, 'EQ_Warehouse', 'vw_SEG_ContractTrx'                        , 'vw_seg_contract_trx_base', 'Status'                                    , 'trx_status'                                , 'STRING'              ,   9, 1, 0, 1, GETUTCDATE());

-- [59] vw_SEG_ContractPrimarySegment (12 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  ( 873, 'EQ_Warehouse', 'vw_SEG_ContractPrimarySegment'             , 'vw_seg_contract_primary_segment_base', 'ContractPK'                                , 'contract_id'                               , 'INT'                 ,   1, 1, 1, 1, GETUTCDATE()),
  ( 874, 'EQ_Warehouse', 'vw_SEG_ContractPrimarySegment'             , 'vw_seg_contract_primary_segment_base', 'SegmentPK'                                 , 'segment_id'                                , 'INT'                 ,   2, 1, 0, 1, GETUTCDATE()),
  ( 875, 'EQ_Warehouse', 'vw_SEG_ContractPrimarySegment'             , 'vw_seg_contract_primary_segment_base', 'ContractNumber'                            , 'contract_number'                           , 'STRING'              ,   3, 1, 0, 1, GETUTCDATE()),
  ( 876, 'EQ_Warehouse', 'vw_SEG_ContractPrimarySegment'             , 'vw_seg_contract_primary_segment_base', 'SegmentNumber'                             , 'segment_number'                            , 'INT'                 ,   4, 1, 0, 1, GETUTCDATE()),
  ( 877, 'EQ_Warehouse', 'vw_SEG_ContractPrimarySegment'             , 'vw_seg_contract_primary_segment_base', 'EffectiveDate'                             , 'effective_date'                            , 'TIMESTAMP'           ,   5, 1, 0, 1, GETUTCDATE()),
  ( 878, 'EQ_Warehouse', 'vw_SEG_ContractPrimarySegment'             , 'vw_seg_contract_primary_segment_base', 'CostBasis'                                 , 'cost_basis'                                , 'DECIMAL(18,4)'       ,   6, 1, 0, 1, GETUTCDATE()),
  ( 879, 'EQ_Warehouse', 'vw_SEG_ContractPrimarySegment'             , 'vw_seg_contract_primary_segment_base', 'FreeAmount'                                , 'free_amount'                               , 'DECIMAL(18,4)'       ,   7, 1, 0, 1, GETUTCDATE());

-- [60] vw_SEG_Agent (15 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  ( 885, 'EQ_Warehouse', 'vw_SEG_Agent'                              , 'vw_seg_agent_base', 'AgentPK'                                   , 'agent_id'                                  , 'INT'                 ,   1, 1, 1, 1, GETUTCDATE()),
  ( 886, 'EQ_Warehouse', 'vw_SEG_Agent'                              , 'vw_seg_agent_base', 'AgentNumber'                               , 'agent_number'                              , 'STRING'              ,   2, 1, 0, 1, GETUTCDATE()),
  ( 887, 'EQ_Warehouse', 'vw_SEG_Agent'                              , 'vw_seg_agent_base', 'DisplayName'                               , 'display_name'                              , 'STRING'              ,   3, 1, 0, 1, GETUTCDATE()),
  ( 888, 'EQ_Warehouse', 'vw_SEG_Agent'                              , 'vw_seg_agent_base', 'NPN'                                       , 'npn_number'                                , 'STRING'              ,   4, 1, 0, 1, GETUTCDATE()),
  ( 889, 'EQ_Warehouse', 'vw_SEG_Agent'                              , 'vw_seg_agent_base', 'NASD'                                      , 'nasd_number'                               , 'STRING'              ,   5, 1, 0, 1, GETUTCDATE()),
  ( 890, 'EQ_Warehouse', 'vw_SEG_Agent'                              , 'vw_seg_agent_base', 'AgentType'                                 , 'agent_type'                                , 'STRING'              ,   6, 1, 0, 1, GETUTCDATE()),
  ( 891, 'EQ_Warehouse', 'vw_SEG_Agent'                              , 'vw_seg_agent_base', 'Status'                                    , 'status'                                    , 'STRING'              ,   7, 1, 0, 1, GETUTCDATE()),
  ( 892, 'EQ_Warehouse', 'vw_SEG_Agent'                              , 'vw_seg_agent_base', 'HireDate'                                  , 'hire_date'                                 , 'TIMESTAMP'           ,   8, 1, 0, 1, GETUTCDATE()),
  ( 893, 'EQ_Warehouse', 'vw_SEG_Agent'                              , 'vw_seg_agent_base', 'TerminationDate'                           , 'termination_date'                          , 'TIMESTAMP'           ,   9, 1, 0, 1, GETUTCDATE()),
  ( 894, 'EQ_Warehouse', 'vw_SEG_Agent'                              , 'vw_seg_agent_base', 'ClientFK'                                  , 'client_id'                                 , 'INT'                 ,  10, 1, 0, 1, GETUTCDATE());

-- [61] vw_SEG_Client (16 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  ( 900, 'EQ_Warehouse', 'vw_SEG_Client'                             , 'vw_seg_client_base', 'ClientPK'                                  , 'client_id'                                 , 'INT'                 ,   1, 1, 1, 1, GETUTCDATE()),
  ( 901, 'EQ_Warehouse', 'vw_SEG_Client'                             , 'vw_seg_client_base', 'SourceKey'                                 , 'source_key'                                , 'BIGINT'              ,   2, 1, 0, 1, GETUTCDATE()),
  ( 902, 'EQ_Warehouse', 'vw_SEG_Client'                             , 'vw_seg_client_base', 'DisplayName'                               , 'display_name'                              , 'STRING'              ,   3, 1, 0, 1, GETUTCDATE()),
  ( 903, 'EQ_Warehouse', 'vw_SEG_Client'                             , 'vw_seg_client_base', 'FirstName'                                 , 'first_name'                                , 'STRING'              ,   4, 1, 0, 1, GETUTCDATE()),
  ( 904, 'EQ_Warehouse', 'vw_SEG_Client'                             , 'vw_seg_client_base', 'LastName'                                  , 'last_name'                                 , 'STRING'              ,   5, 1, 0, 1, GETUTCDATE()),
  ( 905, 'EQ_Warehouse', 'vw_SEG_Client'                             , 'vw_seg_client_base', 'Email'                                     , 'email_address'                             , 'STRING'              ,   6, 1, 0, 1, GETUTCDATE()),
  ( 906, 'EQ_Warehouse', 'vw_SEG_Client'                             , 'vw_seg_client_base', 'Phone'                                     , 'phone_number'                              , 'STRING'              ,   7, 1, 0, 1, GETUTCDATE()),
  ( 907, 'EQ_Warehouse', 'vw_SEG_Client'                             , 'vw_seg_client_base', 'BirthDate'                                 , 'birth_date'                                , 'TIMESTAMP'           ,   8, 1, 0, 1, GETUTCDATE()),
  ( 908, 'EQ_Warehouse', 'vw_SEG_Client'                             , 'vw_seg_client_base', 'Status'                                    , 'status'                                    , 'STRING'              ,   9, 1, 0, 1, GETUTCDATE()),
  ( 909, 'EQ_Warehouse', 'vw_SEG_Client'                             , 'vw_seg_client_base', 'State'                                     , 'state_code'                                , 'STRING'              ,  10, 1, 0, 1, GETUTCDATE()),
  ( 910, 'EQ_Warehouse', 'vw_SEG_Client'                             , 'vw_seg_client_base', 'ZipCode'                                   , 'zip_code'                                  , 'STRING'              ,  11, 1, 0, 1, GETUTCDATE());

-- Total: ~1000 column mappings across 61 source tables (EQ_Warehouse) + HubSpot


-- ============================================================
-- HubSpot source — schema_config seed data
-- IDs 911–1085  (175 rows across 14 landing tables)
-- source_name = 'HubSpot'
-- source_column_name = API JSON field path (camelCase / dot-notation)
-- target_column_name = landing Delta column (snake_case)
-- include_in_md5hash: 0 for JSON blobs and URL-context columns, 1 for all others
-- ============================================================

-- [H01] marketing_events (22 fields)
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  ( 911, 'HubSpot', 'marketing_events', 'marketing_events', 'objectId',         'object_id',          'STRING',   1, 1, 1, 1, GETUTCDATE()),
  ( 912, 'HubSpot', 'marketing_events', 'marketing_events', 'externalEventId',  'external_event_id',  'STRING',   2, 1, 0, 1, GETUTCDATE()),
  ( 913, 'HubSpot', 'marketing_events', 'marketing_events', 'eventName',        'event_name',         'STRING',   3, 1, 0, 1, GETUTCDATE()),
  ( 914, 'HubSpot', 'marketing_events', 'marketing_events', 'eventType',        'event_type',         'STRING',   4, 1, 0, 1, GETUTCDATE()),
  ( 915, 'HubSpot', 'marketing_events', 'marketing_events', 'eventStatus',      'event_status',       'STRING',   5, 1, 0, 1, GETUTCDATE()),
  ( 916, 'HubSpot', 'marketing_events', 'marketing_events', 'eventStatusV2',    'event_status_v2',    'STRING',   6, 1, 0, 1, GETUTCDATE()),
  ( 917, 'HubSpot', 'marketing_events', 'marketing_events', 'startDateTime',    'start_date_time',    'STRING',   7, 1, 0, 1, GETUTCDATE()),
  ( 918, 'HubSpot', 'marketing_events', 'marketing_events', 'endDateTime',      'end_date_time',      'STRING',   8, 1, 0, 1, GETUTCDATE()),
  ( 919, 'HubSpot', 'marketing_events', 'marketing_events', 'eventOrganizer',   'event_organizer',    'STRING',   9, 1, 0, 1, GETUTCDATE()),
  ( 920, 'HubSpot', 'marketing_events', 'marketing_events', 'eventDescription', 'event_description',  'STRING',  10, 1, 0, 1, GETUTCDATE()),
  ( 921, 'HubSpot', 'marketing_events', 'marketing_events', 'eventUrl',         'event_url',          'STRING',  11, 1, 0, 1, GETUTCDATE()),
  ( 922, 'HubSpot', 'marketing_events', 'marketing_events', 'eventCancelled',   'event_cancelled',    'BOOLEAN', 12, 1, 0, 1, GETUTCDATE()),
  ( 923, 'HubSpot', 'marketing_events', 'marketing_events', 'eventCompleted',   'event_completed',    'BOOLEAN', 13, 1, 0, 1, GETUTCDATE()),
  ( 924, 'HubSpot', 'marketing_events', 'marketing_events', 'registrants',      'registrants',        'INT',     14, 1, 0, 1, GETUTCDATE()),
  ( 925, 'HubSpot', 'marketing_events', 'marketing_events', 'attendees',        'attendees',          'INT',     15, 1, 0, 1, GETUTCDATE()),
  ( 926, 'HubSpot', 'marketing_events', 'marketing_events', 'cancellations',    'cancellations',      'INT',     16, 1, 0, 1, GETUTCDATE()),
  ( 927, 'HubSpot', 'marketing_events', 'marketing_events', 'noShows',          'no_shows',           'INT',     17, 1, 0, 1, GETUTCDATE()),
  ( 928, 'HubSpot', 'marketing_events', 'marketing_events', 'appInfo.id',       'app_info_id',        'STRING',  18, 1, 0, 1, GETUTCDATE()),
  ( 929, 'HubSpot', 'marketing_events', 'marketing_events', 'appInfo.name',     'app_info_name',      'STRING',  19, 1, 0, 1, GETUTCDATE()),
  ( 930, 'HubSpot', 'marketing_events', 'marketing_events', 'createdAt',        'created_at',         'STRING',  20, 1, 0, 1, GETUTCDATE()),
  ( 931, 'HubSpot', 'marketing_events', 'marketing_events', 'updatedAt',        'updated_at',         'STRING',  21, 1, 0, 1, GETUTCDATE()),
  ( 932, 'HubSpot', 'marketing_events', 'marketing_events', 'N/A',              'period',             'STRING',  22, 0, 0, 1, GETUTCDATE());

-- [H02] marketing_emails (53 fields)
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  ( 933, 'HubSpot', 'marketing_emails', 'marketing_emails', 'id',                                       'id',                                'STRING',   1, 1, 1, 1, GETUTCDATE()),
  ( 934, 'HubSpot', 'marketing_emails', 'marketing_emails', 'name',                                     'name',                              'STRING',   2, 1, 0, 1, GETUTCDATE()),
  ( 935, 'HubSpot', 'marketing_emails', 'marketing_emails', 'subject',                                  'subject',                           'STRING',   3, 1, 0, 1, GETUTCDATE()),
  ( 936, 'HubSpot', 'marketing_emails', 'marketing_emails', 'state',                                    'state',                             'STRING',   4, 1, 0, 1, GETUTCDATE()),
  ( 937, 'HubSpot', 'marketing_emails', 'marketing_emails', 'type',                                     'type',                              'STRING',   5, 1, 0, 1, GETUTCDATE()),
  ( 938, 'HubSpot', 'marketing_emails', 'marketing_emails', 'subcategory',                              'subcategory',                       'STRING',   6, 1, 0, 1, GETUTCDATE()),
  ( 939, 'HubSpot', 'marketing_emails', 'marketing_emails', 'language',                                 'language',                          'STRING',   7, 1, 0, 1, GETUTCDATE()),
  ( 940, 'HubSpot', 'marketing_emails', 'marketing_emails', 'archived',                                 'archived',                          'BOOLEAN',  8, 1, 0, 1, GETUTCDATE()),
  ( 941, 'HubSpot', 'marketing_emails', 'marketing_emails', 'isAb',                                     'is_ab',                             'BOOLEAN',  9, 1, 0, 1, GETUTCDATE()),
  ( 942, 'HubSpot', 'marketing_emails', 'marketing_emails', 'isPublished',                              'is_published',                      'BOOLEAN', 10, 1, 0, 1, GETUTCDATE()),
  ( 943, 'HubSpot', 'marketing_emails', 'marketing_emails', 'isTransactional',                          'is_transactional',                  'BOOLEAN', 11, 1, 0, 1, GETUTCDATE()),
  ( 944, 'HubSpot', 'marketing_emails', 'marketing_emails', 'sendOnPublish',                            'send_on_publish',                   'BOOLEAN', 12, 1, 0, 1, GETUTCDATE()),
  ( 945, 'HubSpot', 'marketing_emails', 'marketing_emails', 'jitterSendTime',                           'jitter_send_time',                  'BOOLEAN', 13, 1, 0, 1, GETUTCDATE()),
  ( 946, 'HubSpot', 'marketing_emails', 'marketing_emails', 'activeDomain',                             'active_domain',                     'STRING',  14, 1, 0, 1, GETUTCDATE()),
  ( 947, 'HubSpot', 'marketing_emails', 'marketing_emails', 'campaign',                                 'campaign',                          'STRING',  15, 1, 0, 1, GETUTCDATE()),
  ( 948, 'HubSpot', 'marketing_emails', 'marketing_emails', 'campaignName',                             'campaign_name',                     'STRING',  16, 1, 0, 1, GETUTCDATE()),
  ( 949, 'HubSpot', 'marketing_emails', 'marketing_emails', 'campaignUtm',                              'campaign_utm',                      'STRING',  17, 1, 0, 1, GETUTCDATE()),
  ( 950, 'HubSpot', 'marketing_emails', 'marketing_emails', 'emailCampaignGroupId',                     'email_campaign_group_id',           'STRING',  18, 1, 0, 1, GETUTCDATE()),
  ( 951, 'HubSpot', 'marketing_emails', 'marketing_emails', 'primaryEmailCampaignId',                   'primary_email_campaign_id',         'STRING',  19, 1, 0, 1, GETUTCDATE()),
  ( 952, 'HubSpot', 'marketing_emails', 'marketing_emails', 'emailTemplateMode',                        'email_template_mode',               'STRING',  20, 1, 0, 1, GETUTCDATE()),
  ( 953, 'HubSpot', 'marketing_emails', 'marketing_emails', 'feedbackSurveyId',                         'feedback_survey_id',                'STRING',  21, 1, 0, 1, GETUTCDATE()),
  ( 954, 'HubSpot', 'marketing_emails', 'marketing_emails', 'folderId',                                 'folder_id',                         'STRING',  22, 1, 0, 1, GETUTCDATE()),
  ( 955, 'HubSpot', 'marketing_emails', 'marketing_emails', 'businessUnitId',                           'business_unit_id',                  'STRING',  23, 1, 0, 1, GETUTCDATE()),
  ( 956, 'HubSpot', 'marketing_emails', 'marketing_emails', 'clonedFrom',                               'cloned_from',                       'STRING',  24, 1, 0, 1, GETUTCDATE()),
  ( 957, 'HubSpot', 'marketing_emails', 'marketing_emails', 'previewKey',                               'preview_key',                       'STRING',  25, 1, 0, 1, GETUTCDATE()),
  ( 958, 'HubSpot', 'marketing_emails', 'marketing_emails', 'publishDate',                              'publish_date',                      'STRING',  26, 1, 0, 1, GETUTCDATE()),
  ( 959, 'HubSpot', 'marketing_emails', 'marketing_emails', 'publishedAt',                              'published_at',                      'STRING',  27, 1, 0, 1, GETUTCDATE()),
  ( 960, 'HubSpot', 'marketing_emails', 'marketing_emails', 'unpublishedAt',                            'unpublished_at',                    'STRING',  28, 1, 0, 1, GETUTCDATE()),
  ( 961, 'HubSpot', 'marketing_emails', 'marketing_emails', 'publishedByEmail',                         'published_by_email',                'STRING',  29, 1, 0, 1, GETUTCDATE()),
  ( 962, 'HubSpot', 'marketing_emails', 'marketing_emails', 'publishedById',                            'published_by_id',                   'STRING',  30, 1, 0, 1, GETUTCDATE()),
  ( 963, 'HubSpot', 'marketing_emails', 'marketing_emails', 'publishedByName',                          'published_by_name',                 'STRING',  31, 1, 0, 1, GETUTCDATE()),
  ( 964, 'HubSpot', 'marketing_emails', 'marketing_emails', 'createdAt',                                'created_at',                        'STRING',  32, 1, 0, 1, GETUTCDATE()),
  ( 965, 'HubSpot', 'marketing_emails', 'marketing_emails', 'createdById',                              'created_by_id',                     'STRING',  33, 1, 0, 1, GETUTCDATE()),
  ( 966, 'HubSpot', 'marketing_emails', 'marketing_emails', 'deletedAt',                                'deleted_at',                        'STRING',  34, 1, 0, 1, GETUTCDATE()),
  ( 967, 'HubSpot', 'marketing_emails', 'marketing_emails', 'updatedAt',                                'updated_at',                        'STRING',  35, 1, 0, 1, GETUTCDATE()),
  ( 968, 'HubSpot', 'marketing_emails', 'marketing_emails', 'updatedById',                              'updated_by_id',                     'STRING',  36, 1, 0, 1, GETUTCDATE()),
  ( 969, 'HubSpot', 'marketing_emails', 'marketing_emails', 'from.fromName',                            'from_name',                         'STRING',  37, 1, 0, 1, GETUTCDATE()),
  ( 970, 'HubSpot', 'marketing_emails', 'marketing_emails', 'from.replyTo',                             'from_reply_to',                     'STRING',  38, 1, 0, 1, GETUTCDATE()),
  ( 971, 'HubSpot', 'marketing_emails', 'marketing_emails', 'from.customReplyTo',                       'from_custom_reply_to',              'STRING',  39, 1, 0, 1, GETUTCDATE()),
  ( 972, 'HubSpot', 'marketing_emails', 'marketing_emails', 'subscriptionDetails.subscriptionId',       'subscription_id',                   'STRING',  40, 1, 0, 1, GETUTCDATE()),
  ( 973, 'HubSpot', 'marketing_emails', 'marketing_emails', 'subscriptionDetails.subscriptionName',     'subscription_name',                 'STRING',  41, 1, 0, 1, GETUTCDATE()),
  ( 974, 'HubSpot', 'marketing_emails', 'marketing_emails', 'subscriptionDetails.officeLocationId',     'subscription_office_location_id',   'STRING',  42, 1, 0, 1, GETUTCDATE()),
  ( 975, 'HubSpot', 'marketing_emails', 'marketing_emails', 'subscriptionDetails.preferencesGroupId',   'subscription_preferences_group_id', 'STRING',  43, 1, 0, 1, GETUTCDATE()),
  ( 976, 'HubSpot', 'marketing_emails', 'marketing_emails', 'webversion.url',                           'webversion_url',                    'STRING',  44, 1, 0, 1, GETUTCDATE()),
  ( 977, 'HubSpot', 'marketing_emails', 'marketing_emails', 'webversion.enabled',                       'webversion_enabled',                'BOOLEAN', 45, 1, 0, 1, GETUTCDATE()),
  ( 978, 'HubSpot', 'marketing_emails', 'marketing_emails', 'content',                                  'content_json',                      'STRING',  46, 0, 0, 1, GETUTCDATE()),
  ( 979, 'HubSpot', 'marketing_emails', 'marketing_emails', 'stats',                                    'stats_json',                        'STRING',  47, 0, 0, 1, GETUTCDATE()),
  ( 980, 'HubSpot', 'marketing_emails', 'marketing_emails', 'testing',                                  'testing_json',                      'STRING',  48, 0, 0, 1, GETUTCDATE()),
  ( 981, 'HubSpot', 'marketing_emails', 'marketing_emails', 'rssData',                                  'rss_data_json',                     'STRING',  49, 0, 0, 1, GETUTCDATE()),
  ( 982, 'HubSpot', 'marketing_emails', 'marketing_emails', 'to',                                       'to_json',                           'STRING',  50, 0, 0, 1, GETUTCDATE()),
  ( 983, 'HubSpot', 'marketing_emails', 'marketing_emails', 'allEmailCampaignIds',                      'all_email_campaign_ids_json',       'STRING',  51, 0, 0, 1, GETUTCDATE()),
  ( 984, 'HubSpot', 'marketing_emails', 'marketing_emails', 'teamsWithAccess',                          'teams_with_access_json',            'STRING',  52, 0, 0, 1, GETUTCDATE()),
  ( 985, 'HubSpot', 'marketing_emails', 'marketing_emails', 'workflowNames',                            'workflow_names_json',               'STRING',  53, 0, 0, 1, GETUTCDATE());

-- [H03] events_event_types (1 field)
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  ( 986, 'HubSpot', 'events_event_types', 'events_event_types', 'eventTypes[]', 'event_type', 'STRING', 1, 1, 1, 1, GETUTCDATE());

-- [H04–H14] CRM Objects — shared field set (9 fields × 11 object types)
-- source_column_name = landing column (already flattened); properties are stored as JSON blob

-- [H04] crm_contacts
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  ( 987, 'HubSpot', 'crm_contacts', 'crm_contacts', 'id',                   'id',                    'STRING',   1, 1, 1, 1, GETUTCDATE()),
  ( 988, 'HubSpot', 'crm_contacts', 'crm_contacts', 'createdAt',            'created_at',             'STRING',   2, 1, 0, 1, GETUTCDATE()),
  ( 989, 'HubSpot', 'crm_contacts', 'crm_contacts', 'updatedAt',            'updated_at',             'STRING',   3, 1, 0, 1, GETUTCDATE()),
  ( 990, 'HubSpot', 'crm_contacts', 'crm_contacts', 'archived',             'archived',               'BOOLEAN',  4, 1, 0, 1, GETUTCDATE()),
  ( 991, 'HubSpot', 'crm_contacts', 'crm_contacts', 'archivedAt',           'archived_at',            'STRING',   5, 1, 0, 1, GETUTCDATE()),
  ( 992, 'HubSpot', 'crm_contacts', 'crm_contacts', 'objectWriteTraceId',   'object_write_trace_id',  'STRING',   6, 1, 0, 1, GETUTCDATE()),
  ( 993, 'HubSpot', 'crm_contacts', 'crm_contacts', 'url',                  'url',                    'STRING',   7, 1, 0, 1, GETUTCDATE()),
  ( 994, 'HubSpot', 'crm_contacts', 'crm_contacts', 'properties',           'properties_json',        'STRING',   8, 0, 0, 1, GETUTCDATE()),
  ( 995, 'HubSpot', 'crm_contacts', 'crm_contacts', 'N/A',                  'object_type',            'STRING',   9, 0, 0, 1, GETUTCDATE());

-- [H05] crm_companies
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  ( 996, 'HubSpot', 'crm_companies', 'crm_companies', 'id',                  'id',                    'STRING',   1, 1, 1, 1, GETUTCDATE()),
  ( 997, 'HubSpot', 'crm_companies', 'crm_companies', 'createdAt',           'created_at',             'STRING',   2, 1, 0, 1, GETUTCDATE()),
  ( 998, 'HubSpot', 'crm_companies', 'crm_companies', 'updatedAt',           'updated_at',             'STRING',   3, 1, 0, 1, GETUTCDATE()),
  ( 999, 'HubSpot', 'crm_companies', 'crm_companies', 'archived',            'archived',               'BOOLEAN',  4, 1, 0, 1, GETUTCDATE()),
  (1000, 'HubSpot', 'crm_companies', 'crm_companies', 'archivedAt',          'archived_at',            'STRING',   5, 1, 0, 1, GETUTCDATE()),
  (1001, 'HubSpot', 'crm_companies', 'crm_companies', 'objectWriteTraceId',  'object_write_trace_id',  'STRING',   6, 1, 0, 1, GETUTCDATE()),
  (1002, 'HubSpot', 'crm_companies', 'crm_companies', 'url',                 'url',                    'STRING',   7, 1, 0, 1, GETUTCDATE()),
  (1003, 'HubSpot', 'crm_companies', 'crm_companies', 'properties',          'properties_json',        'STRING',   8, 0, 0, 1, GETUTCDATE()),
  (1004, 'HubSpot', 'crm_companies', 'crm_companies', 'N/A',                 'object_type',            'STRING',   9, 0, 0, 1, GETUTCDATE());

-- [H06] crm_deals
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  (1005, 'HubSpot', 'crm_deals', 'crm_deals', 'id',                  'id',                    'STRING',   1, 1, 1, 1, GETUTCDATE()),
  (1006, 'HubSpot', 'crm_deals', 'crm_deals', 'createdAt',           'created_at',             'STRING',   2, 1, 0, 1, GETUTCDATE()),
  (1007, 'HubSpot', 'crm_deals', 'crm_deals', 'updatedAt',           'updated_at',             'STRING',   3, 1, 0, 1, GETUTCDATE()),
  (1008, 'HubSpot', 'crm_deals', 'crm_deals', 'archived',            'archived',               'BOOLEAN',  4, 1, 0, 1, GETUTCDATE()),
  (1009, 'HubSpot', 'crm_deals', 'crm_deals', 'archivedAt',          'archived_at',            'STRING',   5, 1, 0, 1, GETUTCDATE()),
  (1010, 'HubSpot', 'crm_deals', 'crm_deals', 'objectWriteTraceId',  'object_write_trace_id',  'STRING',   6, 1, 0, 1, GETUTCDATE()),
  (1011, 'HubSpot', 'crm_deals', 'crm_deals', 'url',                 'url',                    'STRING',   7, 1, 0, 1, GETUTCDATE()),
  (1012, 'HubSpot', 'crm_deals', 'crm_deals', 'properties',          'properties_json',        'STRING',   8, 0, 0, 1, GETUTCDATE()),
  (1013, 'HubSpot', 'crm_deals', 'crm_deals', 'N/A',                 'object_type',            'STRING',   9, 0, 0, 1, GETUTCDATE());

-- [H07] crm_tickets
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  (1014, 'HubSpot', 'crm_tickets', 'crm_tickets', 'id',                  'id',                    'STRING',   1, 1, 1, 1, GETUTCDATE()),
  (1015, 'HubSpot', 'crm_tickets', 'crm_tickets', 'createdAt',           'created_at',             'STRING',   2, 1, 0, 1, GETUTCDATE()),
  (1016, 'HubSpot', 'crm_tickets', 'crm_tickets', 'updatedAt',           'updated_at',             'STRING',   3, 1, 0, 1, GETUTCDATE()),
  (1017, 'HubSpot', 'crm_tickets', 'crm_tickets', 'archived',            'archived',               'BOOLEAN',  4, 1, 0, 1, GETUTCDATE()),
  (1018, 'HubSpot', 'crm_tickets', 'crm_tickets', 'archivedAt',          'archived_at',            'STRING',   5, 1, 0, 1, GETUTCDATE()),
  (1019, 'HubSpot', 'crm_tickets', 'crm_tickets', 'objectWriteTraceId',  'object_write_trace_id',  'STRING',   6, 1, 0, 1, GETUTCDATE()),
  (1020, 'HubSpot', 'crm_tickets', 'crm_tickets', 'url',                 'url',                    'STRING',   7, 1, 0, 1, GETUTCDATE()),
  (1021, 'HubSpot', 'crm_tickets', 'crm_tickets', 'properties',          'properties_json',        'STRING',   8, 0, 0, 1, GETUTCDATE()),
  (1022, 'HubSpot', 'crm_tickets', 'crm_tickets', 'N/A',                 'object_type',            'STRING',   9, 0, 0, 1, GETUTCDATE());

-- [H08] crm_products
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  (1023, 'HubSpot', 'crm_products', 'crm_products', 'id',                  'id',                    'STRING',   1, 1, 1, 1, GETUTCDATE()),
  (1024, 'HubSpot', 'crm_products', 'crm_products', 'createdAt',           'created_at',             'STRING',   2, 1, 0, 1, GETUTCDATE()),
  (1025, 'HubSpot', 'crm_products', 'crm_products', 'updatedAt',           'updated_at',             'STRING',   3, 1, 0, 1, GETUTCDATE()),
  (1026, 'HubSpot', 'crm_products', 'crm_products', 'archived',            'archived',               'BOOLEAN',  4, 1, 0, 1, GETUTCDATE()),
  (1027, 'HubSpot', 'crm_products', 'crm_products', 'archivedAt',          'archived_at',            'STRING',   5, 1, 0, 1, GETUTCDATE()),
  (1028, 'HubSpot', 'crm_products', 'crm_products', 'objectWriteTraceId',  'object_write_trace_id',  'STRING',   6, 1, 0, 1, GETUTCDATE()),
  (1029, 'HubSpot', 'crm_products', 'crm_products', 'url',                 'url',                    'STRING',   7, 1, 0, 1, GETUTCDATE()),
  (1030, 'HubSpot', 'crm_products', 'crm_products', 'properties',          'properties_json',        'STRING',   8, 0, 0, 1, GETUTCDATE()),
  (1031, 'HubSpot', 'crm_products', 'crm_products', 'N/A',                 'object_type',            'STRING',   9, 0, 0, 1, GETUTCDATE());

-- [H09] crm_line_items
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  (1032, 'HubSpot', 'crm_line_items', 'crm_line_items', 'id',                  'id',                    'STRING',   1, 1, 1, 1, GETUTCDATE()),
  (1033, 'HubSpot', 'crm_line_items', 'crm_line_items', 'createdAt',           'created_at',             'STRING',   2, 1, 0, 1, GETUTCDATE()),
  (1034, 'HubSpot', 'crm_line_items', 'crm_line_items', 'updatedAt',           'updated_at',             'STRING',   3, 1, 0, 1, GETUTCDATE()),
  (1035, 'HubSpot', 'crm_line_items', 'crm_line_items', 'archived',            'archived',               'BOOLEAN',  4, 1, 0, 1, GETUTCDATE()),
  (1036, 'HubSpot', 'crm_line_items', 'crm_line_items', 'archivedAt',          'archived_at',            'STRING',   5, 1, 0, 1, GETUTCDATE()),
  (1037, 'HubSpot', 'crm_line_items', 'crm_line_items', 'objectWriteTraceId',  'object_write_trace_id',  'STRING',   6, 1, 0, 1, GETUTCDATE()),
  (1038, 'HubSpot', 'crm_line_items', 'crm_line_items', 'url',                 'url',                    'STRING',   7, 1, 0, 1, GETUTCDATE()),
  (1039, 'HubSpot', 'crm_line_items', 'crm_line_items', 'properties',          'properties_json',        'STRING',   8, 0, 0, 1, GETUTCDATE()),
  (1040, 'HubSpot', 'crm_line_items', 'crm_line_items', 'N/A',                 'object_type',            'STRING',   9, 0, 0, 1, GETUTCDATE());

-- [H10] crm_quotes
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  (1041, 'HubSpot', 'crm_quotes', 'crm_quotes', 'id',                  'id',                    'STRING',   1, 1, 1, 1, GETUTCDATE()),
  (1042, 'HubSpot', 'crm_quotes', 'crm_quotes', 'createdAt',           'created_at',             'STRING',   2, 1, 0, 1, GETUTCDATE()),
  (1043, 'HubSpot', 'crm_quotes', 'crm_quotes', 'updatedAt',           'updated_at',             'STRING',   3, 1, 0, 1, GETUTCDATE()),
  (1044, 'HubSpot', 'crm_quotes', 'crm_quotes', 'archived',            'archived',               'BOOLEAN',  4, 1, 0, 1, GETUTCDATE()),
  (1045, 'HubSpot', 'crm_quotes', 'crm_quotes', 'archivedAt',          'archived_at',            'STRING',   5, 1, 0, 1, GETUTCDATE()),
  (1046, 'HubSpot', 'crm_quotes', 'crm_quotes', 'objectWriteTraceId',  'object_write_trace_id',  'STRING',   6, 1, 0, 1, GETUTCDATE()),
  (1047, 'HubSpot', 'crm_quotes', 'crm_quotes', 'url',                 'url',                    'STRING',   7, 1, 0, 1, GETUTCDATE()),
  (1048, 'HubSpot', 'crm_quotes', 'crm_quotes', 'properties',          'properties_json',        'STRING',   8, 0, 0, 1, GETUTCDATE()),
  (1049, 'HubSpot', 'crm_quotes', 'crm_quotes', 'N/A',                 'object_type',            'STRING',   9, 0, 0, 1, GETUTCDATE());

-- [H11] crm_calls
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  (1050, 'HubSpot', 'crm_calls', 'crm_calls', 'id',                  'id',                    'STRING',   1, 1, 1, 1, GETUTCDATE()),
  (1051, 'HubSpot', 'crm_calls', 'crm_calls', 'createdAt',           'created_at',             'STRING',   2, 1, 0, 1, GETUTCDATE()),
  (1052, 'HubSpot', 'crm_calls', 'crm_calls', 'updatedAt',           'updated_at',             'STRING',   3, 1, 0, 1, GETUTCDATE()),
  (1053, 'HubSpot', 'crm_calls', 'crm_calls', 'archived',            'archived',               'BOOLEAN',  4, 1, 0, 1, GETUTCDATE()),
  (1054, 'HubSpot', 'crm_calls', 'crm_calls', 'archivedAt',          'archived_at',            'STRING',   5, 1, 0, 1, GETUTCDATE()),
  (1055, 'HubSpot', 'crm_calls', 'crm_calls', 'objectWriteTraceId',  'object_write_trace_id',  'STRING',   6, 1, 0, 1, GETUTCDATE()),
  (1056, 'HubSpot', 'crm_calls', 'crm_calls', 'url',                 'url',                    'STRING',   7, 1, 0, 1, GETUTCDATE()),
  (1057, 'HubSpot', 'crm_calls', 'crm_calls', 'properties',          'properties_json',        'STRING',   8, 0, 0, 1, GETUTCDATE()),
  (1058, 'HubSpot', 'crm_calls', 'crm_calls', 'N/A',                 'object_type',            'STRING',   9, 0, 0, 1, GETUTCDATE());

-- [H12] crm_meetings
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  (1059, 'HubSpot', 'crm_meetings', 'crm_meetings', 'id',                  'id',                    'STRING',   1, 1, 1, 1, GETUTCDATE()),
  (1060, 'HubSpot', 'crm_meetings', 'crm_meetings', 'createdAt',           'created_at',             'STRING',   2, 1, 0, 1, GETUTCDATE()),
  (1061, 'HubSpot', 'crm_meetings', 'crm_meetings', 'updatedAt',           'updated_at',             'STRING',   3, 1, 0, 1, GETUTCDATE()),
  (1062, 'HubSpot', 'crm_meetings', 'crm_meetings', 'archived',            'archived',               'BOOLEAN',  4, 1, 0, 1, GETUTCDATE()),
  (1063, 'HubSpot', 'crm_meetings', 'crm_meetings', 'archivedAt',          'archived_at',            'STRING',   5, 1, 0, 1, GETUTCDATE()),
  (1064, 'HubSpot', 'crm_meetings', 'crm_meetings', 'objectWriteTraceId',  'object_write_trace_id',  'STRING',   6, 1, 0, 1, GETUTCDATE()),
  (1065, 'HubSpot', 'crm_meetings', 'crm_meetings', 'url',                 'url',                    'STRING',   7, 1, 0, 1, GETUTCDATE()),
  (1066, 'HubSpot', 'crm_meetings', 'crm_meetings', 'properties',          'properties_json',        'STRING',   8, 0, 0, 1, GETUTCDATE()),
  (1067, 'HubSpot', 'crm_meetings', 'crm_meetings', 'N/A',                 'object_type',            'STRING',   9, 0, 0, 1, GETUTCDATE());

-- [H13] crm_notes
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  (1068, 'HubSpot', 'crm_notes', 'crm_notes', 'id',                  'id',                    'STRING',   1, 1, 1, 1, GETUTCDATE()),
  (1069, 'HubSpot', 'crm_notes', 'crm_notes', 'createdAt',           'created_at',             'STRING',   2, 1, 0, 1, GETUTCDATE()),
  (1070, 'HubSpot', 'crm_notes', 'crm_notes', 'updatedAt',           'updated_at',             'STRING',   3, 1, 0, 1, GETUTCDATE()),
  (1071, 'HubSpot', 'crm_notes', 'crm_notes', 'archived',            'archived',               'BOOLEAN',  4, 1, 0, 1, GETUTCDATE()),
  (1072, 'HubSpot', 'crm_notes', 'crm_notes', 'archivedAt',          'archived_at',            'STRING',   5, 1, 0, 1, GETUTCDATE()),
  (1073, 'HubSpot', 'crm_notes', 'crm_notes', 'objectWriteTraceId',  'object_write_trace_id',  'STRING',   6, 1, 0, 1, GETUTCDATE()),
  (1074, 'HubSpot', 'crm_notes', 'crm_notes', 'url',                 'url',                    'STRING',   7, 1, 0, 1, GETUTCDATE()),
  (1075, 'HubSpot', 'crm_notes', 'crm_notes', 'properties',          'properties_json',        'STRING',   8, 0, 0, 1, GETUTCDATE()),
  (1076, 'HubSpot', 'crm_notes', 'crm_notes', 'N/A',                 'object_type',            'STRING',   9, 0, 0, 1, GETUTCDATE());

-- [H14] crm_tasks
INSERT INTO schema_config
    (id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active, created_at)
VALUES
  (1077, 'HubSpot', 'crm_tasks', 'crm_tasks', 'id',                  'id',                    'STRING',   1, 1, 1, 1, GETUTCDATE()),
  (1078, 'HubSpot', 'crm_tasks', 'crm_tasks', 'createdAt',           'created_at',             'STRING',   2, 1, 0, 1, GETUTCDATE()),
  (1079, 'HubSpot', 'crm_tasks', 'crm_tasks', 'updatedAt',           'updated_at',             'STRING',   3, 1, 0, 1, GETUTCDATE()),
  (1080, 'HubSpot', 'crm_tasks', 'crm_tasks', 'archived',            'archived',               'BOOLEAN',  4, 1, 0, 1, GETUTCDATE()),
  (1081, 'HubSpot', 'crm_tasks', 'crm_tasks', 'archivedAt',          'archived_at',            'STRING',   5, 1, 0, 1, GETUTCDATE()),
  (1082, 'HubSpot', 'crm_tasks', 'crm_tasks', 'objectWriteTraceId',  'object_write_trace_id',  'STRING',   6, 1, 0, 1, GETUTCDATE()),
  (1083, 'HubSpot', 'crm_tasks', 'crm_tasks', 'url',                 'url',                    'STRING',   7, 1, 0, 1, GETUTCDATE()),
  (1084, 'HubSpot', 'crm_tasks', 'crm_tasks', 'properties',          'properties_json',        'STRING',   8, 0, 0, 1, GETUTCDATE()),
  (1085, 'HubSpot', 'crm_tasks', 'crm_tasks', 'N/A',                 'object_type',            'STRING',   9, 0, 0, 1, GETUTCDATE());

-- Total HubSpot: 175 column mappings across 14 landing tables (IDs 911–1085)