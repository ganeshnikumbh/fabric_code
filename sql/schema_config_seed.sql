-- ============================================================
-- schema_config seed data — EQ_Warehouse source system
-- Generated from: EquiTrust_Data_Source_Intake_Template_eqWarehouse.xlsx
-- Target table  : control.schema_config
-- Columns       : id, source_name, source_table_name, source_column_name,
--                 target_column_name, target_data_type,
--                 ordinal_position, include_in_md5hash, is_active, created_at
-- ============================================================

-- [01] Territory (7 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  (   1, 'EQ_Warehouse', 'Territory'                                 , 'TerritoryPK'                               , 'territory_id'                              , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  (   2, 'EQ_Warehouse', 'Territory'                                 , 'TerritoryName'                             , 'territory_name'                            , 'STRING'              ,   2, 1, 1, GETUTCDATE());

-- [02] HierarchyTerritory (8 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  (   8, 'EQ_Warehouse', 'HierarchyTerritory'                        , 'HierarchyTerritoryPK'                      , 'hierarchy_territory_id'                    , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  (   9, 'EQ_Warehouse', 'HierarchyTerritory'                        , 'HierarchySetKey'                           , 'hierarchy_set_key'                         , 'INT'                 ,   2, 1, 1, GETUTCDATE()),
  (  10, 'EQ_Warehouse', 'HierarchyTerritory'                        , 'TerritoryFK'                               , 'territory_id'                              , 'INT'                 ,   3, 1, 1, GETUTCDATE());

-- [03] Hierarchy_SuperHierarchy (10 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  (  16, 'EQ_Warehouse', 'Hierarchy_SuperHierarchy'                  , 'SuperHierarchyPK'                          , 'super_hierarchy_id'                        , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  (  17, 'EQ_Warehouse', 'Hierarchy_SuperHierarchy'                  , 'AgentContractFK'                           , 'agent_contract_id'                         , 'INT'                 ,   2, 1, 1, GETUTCDATE()),
  (  18, 'EQ_Warehouse', 'Hierarchy_SuperHierarchy'                  , 'HierarchySetKey'                           , 'hierarchy_set_key'                         , 'INT'                 ,   3, 1, 1, GETUTCDATE()),
  (  19, 'EQ_Warehouse', 'Hierarchy_SuperHierarchy'                  , 'ReverseLevel'                              , 'reverse_level'                             , 'DECIMAL(18,4)'       ,   4, 1, 1, GETUTCDATE()),
  (  20, 'EQ_Warehouse', 'Hierarchy_SuperHierarchy'                  , 'DisplayName'                               , 'display_name'                              , 'STRING'              ,   5, 1, 1, GETUTCDATE());

-- [04] Hierarchy_Option (9 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  (  26, 'EQ_Warehouse', 'Hierarchy_Option'                          , 'HierarchyOptionPK'                         , 'hierarchy_option_id'                       , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  (  27, 'EQ_Warehouse', 'Hierarchy_Option'                          , 'HierarchyBridgeFK'                         , 'hierarchy_bridge_id'                       , 'INT'                 ,   2, 1, 1, GETUTCDATE()),
  (  28, 'EQ_Warehouse', 'Hierarchy_Option'                          , 'AgentContractFK'                           , 'agent_contract_id'                         , 'INT'                 ,   3, 1, 1, GETUTCDATE()),
  (  29, 'EQ_Warehouse', 'Hierarchy_Option'                          , 'AccessRemovedInd'                          , 'is_access_removed'                         , 'BOOLEAN'             ,   4, 1, 1, GETUTCDATE());

-- [05] Hierarchy_Bridge (15 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  (  35, 'EQ_Warehouse', 'Hierarchy_Bridge'                          , 'HierarchyBridgePK'                         , 'hierarchy_bridge_id'                       , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  (  36, 'EQ_Warehouse', 'Hierarchy_Bridge'                          , 'HierarchyGroupKey'                         , 'hierarchy_group_key'                       , 'INT'                 ,   2, 1, 1, GETUTCDATE()),
  (  37, 'EQ_Warehouse', 'Hierarchy_Bridge'                          , 'HierarchySetKey'                           , 'hierarchy_set_key'                         , 'INT'                 ,   3, 1, 1, GETUTCDATE()),
  (  38, 'EQ_Warehouse', 'Hierarchy_Bridge'                          , 'SplitPercent'                              , 'split_percent'                             , 'DECIMAL(18,4)'       ,   4, 1, 1, GETUTCDATE()),
  (  39, 'EQ_Warehouse', 'Hierarchy_Bridge'                          , 'ServicingAgentIndicator'                   , 'servicing_agent_indicator'                 , 'STRING'              ,   5, 1, 1, GETUTCDATE()),
  (  40, 'EQ_Warehouse', 'Hierarchy_Bridge'                          , 'CommissionOnlyIndicator'                   , 'commission_only_indicator'                 , 'STRING'              ,   6, 1, 1, GETUTCDATE()),
  (  41, 'EQ_Warehouse', 'Hierarchy_Bridge'                          , 'CommissionOption'                          , 'commission_option'                         , 'STRING'              ,   7, 1, 1, GETUTCDATE()),
  (  42, 'EQ_Warehouse', 'Hierarchy_Bridge'                          , 'HierarchyOrder'                            , 'hierarchy_order'                           , 'INT'                 ,   8, 1, 1, GETUTCDATE()),
  (  43, 'EQ_Warehouse', 'Hierarchy_Bridge'                          , 'StartDate'                                 , 'start_timestamp'                           , 'TIMESTAMP'           ,   9, 1, 1, GETUTCDATE()),
  (  44, 'EQ_Warehouse', 'Hierarchy_Bridge'                          , 'StopDate'                                  , 'stop_timestamp'                            , 'TIMESTAMP'           ,  10, 1, 1, GETUTCDATE());

-- [06] Hierarchy (10 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  (  50, 'EQ_Warehouse', 'Hierarchy'                                 , 'Source Column Name'                        , 'Target Column Name'                        , 'TARGET DATA TYPE'    ,   1, 1, 1, GETUTCDATE()),
  (  51, 'EQ_Warehouse', 'Hierarchy'                                 , 'HierarchyPK'                               , 'hierarchy_id'                              , 'INT'                 ,   2, 1, 1, GETUTCDATE()),
  (  52, 'EQ_Warehouse', 'Hierarchy'                                 , 'HierarchySetKey'                           , 'hierarchy_set_key'                         , 'INT'                 ,   3, 1, 1, GETUTCDATE()),
  (  53, 'EQ_Warehouse', 'Hierarchy'                                 , 'AgentContractFK'                           , 'agent_contract_id'                         , 'INT'                 ,   4, 1, 1, GETUTCDATE()),
  (  54, 'EQ_Warehouse', 'Hierarchy'                                 , 'ReverseLevel'                              , 'reverse_level'                             , 'INT'                 ,   5, 1, 1, GETUTCDATE());

-- [07] CommissionLevelRank (8 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  (  60, 'EQ_Warehouse', 'CommissionLevelRank'                       , 'CommissionLevelRankPK'                     , 'commission_level_rank_id'                  , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  (  61, 'EQ_Warehouse', 'CommissionLevelRank'                       , 'CommissionLevel'                           , 'commission_level'                          , 'STRING'              ,   2, 1, 1, GETUTCDATE()),
  (  62, 'EQ_Warehouse', 'CommissionLevelRank'                       , 'Rank'                                      , 'rank'                                      , 'INT'                 ,   3, 1, 1, GETUTCDATE());

-- [08] AgentContract (16 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  (  68, 'EQ_Warehouse', 'AgentContract'                             , 'AgentContractPK'                           , 'agent_contract_id'                         , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  (  69, 'EQ_Warehouse', 'AgentContract'                             , 'AgentNumber'                               , 'agent_number'                              , 'STRING'              ,   2, 1, 1, GETUTCDATE()),
  (  70, 'EQ_Warehouse', 'AgentContract'                             , 'AgentFK'                                   , 'agent_id'                                  , 'INT'                 ,   3, 1, 1, GETUTCDATE()),
  (  71, 'EQ_Warehouse', 'AgentContract'                             , 'Context'                                   , 'context'                                   , 'STRING'              ,   4, 1, 1, GETUTCDATE()),
  (  72, 'EQ_Warehouse', 'AgentContract'                             , 'Status'                                    , 'status'                                    , 'STRING'              ,   5, 1, 1, GETUTCDATE()),
  (  73, 'EQ_Warehouse', 'AgentContract'                             , 'CommissionLevel'                           , 'commission_level'                          , 'STRING'              ,   6, 1, 1, GETUTCDATE()),
  (  74, 'EQ_Warehouse', 'AgentContract'                             , 'SituationCode'                             , 'situation_code'                            , 'STRING'              ,   7, 1, 1, GETUTCDATE()),
  (  75, 'EQ_Warehouse', 'AgentContract'                             , 'ContractEffectiveDate'                     , 'contract_effective_timestamp'              , 'TIMESTAMP'           ,   8, 1, 1, GETUTCDATE()),
  (  76, 'EQ_Warehouse', 'AgentContract'                             , 'ContractTerminationDate'                   , 'contract_termination_timestamp'            , 'TIMESTAMP'           ,   9, 1, 1, GETUTCDATE()),
  (  77, 'EQ_Warehouse', 'AgentContract'                             , 'CurrentRecord'                             , 'is_current_record'                         , 'STRING'              ,  10, 1, 1, GETUTCDATE()),
  (  78, 'EQ_Warehouse', 'AgentContract'                             , 'SetToCurrentDate'                          , 'set_to_current_timestamp'                  , 'TIMESTAMP'           ,  11, 1, 1, GETUTCDATE());

-- [09] TrainingState_Group (10 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  (  84, 'EQ_Warehouse', 'TrainingState_Group'                       , 'TrainingStateGroupPK'                      , 'training_state_group_id'                   , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  (  85, 'EQ_Warehouse', 'TrainingState_Group'                       , 'TrainingStateGroupKey'                     , 'training_state_group_key'                  , 'INT'                 ,   2, 1, 1, GETUTCDATE()),
  (  86, 'EQ_Warehouse', 'TrainingState_Group'                       , 'State'                                     , 'state_code'                                , 'STRING'              ,   3, 1, 1, GETUTCDATE()),
  (  87, 'EQ_Warehouse', 'TrainingState_Group'                       , 'Required'                                  , 'is_required'                               , 'BOOLEAN'             ,   4, 1, 1, GETUTCDATE()),
  (  88, 'EQ_Warehouse', 'TrainingState_Group'                       , 'EffectiveDate'                             , 'effective_timestamp'                       , 'TIMESTAMP'           ,   5, 1, 1, GETUTCDATE());

-- [10] TrainingProduct_Group (9 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  (  94, 'EQ_Warehouse', 'TrainingProduct_Group'                     , 'TrainingProductGroupPK'                    , 'training_product_group_id'                 , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  (  95, 'EQ_Warehouse', 'TrainingProduct_Group'                     , 'TrainingProductGroupKey'                   , 'training_product_group_key'                , 'INT'                 ,   2, 1, 1, GETUTCDATE()),
  (  96, 'EQ_Warehouse', 'TrainingProduct_Group'                     , 'ProductFK'                                 , 'product_id'                                , 'INT'                 ,   3, 1, 1, GETUTCDATE()),
  (  97, 'EQ_Warehouse', 'TrainingProduct_Group'                     , 'Required'                                  , 'is_required'                               , 'BOOLEAN'             ,   4, 1, 1, GETUTCDATE());

-- [11] Rider_Group (20 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 103, 'EQ_Warehouse', 'Rider_Group'                               , 'RiderGroupPK'                              , 'rider_group_id'                            , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 104, 'EQ_Warehouse', 'Rider_Group'                               , 'RiderGroupKey'                             , 'rider_group_key'                           , 'INT'                 ,   2, 1, 1, GETUTCDATE()),
  ( 105, 'EQ_Warehouse', 'Rider_Group'                               , 'Code'                                      , 'rider_code'                                , 'STRING'              ,   3, 1, 1, GETUTCDATE()),
  ( 106, 'EQ_Warehouse', 'Rider_Group'                               , 'Description'                               , 'description'                               , 'STRING'              ,   4, 1, 1, GETUTCDATE()),
  ( 107, 'EQ_Warehouse', 'Rider_Group'                               , 'BaseValue'                                 , 'base_value'                                , 'DECIMAL(18,4)'       ,   5, 1, 1, GETUTCDATE()),
  ( 108, 'EQ_Warehouse', 'Rider_Group'                               , 'EligibilityDate'                           , 'eligibility_timestamp'                     , 'TIMESTAMP'           ,   6, 1, 1, GETUTCDATE()),
  ( 109, 'EQ_Warehouse', 'Rider_Group'                               , 'FeePercent'                                , 'fee_percent'                               , 'DECIMAL(18,4)'       ,   7, 1, 1, GETUTCDATE()),
  ( 110, 'EQ_Warehouse', 'Rider_Group'                               , 'Lives'                                     , 'lives'                                     , 'STRING'              ,   8, 1, 1, GETUTCDATE()),
  ( 111, 'EQ_Warehouse', 'Rider_Group'                               , 'PayValue'                                  , 'pay_value'                                 , 'DECIMAL(18,4)'       ,   9, 1, 1, GETUTCDATE()),
  ( 112, 'EQ_Warehouse', 'Rider_Group'                               , 'Frequency'                                 , 'frequency'                                 , 'STRING'              ,  10, 1, 1, GETUTCDATE()),
  ( 113, 'EQ_Warehouse', 'Rider_Group'                               , 'WellnessEnrollment'                        , 'is_wellness_enrollment'                    , 'BOOLEAN'             ,  11, 1, 1, GETUTCDATE()),
  ( 114, 'EQ_Warehouse', 'Rider_Group'                               , 'WellnessCredits'                           , 'wellness_credits'                          , 'DECIMAL(18,4)'       ,  12, 1, 1, GETUTCDATE()),
  ( 115, 'EQ_Warehouse', 'Rider_Group'                               , 'StartAge'                                  , 'start_age'                                 , 'INT'                 ,  13, 1, 1, GETUTCDATE()),
  ( 116, 'EQ_Warehouse', 'Rider_Group'                               , 'StartDate'                                 , 'start_timestamp'                           , 'TIMESTAMP'           ,  14, 1, 1, GETUTCDATE()),
  ( 117, 'EQ_Warehouse', 'Rider_Group'                               , 'StopDate'                                  , 'stop_timestamp'                            , 'TIMESTAMP'           ,  15, 1, 1, GETUTCDATE());

-- [12] Requirement_Group (14 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 123, 'EQ_Warehouse', 'Requirement_Group'                         , 'RequirementGroupPK'                        , 'requirement_group_id'                      , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 124, 'EQ_Warehouse', 'Requirement_Group'                         , 'RequirementGroupKey'                       , 'requirement_group_key'                     , 'INT'                 ,   2, 1, 1, GETUTCDATE()),
  ( 125, 'EQ_Warehouse', 'Requirement_Group'                         , 'Code'                                      , 'requirement_code'                          , 'STRING'              ,   3, 1, 1, GETUTCDATE()),
  ( 126, 'EQ_Warehouse', 'Requirement_Group'                         , 'Description'                               , 'description'                               , 'STRING'              ,   4, 1, 1, GETUTCDATE()),
  ( 127, 'EQ_Warehouse', 'Requirement_Group'                         , 'Status'                                    , 'status'                                    , 'STRING'              ,   5, 1, 1, GETUTCDATE()),
  ( 128, 'EQ_Warehouse', 'Requirement_Group'                         , 'EffectiveDate'                             , 'effective_timestamp'                       , 'TIMESTAMP'           ,   6, 1, 1, GETUTCDATE()),
  ( 129, 'EQ_Warehouse', 'Requirement_Group'                         , 'FollowUpDate'                              , 'follow_up_timestamp'                       , 'TIMESTAMP'           ,   7, 1, 1, GETUTCDATE()),
  ( 130, 'EQ_Warehouse', 'Requirement_Group'                         , 'ReceivedDate'                              , 'received_timestamp'                        , 'TIMESTAMP'           ,   8, 1, 1, GETUTCDATE()),
  ( 131, 'EQ_Warehouse', 'Requirement_Group'                         , 'ExecutedDate'                              , 'executed_timestamp'                        , 'TIMESTAMP'           ,   9, 1, 1, GETUTCDATE());

-- [13] RenewalRate_Group (11 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 137, 'EQ_Warehouse', 'RenewalRate_Group'                         , 'RenewalRateGroupPK'                        , 'renewal_rate_group_id'                     , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 138, 'EQ_Warehouse', 'RenewalRate_Group'                         , 'RenewalRateGroupKey'                       , 'renewal_rate_group_key'                    , 'INT'                 ,   2, 1, 1, GETUTCDATE()),
  ( 139, 'EQ_Warehouse', 'RenewalRate_Group'                         , 'EffectiveDate'                             , 'effective_timestamp'                       , 'TIMESTAMP'           ,   3, 1, 1, GETUTCDATE()),
  ( 140, 'EQ_Warehouse', 'RenewalRate_Group'                         , 'Year'                                      , 'year'                                      , 'INT'                 ,   4, 1, 1, GETUTCDATE()),
  ( 141, 'EQ_Warehouse', 'RenewalRate_Group'                         , 'YearDisplay'                               , 'year_display'                              , 'STRING'              ,   5, 1, 1, GETUTCDATE()),
  ( 142, 'EQ_Warehouse', 'RenewalRate_Group'                         , 'Rate'                                      , 'rate'                                      , 'DECIMAL(18,4)'       ,   6, 1, 1, GETUTCDATE());

-- [14] Reinsurance_Group (9 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 148, 'EQ_Warehouse', 'Reinsurance_Group'                         , 'ReinsuranceGroupPK'                        , 'reinsurance_group_id'                      , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 149, 'EQ_Warehouse', 'Reinsurance_Group'                         , 'ReinsuranceGroupKey'                       , 'reinsurance_group_key'                     , 'INT'                 ,   2, 1, 1, GETUTCDATE()),
  ( 150, 'EQ_Warehouse', 'Reinsurance_Group'                         , 'TreatyCode'                                , 'treaty_code'                               , 'STRING'              ,   3, 1, 1, GETUTCDATE()),
  ( 151, 'EQ_Warehouse', 'Reinsurance_Group'                         , 'CoinsurancePercentage'                     , 'coinsurance_percentage'                    , 'DECIMAL(18,4)'       ,   4, 1, 1, GETUTCDATE());

-- [15] RecurringPayment_Group (21 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 157, 'EQ_Warehouse', 'RecurringPayment_Group'                    , 'RecurringPaymentGroupPK'                   , 'recurring_payment_group_id'                , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 158, 'EQ_Warehouse', 'RecurringPayment_Group'                    , 'RecurringPaymentGroupKey'                  , 'recurring_payment_group_key'               , 'INT'                 ,   2, 1, 1, GETUTCDATE()),
  ( 159, 'EQ_Warehouse', 'RecurringPayment_Group'                    , 'ActivityTypeFK'                            , 'activity_type_id'                          , 'INT'                 ,   3, 1, 1, GETUTCDATE()),
  ( 160, 'EQ_Warehouse', 'RecurringPayment_Group'                    , 'PayeeFK'                                   , 'payee_id'                                  , 'INT'                 ,   4, 1, 1, GETUTCDATE()),
  ( 161, 'EQ_Warehouse', 'RecurringPayment_Group'                    , 'NextEffectiveDate'                         , 'next_effective_timestamp'                  , 'TIMESTAMP'           ,   5, 1, 1, GETUTCDATE()),
  ( 162, 'EQ_Warehouse', 'RecurringPayment_Group'                    , 'PausedInd'                                 , 'is_paused'                                 , 'BOOLEAN'             ,   6, 1, 1, GETUTCDATE()),
  ( 163, 'EQ_Warehouse', 'RecurringPayment_Group'                    , 'DistributionType'                          , 'distribution_type'                         , 'STRING'              ,   7, 1, 1, GETUTCDATE()),
  ( 164, 'EQ_Warehouse', 'RecurringPayment_Group'                    , 'Lives'                                     , 'lives'                                     , 'STRING'              ,   8, 1, 1, GETUTCDATE()),
  ( 165, 'EQ_Warehouse', 'RecurringPayment_Group'                    , 'Frequency'                                 , 'frequency'                                 , 'STRING'              ,   9, 1, 1, GETUTCDATE()),
  ( 166, 'EQ_Warehouse', 'RecurringPayment_Group'                    , 'WithdrawalType'                            , 'withdrawal_type'                           , 'STRING'              ,  10, 1, 1, GETUTCDATE()),
  ( 167, 'EQ_Warehouse', 'RecurringPayment_Group'                    , 'FirstDate'                                 , 'first_timestamp'                           , 'TIMESTAMP'           ,  11, 1, 1, GETUTCDATE()),
  ( 168, 'EQ_Warehouse', 'RecurringPayment_Group'                    , 'PriorDate'                                 , 'prior_timestamp'                           , 'TIMESTAMP'           ,  12, 1, 1, GETUTCDATE()),
  ( 169, 'EQ_Warehouse', 'RecurringPayment_Group'                    , 'PriorActivityFK'                           , 'prior_activity_id'                         , 'INT'                 ,  13, 1, 1, GETUTCDATE()),
  ( 170, 'EQ_Warehouse', 'RecurringPayment_Group'                    , 'EligibleRMDDate'                           , 'eligible_rmd_timestamp'                    , 'TIMESTAMP'           ,  14, 1, 1, GETUTCDATE()),
  ( 171, 'EQ_Warehouse', 'RecurringPayment_Group'                    , 'CalculatedAmount'                          , 'calculated_amount'                         , 'DECIMAL(18,4)'       ,  15, 1, 1, GETUTCDATE()),
  ( 172, 'EQ_Warehouse', 'RecurringPayment_Group'                    , 'GrossNet'                                  , 'gross_net'                                 , 'STRING'              ,  16, 1, 1, GETUTCDATE());

-- [16] Note_Group (21 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 178, 'EQ_Warehouse', 'Note_Group'                                , 'NoteGroupPK'                               , 'note_group_id'                             , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 179, 'EQ_Warehouse', 'Note_Group'                                , 'SourceKey'                                 , 'source_key'                                , 'BIGINT'              ,   2, 1, 1, GETUTCDATE()),
  ( 180, 'EQ_Warehouse', 'Note_Group'                                , 'NoteGroupKey'                              , 'note_group_key'                            , 'INT'                 ,   3, 1, 1, GETUTCDATE()),
  ( 181, 'EQ_Warehouse', 'Note_Group'                                , 'Order'                                     , 'sort_order'                                , 'INT'                 ,   4, 1, 1, GETUTCDATE()),
  ( 182, 'EQ_Warehouse', 'Note_Group'                                , 'Text'                                      , 'note_text'                                 , 'STRING'              ,   5, 1, 1, GETUTCDATE()),
  ( 183, 'EQ_Warehouse', 'Note_Group'                                , 'Type'                                      , 'note_type'                                 , 'STRING'              ,   6, 1, 1, GETUTCDATE()),
  ( 184, 'EQ_Warehouse', 'Note_Group'                                , 'Role'                                      , 'role'                                      , 'STRING'              ,   7, 1, 1, GETUTCDATE()),
  ( 185, 'EQ_Warehouse', 'Note_Group'                                , 'MaintDate'                                 , 'maint_timestamp'                           , 'TIMESTAMP'           ,   8, 1, 1, GETUTCDATE()),
  ( 186, 'EQ_Warehouse', 'Note_Group'                                , 'MaintBy'                                   , 'maint_by'                                  , 'STRING'              ,   9, 1, 1, GETUTCDATE()),
  ( 187, 'EQ_Warehouse', 'Note_Group'                                , 'Call_ID'                                   , 'call_id'                                   , 'INT'                 ,  10, 1, 1, GETUTCDATE()),
  ( 188, 'EQ_Warehouse', 'Note_Group'                                , 'Call_Length'                               , 'call_length'                               , 'INT'                 ,  11, 1, 1, GETUTCDATE()),
  ( 189, 'EQ_Warehouse', 'Note_Group'                                , 'Call_StartDate'                            , 'call_start_timestamp'                      , 'TIMESTAMP'           ,  12, 1, 1, GETUTCDATE()),
  ( 190, 'EQ_Warehouse', 'Note_Group'                                , 'Call_InOut'                                , 'call_direction'                            , 'STRING'              ,  13, 1, 1, GETUTCDATE()),
  ( 191, 'EQ_Warehouse', 'Note_Group'                                , 'Call_Operators'                            , 'call_operators'                            , 'STRING'              ,  14, 1, 1, GETUTCDATE()),
  ( 192, 'EQ_Warehouse', 'Note_Group'                                , 'Call_FilePath'                             , 'call_file_path'                            , 'STRING'              ,  15, 1, 1, GETUTCDATE()),
  ( 193, 'EQ_Warehouse', 'Note_Group'                                , 'Call_EncryptKey'                           , 'call_encrypt_key'                          , 'STRING'              ,  16, 1, 1, GETUTCDATE());

-- [17] IndexValue_Group (12 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 199, 'EQ_Warehouse', 'IndexValue_Group'                          , 'IndexValueGroupPK'                         , 'index_value_group_id'                      , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 200, 'EQ_Warehouse', 'IndexValue_Group'                          , 'IndexValueGroupKey'                        , 'index_value_group_key'                     , 'INT'                 ,   2, 1, 1, GETUTCDATE()),
  ( 201, 'EQ_Warehouse', 'IndexValue_Group'                          , 'Ticker'                                    , 'ticker'                                    , 'STRING'              ,   3, 1, 1, GETUTCDATE()),
  ( 202, 'EQ_Warehouse', 'IndexValue_Group'                          , 'IndexName'                                 , 'index_name'                                , 'STRING'              ,   4, 1, 1, GETUTCDATE()),
  ( 203, 'EQ_Warehouse', 'IndexValue_Group'                          , 'EffectiveDate'                             , 'effective_timestamp'                       , 'TIMESTAMP'           ,   5, 1, 1, GETUTCDATE()),
  ( 204, 'EQ_Warehouse', 'IndexValue_Group'                          , 'IndexValue'                                , 'index_value'                               , 'DECIMAL(18,4)'       ,   6, 1, 1, GETUTCDATE()),
  ( 205, 'EQ_Warehouse', 'IndexValue_Group'                          , 'Change'                                    , 'change_amount'                             , 'DECIMAL(18,4)'       ,   7, 1, 1, GETUTCDATE());

-- [18] ExternalAccount_Group (14 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 211, 'EQ_Warehouse', 'ExternalAccount_Group'                     , 'ExternalAccountGroupPK'                    , 'external_account_group_id'                 , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 212, 'EQ_Warehouse', 'ExternalAccount_Group'                     , 'ExternalAccountGroupKey'                   , 'external_account_group_key'                , 'INT'                 ,   2, 1, 1, GETUTCDATE()),
  ( 213, 'EQ_Warehouse', 'ExternalAccount_Group'                     , 'ExternalCompanyName'                       , 'external_company_name'                     , 'STRING'              ,   3, 1, 1, GETUTCDATE()),
  ( 214, 'EQ_Warehouse', 'ExternalAccount_Group'                     , 'AccountType'                               , 'account_type'                              , 'STRING'              ,   4, 1, 1, GETUTCDATE()),
  ( 215, 'EQ_Warehouse', 'ExternalAccount_Group'                     , 'AccountNumber'                             , 'account_number'                            , 'STRING'              ,   5, 1, 1, GETUTCDATE()),
  ( 216, 'EQ_Warehouse', 'ExternalAccount_Group'                     , 'Status'                                    , 'status'                                    , 'STRING'              ,   6, 1, 1, GETUTCDATE()),
  ( 217, 'EQ_Warehouse', 'ExternalAccount_Group'                     , 'Active'                                    , 'is_active'                                 , 'BOOLEAN'             ,   7, 1, 1, GETUTCDATE()),
  ( 218, 'EQ_Warehouse', 'ExternalAccount_Group'                     , 'StartDate'                                 , 'start_timestamp'                           , 'TIMESTAMP'           ,   8, 1, 1, GETUTCDATE()),
  ( 219, 'EQ_Warehouse', 'ExternalAccount_Group'                     , 'EndDate'                                   , 'end_timestamp'                             , 'TIMESTAMP'           ,   9, 1, 1, GETUTCDATE());

-- [19] ContractValue_Group (13 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 225, 'EQ_Warehouse', 'ContractValue_Group'                       , 'ContractValueGroupPK'                      , 'contract_value_group_id'                   , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 226, 'EQ_Warehouse', 'ContractValue_Group'                       , 'ContractValueGroupKey'                     , 'contract_value_group_key'                  , 'INT'                 ,   2, 1, 1, GETUTCDATE()),
  ( 227, 'EQ_Warehouse', 'ContractValue_Group'                       , 'ValueType'                                 , 'value_type'                                , 'STRING'              ,   3, 1, 1, GETUTCDATE()),
  ( 228, 'EQ_Warehouse', 'ContractValue_Group'                       , 'ValueDate'                                 , 'value_timestamp'                           , 'TIMESTAMP'           ,   4, 1, 1, GETUTCDATE()),
  ( 229, 'EQ_Warehouse', 'ContractValue_Group'                       , 'Value'                                     , 'value'                                     , 'DECIMAL(18,4)'       ,   5, 1, 1, GETUTCDATE()),
  ( 230, 'EQ_Warehouse', 'ContractValue_Group'                       , 'ValueAsDate'                               , 'value_as_timestamp'                        , 'TIMESTAMP'           ,   6, 1, 1, GETUTCDATE()),
  ( 231, 'EQ_Warehouse', 'ContractValue_Group'                       , 'StartDate'                                 , 'start_timestamp'                           , 'TIMESTAMP'           ,   7, 1, 1, GETUTCDATE()),
  ( 232, 'EQ_Warehouse', 'ContractValue_Group'                       , 'EndDate'                                   , 'end_timestamp'                             , 'TIMESTAMP'           ,   8, 1, 1, GETUTCDATE());

-- [20] ContractDeposit_Group (22 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 238, 'EQ_Warehouse', 'ContractDeposit_Group'                     , 'ContractDepositGroupPK'                    , 'contract_deposit_group_id'                 , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 239, 'EQ_Warehouse', 'ContractDeposit_Group'                     , 'SourceKey'                                 , 'source_key'                                , 'BIGINT'              ,   2, 1, 1, GETUTCDATE()),
  ( 240, 'EQ_Warehouse', 'ContractDeposit_Group'                     , 'ContractDepositGroupKey'                   , 'contract_deposit_group_key'                , 'INT'                 ,   3, 1, 1, GETUTCDATE()),
  ( 241, 'EQ_Warehouse', 'ContractDeposit_Group'                     , 'DepositType'                               , 'deposit_type'                              , 'STRING'              ,   4, 1, 1, GETUTCDATE()),
  ( 242, 'EQ_Warehouse', 'ContractDeposit_Group'                     , 'DepositSource'                             , 'deposit_source'                            , 'STRING'              ,   5, 1, 1, GETUTCDATE()),
  ( 243, 'EQ_Warehouse', 'ContractDeposit_Group'                     , 'OriginalContract'                          , 'original_contract'                         , 'STRING'              ,   6, 1, 1, GETUTCDATE()),
  ( 244, 'EQ_Warehouse', 'ContractDeposit_Group'                     , 'DateReceived'                              , 'date_received_timestamp'                   , 'TIMESTAMP'           ,   7, 1, 1, GETUTCDATE()),
  ( 245, 'EQ_Warehouse', 'ContractDeposit_Group'                     , 'ProcessDate'                               , 'process_timestamp'                         , 'TIMESTAMP'           ,   8, 1, 1, GETUTCDATE()),
  ( 246, 'EQ_Warehouse', 'ContractDeposit_Group'                     , 'TaxYear'                                   , 'tax_year'                                  , 'INT'                 ,   9, 1, 1, GETUTCDATE()),
  ( 247, 'EQ_Warehouse', 'ContractDeposit_Group'                     , 'ReplacementType'                           , 'replacement_type'                          , 'STRING'              ,  10, 1, 1, GETUTCDATE()),
  ( 248, 'EQ_Warehouse', 'ContractDeposit_Group'                     , 'PremiumType'                               , 'premium_type'                              , 'STRING'              ,  11, 1, 1, GETUTCDATE()),
  ( 249, 'EQ_Warehouse', 'ContractDeposit_Group'                     , 'PlannedIndicator'                          , 'planned_indicator'                         , 'STRING'              ,  12, 1, 1, GETUTCDATE()),
  ( 250, 'EQ_Warehouse', 'ContractDeposit_Group'                     , 'Reference'                                 , 'reference'                                 , 'STRING'              ,  13, 1, 1, GETUTCDATE()),
  ( 251, 'EQ_Warehouse', 'ContractDeposit_Group'                     , 'AnticipatedAmount'                         , 'anticipated_amount'                        , 'DECIMAL(18,4)'       ,  14, 1, 1, GETUTCDATE()),
  ( 252, 'EQ_Warehouse', 'ContractDeposit_Group'                     , 'ActualAmount'                              , 'actual_amount'                             , 'DECIMAL(18,4)'       ,  15, 1, 1, GETUTCDATE()),
  ( 253, 'EQ_Warehouse', 'ContractDeposit_Group'                     , 'CostBasis'                                 , 'cost_basis'                                , 'DECIMAL(18,4)'       ,  16, 1, 1, GETUTCDATE()),
  ( 254, 'EQ_Warehouse', 'ContractDeposit_Group'                     , 'RefundAmount'                              , 'refund_amount'                             , 'DECIMAL(18,4)'       ,  17, 1, 1, GETUTCDATE());

-- [21] AgentSummary_Group (10 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 260, 'EQ_Warehouse', 'AgentSummary_Group'                        , 'AgentSummaryGroupPK'                       , 'agent_summary_group_id'                    , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 261, 'EQ_Warehouse', 'AgentSummary_Group'                        , 'AgentSummaryGroupKey'                      , 'agent_summary_group_key'                   , 'INT'                 ,   2, 1, 1, GETUTCDATE()),
  ( 262, 'EQ_Warehouse', 'AgentSummary_Group'                        , 'SummaryType'                               , 'summary_type'                              , 'STRING'              ,   3, 1, 1, GETUTCDATE()),
  ( 263, 'EQ_Warehouse', 'AgentSummary_Group'                        , 'SummaryDate'                               , 'summary_timestamp'                         , 'TIMESTAMP'           ,   4, 1, 1, GETUTCDATE()),
  ( 264, 'EQ_Warehouse', 'AgentSummary_Group'                        , 'SummaryValue'                              , 'summary_value'                             , 'DECIMAL(18,4)'       ,   5, 1, 1, GETUTCDATE());

-- [22] AgentPrincipal_Group (10 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 270, 'EQ_Warehouse', 'AgentPrincipal_Group'                      , 'AgentPrincipalGroupPK'                     , 'agent_principal_group_id'                  , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 271, 'EQ_Warehouse', 'AgentPrincipal_Group'                      , 'AgentPrincipalGroupKey'                    , 'agent_principal_group_key'                 , 'INT'                 ,   2, 1, 1, GETUTCDATE()),
  ( 272, 'EQ_Warehouse', 'AgentPrincipal_Group'                      , 'PrincipalAgentFK'                          , 'principal_agent_id'                        , 'INT'                 ,   3, 1, 1, GETUTCDATE()),
  ( 273, 'EQ_Warehouse', 'AgentPrincipal_Group'                      , 'StartDate'                                 , 'start_timestamp'                           , 'TIMESTAMP'           ,   4, 1, 1, GETUTCDATE()),
  ( 274, 'EQ_Warehouse', 'AgentPrincipal_Group'                      , 'EndDate'                                   , 'end_timestamp'                             , 'TIMESTAMP'           ,   5, 1, 1, GETUTCDATE());

-- [23] AgentLicense_Group (16 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 280, 'EQ_Warehouse', 'AgentLicense_Group'                        , 'AgentLicenseGroupPK'                       , 'agent_license_group_id'                    , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 281, 'EQ_Warehouse', 'AgentLicense_Group'                        , 'SourceKey'                                 , 'source_key'                                , 'BIGINT'              ,   2, 1, 1, GETUTCDATE()),
  ( 282, 'EQ_Warehouse', 'AgentLicense_Group'                        , 'AgentLicenseGroupKey'                      , 'agent_license_group_key'                   , 'INT'                 ,   3, 1, 1, GETUTCDATE()),
  ( 283, 'EQ_Warehouse', 'AgentLicense_Group'                        , 'LicenseType'                               , 'license_type'                              , 'STRING'              ,   4, 1, 1, GETUTCDATE()),
  ( 284, 'EQ_Warehouse', 'AgentLicense_Group'                        , 'LicenseState'                              , 'license_state'                             , 'STRING'              ,   5, 1, 1, GETUTCDATE()),
  ( 285, 'EQ_Warehouse', 'AgentLicense_Group'                        , 'Resident'                                  , 'resident'                                  , 'STRING'              ,   6, 1, 1, GETUTCDATE()),
  ( 286, 'EQ_Warehouse', 'AgentLicense_Group'                        , 'LicenseNumber'                             , 'license_number'                            , 'STRING'              ,   7, 1, 1, GETUTCDATE()),
  ( 287, 'EQ_Warehouse', 'AgentLicense_Group'                        , 'Status'                                    , 'status'                                    , 'STRING'              ,   8, 1, 1, GETUTCDATE()),
  ( 288, 'EQ_Warehouse', 'AgentLicense_Group'                        , 'EffectiveDate'                             , 'effective_timestamp'                       , 'TIMESTAMP'           ,   9, 1, 1, GETUTCDATE()),
  ( 289, 'EQ_Warehouse', 'AgentLicense_Group'                        , 'ExpirationDate'                            , 'expiration_timestamp'                      , 'TIMESTAMP'           ,  10, 1, 1, GETUTCDATE()),
  ( 290, 'EQ_Warehouse', 'AgentLicense_Group'                        , 'TerminationDate'                           , 'termination_timestamp'                     , 'TIMESTAMP'           ,  11, 1, 1, GETUTCDATE());

-- [24] AdditionalInfo_Group (19 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 296, 'EQ_Warehouse', 'AdditionalInfo_Group'                      , 'AdditionalInfoGroupPK'                     , 'additional_info_group_id'                  , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 297, 'EQ_Warehouse', 'AdditionalInfo_Group'                      , 'AdditionalInfoGroupKey'                    , 'additional_info_group_key'                 , 'INT'                 ,   2, 1, 1, GETUTCDATE()),
  ( 298, 'EQ_Warehouse', 'AdditionalInfo_Group'                      , 'AdditionalInfoSource'                      , 'additional_info_source'                    , 'STRING'              ,   3, 1, 1, GETUTCDATE()),
  ( 299, 'EQ_Warehouse', 'AdditionalInfo_Group'                      , 'AdditionalInfoType'                        , 'additional_info_type'                      , 'STRING'              ,   4, 1, 1, GETUTCDATE()),
  ( 300, 'EQ_Warehouse', 'AdditionalInfo_Group'                      , 'AdditionalInfoDescription'                 , 'additional_info_description'               , 'STRING'              ,   5, 1, 1, GETUTCDATE()),
  ( 301, 'EQ_Warehouse', 'AdditionalInfo_Group'                      , 'AdditionalInfoValue'                       , 'additional_info_value'                     , 'STRING'              ,   6, 1, 1, GETUTCDATE()),
  ( 302, 'EQ_Warehouse', 'AdditionalInfo_Group'                      , 'AddressLine1'                              , 'address_line_1'                            , 'STRING'              ,   7, 1, 1, GETUTCDATE()),
  ( 303, 'EQ_Warehouse', 'AdditionalInfo_Group'                      , 'AddressLine2'                              , 'address_line_2'                            , 'STRING'              ,   8, 1, 1, GETUTCDATE()),
  ( 304, 'EQ_Warehouse', 'AdditionalInfo_Group'                      , 'AddressLine3'                              , 'address_line_3'                            , 'STRING'              ,   9, 1, 1, GETUTCDATE()),
  ( 305, 'EQ_Warehouse', 'AdditionalInfo_Group'                      , 'AddressLine4'                              , 'address_line_4'                            , 'STRING'              ,  10, 1, 1, GETUTCDATE()),
  ( 306, 'EQ_Warehouse', 'AdditionalInfo_Group'                      , 'City'                                      , 'city'                                      , 'STRING'              ,  11, 1, 1, GETUTCDATE()),
  ( 307, 'EQ_Warehouse', 'AdditionalInfo_Group'                      , 'State'                                     , 'state'                                     , 'STRING'              ,  12, 1, 1, GETUTCDATE()),
  ( 308, 'EQ_Warehouse', 'AdditionalInfo_Group'                      , 'ZipCode'                                   , 'zip_code'                                  , 'STRING'              ,  13, 1, 1, GETUTCDATE()),
  ( 309, 'EQ_Warehouse', 'AdditionalInfo_Group'                      , 'EffectiveDate'                             , 'effective_timestamp'                       , 'TIMESTAMP'           ,  14, 1, 1, GETUTCDATE());

-- [25] AdditionalClient_Group (12 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 315, 'EQ_Warehouse', 'AdditionalClient_Group'                    , 'AdditionalClientGroupPK'                   , 'additional_client_group_id'                , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 316, 'EQ_Warehouse', 'AdditionalClient_Group'                    , 'AdditionalClientGroupKey'                  , 'additional_client_group_key'               , 'INT'                 ,   2, 1, 1, GETUTCDATE()),
  ( 317, 'EQ_Warehouse', 'AdditionalClient_Group'                    , 'ClientFK'                                  , 'client_id'                                 , 'INT'                 ,   3, 1, 1, GETUTCDATE()),
  ( 318, 'EQ_Warehouse', 'AdditionalClient_Group'                    , 'AdditionalType'                            , 'additional_type'                           , 'STRING'              ,   4, 1, 1, GETUTCDATE()),
  ( 319, 'EQ_Warehouse', 'AdditionalClient_Group'                    , 'Relation'                                  , 'relation'                                  , 'STRING'              ,   5, 1, 1, GETUTCDATE()),
  ( 320, 'EQ_Warehouse', 'AdditionalClient_Group'                    , 'AllocationPercent'                         , 'allocation_percent'                        , 'DECIMAL(18,4)'       ,   6, 1, 1, GETUTCDATE()),
  ( 321, 'EQ_Warehouse', 'AdditionalClient_Group'                    , 'Active'                                    , 'is_active'                                 , 'BOOLEAN'             ,   7, 1, 1, GETUTCDATE());

-- [26] AccountingReporting_Group (10 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 327, 'EQ_Warehouse', 'AccountingReporting_Group'                 , 'AccountingReportingGroupPK'                , 'accounting_reporting_group_id'             , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 328, 'EQ_Warehouse', 'AccountingReporting_Group'                 , 'AccountingReportingGroupKey'               , 'accounting_reporting_group_key'            , 'INT'                 ,   2, 1, 1, GETUTCDATE()),
  ( 329, 'EQ_Warehouse', 'AccountingReporting_Group'                 , 'ReportingCode'                             , 'reporting_code'                            , 'STRING'              ,   3, 1, 1, GETUTCDATE()),
  ( 330, 'EQ_Warehouse', 'AccountingReporting_Group'                 , 'ReportingClassCode'                        , 'reporting_class_code'                      , 'STRING'              ,   4, 1, 1, GETUTCDATE()),
  ( 331, 'EQ_Warehouse', 'AccountingReporting_Group'                 , 'ReportingDescription'                      , 'reporting_description'                     , 'STRING'              ,   5, 1, 1, GETUTCDATE());

-- [27] ProductVariationDetail (9 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 337, 'EQ_Warehouse', 'ProductVariationDetail'                    , 'ProductVariationDetailPK'                  , 'product_variation_detail_id'               , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 338, 'EQ_Warehouse', 'ProductVariationDetail'                    , 'DisclosureText'                            , 'disclosure_text'                           , 'STRING'              ,   2, 1, 1, GETUTCDATE()),
  ( 339, 'EQ_Warehouse', 'ProductVariationDetail'                    , 'SortOrder'                                 , 'sort_order'                                , 'INT'                 ,   3, 1, 1, GETUTCDATE()),
  ( 340, 'EQ_Warehouse', 'ProductVariationDetail'                    , 'Type'                                      , 'type'                                      , 'STRING'              ,   4, 1, 1, GETUTCDATE());

-- [28] ProductStateVariation (9 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 346, 'EQ_Warehouse', 'ProductStateVariation'                     , 'ProductStateVariationPK'                   , 'product_state_variation_id'                , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 347, 'EQ_Warehouse', 'ProductStateVariation'                     , 'ProductFK'                                 , 'product_id'                                , 'INT'                 ,   2, 1, 1, GETUTCDATE()),
  ( 348, 'EQ_Warehouse', 'ProductStateVariation'                     , 'StateCode'                                 , 'state_code'                                , 'STRING'              ,   3, 1, 1, GETUTCDATE()),
  ( 349, 'EQ_Warehouse', 'ProductStateVariation'                     , 'ProductVariationDetailFK'                  , 'product_variation_detail_id'               , 'INT'                 ,   4, 1, 1, GETUTCDATE());

-- [29] ProductStateApprovalDisclosure (10 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 355, 'EQ_Warehouse', 'ProductStateApprovalDisclosure'            , 'PSADisclosurePK'                           , 'product_state_approval_disclosure_id'      , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 356, 'EQ_Warehouse', 'ProductStateApprovalDisclosure'            , 'ProductStateApprovalFK'                    , 'product_state_approval_id'                 , 'INT'                 ,   2, 1, 1, GETUTCDATE()),
  ( 357, 'EQ_Warehouse', 'ProductStateApprovalDisclosure'            , 'MarketingNameOverride'                     , 'marketing_name_override'                   , 'STRING'              ,   3, 1, 1, GETUTCDATE()),
  ( 358, 'EQ_Warehouse', 'ProductStateApprovalDisclosure'            , 'DisclosureText'                            , 'disclosure_text'                           , 'STRING'              ,   4, 1, 1, GETUTCDATE()),
  ( 359, 'EQ_Warehouse', 'ProductStateApprovalDisclosure'            , 'SortOrder'                                 , 'sort_order'                                , 'INT'                 ,   5, 1, 1, GETUTCDATE());

-- [30] ProductStateApproval (11 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 365, 'EQ_Warehouse', 'ProductStateApproval'                      , 'ProductStateApprovalPK'                    , 'product_state_approval_id'                 , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 366, 'EQ_Warehouse', 'ProductStateApproval'                      , 'ProductFK'                                 , 'product_id'                                , 'INT'                 ,   2, 1, 1, GETUTCDATE()),
  ( 367, 'EQ_Warehouse', 'ProductStateApproval'                      , 'StateCode'                                 , 'state_code'                                , 'STRING'              ,   3, 1, 1, GETUTCDATE()),
  ( 368, 'EQ_Warehouse', 'ProductStateApproval'                      , 'ApprovedInd'                               , 'is_approved'                               , 'BOOLEAN'             ,   4, 1, 1, GETUTCDATE()),
  ( 369, 'EQ_Warehouse', 'ProductStateApproval'                      , 'StartDate'                                 , 'start_timestamp'                           , 'TIMESTAMP'           ,   5, 1, 1, GETUTCDATE()),
  ( 370, 'EQ_Warehouse', 'ProductStateApproval'                      , 'EndDate'                                   , 'end_timestamp'                             , 'TIMESTAMP'           ,   6, 1, 1, GETUTCDATE());

-- [31] hedge.Ratios (12 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 376, 'EQ_Warehouse', 'hedge.Ratios'                              , 'RatiosPK'                                  , 'ratios_id'                                 , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 377, 'EQ_Warehouse', 'hedge.Ratios'                              , 'ContractFK'                                , 'contract_id'                               , 'INT'                 ,   2, 1, 1, GETUTCDATE()),
  ( 378, 'EQ_Warehouse', 'hedge.Ratios'                              , 'ValueDate'                                 , 'value_timestamp'                           , 'TIMESTAMP'           ,   3, 1, 1, GETUTCDATE()),
  ( 379, 'EQ_Warehouse', 'hedge.Ratios'                              , 'BaseHedgeRatio'                            , 'base_hedge_ratio'                          , 'DECIMAL(18,4)'       ,   4, 1, 1, GETUTCDATE()),
  ( 380, 'EQ_Warehouse', 'hedge.Ratios'                              , 'BaseSurvivalRatio'                         , 'base_survival_ratio'                       , 'DECIMAL(18,4)'       ,   5, 1, 1, GETUTCDATE()),
  ( 381, 'EQ_Warehouse', 'hedge.Ratios'                              , 'StartDate'                                 , 'start_timestamp'                           , 'TIMESTAMP'           ,   6, 1, 1, GETUTCDATE()),
  ( 382, 'EQ_Warehouse', 'hedge.Ratios'                              , 'EndDate'                                   , 'end_timestamp'                             , 'TIMESTAMP'           ,   7, 1, 1, GETUTCDATE());

-- [32] hedge.Options (26 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 388, 'EQ_Warehouse', 'hedge.Options'                             , 'OptionsPK'                                 , 'options_id'                                , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 389, 'EQ_Warehouse', 'hedge.Options'                             , 'ContractFK'                                , 'contract_id'                               , 'INT'                 ,   2, 1, 1, GETUTCDATE()),
  ( 390, 'EQ_Warehouse', 'hedge.Options'                             , 'InvestmentFK'                              , 'investment_id'                             , 'INT'                 ,   3, 1, 1, GETUTCDATE()),
  ( 391, 'EQ_Warehouse', 'hedge.Options'                             , 'RenewalDate'                               , 'renewal_timestamp'                         , 'TIMESTAMP'           ,   4, 1, 1, GETUTCDATE()),
  ( 392, 'EQ_Warehouse', 'hedge.Options'                             , 'IndexValue'                                , 'index_value'                               , 'DECIMAL(18,4)'       ,   5, 1, 1, GETUTCDATE()),
  ( 393, 'EQ_Warehouse', 'hedge.Options'                             , 'HedgingPercentage'                         , 'hedging_percentage'                        , 'DECIMAL(18,4)'       ,   6, 1, 1, GETUTCDATE()),
  ( 394, 'EQ_Warehouse', 'hedge.Options'                             , 'HedgeID1'                                  , 'hedge_id_1'                                , 'STRING'              ,   7, 1, 1, GETUTCDATE()),
  ( 395, 'EQ_Warehouse', 'hedge.Options'                             , 'HedgeID2'                                  , 'hedge_id_2'                                , 'STRING'              ,   8, 1, 1, GETUTCDATE()),
  ( 396, 'EQ_Warehouse', 'hedge.Options'                             , 'HedgeRenewalDate'                          , 'hedge_renewal_timestamp'                   , 'TIMESTAMP'           ,   9, 1, 1, GETUTCDATE()),
  ( 397, 'EQ_Warehouse', 'hedge.Options'                             , 'ValueDate'                                 , 'value_timestamp'                           , 'TIMESTAMP'           ,  10, 1, 1, GETUTCDATE()),
  ( 398, 'EQ_Warehouse', 'hedge.Options'                             , 'SeriatimHedgeRatio'                        , 'seriatim_hedge_ratio'                      , 'DECIMAL(18,4)'       ,  11, 1, 1, GETUTCDATE()),
  ( 399, 'EQ_Warehouse', 'hedge.Options'                             , 'PresentValue'                              , 'present_value'                             , 'DECIMAL(18,4)'       ,  12, 1, 1, GETUTCDATE()),
  ( 400, 'EQ_Warehouse', 'hedge.Options'                             , 'Delta'                                     , 'delta'                                     , 'DECIMAL(18,4)'       ,  13, 1, 1, GETUTCDATE()),
  ( 401, 'EQ_Warehouse', 'hedge.Options'                             , 'Gamma'                                     , 'gamma'                                     , 'DECIMAL(18,4)'       ,  14, 1, 1, GETUTCDATE()),
  ( 402, 'EQ_Warehouse', 'hedge.Options'                             , 'Vega'                                      , 'vega'                                      , 'DECIMAL(18,4)'       ,  15, 1, 1, GETUTCDATE()),
  ( 403, 'EQ_Warehouse', 'hedge.Options'                             , 'Rho'                                       , 'rho'                                       , 'DECIMAL(18,4)'       ,  16, 1, 1, GETUTCDATE()),
  ( 404, 'EQ_Warehouse', 'hedge.Options'                             , 'Theta'                                     , 'theta'                                     , 'DECIMAL(18,4)'       ,  17, 1, 1, GETUTCDATE()),
  ( 405, 'EQ_Warehouse', 'hedge.Options'                             , 'NeedsHedged'                               , 'needs_hedged'                              , 'BOOLEAN'             ,  18, 1, 1, GETUTCDATE()),
  ( 406, 'EQ_Warehouse', 'hedge.Options'                             , 'IsHedged'                                  , 'is_hedged'                                 , 'BOOLEAN'             ,  19, 1, 1, GETUTCDATE()),
  ( 407, 'EQ_Warehouse', 'hedge.Options'                             , 'StartDate'                                 , 'start_timestamp'                           , 'TIMESTAMP'           ,  20, 1, 1, GETUTCDATE()),
  ( 408, 'EQ_Warehouse', 'hedge.Options'                             , 'EndDate'                                   , 'end_timestamp'                             , 'TIMESTAMP'           ,  21, 1, 1, GETUTCDATE());

-- [33] State (8 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 414, 'EQ_Warehouse', 'State'                                     , 'StateCode'                                 , 'state_code'                                , 'STRING'              ,   1, 1, 1, GETUTCDATE()),
  ( 415, 'EQ_Warehouse', 'State'                                     , 'StateName'                                 , 'state_name'                                , 'STRING'              ,   2, 1, 1, GETUTCDATE()),
  ( 416, 'EQ_Warehouse', 'State'                                     , 'DisplayOrder'                              , 'display_order'                             , 'INT'                 ,   3, 1, 1, GETUTCDATE());

-- [34] Date (37 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 422, 'EQ_Warehouse', 'Date'                                      , 'DatePK'                                    , 'date_id'                                   , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 423, 'EQ_Warehouse', 'Date'                                      , 'Date'                                      , 'calendar_timestamp'                        , 'TIMESTAMP'           ,   2, 1, 1, GETUTCDATE()),
  ( 424, 'EQ_Warehouse', 'Date'                                      , 'DateDisplay'                               , 'date_display'                              , 'STRING'              ,   3, 1, 1, GETUTCDATE()),
  ( 425, 'EQ_Warehouse', 'Date'                                      , 'DayOfMonth'                                , 'day_of_month'                              , 'STRING'              ,   4, 1, 1, GETUTCDATE()),
  ( 426, 'EQ_Warehouse', 'Date'                                      , 'DaySuffix'                                 , 'day_suffix'                                , 'STRING'              ,   5, 1, 1, GETUTCDATE()),
  ( 427, 'EQ_Warehouse', 'Date'                                      , 'DayName'                                   , 'day_name'                                  , 'STRING'              ,   6, 1, 1, GETUTCDATE()),
  ( 428, 'EQ_Warehouse', 'Date'                                      , 'DayOfWeek'                                 , 'day_of_week'                               , 'STRING'              ,   7, 1, 1, GETUTCDATE()),
  ( 429, 'EQ_Warehouse', 'Date'                                      , 'DayOfWeekInMonth'                          , 'day_of_week_in_month'                      , 'STRING'              ,   8, 1, 1, GETUTCDATE()),
  ( 430, 'EQ_Warehouse', 'Date'                                      , 'DayOfWeekInYear'                           , 'day_of_week_in_year'                       , 'STRING'              ,   9, 1, 1, GETUTCDATE()),
  ( 431, 'EQ_Warehouse', 'Date'                                      , 'DayOfYear'                                 , 'day_of_year'                               , 'STRING'              ,  10, 1, 1, GETUTCDATE()),
  ( 432, 'EQ_Warehouse', 'Date'                                      , 'WeekOfMonth'                               , 'week_of_month'                             , 'STRING'              ,  11, 1, 1, GETUTCDATE()),
  ( 433, 'EQ_Warehouse', 'Date'                                      , 'WeekOfQuarter'                             , 'week_of_quarter'                           , 'STRING'              ,  12, 1, 1, GETUTCDATE()),
  ( 434, 'EQ_Warehouse', 'Date'                                      , 'WeekOfYear'                                , 'week_of_year'                              , 'STRING'              ,  13, 1, 1, GETUTCDATE()),
  ( 435, 'EQ_Warehouse', 'Date'                                      , 'Month'                                     , 'month'                                     , 'STRING'              ,  14, 1, 1, GETUTCDATE()),
  ( 436, 'EQ_Warehouse', 'Date'                                      , 'MonthName'                                 , 'month_name'                                , 'STRING'              ,  15, 1, 1, GETUTCDATE()),
  ( 437, 'EQ_Warehouse', 'Date'                                      , 'MonthOfQuarter'                            , 'month_of_quarter'                          , 'STRING'              ,  16, 1, 1, GETUTCDATE()),
  ( 438, 'EQ_Warehouse', 'Date'                                      , 'Quarter'                                   , 'quarter'                                   , 'STRING'              ,  17, 1, 1, GETUTCDATE()),
  ( 439, 'EQ_Warehouse', 'Date'                                      , 'QuarterName'                               , 'quarter_name'                              , 'STRING'              ,  18, 1, 1, GETUTCDATE()),
  ( 440, 'EQ_Warehouse', 'Date'                                      , 'Year'                                      , 'year'                                      , 'STRING'              ,  19, 1, 1, GETUTCDATE()),
  ( 441, 'EQ_Warehouse', 'Date'                                      , 'YearName'                                  , 'year_name'                                 , 'STRING'              ,  20, 1, 1, GETUTCDATE()),
  ( 442, 'EQ_Warehouse', 'Date'                                      , 'MonthYear'                                 , 'month_year'                                , 'STRING'              ,  21, 1, 1, GETUTCDATE()),
  ( 443, 'EQ_Warehouse', 'Date'                                      , 'MMYYYY'                                    , 'mmyyyy'                                    , 'STRING'              ,  22, 1, 1, GETUTCDATE()),
  ( 444, 'EQ_Warehouse', 'Date'                                      , 'FirstDayOfMonth'                           , 'first_day_of_month'                        , 'DATE'                ,  23, 1, 1, GETUTCDATE()),
  ( 445, 'EQ_Warehouse', 'Date'                                      , 'LastDayOfMonth'                            , 'last_day_of_month'                         , 'DATE'                ,  24, 1, 1, GETUTCDATE()),
  ( 446, 'EQ_Warehouse', 'Date'                                      , 'FirstDayOfQuarter'                         , 'first_day_of_quarter'                      , 'DATE'                ,  25, 1, 1, GETUTCDATE()),
  ( 447, 'EQ_Warehouse', 'Date'                                      , 'LastDayOfQuarter'                          , 'last_day_of_quarter'                       , 'DATE'                ,  26, 1, 1, GETUTCDATE()),
  ( 448, 'EQ_Warehouse', 'Date'                                      , 'FirstDayOfYear'                            , 'first_day_of_year'                         , 'DATE'                ,  27, 1, 1, GETUTCDATE()),
  ( 449, 'EQ_Warehouse', 'Date'                                      , 'LastDayOfYear'                             , 'last_day_of_year'                          , 'DATE'                ,  28, 1, 1, GETUTCDATE()),
  ( 450, 'EQ_Warehouse', 'Date'                                      , 'IsWeekday'                                 , 'is_weekday'                                , 'BOOLEAN'             ,  29, 1, 1, GETUTCDATE()),
  ( 451, 'EQ_Warehouse', 'Date'                                      , 'IsHoliday'                                 , 'is_holiday'                                , 'BOOLEAN'             ,  30, 1, 1, GETUTCDATE()),
  ( 452, 'EQ_Warehouse', 'Date'                                      , 'HolidayName'                               , 'holiday_name'                              , 'STRING'              ,  31, 1, 1, GETUTCDATE()),
  ( 453, 'EQ_Warehouse', 'Date'                                      , 'IsLastDayOfMonth'                          , 'is_last_day_of_month'                      , 'BOOLEAN'             ,  32, 1, 1, GETUTCDATE());

-- [35] TrainingCourse (11 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 459, 'EQ_Warehouse', 'TrainingCourse'                            , 'TrainingCoursePK'                          , 'training_course_id'                        , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 460, 'EQ_Warehouse', 'TrainingCourse'                            , 'CourseName'                                , 'course_name'                               , 'STRING'              ,   2, 1, 1, GETUTCDATE()),
  ( 461, 'EQ_Warehouse', 'TrainingCourse'                            , 'Context'                                   , 'context'                                   , 'STRING'              ,   3, 1, 1, GETUTCDATE()),
  ( 462, 'EQ_Warehouse', 'TrainingCourse'                            , 'TrainingProductGroupKey'                   , 'training_product_group_key'                , 'INT'                 ,   4, 1, 1, GETUTCDATE()),
  ( 463, 'EQ_Warehouse', 'TrainingCourse'                            , 'TrainingStateGroupKey'                     , 'training_state_group_key'                  , 'INT'                 ,   5, 1, 1, GETUTCDATE()),
  ( 464, 'EQ_Warehouse', 'TrainingCourse'                            , 'Description'                               , 'description'                               , 'STRING'              ,   6, 1, 1, GETUTCDATE());

-- [36] AgentTraining (10 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 470, 'EQ_Warehouse', 'AgentTraining'                             , 'AgentTrainingPK'                           , 'agent_training_id'                         , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 471, 'EQ_Warehouse', 'AgentTraining'                             , 'AgentFK'                                   , 'agent_id'                                  , 'INT'                 ,   2, 1, 1, GETUTCDATE()),
  ( 472, 'EQ_Warehouse', 'AgentTraining'                             , 'TrainingCourseFK'                          , 'training_course_id'                        , 'INT'                 ,   3, 1, 1, GETUTCDATE()),
  ( 473, 'EQ_Warehouse', 'AgentTraining'                             , 'CompletionDate'                            , 'completion_timestamp'                      , 'TIMESTAMP'           ,   4, 1, 1, GETUTCDATE()),
  ( 474, 'EQ_Warehouse', 'AgentTraining'                             , 'ExpirationDate'                            , 'expiration_timestamp'                      , 'TIMESTAMP'           ,   5, 1, 1, GETUTCDATE());

-- [37] Company (17 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 480, 'EQ_Warehouse', 'Company'                                   , 'CompanyPK'                                 , 'company_id'                                , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 481, 'EQ_Warehouse', 'Company'                                   , 'CompanyCode'                               , 'company_code'                              , 'STRING'              ,   2, 1, 1, GETUTCDATE()),
  ( 482, 'EQ_Warehouse', 'Company'                                   , 'AgentFK'                                   , 'agent_id'                                  , 'INT'                 ,   3, 1, 1, GETUTCDATE()),
  ( 483, 'EQ_Warehouse', 'Company'                                   , 'Name'                                      , 'name'                                      , 'STRING'              ,   4, 1, 1, GETUTCDATE()),
  ( 484, 'EQ_Warehouse', 'Company'                                   , 'DisplayName'                               , 'display_name'                              , 'STRING'              ,   5, 1, 1, GETUTCDATE()),
  ( 485, 'EQ_Warehouse', 'Company'                                   , 'AddressLine1'                              , 'address_line_1'                            , 'STRING'              ,   6, 1, 1, GETUTCDATE()),
  ( 486, 'EQ_Warehouse', 'Company'                                   , 'AddressLine2'                              , 'address_line_2'                            , 'STRING'              ,   7, 1, 1, GETUTCDATE()),
  ( 487, 'EQ_Warehouse', 'Company'                                   , 'City'                                      , 'city'                                      , 'STRING'              ,   8, 1, 1, GETUTCDATE()),
  ( 488, 'EQ_Warehouse', 'Company'                                   , 'State'                                     , 'state'                                     , 'STRING'              ,   9, 1, 1, GETUTCDATE()),
  ( 489, 'EQ_Warehouse', 'Company'                                   , 'ZipCode'                                   , 'zip_code'                                  , 'STRING'              ,  10, 1, 1, GETUTCDATE()),
  ( 490, 'EQ_Warehouse', 'Company'                                   , 'Phone'                                     , 'phone'                                     , 'STRING'              ,  11, 1, 1, GETUTCDATE()),
  ( 491, 'EQ_Warehouse', 'Company'                                   , 'Footer'                                    , 'footer'                                    , 'STRING'              ,  12, 1, 1, GETUTCDATE());

-- [38] CAPStatusChange (12 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 497, 'EQ_Warehouse', 'CAPStatusChange'                           , 'CAPStatusChangePK'                         , 'cap_status_change_id'                      , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 498, 'EQ_Warehouse', 'CAPStatusChange'                           , 'ContractFK'                                , 'contract_id'                               , 'INT'                 ,   2, 1, 1, GETUTCDATE()),
  ( 499, 'EQ_Warehouse', 'CAPStatusChange'                           , 'SourceCompanyFK'                           , 'source_company_id'                         , 'INT'                 ,   3, 1, 1, GETUTCDATE()),
  ( 500, 'EQ_Warehouse', 'CAPStatusChange'                           , 'StatusChangeDate'                          , 'status_change_date'                        , 'TIMESTAMP'           ,   4, 1, 1, GETUTCDATE()),
  ( 501, 'EQ_Warehouse', 'CAPStatusChange'                           , 'StatusChangeCode'                          , 'status_change_code'                        , 'STRING'              ,   5, 1, 1, GETUTCDATE()),
  ( 502, 'EQ_Warehouse', 'CAPStatusChange'                           , 'ProcessDate'                               , 'process_date'                              , 'TIMESTAMP'           ,   6, 1, 1, GETUTCDATE()),
  ( 503, 'EQ_Warehouse', 'CAPStatusChange'                           , 'RenewalPeriod'                             , 'renewal_period'                            , 'INT'                 ,   7, 1, 1, GETUTCDATE());

-- [39] CAPRepayment (16 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 509, 'EQ_Warehouse', 'CAPRepayment'                              , 'CAPRepaymentPK'                            , 'cap_repayment_id'                          , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 510, 'EQ_Warehouse', 'CAPRepayment'                              , 'SourceKey'                                 , 'source_key'                                , 'BIGINT'              ,   2, 1, 1, GETUTCDATE()),
  ( 511, 'EQ_Warehouse', 'CAPRepayment'                              , 'SourceCompanyFK'                           , 'source_company_id'                         , 'INT'                 ,   3, 1, 1, GETUTCDATE()),
  ( 512, 'EQ_Warehouse', 'CAPRepayment'                              , 'PlanCode'                                  , 'plan_code'                                 , 'STRING'              ,   4, 1, 1, GETUTCDATE()),
  ( 513, 'EQ_Warehouse', 'CAPRepayment'                              , 'PlanCode2'                                 , 'plan_code_2'                               , 'STRING'              ,   5, 1, 1, GETUTCDATE()),
  ( 514, 'EQ_Warehouse', 'CAPRepayment'                              , 'OwnerResState'                             , 'owner_res_state'                           , 'STRING'              ,   6, 1, 1, GETUTCDATE()),
  ( 515, 'EQ_Warehouse', 'CAPRepayment'                              , 'OwnerCountry'                              , 'owner_country'                             , 'STRING'              ,   7, 1, 1, GETUTCDATE()),
  ( 516, 'EQ_Warehouse', 'CAPRepayment'                              , 'TerminationDate'                           , 'termination_date'                          , 'TIMESTAMP'           ,   8, 1, 1, GETUTCDATE()),
  ( 517, 'EQ_Warehouse', 'CAPRepayment'                              , 'FactorTrail'                               , 'factor_trail'                              , 'DECIMAL(18,4)'       ,   9, 1, 1, GETUTCDATE()),
  ( 518, 'EQ_Warehouse', 'CAPRepayment'                              , 'RenewalPeriod'                             , 'renewal_period'                            , 'INT'                 ,  10, 1, 1, GETUTCDATE()),
  ( 519, 'EQ_Warehouse', 'CAPRepayment'                              , 'CommissionableAmount'                      , 'commissionable_amount'                     , 'DECIMAL(18,4)'       ,  11, 1, 1, GETUTCDATE());

-- [40] ActivityType (11 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 525, 'EQ_Warehouse', 'ActivityType'                              , 'ActivityTypePK'                            , 'activity_type_id'                          , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 526, 'EQ_Warehouse', 'ActivityType'                              , 'ActivityTypeName'                          , 'activity_type_name'                        , 'STRING'              ,   2, 1, 1, GETUTCDATE()),
  ( 527, 'EQ_Warehouse', 'ActivityType'                              , 'ActivityTypeQualifier'                     , 'activity_type_qualifier'                   , 'STRING'              ,   3, 1, 1, GETUTCDATE()),
  ( 528, 'EQ_Warehouse', 'ActivityType'                              , 'Source'                                    , 'source'                                    , 'STRING'              ,   4, 1, 1, GETUTCDATE()),
  ( 529, 'EQ_Warehouse', 'ActivityType'                              , 'ValueType'                                 , 'value_type'                                , 'STRING'              ,   5, 1, 1, GETUTCDATE()),
  ( 530, 'EQ_Warehouse', 'ActivityType'                              , 'SortOrder'                                 , 'sort_order'                                , 'INT'                 ,   6, 1, 1, GETUTCDATE());

-- [41] ActivityFinancial (18 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 536, 'EQ_Warehouse', 'ActivityFinancial'                         , 'ActivityPK'                                , 'activity_id'                               , 'BIGINT'              ,   1, 1, 1, GETUTCDATE()),
  ( 537, 'EQ_Warehouse', 'ActivityFinancial'                         , 'FreeAmount'                                , 'free_amount'                               , 'DECIMAL(18,4)'       ,   2, 1, 1, GETUTCDATE()),
  ( 538, 'EQ_Warehouse', 'ActivityFinancial'                         , 'SurrenderCharge'                           , 'surrender_charge'                          , 'DECIMAL(18,4)'       ,   3, 1, 1, GETUTCDATE()),
  ( 539, 'EQ_Warehouse', 'ActivityFinancial'                         , 'MVA'                                       , 'mva'                                       , 'DECIMAL(18,4)'       ,   4, 1, 1, GETUTCDATE()),
  ( 540, 'EQ_Warehouse', 'ActivityFinancial'                         , 'PolicyFee'                                 , 'policy_fee'                                , 'DECIMAL(18,4)'       ,   5, 1, 1, GETUTCDATE()),
  ( 541, 'EQ_Warehouse', 'ActivityFinancial'                         , 'COIRefund'                                 , 'coi_refund'                                , 'DECIMAL(18,4)'       ,   6, 1, 1, GETUTCDATE()),
  ( 542, 'EQ_Warehouse', 'ActivityFinancial'                         , 'ABRDiscountCharge'                         , 'abr_discount_charge'                       , 'DECIMAL(18,4)'       ,   7, 1, 1, GETUTCDATE()),
  ( 543, 'EQ_Warehouse', 'ActivityFinancial'                         , 'AdminCharge'                               , 'admin_charge'                              , 'DECIMAL(18,4)'       ,   8, 1, 1, GETUTCDATE()),
  ( 544, 'EQ_Warehouse', 'ActivityFinancial'                         , 'FederalTax'                                , 'federal_tax'                               , 'DECIMAL(18,4)'       ,   9, 1, 1, GETUTCDATE()),
  ( 545, 'EQ_Warehouse', 'ActivityFinancial'                         , 'StateTax'                                  , 'state_tax'                                 , 'DECIMAL(18,4)'       ,  10, 1, 1, GETUTCDATE()),
  ( 546, 'EQ_Warehouse', 'ActivityFinancial'                         , 'Rate'                                      , 'rate'                                      , 'DECIMAL(18,4)'       ,  11, 1, 1, GETUTCDATE()),
  ( 547, 'EQ_Warehouse', 'ActivityFinancial'                         , 'BaseAmount'                                , 'base_amount'                               , 'DECIMAL(18,4)'       ,  12, 1, 1, GETUTCDATE()),
  ( 548, 'EQ_Warehouse', 'ActivityFinancial'                         , 'TaxableBenefit'                            , 'taxable_benefit'                           , 'DECIMAL(18,4)'       ,  13, 1, 1, GETUTCDATE());

-- [42] AccountingDetail (23 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 554, 'EQ_Warehouse', 'AccountingDetail'                          , 'AccountingPK'                              , 'accounting_id'                             , 'BIGINT'              ,   1, 1, 1, GETUTCDATE()),
  ( 555, 'EQ_Warehouse', 'AccountingDetail'                          , 'SourceCode'                                , 'source_code'                               , 'STRING'              ,   2, 1, 1, GETUTCDATE()),
  ( 556, 'EQ_Warehouse', 'AccountingDetail'                          , 'ReferenceData'                             , 'reference_data'                            , 'STRING'              ,   3, 1, 1, GETUTCDATE()),
  ( 557, 'EQ_Warehouse', 'AccountingDetail'                          , 'Approval'                                  , 'approval'                                  , 'STRING'              ,   4, 1, 1, GETUTCDATE()),
  ( 558, 'EQ_Warehouse', 'AccountingDetail'                          , 'Description'                               , 'description'                               , 'STRING'              ,   5, 1, 1, GETUTCDATE()),
  ( 559, 'EQ_Warehouse', 'AccountingDetail'                          , 'CompanyCode'                               , 'company_code'                              , 'STRING'              ,   6, 1, 1, GETUTCDATE()),
  ( 560, 'EQ_Warehouse', 'AccountingDetail'                          , 'DCIndicator'                               , 'dc_indicator'                              , 'STRING'              ,   7, 1, 1, GETUTCDATE()),
  ( 561, 'EQ_Warehouse', 'AccountingDetail'                          , 'EntryOperator'                             , 'entry_operator'                            , 'STRING'              ,   8, 1, 1, GETUTCDATE()),
  ( 562, 'EQ_Warehouse', 'AccountingDetail'                          , 'ApprovalOperator'                          , 'approval_operator'                         , 'STRING'              ,   9, 1, 1, GETUTCDATE()),
  ( 563, 'EQ_Warehouse', 'AccountingDetail'                          , 'APEXTIndicator'                            , 'apext_indicator'                           , 'STRING'              ,  10, 1, 1, GETUTCDATE()),
  ( 564, 'EQ_Warehouse', 'AccountingDetail'                          , 'SuspenseEXTIndicator'                      , 'suspense_ext_indicator'                    , 'STRING'              ,  11, 1, 1, GETUTCDATE()),
  ( 565, 'EQ_Warehouse', 'AccountingDetail'                          , 'EntryGenIndicator'                         , 'entry_gen_indicator'                       , 'STRING'              ,  12, 1, 1, GETUTCDATE()),
  ( 566, 'EQ_Warehouse', 'AccountingDetail'                          , 'Treaty'                                    , 'treaty'                                    , 'STRING'              ,  13, 1, 1, GETUTCDATE()),
  ( 567, 'EQ_Warehouse', 'AccountingDetail'                          , 'QualType'                                  , 'qual_type'                                 , 'STRING'              ,  14, 1, 1, GETUTCDATE()),
  ( 568, 'EQ_Warehouse', 'AccountingDetail'                          , 'SEG_EDITTrxPK'                             , 'seg_edit_trx_id'                           , 'BIGINT'              ,  15, 1, 1, GETUTCDATE()),
  ( 569, 'EQ_Warehouse', 'AccountingDetail'                          , 'SEG_PlacedAgentPK'                         , 'seg_placed_agent_id'                       , 'BIGINT'              ,  16, 1, 1, GETUTCDATE()),
  ( 570, 'EQ_Warehouse', 'AccountingDetail'                          , 'CostCenter'                                , 'cost_center'                               , 'STRING'              ,  17, 1, 1, GETUTCDATE()),
  ( 571, 'EQ_Warehouse', 'AccountingDetail'                          , 'SuspenseCode'                              , 'suspense_code'                             , 'STRING'              ,  18, 1, 1, GETUTCDATE());

-- [43] AccountingAccount (16 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 577, 'EQ_Warehouse', 'AccountingAccount'                         , 'AccountingAccountPK'                       , 'accounting_account_id'                     , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 578, 'EQ_Warehouse', 'AccountingAccount'                         , 'AccountNumber'                             , 'account_number'                            , 'STRING'              ,   2, 1, 1, GETUTCDATE()),
  ( 579, 'EQ_Warehouse', 'AccountingAccount'                         , 'AccountSource'                             , 'account_source'                            , 'STRING'              ,   3, 1, 1, GETUTCDATE()),
  ( 580, 'EQ_Warehouse', 'AccountingAccount'                         , 'ClassCode'                                 , 'class_code'                                , 'STRING'              ,   4, 1, 1, GETUTCDATE()),
  ( 581, 'EQ_Warehouse', 'AccountingAccount'                         , 'CubeDescription'                           , 'cube_description'                          , 'STRING'              ,   5, 1, 1, GETUTCDATE()),
  ( 582, 'EQ_Warehouse', 'AccountingAccount'                         , 'GroupIndicator'                            , 'group_indicator'                           , 'BOOLEAN'             ,   6, 1, 1, GETUTCDATE()),
  ( 583, 'EQ_Warehouse', 'AccountingAccount'                         , 'CededIndicator'                            , 'ceded_indicator'                           , 'BOOLEAN'             ,   7, 1, 1, GETUTCDATE()),
  ( 584, 'EQ_Warehouse', 'AccountingAccount'                         , 'Context'                                   , 'context'                                   , 'STRING'              ,   8, 1, 1, GETUTCDATE()),
  ( 585, 'EQ_Warehouse', 'AccountingAccount'                         , 'ActuarialGrouping'                         , 'actuarial_grouping'                        , 'STRING'              ,   9, 1, 1, GETUTCDATE()),
  ( 586, 'EQ_Warehouse', 'AccountingAccount'                         , 'AccountDescription'                        , 'account_description'                       , 'STRING'              ,  10, 1, 1, GETUTCDATE()),
  ( 587, 'EQ_Warehouse', 'AccountingAccount'                         , 'AccountingReportingGroupKey'               , 'accounting_reporting_group_key'            , 'INT'                 ,  11, 1, 1, GETUTCDATE());

-- [44] Accounting (24 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 593, 'EQ_Warehouse', 'Accounting'                                , 'AccountingPK'                              , 'accounting_id'                             , 'BIGINT'              ,   1, 1, 1, GETUTCDATE()),
  ( 594, 'EQ_Warehouse', 'Accounting'                                , 'SourceSystem'                              , 'source_system_code'                        , 'STRING'              ,   2, 1, 1, GETUTCDATE()),
  ( 595, 'EQ_Warehouse', 'Accounting'                                , 'TranID'                                    , 'transaction_id'                            , 'INT'                 ,   3, 1, 1, GETUTCDATE()),
  ( 596, 'EQ_Warehouse', 'Accounting'                                , 'TranDetailID'                              , 'transaction_detail_id'                     , 'BIGINT'              ,   4, 1, 1, GETUTCDATE()),
  ( 597, 'EQ_Warehouse', 'Accounting'                                , 'StatusCode'                                , 'status_code'                               , 'STRING'              ,   5, 1, 1, GETUTCDATE()),
  ( 598, 'EQ_Warehouse', 'Accounting'                                , 'StatusIndicator'                           , 'status_indicator'                          , 'STRING'              ,   6, 1, 1, GETUTCDATE()),
  ( 599, 'EQ_Warehouse', 'Accounting'                                , 'BasisCode'                                 , 'basis_code'                                , 'STRING'              ,   7, 1, 1, GETUTCDATE()),
  ( 600, 'EQ_Warehouse', 'Accounting'                                , 'State'                                     , 'state_code'                                , 'STRING'              ,   8, 1, 1, GETUTCDATE()),
  ( 601, 'EQ_Warehouse', 'Accounting'                                , 'EffectiveDateFK'                           , 'effective_date_id'                         , 'INT'                 ,   9, 1, 1, GETUTCDATE()),
  ( 602, 'EQ_Warehouse', 'Accounting'                                , 'PeriodDateFK'                              , 'period_date_id'                            , 'INT'                 ,  10, 1, 1, GETUTCDATE()),
  ( 603, 'EQ_Warehouse', 'Accounting'                                , 'AccountingAccountFK'                       , 'accounting_account_id'                     , 'INT'                 ,  11, 1, 1, GETUTCDATE()),
  ( 604, 'EQ_Warehouse', 'Accounting'                                , 'EntryDate'                                 , 'entry_date'                                , 'DATE'                ,  12, 1, 1, GETUTCDATE()),
  ( 605, 'EQ_Warehouse', 'Accounting'                                , 'EntryUpdateDate'                           , 'entry_update_date'                         , 'DATE'                ,  13, 1, 1, GETUTCDATE()),
  ( 606, 'EQ_Warehouse', 'Accounting'                                , 'ContractFK'                                , 'contract_id'                               , 'INT'                 ,  14, 1, 1, GETUTCDATE()),
  ( 607, 'EQ_Warehouse', 'Accounting'                                , 'InvestmentFK'                              , 'investment_id'                             , 'INT'                 ,  15, 1, 1, GETUTCDATE()),
  ( 608, 'EQ_Warehouse', 'Accounting'                                , 'ProductFK'                                 , 'product_id'                                , 'INT'                 ,  16, 1, 1, GETUTCDATE()),
  ( 609, 'EQ_Warehouse', 'Accounting'                                , 'AgentFK'                                   , 'agent_id'                                  , 'INT'                 ,  17, 1, 1, GETUTCDATE()),
  ( 610, 'EQ_Warehouse', 'Accounting'                                , 'Amount'                                    , 'amount'                                    , 'DECIMAL(18,4)'       ,  18, 1, 1, GETUTCDATE()),
  ( 611, 'EQ_Warehouse', 'Accounting'                                , 'Block'                                     , 'block_code'                                , 'STRING'              ,  19, 1, 1, GETUTCDATE());

-- [45] Surrender (18 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 617, 'EQ_Warehouse', 'Surrender'                                 , 'SurrenderPK'                               , 'surrender_id'                              , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 618, 'EQ_Warehouse', 'Surrender'                                 , 'ProductFK'                                 , 'product_id'                                , 'INT'                 ,   2, 1, 1, GETUTCDATE()),
  ( 619, 'EQ_Warehouse', 'Surrender'                                 , 'FundNumber'                                , 'fund_number'                               , 'STRING'              ,   3, 1, 1, GETUTCDATE()),
  ( 620, 'EQ_Warehouse', 'Surrender'                                 , 'State'                                     , 'state_code'                                , 'STRING'              ,   4, 1, 1, GETUTCDATE()),
  ( 621, 'EQ_Warehouse', 'Surrender'                                 , 'Gender'                                    , 'gender'                                    , 'STRING'              ,   5, 1, 1, GETUTCDATE()),
  ( 622, 'EQ_Warehouse', 'Surrender'                                 , 'Class'                                     , 'risk_class'                                , 'STRING'              ,   6, 1, 1, GETUTCDATE()),
  ( 623, 'EQ_Warehouse', 'Surrender'                                 , 'Age'                                       , 'customer_age'                              , 'INT'                 ,   7, 1, 1, GETUTCDATE()),
  ( 624, 'EQ_Warehouse', 'Surrender'                                 , 'ContractYear'                              , 'policy_year'                               , 'INT'                 ,   8, 1, 1, GETUTCDATE()),
  ( 625, 'EQ_Warehouse', 'Surrender'                                 , 'SurrenderLength'                           , 'penalty_duration_years'                    , 'INT'                 ,   9, 1, 1, GETUTCDATE()),
  ( 626, 'EQ_Warehouse', 'Surrender'                                 , 'Rate'                                      , 'penalty_percentage'                        , 'DECIMAL(18,4)'       ,  10, 1, 1, GETUTCDATE()),
  ( 627, 'EQ_Warehouse', 'Surrender'                                 , 'RateAppliedTo'                             , 'rate_calculation_basis'                    , 'STRING'              ,  11, 1, 1, GETUTCDATE()),
  ( 628, 'EQ_Warehouse', 'Surrender'                                 , 'EffectiveDate'                             , 'rule_start_date'                           , 'TIMESTAMP'           ,  12, 1, 1, GETUTCDATE()),
  ( 629, 'EQ_Warehouse', 'Surrender'                                 , 'EndDate'                                   , 'rule_end_date'                             , 'TIMESTAMP'           ,  13, 1, 1, GETUTCDATE());

-- [46] InvestmentDetail (14 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 635, 'EQ_Warehouse', 'InvestmentDetail'                          , 'InvestmentDetailPK'                        , 'investment_detail_id'                      , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 636, 'EQ_Warehouse', 'InvestmentDetail'                          , 'Name'                                      , 'investment_detail_name'                    , 'STRING'              ,   2, 1, 1, GETUTCDATE()),
  ( 637, 'EQ_Warehouse', 'InvestmentDetail'                          , 'FundType'                                  , 'fund_type'                                 , 'STRING'              ,   3, 1, 1, GETUTCDATE()),
  ( 638, 'EQ_Warehouse', 'InvestmentDetail'                          , 'GroupingName'                              , 'grouping_name'                             , 'STRING'              ,   4, 1, 1, GETUTCDATE()),
  ( 639, 'EQ_Warehouse', 'InvestmentDetail'                          , 'MarketingName'                             , 'marketing_name'                            , 'STRING'              ,   5, 1, 1, GETUTCDATE()),
  ( 640, 'EQ_Warehouse', 'InvestmentDetail'                          , 'AltMarketingName'                          , 'alt_marketing_name'                        , 'STRING'              ,   6, 1, 1, GETUTCDATE()),
  ( 641, 'EQ_Warehouse', 'InvestmentDetail'                          , 'SortOrder'                                 , 'sort_order'                                , 'STRING'              ,   7, 1, 1, GETUTCDATE()),
  ( 642, 'EQ_Warehouse', 'InvestmentDetail'                          , 'IsCap'                                     , 'is_cap_indicator'                          , 'BOOLEAN'             ,   8, 1, 1, GETUTCDATE()),
  ( 643, 'EQ_Warehouse', 'InvestmentDetail'                          , 'FundStartDate'                             , 'fund_start_date'                           , 'TIMESTAMP'           ,   9, 1, 1, GETUTCDATE());

-- [47] Investment (13 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 649, 'EQ_Warehouse', 'Investment'                                , 'InvestmentPK'                              , 'investment_id'                             , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 650, 'EQ_Warehouse', 'Investment'                                , 'InvestmentKey'                             , 'investment_key'                            , 'INT'                 ,   2, 1, 1, GETUTCDATE()),
  ( 651, 'EQ_Warehouse', 'Investment'                                , 'InvestmentName'                            , 'investment_name'                           , 'STRING'              ,   3, 1, 1, GETUTCDATE()),
  ( 652, 'EQ_Warehouse', 'Investment'                                , 'InvestmentDescription'                     , 'investment_description'                    , 'STRING'              ,   4, 1, 1, GETUTCDATE()),
  ( 653, 'EQ_Warehouse', 'Investment'                                , 'EffectiveDate'                             , 'effective_date'                            , 'TIMESTAMP'           ,   5, 1, 1, GETUTCDATE()),
  ( 654, 'EQ_Warehouse', 'Investment'                                , 'Active'                                    , 'active_indicator'                          , 'BOOLEAN'             ,   6, 1, 1, GETUTCDATE()),
  ( 655, 'EQ_Warehouse', 'Investment'                                , 'StartDate'                                 , 'start_timestamp'                           , 'TIMESTAMP'           ,   7, 1, 1, GETUTCDATE()),
  ( 656, 'EQ_Warehouse', 'Investment'                                , 'EndDate'                                   , 'end_timestamp'                             , 'TIMESTAMP'           ,   8, 1, 1, GETUTCDATE());

-- [48] Activity (27 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 662, 'EQ_Warehouse', 'Activity'                                  , 'ActivityPK'                                , 'activity_id'                               , 'BIGINT'              ,   1, 1, 1, GETUTCDATE()),
  ( 663, 'EQ_Warehouse', 'Activity'                                  , 'ActivityTypeFK'                            , 'activity_type_id'                          , 'INT'                 ,   2, 1, 1, GETUTCDATE()),
  ( 664, 'EQ_Warehouse', 'Activity'                                  , 'CompanyFK'                                 , 'company_id'                                , 'INT'                 ,   3, 1, 1, GETUTCDATE()),
  ( 665, 'EQ_Warehouse', 'Activity'                                  , 'ContractFK'                                , 'contract_id'                               , 'INT'                 ,   4, 1, 1, GETUTCDATE()),
  ( 666, 'EQ_Warehouse', 'Activity'                                  , 'ProductFK'                                 , 'product_id'                                , 'INT'                 ,   5, 1, 1, GETUTCDATE()),
  ( 667, 'EQ_Warehouse', 'Activity'                                  , 'InvestmentFK'                              , 'investment_id'                             , 'INT'                 ,   6, 1, 1, GETUTCDATE()),
  ( 668, 'EQ_Warehouse', 'Activity'                                  , 'AccountingFK'                              , 'accounting_id'                             , 'INT'                 ,   7, 1, 1, GETUTCDATE()),
  ( 669, 'EQ_Warehouse', 'Activity'                                  , 'AccountingAccountFK'                       , 'accounting_account_id'                     , 'INT'                 ,   8, 1, 1, GETUTCDATE()),
  ( 670, 'EQ_Warehouse', 'Activity'                                  , 'CAPRepaymentFK'                            , 'cap_repayment_id'                          , 'INT'                 ,   9, 1, 1, GETUTCDATE()),
  ( 671, 'EQ_Warehouse', 'Activity'                                  , 'HierarchySetKey'                           , 'hierarchy_set_id'                          , 'INT'                 ,  10, 1, 1, GETUTCDATE()),
  ( 672, 'EQ_Warehouse', 'Activity'                                  , 'AgentFK'                                   , 'agent_id'                                  , 'INT'                 ,  11, 1, 1, GETUTCDATE()),
  ( 673, 'EQ_Warehouse', 'Activity'                                  , 'ActivityClientFK'                          , 'activity_client_id'                        , 'INT'                 ,  12, 1, 1, GETUTCDATE()),
  ( 674, 'EQ_Warehouse', 'Activity'                                  , 'ActivityPayeeFK'                           , 'activity_payee_id'                         , 'INT'                 ,  13, 1, 1, GETUTCDATE()),
  ( 675, 'EQ_Warehouse', 'Activity'                                  , 'EffectiveDateFK'                           , 'effective_date_id'                         , 'INT'                 ,  14, 1, 1, GETUTCDATE()),
  ( 676, 'EQ_Warehouse', 'Activity'                                  , 'ProcessDateFK'                             , 'process_date_id'                           , 'INT'                 ,  15, 1, 1, GETUTCDATE()),
  ( 677, 'EQ_Warehouse', 'Activity'                                  , 'ReleaseDate'                               , 'release_date'                              , 'TIMESTAMP'           ,  16, 1, 1, GETUTCDATE()),
  ( 678, 'EQ_Warehouse', 'Activity'                                  , 'PeriodDate'                                , 'period_date'                               , 'TIMESTAMP'           ,  17, 1, 1, GETUTCDATE()),
  ( 679, 'EQ_Warehouse', 'Activity'                                  , 'GrossAmount'                               , 'gross_amount'                              , 'DECIMAL(18,4)'       ,  18, 1, 1, GETUTCDATE()),
  ( 680, 'EQ_Warehouse', 'Activity'                                  , 'NetAmount'                                 , 'net_amount'                                , 'DECIMAL(18,4)'       ,  19, 1, 1, GETUTCDATE()),
  ( 681, 'EQ_Warehouse', 'Activity'                                  , 'CheckAmount'                               , 'check_amount'                              , 'DECIMAL(18,4)'       ,  20, 1, 1, GETUTCDATE()),
  ( 682, 'EQ_Warehouse', 'Activity'                                  , 'DistributionType'                          , 'distribution_type'                         , 'STRING'              ,  21, 1, 1, GETUTCDATE()),
  ( 683, 'EQ_Warehouse', 'Activity'                                  , 'TextValue'                                 , 'activity_notes'                            , 'STRING'              ,  22, 1, 1, GETUTCDATE());

-- [49] AccountValue (16 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 689, 'EQ_Warehouse', 'AccountValue'                              , 'AccountValuePK'                            , 'account_value_id'                          , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 690, 'EQ_Warehouse', 'AccountValue'                              , 'ContractFK'                                , 'contract_id'                               , 'INT'                 ,   2, 1, 1, GETUTCDATE()),
  ( 691, 'EQ_Warehouse', 'AccountValue'                              , 'InvestmentFK'                              , 'investment_id'                             , 'INT'                 ,   3, 1, 1, GETUTCDATE()),
  ( 692, 'EQ_Warehouse', 'AccountValue'                              , 'Value'                                     , 'account_value_amount'                      , 'DECIMAL(18,4)'       ,   4, 1, 1, GETUTCDATE()),
  ( 693, 'EQ_Warehouse', 'AccountValue'                              , 'CurrentInterestRate'                       , 'current_interest_rate'                     , 'DECIMAL(18,4)'       ,   5, 1, 1, GETUTCDATE()),
  ( 694, 'EQ_Warehouse', 'AccountValue'                              , 'AllocationPercent'                         , 'allocation_percentage'                     , 'DECIMAL(18,4)'       ,   6, 1, 1, GETUTCDATE()),
  ( 695, 'EQ_Warehouse', 'AccountValue'                              , 'DepositDate'                               , 'deposit_date'                              , 'TIMESTAMP'           ,   7, 1, 1, GETUTCDATE()),
  ( 696, 'EQ_Warehouse', 'AccountValue'                              , 'RenewalDate'                               , 'renewal_date'                              , 'TIMESTAMP'           ,   8, 1, 1, GETUTCDATE()),
  ( 697, 'EQ_Warehouse', 'AccountValue'                              , 'ValuationDate'                             , 'valuation_date'                            , 'TIMESTAMP'           ,   9, 1, 1, GETUTCDATE()),
  ( 698, 'EQ_Warehouse', 'AccountValue'                              , 'StartDate'                                 , 'start_timestamp'                           , 'TIMESTAMP'           ,  10, 1, 1, GETUTCDATE()),
  ( 699, 'EQ_Warehouse', 'AccountValue'                              , 'EndDate'                                   , 'end_timestamp'                             , 'TIMESTAMP'           ,  11, 1, 1, GETUTCDATE());

-- [50] Product (14 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 705, 'EQ_Warehouse', 'Product'                                   , 'ProductPK'                                 , 'product_id'                                , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 706, 'EQ_Warehouse', 'Product'                                   , 'ProductName'                               , 'product_name'                              , 'STRING'              ,   2, 1, 1, GETUTCDATE()),
  ( 707, 'EQ_Warehouse', 'Product'                                   , 'MarketingName'                             , 'marketing_name'                            , 'STRING'              ,   3, 1, 1, GETUTCDATE()),
  ( 708, 'EQ_Warehouse', 'Product'                                   , 'ProductType'                               , 'product_type'                              , 'STRING'              ,   4, 1, 1, GETUTCDATE()),
  ( 709, 'EQ_Warehouse', 'Product'                                   , 'CUSIPNumber'                               , 'cusip_number'                              , 'STRING'              ,   5, 1, 1, GETUTCDATE()),
  ( 710, 'EQ_Warehouse', 'Product'                                   , 'Context'                                   , 'product_context'                           , 'STRING'              ,   6, 1, 1, GETUTCDATE()),
  ( 711, 'EQ_Warehouse', 'Product'                                   , 'GLLOB'                                     , 'gl_line_of_business'                       , 'STRING'              ,   7, 1, 1, GETUTCDATE()),
  ( 712, 'EQ_Warehouse', 'Product'                                   , 'Status'                                    , 'status'                                    , 'STRING'              ,   8, 1, 1, GETUTCDATE()),
  ( 713, 'EQ_Warehouse', 'Product'                                   , 'EffectiveDate'                             , 'effective_date'                            , 'TIMESTAMP'           ,   9, 1, 1, GETUTCDATE());

-- [51] Agent (20 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 719, 'EQ_Warehouse', 'Agent'                                     , 'AgentPK'                                   , 'agent_id'                                  , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 720, 'EQ_Warehouse', 'Agent'                                     , 'AgentNumber'                               , 'agent_number'                              , 'STRING'              ,   2, 1, 1, GETUTCDATE()),
  ( 721, 'EQ_Warehouse', 'Agent'                                     , 'DisplayName'                               , 'display_name'                              , 'STRING'              ,   3, 1, 1, GETUTCDATE()),
  ( 722, 'EQ_Warehouse', 'Agent'                                     , 'NPN'                                       , 'national_producer_number'                  , 'STRING'              ,   4, 1, 1, GETUTCDATE()),
  ( 723, 'EQ_Warehouse', 'Agent'                                     , 'NASD'                                      , 'nasd_finra_number'                         , 'STRING'              ,   5, 1, 1, GETUTCDATE()),
  ( 724, 'EQ_Warehouse', 'Agent'                                     , 'AgentType'                                 , 'agent_type'                                , 'STRING'              ,   6, 1, 1, GETUTCDATE()),
  ( 725, 'EQ_Warehouse', 'Agent'                                     , 'Status'                                    , 'status'                                    , 'STRING'              ,   7, 1, 1, GETUTCDATE()),
  ( 726, 'EQ_Warehouse', 'Agent'                                     , 'HireDate'                                  , 'hire_date'                                 , 'TIMESTAMP'           ,   8, 1, 1, GETUTCDATE()),
  ( 727, 'EQ_Warehouse', 'Agent'                                     , 'TerminationDate'                           , 'termination_date'                          , 'TIMESTAMP'           ,   9, 1, 1, GETUTCDATE()),
  ( 728, 'EQ_Warehouse', 'Agent'                                     , 'ClientFK'                                  , 'client_id'                                 , 'INT'                 ,  10, 1, 1, GETUTCDATE()),
  ( 729, 'EQ_Warehouse', 'Agent'                                     , 'AddressGroupFK'                            , 'address_group_id'                          , 'INT'                 ,  11, 1, 1, GETUTCDATE()),
  ( 730, 'EQ_Warehouse', 'Agent'                                     , 'AdditionalInfoGroupFK'                     , 'additional_info_group_id'                  , 'INT'                 ,  12, 1, 1, GETUTCDATE()),
  ( 731, 'EQ_Warehouse', 'Agent'                                     , 'EffectiveDate'                             , 'effective_date'                            , 'TIMESTAMP'           ,  13, 1, 1, GETUTCDATE()),
  ( 732, 'EQ_Warehouse', 'Agent'                                     , 'StartTimestamp'                            , 'start_timestamp'                           , 'TIMESTAMP'           ,  14, 1, 1, GETUTCDATE()),
  ( 733, 'EQ_Warehouse', 'Agent'                                     , 'EndTimestamp'                              , 'end_timestamp'                             , 'TIMESTAMP'           ,  15, 1, 1, GETUTCDATE());

-- [52] Client (39 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 739, 'EQ_Warehouse', 'Client'                                    , 'ClientPK'                                  , 'client_id'                                 , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 740, 'EQ_Warehouse', 'Client'                                    , 'SourceKey'                                 , 'source_key'                                , 'BIGINT'              ,   2, 1, 1, GETUTCDATE()),
  ( 741, 'EQ_Warehouse', 'Client'                                    , 'TaxIDHash'                                 , 'tax_id_hash'                               , 'BINARY'              ,   3, 1, 1, GETUTCDATE()),
  ( 742, 'EQ_Warehouse', 'Client'                                    , 'Last4Hash'                                 , 'last_4_hash'                               , 'BINARY'              ,   4, 1, 1, GETUTCDATE()),
  ( 743, 'EQ_Warehouse', 'Client'                                    , 'Last4Token'                                , 'last_4_token'                              , 'STRING'              ,   5, 1, 1, GETUTCDATE()),
  ( 744, 'EQ_Warehouse', 'Client'                                    , 'DisplayName'                               , 'display_name'                              , 'STRING'              ,   6, 1, 1, GETUTCDATE()),
  ( 745, 'EQ_Warehouse', 'Client'                                    , 'FirstName'                                 , 'first_name'                                , 'STRING'              ,   7, 1, 1, GETUTCDATE()),
  ( 746, 'EQ_Warehouse', 'Client'                                    , 'MiddleName'                                , 'middle_name'                               , 'STRING'              ,   8, 1, 1, GETUTCDATE()),
  ( 747, 'EQ_Warehouse', 'Client'                                    , 'LastName'                                  , 'last_name'                                 , 'STRING'              ,   9, 1, 1, GETUTCDATE()),
  ( 748, 'EQ_Warehouse', 'Client'                                    , 'Prefix'                                    , 'prefix'                                    , 'STRING'              ,  10, 1, 1, GETUTCDATE()),
  ( 749, 'EQ_Warehouse', 'Client'                                    , 'Suffix'                                    , 'suffix'                                    , 'STRING'              ,  11, 1, 1, GETUTCDATE()),
  ( 750, 'EQ_Warehouse', 'Client'                                    , 'CorporateName'                             , 'corporate_name'                            , 'STRING'              ,  12, 1, 1, GETUTCDATE()),
  ( 751, 'EQ_Warehouse', 'Client'                                    , 'Gender'                                    , 'gender'                                    , 'STRING'              ,  13, 1, 1, GETUTCDATE()),
  ( 752, 'EQ_Warehouse', 'Client'                                    , 'Phone'                                     , 'phone_number'                              , 'STRING'              ,  14, 1, 1, GETUTCDATE()),
  ( 753, 'EQ_Warehouse', 'Client'                                    , 'Email'                                     , 'email_address'                             , 'STRING'              ,  15, 1, 1, GETUTCDATE()),
  ( 754, 'EQ_Warehouse', 'Client'                                    , 'Fax'                                       , 'fax_number'                                , 'STRING'              ,  16, 1, 1, GETUTCDATE()),
  ( 755, 'EQ_Warehouse', 'Client'                                    , 'BirthDate'                                 , 'birth_date'                                , 'TIMESTAMP'           ,  17, 1, 1, GETUTCDATE()),
  ( 756, 'EQ_Warehouse', 'Client'                                    , 'DeathDate'                                 , 'death_date'                                , 'TIMESTAMP'           ,  18, 1, 1, GETUTCDATE()),
  ( 757, 'EQ_Warehouse', 'Client'                                    , 'Status'                                    , 'status'                                    , 'STRING'              ,  19, 1, 1, GETUTCDATE()),
  ( 758, 'EQ_Warehouse', 'Client'                                    , 'PayPreference'                             , 'pay_preference'                            , 'STRING'              ,  20, 1, 1, GETUTCDATE()),
  ( 759, 'EQ_Warehouse', 'Client'                                    , 'ExternalAccountGroupFK'                    , 'external_account_group_id'                 , 'INT'                 ,  21, 1, 1, GETUTCDATE()),
  ( 760, 'EQ_Warehouse', 'Client'                                    , 'Address1'                                  , 'address_line_1'                            , 'STRING'              ,  22, 1, 1, GETUTCDATE()),
  ( 761, 'EQ_Warehouse', 'Client'                                    , 'Address2'                                  , 'address_line_2'                            , 'STRING'              ,  23, 1, 1, GETUTCDATE()),
  ( 762, 'EQ_Warehouse', 'Client'                                    , 'City'                                      , 'city'                                      , 'STRING'              ,  24, 1, 1, GETUTCDATE()),
  ( 763, 'EQ_Warehouse', 'Client'                                    , 'State'                                     , 'state_code'                                , 'STRING'              ,  25, 1, 1, GETUTCDATE()),
  ( 764, 'EQ_Warehouse', 'Client'                                    , 'ZipCode'                                   , 'zip_code'                                  , 'STRING'              ,  26, 1, 1, GETUTCDATE()),
  ( 765, 'EQ_Warehouse', 'Client'                                    , 'County'                                    , 'county'                                    , 'STRING'              ,  27, 1, 1, GETUTCDATE()),
  ( 766, 'EQ_Warehouse', 'Client'                                    , 'CountryCode'                               , 'country_code'                              , 'STRING'              ,  28, 1, 1, GETUTCDATE()),
  ( 767, 'EQ_Warehouse', 'Client'                                    , 'AdditionalInfoGroupFK'                     , 'additional_info_group_id'                  , 'INT'                 ,  29, 1, 1, GETUTCDATE()),
  ( 768, 'EQ_Warehouse', 'Client'                                    , 'VerificationDetails'                       , 'verification_details'                      , 'STRING'              ,  30, 1, 1, GETUTCDATE()),
  ( 769, 'EQ_Warehouse', 'Client'                                    , 'NoNewBusiness'                             , 'no_new_business_indicator'                 , 'BOOLEAN'             ,  31, 1, 1, GETUTCDATE()),
  ( 770, 'EQ_Warehouse', 'Client'                                    , 'EffectiveDate'                             , 'effective_date'                            , 'TIMESTAMP'           ,  32, 1, 1, GETUTCDATE()),
  ( 771, 'EQ_Warehouse', 'Client'                                    , 'StartTimestamp'                            , 'start_timestamp'                           , 'TIMESTAMP'           ,  33, 1, 1, GETUTCDATE()),
  ( 772, 'EQ_Warehouse', 'Client'                                    , 'EndTimestamp'                              , 'end_timestamp'                             , 'TIMESTAMP'           ,  34, 1, 1, GETUTCDATE());

-- [53] Contract (14 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 778, 'EQ_Warehouse', 'Contract'                                  , 'ContractPK'                                , 'contract_id'                               , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 779, 'EQ_Warehouse', 'Contract'                                  , 'ContractNumber'                            , 'contract_number'                           , 'STRING'              ,   2, 1, 1, GETUTCDATE()),
  ( 780, 'EQ_Warehouse', 'Contract'                                  , 'ProductFK'                                 , 'product_id'                                , 'INT'                 ,   3, 1, 1, GETUTCDATE()),
  ( 781, 'EQ_Warehouse', 'Contract'                                  , 'AgentFK'                                   , 'agent_id'                                  , 'INT'                 ,   4, 1, 1, GETUTCDATE()),
  ( 782, 'EQ_Warehouse', 'Contract'                                  , 'IssueDate'                                 , 'issue_date'                                , 'TIMESTAMP'           ,   5, 1, 1, GETUTCDATE()),
  ( 783, 'EQ_Warehouse', 'Contract'                                  , 'Status'                                    , 'status_code'                               , 'STRING'              ,   6, 1, 1, GETUTCDATE()),
  ( 784, 'EQ_Warehouse', 'Contract'                                  , 'StatusDate'                                , 'status_date'                               , 'TIMESTAMP'           ,   7, 1, 1, GETUTCDATE()),
  ( 785, 'EQ_Warehouse', 'Contract'                                  , 'PlanCode'                                  , 'plan_code'                                 , 'STRING'              ,   8, 1, 1, GETUTCDATE()),
  ( 786, 'EQ_Warehouse', 'Contract'                                  , 'StateCode'                                 , 'issue_state_code'                          , 'STRING'              ,   9, 1, 1, GETUTCDATE());

-- [54] vw_SEG_ContractClient (12 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 792, 'EQ_Warehouse', 'vw_SEG_ContractClient'                     , 'Source Column Name'                        , 'Target Column Name'                        , 'TARGET DATA TYPE (FABRIC)',   1, 1, 1, GETUTCDATE()),
  ( 793, 'EQ_Warehouse', 'vw_SEG_ContractClient'                     , 'ContractPK'                                , 'contract_id'                               , 'INT'                 ,   2, 1, 1, GETUTCDATE()),
  ( 794, 'EQ_Warehouse', 'vw_SEG_ContractClient'                     , 'ClientFK'                                  , 'client_id'                                 , 'INT'                 ,   3, 1, 1, GETUTCDATE()),
  ( 795, 'EQ_Warehouse', 'vw_SEG_ContractClient'                     , 'RoleName'                                  , 'client_role_name'                          , 'STRING'              ,   4, 1, 1, GETUTCDATE()),
  ( 796, 'EQ_Warehouse', 'vw_SEG_ContractClient'                     , 'Relationship'                              , 'relationship_to_insured'                   , 'STRING'              ,   5, 1, 1, GETUTCDATE()),
  ( 797, 'EQ_Warehouse', 'vw_SEG_ContractClient'                     , 'AllocationPercent'                         , 'share_percentage'                          , 'DECIMAL(18,4)'       ,   6, 1, 1, GETUTCDATE()),
  ( 798, 'EQ_Warehouse', 'vw_SEG_ContractClient'                     , 'Status'                                    , 'status'                                    , 'STRING'              ,   7, 1, 1, GETUTCDATE());

-- [55] vw_SEG_ContractTreaty (12 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 804, 'EQ_Warehouse', 'vw_SEG_ContractTreaty'                     , 'ContractPK'                                , 'contract_id'                               , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 805, 'EQ_Warehouse', 'vw_SEG_ContractTreaty'                     , 'TreatyPK'                                  , 'treaty_id'                                 , 'INT'                 ,   2, 1, 1, GETUTCDATE()),
  ( 806, 'EQ_Warehouse', 'vw_SEG_ContractTreaty'                     , 'ContractNumber'                            , 'contract_number'                           , 'STRING'              ,   3, 1, 1, GETUTCDATE()),
  ( 807, 'EQ_Warehouse', 'vw_SEG_ContractTreaty'                     , 'TreatyName'                                , 'treaty_name'                               , 'STRING'              ,   4, 1, 1, GETUTCDATE()),
  ( 808, 'EQ_Warehouse', 'vw_SEG_ContractTreaty'                     , 'TreatyDescription'                         , 'treaty_description'                        , 'STRING'              ,   5, 1, 1, GETUTCDATE()),
  ( 809, 'EQ_Warehouse', 'vw_SEG_ContractTreaty'                     , 'EffectiveDate'                             , 'effective_date'                            , 'TIMESTAMP'           ,   6, 1, 1, GETUTCDATE()),
  ( 810, 'EQ_Warehouse', 'vw_SEG_ContractTreaty'                     , 'Status'                                    , 'status'                                    , 'STRING'              ,   7, 1, 1, GETUTCDATE());

-- [56] vw_SEG_ContractRider (28 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 816, 'EQ_Warehouse', 'vw_SEG_ContractRider'                      , 'RiderGroupKey'                             , 'rider_group_id'                            , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 817, 'EQ_Warehouse', 'vw_SEG_ContractRider'                      , 'IBREligibilityDate'                        , 'ibr_eligibility_date'                      , 'TIMESTAMP'           ,   2, 1, 1, GETUTCDATE()),
  ( 818, 'EQ_Warehouse', 'vw_SEG_ContractRider'                      , 'IBRStartDate'                              , 'ibr_start_date'                            , 'TIMESTAMP'           ,   3, 1, 1, GETUTCDATE()),
  ( 819, 'EQ_Warehouse', 'vw_SEG_ContractRider'                      , 'ABR'                                       , 'abr_stop_date'                             , 'TIMESTAMP'           ,   4, 1, 1, GETUTCDATE()),
  ( 820, 'EQ_Warehouse', 'vw_SEG_ContractRider'                      , 'ABR-TI'                                    , 'abr_ti_stop_date'                          , 'TIMESTAMP'           ,   5, 1, 1, GETUTCDATE()),
  ( 821, 'EQ_Warehouse', 'vw_SEG_ContractRider'                      , 'AVGuarRider'                               , 'av_guar_rider_stop_date'                   , 'TIMESTAMP'           ,   6, 1, 1, GETUTCDATE()),
  ( 822, 'EQ_Warehouse', 'vw_SEG_ContractRider'                      , 'IBR'                                       , 'ibr_stop_date'                             , 'TIMESTAMP'           ,   7, 1, 1, GETUTCDATE()),
  ( 823, 'EQ_Warehouse', 'vw_SEG_ContractRider'                      , 'IBR-SD'                                    , 'ibr_sd_stop_date'                          , 'TIMESTAMP'           ,   8, 1, 1, GETUTCDATE()),
  ( 824, 'EQ_Warehouse', 'vw_SEG_ContractRider'                      , 'IBR-ST'                                    , 'ibr_st_stop_date'                          , 'TIMESTAMP'           ,   9, 1, 1, GETUTCDATE()),
  ( 825, 'EQ_Warehouse', 'vw_SEG_ContractRider'                      , 'InflationRider'                            , 'inflation_rider_stop_date'                 , 'TIMESTAMP'           ,  10, 1, 1, GETUTCDATE()),
  ( 826, 'EQ_Warehouse', 'vw_SEG_ContractRider'                      , 'LIQ'                                       , 'liq_stop_date'                             , 'TIMESTAMP'           ,  11, 1, 1, GETUTCDATE()),
  ( 827, 'EQ_Warehouse', 'vw_SEG_ContractRider'                      , 'LongevityRider'                            , 'longevity_rider_stop_date'                 , 'TIMESTAMP'           ,  12, 1, 1, GETUTCDATE()),
  ( 828, 'EQ_Warehouse', 'vw_SEG_ContractRider'                      , 'LTCRider'                                  , 'ltc_rider_stop_date'                       , 'TIMESTAMP'           ,  13, 1, 1, GETUTCDATE()),
  ( 829, 'EQ_Warehouse', 'vw_SEG_ContractRider'                      , 'MVA'                                       , 'mva_stop_date'                             , 'TIMESTAMP'           ,  14, 1, 1, GETUTCDATE()),
  ( 830, 'EQ_Warehouse', 'vw_SEG_ContractRider'                      , 'NFRider'                                   , 'nf_rider_stop_date'                        , 'TIMESTAMP'           ,  15, 1, 1, GETUTCDATE()),
  ( 831, 'EQ_Warehouse', 'vw_SEG_ContractRider'                      , 'NursingHomeWaiver'                         , 'nursing_home_waiver_stop_date'             , 'TIMESTAMP'           ,  16, 1, 1, GETUTCDATE()),
  ( 832, 'EQ_Warehouse', 'vw_SEG_ContractRider'                      , 'OP'                                        , 'op_stop_date'                              , 'TIMESTAMP'           ,  17, 1, 1, GETUTCDATE()),
  ( 833, 'EQ_Warehouse', 'vw_SEG_ContractRider'                      , 'ROP'                                       , 'rop_stop_date'                             , 'TIMESTAMP'           ,  18, 1, 1, GETUTCDATE()),
  ( 834, 'EQ_Warehouse', 'vw_SEG_ContractRider'                      , 'SR'                                        , 'sr_stop_date'                              , 'TIMESTAMP'           ,  19, 1, 1, GETUTCDATE()),
  ( 835, 'EQ_Warehouse', 'vw_SEG_ContractRider'                      , 'TIR'                                       , 'tir_stop_date'                             , 'TIMESTAMP'           ,  20, 1, 1, GETUTCDATE()),
  ( 836, 'EQ_Warehouse', 'vw_SEG_ContractRider'                      , 'WellnessCredits'                           , 'wellness_credits_stop_date'                , 'TIMESTAMP'           ,  21, 1, 1, GETUTCDATE()),
  ( 837, 'EQ_Warehouse', 'vw_SEG_ContractRider'                      , 'WellnessRider'                             , 'wellness_rider_stop_date'                  , 'TIMESTAMP'           ,  22, 1, 1, GETUTCDATE()),
  ( 838, 'EQ_Warehouse', 'vw_SEG_ContractRider'                      , 'WSC'                                       , 'wsc_stop_date'                             , 'TIMESTAMP'           ,  23, 1, 1, GETUTCDATE());

-- [57] ref_Product (15 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 844, 'EQ_Warehouse', 'ref_Product'                               , 'Source Column Name'                        , 'Target Column Name'                        , 'TARGET DATA TYPE (FABRIC)',   1, 1, 1, GETUTCDATE()),
  ( 845, 'EQ_Warehouse', 'ref_Product'                               , 'ProductPK'                                 , 'product_id'                                , 'INT'                 ,   2, 1, 1, GETUTCDATE()),
  ( 846, 'EQ_Warehouse', 'ref_Product'                               , 'ProductName'                               , 'product_name'                              , 'STRING'              ,   3, 1, 1, GETUTCDATE()),
  ( 847, 'EQ_Warehouse', 'ref_Product'                               , 'MarketingName'                             , 'marketing_name'                            , 'STRING'              ,   4, 1, 1, GETUTCDATE()),
  ( 848, 'EQ_Warehouse', 'ref_Product'                               , 'ProductType'                               , 'product_type'                              , 'STRING'              ,   5, 1, 1, GETUTCDATE()),
  ( 849, 'EQ_Warehouse', 'ref_Product'                               , 'CUSIPNumber'                               , 'cusip_number'                              , 'STRING'              ,   6, 1, 1, GETUTCDATE()),
  ( 850, 'EQ_Warehouse', 'ref_Product'                               , 'Context'                                   , 'product_context'                           , 'STRING'              ,   7, 1, 1, GETUTCDATE()),
  ( 851, 'EQ_Warehouse', 'ref_Product'                               , 'GLLOB'                                     , 'gl_line_of_business'                       , 'STRING'              ,   8, 1, 1, GETUTCDATE()),
  ( 852, 'EQ_Warehouse', 'ref_Product'                               , 'Status'                                    , 'status'                                    , 'STRING'              ,   9, 1, 1, GETUTCDATE()),
  ( 853, 'EQ_Warehouse', 'ref_Product'                               , 'EffectiveDate'                             , 'effective_date'                            , 'TIMESTAMP'           ,  10, 1, 1, GETUTCDATE());

-- [58] vw_SEG_ContractTrx (14 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 859, 'EQ_Warehouse', 'vw_SEG_ContractTrx'                        , 'TrxPK'                                     , 'trx_id'                                    , 'BIGINT'              ,   1, 1, 1, GETUTCDATE()),
  ( 860, 'EQ_Warehouse', 'vw_SEG_ContractTrx'                        , 'ContractPK'                                , 'contract_id'                               , 'INT'                 ,   2, 1, 1, GETUTCDATE()),
  ( 861, 'EQ_Warehouse', 'vw_SEG_ContractTrx'                        , 'ContractNumber'                            , 'contract_number'                           , 'STRING'              ,   3, 1, 1, GETUTCDATE()),
  ( 862, 'EQ_Warehouse', 'vw_SEG_ContractTrx'                        , 'TrxType'                                   , 'trx_type_code'                             , 'STRING'              ,   4, 1, 1, GETUTCDATE()),
  ( 863, 'EQ_Warehouse', 'vw_SEG_ContractTrx'                        , 'TrxDescription'                            , 'trx_description'                           , 'STRING'              ,   5, 1, 1, GETUTCDATE()),
  ( 864, 'EQ_Warehouse', 'vw_SEG_ContractTrx'                        , 'EffectiveDate'                             , 'effective_date'                            , 'TIMESTAMP'           ,   6, 1, 1, GETUTCDATE()),
  ( 865, 'EQ_Warehouse', 'vw_SEG_ContractTrx'                        , 'ProcessDate'                               , 'process_date'                              , 'TIMESTAMP'           ,   7, 1, 1, GETUTCDATE()),
  ( 866, 'EQ_Warehouse', 'vw_SEG_ContractTrx'                        , 'Amount'                                    , 'trx_amount'                                , 'DECIMAL(18,4)'       ,   8, 1, 1, GETUTCDATE()),
  ( 867, 'EQ_Warehouse', 'vw_SEG_ContractTrx'                        , 'Status'                                    , 'trx_status'                                , 'STRING'              ,   9, 1, 1, GETUTCDATE());

-- [59] vw_SEG_ContractPrimarySegment (12 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 873, 'EQ_Warehouse', 'vw_SEG_ContractPrimarySegment'             , 'ContractPK'                                , 'contract_id'                               , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 874, 'EQ_Warehouse', 'vw_SEG_ContractPrimarySegment'             , 'SegmentPK'                                 , 'segment_id'                                , 'INT'                 ,   2, 1, 1, GETUTCDATE()),
  ( 875, 'EQ_Warehouse', 'vw_SEG_ContractPrimarySegment'             , 'ContractNumber'                            , 'contract_number'                           , 'STRING'              ,   3, 1, 1, GETUTCDATE()),
  ( 876, 'EQ_Warehouse', 'vw_SEG_ContractPrimarySegment'             , 'SegmentNumber'                             , 'segment_number'                            , 'INT'                 ,   4, 1, 1, GETUTCDATE()),
  ( 877, 'EQ_Warehouse', 'vw_SEG_ContractPrimarySegment'             , 'EffectiveDate'                             , 'effective_date'                            , 'TIMESTAMP'           ,   5, 1, 1, GETUTCDATE()),
  ( 878, 'EQ_Warehouse', 'vw_SEG_ContractPrimarySegment'             , 'CostBasis'                                 , 'cost_basis'                                , 'DECIMAL(18,4)'       ,   6, 1, 1, GETUTCDATE()),
  ( 879, 'EQ_Warehouse', 'vw_SEG_ContractPrimarySegment'             , 'FreeAmount'                                , 'free_amount'                               , 'DECIMAL(18,4)'       ,   7, 1, 1, GETUTCDATE());

-- [60] vw_SEG_Agent (15 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 885, 'EQ_Warehouse', 'vw_SEG_Agent'                              , 'AgentPK'                                   , 'agent_id'                                  , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 886, 'EQ_Warehouse', 'vw_SEG_Agent'                              , 'AgentNumber'                               , 'agent_number'                              , 'STRING'              ,   2, 1, 1, GETUTCDATE()),
  ( 887, 'EQ_Warehouse', 'vw_SEG_Agent'                              , 'DisplayName'                               , 'display_name'                              , 'STRING'              ,   3, 1, 1, GETUTCDATE()),
  ( 888, 'EQ_Warehouse', 'vw_SEG_Agent'                              , 'NPN'                                       , 'npn_number'                                , 'STRING'              ,   4, 1, 1, GETUTCDATE()),
  ( 889, 'EQ_Warehouse', 'vw_SEG_Agent'                              , 'NASD'                                      , 'nasd_number'                               , 'STRING'              ,   5, 1, 1, GETUTCDATE()),
  ( 890, 'EQ_Warehouse', 'vw_SEG_Agent'                              , 'AgentType'                                 , 'agent_type'                                , 'STRING'              ,   6, 1, 1, GETUTCDATE()),
  ( 891, 'EQ_Warehouse', 'vw_SEG_Agent'                              , 'Status'                                    , 'status'                                    , 'STRING'              ,   7, 1, 1, GETUTCDATE()),
  ( 892, 'EQ_Warehouse', 'vw_SEG_Agent'                              , 'HireDate'                                  , 'hire_date'                                 , 'TIMESTAMP'           ,   8, 1, 1, GETUTCDATE()),
  ( 893, 'EQ_Warehouse', 'vw_SEG_Agent'                              , 'TerminationDate'                           , 'termination_date'                          , 'TIMESTAMP'           ,   9, 1, 1, GETUTCDATE()),
  ( 894, 'EQ_Warehouse', 'vw_SEG_Agent'                              , 'ClientFK'                                  , 'client_id'                                 , 'INT'                 ,  10, 1, 1, GETUTCDATE());

-- [61] vw_SEG_Client (16 columns)
INSERT INTO schema_config
    (id, source_name, source_table_name, source_column_name, target_column_name,
     target_data_type, ordinal_position, include_in_md5hash, is_active, created_at)
VALUES
  ( 900, 'EQ_Warehouse', 'vw_SEG_Client'                             , 'ClientPK'                                  , 'client_id'                                 , 'INT'                 ,   1, 1, 1, GETUTCDATE()),
  ( 901, 'EQ_Warehouse', 'vw_SEG_Client'                             , 'SourceKey'                                 , 'source_key'                                , 'BIGINT'              ,   2, 1, 1, GETUTCDATE()),
  ( 902, 'EQ_Warehouse', 'vw_SEG_Client'                             , 'DisplayName'                               , 'display_name'                              , 'STRING'              ,   3, 1, 1, GETUTCDATE()),
  ( 903, 'EQ_Warehouse', 'vw_SEG_Client'                             , 'FirstName'                                 , 'first_name'                                , 'STRING'              ,   4, 1, 1, GETUTCDATE()),
  ( 904, 'EQ_Warehouse', 'vw_SEG_Client'                             , 'LastName'                                  , 'last_name'                                 , 'STRING'              ,   5, 1, 1, GETUTCDATE()),
  ( 905, 'EQ_Warehouse', 'vw_SEG_Client'                             , 'Email'                                     , 'email_address'                             , 'STRING'              ,   6, 1, 1, GETUTCDATE()),
  ( 906, 'EQ_Warehouse', 'vw_SEG_Client'                             , 'Phone'                                     , 'phone_number'                              , 'STRING'              ,   7, 1, 1, GETUTCDATE()),
  ( 907, 'EQ_Warehouse', 'vw_SEG_Client'                             , 'BirthDate'                                 , 'birth_date'                                , 'TIMESTAMP'           ,   8, 1, 1, GETUTCDATE()),
  ( 908, 'EQ_Warehouse', 'vw_SEG_Client'                             , 'Status'                                    , 'status'                                    , 'STRING'              ,   9, 1, 1, GETUTCDATE()),
  ( 909, 'EQ_Warehouse', 'vw_SEG_Client'                             , 'State'                                     , 'state_code'                                , 'STRING'              ,  10, 1, 1, GETUTCDATE()),
  ( 910, 'EQ_Warehouse', 'vw_SEG_Client'                             , 'ZipCode'                                   , 'zip_code'                                  , 'STRING'              ,  11, 1, 1, GETUTCDATE());

-- Total: 915 column mappings across 61 source tables