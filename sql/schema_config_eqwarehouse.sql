--Temp_schema_config
-- schema_config — DDL + seed data
-- ============================================================

IF OBJECT_ID('dbo.schema_config', 'U') IS NOT NULL
    DROP TABLE dbo.schema_config;
GO

CREATE TABLE dbo.schema_config (
    id                  INT             NOT NULL    IDENTITY(1,1),
    source_name         NVARCHAR(100)   NOT NULL,
    landing_table_name  NVARCHAR(200)   NOT NULL,
    landing_column_name NVARCHAR(200)   NOT NULL,
    landing_data_type   NVARCHAR(100)   NOT NULL,
    bronze_table_name   NVARCHAR(200)   NOT NULL,
    bronze_column_name  NVARCHAR(200)   NOT NULL,
    bronze_data_type    NVARCHAR(100)   NOT NULL,
    silver_table_name   NVARCHAR(200)   NOT NULL,
    silver_column_name  NVARCHAR(200)   NOT NULL,
    silver_data_type    NVARCHAR(100)   NOT NULL,
    ordinal_position    INT             NOT NULL,
    include_in_md5hash  BIT             NOT NULL    CONSTRAINT df_schema_config_hash     DEFAULT (1),
    is_primary_key      BIT             NOT NULL    CONSTRAINT df_schema_config_pk       DEFAULT (0),
    is_nullable         BIT             NOT NULL    CONSTRAINT df_schema_config_nullable DEFAULT (1),
    default_value       NVARCHAR(200)   NULL,
    is_active           BIT             NOT NULL    CONSTRAINT df_schema_config_active   DEFAULT (1),
    created_at          DATETIME2       NOT NULL    CONSTRAINT df_schema_config_created  DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT pk_schema_config PRIMARY KEY (id)
);
GO

GO

-- [01] Territory
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'Territory', 'TerritoryPK', 'STRING', 'territory_base_temp', 'territory_pk', 'STRING', 'territory_temp', 'territory_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Territory', 'TerritoryName', 'STRING', 'territory_base_temp', 'territory_name', 'STRING', 'territory_temp', 'territory_name', 'STRING', 2, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Territory', 'ClientFK', 'STRING', 'territory_base_temp', 'client_fk', 'STRING', 'territory_temp', 'client_id', 'INT', 3, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Territory', 'TerritoryActive', 'STRING', 'territory_base_temp', 'territory_active', 'STRING', 'territory_temp', 'is_territory_active', 'BOOLEAN', 4, 1, 0, 0, '0', 1, GETUTCDATE());

-- [02] HierarchyTerritory
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'HierarchyTerritory', 'HierarchyTerritoryPK', 'STRING', 'hierarchy_territory_base_temp', 'hierarchy_territory_pk', 'STRING', 'hierarchy_territory_temp', 'hierarchy_territory_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'HierarchyTerritory', 'HierarchySetKey', 'STRING', 'hierarchy_territory_base_temp', 'hierarchy_set_key', 'STRING', 'hierarchy_territory_temp', 'hierarchy_set_key', 'INT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'HierarchyTerritory', 'TerritoryFK', 'STRING', 'hierarchy_territory_base_temp', 'territory_fk', 'STRING', 'hierarchy_territory_temp', 'territory_id', 'INT', 3, 1, 0, 0, '0', 1, GETUTCDATE());

-- [03] Hierarchy_SuperHierarchy
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'Hierarchy_SuperHierarchy', 'SuperHierarchyPK', 'STRING', 'hierarchy_super_hierarchy_base_temp', 'super_hierarchy_pk', 'STRING', 'hierarchy_super_hierarchy_temp', 'super_hierarchy_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Hierarchy_SuperHierarchy', 'AgentContractFK', 'STRING', 'hierarchy_super_hierarchy_base_temp', 'agent_contract_fk', 'STRING', 'hierarchy_super_hierarchy_temp', 'agent_contract_id', 'INT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Hierarchy_SuperHierarchy', 'HierarchySetKey', 'STRING', 'hierarchy_super_hierarchy_base_temp', 'hierarchy_set_key', 'STRING', 'hierarchy_super_hierarchy_temp', 'hierarchy_set_key', 'INT', 3, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Hierarchy_SuperHierarchy', 'ReverseLevel', 'STRING', 'hierarchy_super_hierarchy_base_temp', 'reverse_level', 'STRING', 'hierarchy_super_hierarchy_temp', 'reverse_level', 'DECIMAL(18,4)', 4, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Hierarchy_SuperHierarchy', 'DisplayName', 'STRING', 'hierarchy_super_hierarchy_base_temp', 'display_name', 'STRING', 'hierarchy_super_hierarchy_temp', 'display_name', 'STRING', 5, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE());

-- [04] Hierarchy_Option
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'Hierarchy_Option', 'HierarchyOptionPK', 'STRING', 'hierarchy_option_base_temp', 'hierarchy_option_pk', 'STRING', 'hierarchy_option_temp', 'hierarchy_option_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Hierarchy_Option', 'HierarchyBridgeFK', 'STRING', 'hierarchy_option_base_temp', 'hierarchy_bridge_fk', 'STRING', 'hierarchy_option_temp', 'hierarchy_bridge_id', 'INT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Hierarchy_Option', 'AgentContractFK', 'STRING', 'hierarchy_option_base_temp', 'agent_contract_fk', 'STRING', 'hierarchy_option_temp', 'agent_contract_id', 'INT', 3, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Hierarchy_Option', 'AccessRemovedInd', 'STRING', 'hierarchy_option_base_temp', 'access_removed_ind', 'STRING', 'hierarchy_option_temp', 'is_access_removed', 'BOOLEAN', 4, 1, 0, 0, '0', 1, GETUTCDATE());

-- [05] Hierarchy_Bridge
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'Hierarchy_Bridge', 'HierarchyBridgePK', 'STRING', 'hierarchy_bridge_base_temp', 'hierarchy_bridge_pk', 'STRING', 'hierarchy_bridge_temp', 'hierarchy_bridge_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Hierarchy_Bridge', 'HierarchyGroupKey', 'STRING', 'hierarchy_bridge_base_temp', 'hierarchy_group_key', 'STRING', 'hierarchy_bridge_temp', 'hierarchy_group_key', 'INT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Hierarchy_Bridge', 'HierarchySetKey', 'STRING', 'hierarchy_bridge_base_temp', 'hierarchy_set_key', 'STRING', 'hierarchy_bridge_temp', 'hierarchy_set_key', 'INT', 3, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Hierarchy_Bridge', 'SplitPercent', 'STRING', 'hierarchy_bridge_base_temp', 'split_percent', 'STRING', 'hierarchy_bridge_temp', 'split_percent', 'DECIMAL(18,4)', 4, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Hierarchy_Bridge', 'ServicingAgentIndicator', 'STRING', 'hierarchy_bridge_base_temp', 'servicing_agent_indicator', 'STRING', 'hierarchy_bridge_temp', 'servicing_agent_indicator', 'STRING', 5, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Hierarchy_Bridge', 'CommissionOnlyIndicator', 'STRING', 'hierarchy_bridge_base_temp', 'commission_only_indicator', 'STRING', 'hierarchy_bridge_temp', 'commission_only_indicator', 'STRING', 6, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Hierarchy_Bridge', 'CommissionOption', 'STRING', 'hierarchy_bridge_base_temp', 'commission_option', 'STRING', 'hierarchy_bridge_temp', 'commission_option', 'STRING', 7, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Hierarchy_Bridge', 'HierarchyOrder', 'STRING', 'hierarchy_bridge_base_temp', 'hierarchy_order', 'STRING', 'hierarchy_bridge_temp', 'hierarchy_order', 'INT', 8, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Hierarchy_Bridge', 'StartDate', 'STRING', 'hierarchy_bridge_base_temp', 'start_date', 'STRING', 'hierarchy_bridge_temp', 'start_timestamp', 'TIMESTAMP', 9, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Hierarchy_Bridge', 'StopDate', 'STRING', 'hierarchy_bridge_base_temp', 'stop_date', 'STRING', 'hierarchy_bridge_temp', 'stop_timestamp', 'TIMESTAMP', 10, 1, 0, 0, '3000-01-01', 1, GETUTCDATE());

-- [06] Hierarchy
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'Hierarchy', 'HierarchyPK', 'STRING', 'hierarchy_base_temp', 'hierarchy_pk', 'STRING', 'hierarchy_temp', 'hierarchy_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Hierarchy', 'HierarchySetKey', 'STRING', 'hierarchy_base_temp', 'hierarchy_set_key', 'STRING', 'hierarchy_temp', 'hierarchy_set_key', 'INT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Hierarchy', 'AgentContractFK', 'STRING', 'hierarchy_base_temp', 'agent_contract_fk', 'STRING', 'hierarchy_temp', 'agent_contract_id', 'INT', 3, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Hierarchy', 'Level', 'STRING', 'hierarchy_base_temp', 'level', 'STRING', 'hierarchy_temp', 'level', 'INT', 4, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Hierarchy', 'ReverseLevel', 'STRING', 'hierarchy_base_temp', 'reverse_level', 'STRING', 'hierarchy_temp', 'reverse_level', 'INT', 5, 1, 0, 0, '0', 1, GETUTCDATE());

-- [07] CommissionLevelRank
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'CommissionLevelRank', 'CommissionLevelRankPK', 'STRING', 'commission_level_rank_base_temp', 'commission_level_rank_pk', 'STRING', 'commission_level_rank_temp', 'commission_level_rank_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'CommissionLevelRank', 'CommissionLevel', 'STRING', 'commission_level_rank_base_temp', 'commission_level', 'STRING', 'commission_level_rank_temp', 'commission_level', 'STRING', 2, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'CommissionLevelRank', 'Rank', 'STRING', 'commission_level_rank_base_temp', 'rank', 'STRING', 'commission_level_rank_temp', 'rank', 'INT', 3, 1, 0, 0, '0', 1, GETUTCDATE());

-- [08] AgentContract
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'AgentContract', 'AgentContractPK', 'STRING', 'agent_contract_base_temp', 'agent_contract_pk', 'STRING', 'agent_contract_temp', 'agent_contract_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'AgentContract', 'AgentNumber', 'STRING', 'agent_contract_base_temp', 'agent_number', 'STRING', 'agent_contract_temp', 'agent_number', 'STRING', 2, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AgentContract', 'AgentFK', 'STRING', 'agent_contract_base_temp', 'agent_fk', 'STRING', 'agent_contract_temp', 'agent_id', 'INT', 3, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'AgentContract', 'Context', 'STRING', 'agent_contract_base_temp', 'context', 'STRING', 'agent_contract_temp', 'context', 'STRING', 4, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AgentContract', 'Status', 'STRING', 'agent_contract_base_temp', 'status', 'STRING', 'agent_contract_temp', 'status', 'STRING', 5, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AgentContract', 'CommissionLevel', 'STRING', 'agent_contract_base_temp', 'commission_level', 'STRING', 'agent_contract_temp', 'commission_level', 'STRING', 6, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AgentContract', 'SituationCode', 'STRING', 'agent_contract_base_temp', 'situation_code', 'STRING', 'agent_contract_temp', 'situation_code', 'STRING', 7, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AgentContract', 'ContractEffectiveDate', 'STRING', 'agent_contract_base_temp', 'contract_effective_date', 'STRING', 'agent_contract_temp', 'contract_effective_timestamp', 'TIMESTAMP', 8, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'AgentContract', 'ContractTerminationDate', 'STRING', 'agent_contract_base_temp', 'contract_termination_date', 'STRING', 'agent_contract_temp', 'contract_termination_timestamp', 'TIMESTAMP', 9, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'AgentContract', 'CurrentRecord', 'STRING', 'agent_contract_base_temp', 'current_record', 'STRING', 'agent_contract_temp', 'is_current_record', 'STRING', 10, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AgentContract', 'SetToCurrentDate', 'STRING', 'agent_contract_base_temp', 'set_to_current_date', 'STRING', 'agent_contract_temp', 'set_to_current_timestamp', 'TIMESTAMP', 11, 1, 0, 0, '3000-01-01', 1, GETUTCDATE());

-- [09] TrainingState_Group
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'TrainingState_Group', 'TrainingStateGroupPK', 'STRING', 'training_state_group_base_temp', 'training_state_group_pk', 'STRING', 'training_state_group_temp', 'training_state_group_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'TrainingState_Group', 'TrainingStateGroupKey', 'STRING', 'training_state_group_base_temp', 'training_state_group_key', 'STRING', 'training_state_group_temp', 'training_state_group_key', 'INT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'TrainingState_Group', 'State', 'STRING', 'training_state_group_base_temp', 'state', 'STRING', 'training_state_group_temp', 'state_code', 'STRING', 3, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'TrainingState_Group', 'Required', 'STRING', 'training_state_group_base_temp', 'required', 'STRING', 'training_state_group_temp', 'is_required', 'BOOLEAN', 4, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'TrainingState_Group', 'EffectiveDate', 'STRING', 'training_state_group_base_temp', 'effective_date', 'STRING', 'training_state_group_temp', 'effective_timestamp', 'TIMESTAMP', 5, 1, 0, 0, '3000-01-01', 1, GETUTCDATE());

-- [10] TrainingProduct_Group
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'TrainingProduct_Group', 'TrainingProductGroupPK', 'STRING', 'training_product_group_base_temp', 'training_product_group_pk', 'STRING', 'training_product_group_temp', 'training_product_group_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'TrainingProduct_Group', 'TrainingProductGroupKey', 'STRING', 'training_product_group_base_temp', 'training_product_group_key', 'STRING', 'training_product_group_temp', 'training_product_group_key', 'INT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'TrainingProduct_Group', 'ProductFK', 'STRING', 'training_product_group_base_temp', 'product_fk', 'STRING', 'training_product_group_temp', 'product_id', 'INT', 3, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'TrainingProduct_Group', 'Required', 'STRING', 'training_product_group_base_temp', 'required', 'STRING', 'training_product_group_temp', 'is_required', 'BOOLEAN', 4, 1, 0, 0, '0', 1, GETUTCDATE());

-- [11] Rider_Group
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'Rider_Group', 'RiderGroupPK', 'STRING', 'rider_group_base_temp', 'rider_group_pk', 'STRING', 'rider_group_temp', 'rider_group_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Rider_Group', 'RiderGroupKey', 'STRING', 'rider_group_base_temp', 'rider_group_key', 'STRING', 'rider_group_temp', 'rider_group_key', 'INT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Rider_Group', 'Code', 'STRING', 'rider_group_base_temp', 'code', 'STRING', 'rider_group_temp', 'rider_code', 'STRING', 3, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Rider_Group', 'Description', 'STRING', 'rider_group_base_temp', 'description', 'STRING', 'rider_group_temp', 'description', 'STRING', 4, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Rider_Group', 'BaseValue', 'STRING', 'rider_group_base_temp', 'base_value', 'STRING', 'rider_group_temp', 'base_value', 'DECIMAL(18,4)', 5, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Rider_Group', 'EligibilityDate', 'STRING', 'rider_group_base_temp', 'eligibility_date', 'STRING', 'rider_group_temp', 'eligibility_timestamp', 'TIMESTAMP', 6, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Rider_Group', 'FeePercent', 'STRING', 'rider_group_base_temp', 'fee_percent', 'STRING', 'rider_group_temp', 'fee_percent', 'DECIMAL(18,4)', 7, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Rider_Group', 'Lives', 'STRING', 'rider_group_base_temp', 'lives', 'STRING', 'rider_group_temp', 'lives', 'STRING', 8, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Rider_Group', 'PayValue', 'STRING', 'rider_group_base_temp', 'pay_value', 'STRING', 'rider_group_temp', 'pay_value', 'DECIMAL(18,4)', 9, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Rider_Group', 'Frequency', 'STRING', 'rider_group_base_temp', 'frequency', 'STRING', 'rider_group_temp', 'frequency', 'STRING', 10, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Rider_Group', 'WellnessEnrollment', 'STRING', 'rider_group_base_temp', 'wellness_enrollment', 'STRING', 'rider_group_temp', 'is_wellness_enrollment', 'BOOLEAN', 11, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Rider_Group', 'WellnessCredits', 'STRING', 'rider_group_base_temp', 'wellness_credits', 'STRING', 'rider_group_temp', 'wellness_credits', 'DECIMAL(18,4)', 12, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Rider_Group', 'StartAge', 'STRING', 'rider_group_base_temp', 'start_age', 'STRING', 'rider_group_temp', 'start_age', 'INT', 13, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Rider_Group', 'StartDate', 'STRING', 'rider_group_base_temp', 'start_date', 'STRING', 'rider_group_temp', 'start_timestamp', 'TIMESTAMP', 14, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Rider_Group', 'StopDate', 'STRING', 'rider_group_base_temp', 'stop_date', 'STRING', 'rider_group_temp', 'stop_timestamp', 'TIMESTAMP', 15, 1, 0, 0, '3000-01-01', 1, GETUTCDATE());

-- [12] Requirement_Group
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'Requirement_Group', 'RequirementGroupPK', 'STRING', 'requirement_group_base_temp', 'requirement_group_pk', 'STRING', 'requirement_group_temp', 'requirement_group_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Requirement_Group', 'RequirementGroupKey', 'STRING', 'requirement_group_base_temp', 'requirement_group_key', 'STRING', 'requirement_group_temp', 'requirement_group_key', 'INT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Requirement_Group', 'Code', 'STRING', 'requirement_group_base_temp', 'code', 'STRING', 'requirement_group_temp', 'requirement_code', 'STRING', 3, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Requirement_Group', 'Description', 'STRING', 'requirement_group_base_temp', 'description', 'STRING', 'requirement_group_temp', 'description', 'STRING', 4, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Requirement_Group', 'Status', 'STRING', 'requirement_group_base_temp', 'status', 'STRING', 'requirement_group_temp', 'status', 'STRING', 5, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Requirement_Group', 'EffectiveDate', 'STRING', 'requirement_group_base_temp', 'effective_date', 'STRING', 'requirement_group_temp', 'effective_timestamp', 'TIMESTAMP', 6, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Requirement_Group', 'FollowUpDate', 'STRING', 'requirement_group_base_temp', 'follow_up_date', 'STRING', 'requirement_group_temp', 'follow_up_timestamp', 'TIMESTAMP', 7, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Requirement_Group', 'ReceivedDate', 'STRING', 'requirement_group_base_temp', 'received_date', 'STRING', 'requirement_group_temp', 'received_timestamp', 'TIMESTAMP', 8, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Requirement_Group', 'ExecutedDate', 'STRING', 'requirement_group_base_temp', 'executed_date', 'STRING', 'requirement_group_temp', 'executed_timestamp', 'TIMESTAMP', 9, 1, 0, 0, '3000-01-01', 1, GETUTCDATE());

-- [13] RenewalRate_Group
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'RenewalRate_Group', 'RenewalRateGroupPK', 'STRING', 'renewal_rate_group_base_temp', 'renewal_rate_group_pk', 'STRING', 'renewal_rate_group_temp', 'renewal_rate_group_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'RenewalRate_Group', 'RenewalRateGroupKey', 'STRING', 'renewal_rate_group_base_temp', 'renewal_rate_group_key', 'STRING', 'renewal_rate_group_temp', 'renewal_rate_group_key', 'INT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'RenewalRate_Group', 'Rate', 'STRING', 'renewal_rate_group_base_temp', 'rate', 'STRING', 'renewal_rate_group_temp', 'rate', 'DECIMAL(18,4)', 3, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'RenewalRate_Group', 'EffectiveDate', 'STRING', 'renewal_rate_group_base_temp', 'effective_date', 'STRING', 'renewal_rate_group_temp', 'effective_timestamp', 'TIMESTAMP', 4, 1, 0, 0, '3000-01-01', 1, GETUTCDATE());

-- [14] Reinsurance_Group
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'Reinsurance_Group', 'ReinsuranceGroupPK', 'STRING', 'reinsurance_group_base_temp', 'reinsurance_group_pk', 'STRING', 'reinsurance_group_temp', 'reinsurance_group_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Reinsurance_Group', 'ReinsuranceGroupKey', 'STRING', 'reinsurance_group_base_temp', 'reinsurance_group_key', 'STRING', 'reinsurance_group_temp', 'reinsurance_group_key', 'INT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Reinsurance_Group', 'TreatyCode', 'STRING', 'reinsurance_group_base_temp', 'treaty_code', 'STRING', 'reinsurance_group_temp', 'treaty_code', 'STRING', 3, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Reinsurance_Group', 'CoinsurancePercentage', 'STRING', 'reinsurance_group_base_temp', 'coinsurance_percentage', 'STRING', 'reinsurance_group_temp', 'coinsurance_percentage', 'DECIMAL(18,4)', 4, 1, 0, 0, '0', 1, GETUTCDATE());

-- [15] RecurringPayment_Group
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'RecurringPayment_Group', 'RecurringPaymentGroupPK', 'STRING', 'recurring_payment_group_base_temp', 'recurring_payment_group_pk', 'STRING', 'recurring_payment_group_temp', 'recurring_payment_group_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'RecurringPayment_Group', 'RecurringPaymentGroupKey', 'STRING', 'recurring_payment_group_base_temp', 'recurring_payment_group_key', 'STRING', 'recurring_payment_group_temp', 'recurring_payment_group_key', 'INT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'RecurringPayment_Group', 'ActivityTypeFK', 'STRING', 'recurring_payment_group_base_temp', 'activity_type_fk', 'STRING', 'recurring_payment_group_temp', 'activity_type_id', 'INT', 3, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'RecurringPayment_Group', 'PayeeFK', 'STRING', 'recurring_payment_group_base_temp', 'payee_fk', 'STRING', 'recurring_payment_group_temp', 'payee_id', 'INT', 4, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'RecurringPayment_Group', 'NextEffectiveDate', 'STRING', 'recurring_payment_group_base_temp', 'next_effective_date', 'STRING', 'recurring_payment_group_temp', 'next_effective_timestamp', 'TIMESTAMP', 5, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'RecurringPayment_Group', 'PausedInd', 'STRING', 'recurring_payment_group_base_temp', 'paused_ind', 'STRING', 'recurring_payment_group_temp', 'is_paused', 'BOOLEAN', 6, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'RecurringPayment_Group', 'DistributionType', 'STRING', 'recurring_payment_group_base_temp', 'distribution_type', 'STRING', 'recurring_payment_group_temp', 'distribution_type', 'STRING', 7, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'RecurringPayment_Group', 'Lives', 'STRING', 'recurring_payment_group_base_temp', 'lives', 'STRING', 'recurring_payment_group_temp', 'lives', 'STRING', 8, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'RecurringPayment_Group', 'Frequency', 'STRING', 'recurring_payment_group_base_temp', 'frequency', 'STRING', 'recurring_payment_group_temp', 'frequency', 'STRING', 9, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'RecurringPayment_Group', 'WithdrawalType', 'STRING', 'recurring_payment_group_base_temp', 'withdrawal_type', 'STRING', 'recurring_payment_group_temp', 'withdrawal_type', 'STRING', 10, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'RecurringPayment_Group', 'FirstDate', 'STRING', 'recurring_payment_group_base_temp', 'first_date', 'STRING', 'recurring_payment_group_temp', 'first_timestamp', 'TIMESTAMP', 11, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'RecurringPayment_Group', 'PriorDate', 'STRING', 'recurring_payment_group_base_temp', 'prior_date', 'STRING', 'recurring_payment_group_temp', 'prior_timestamp', 'TIMESTAMP', 12, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'RecurringPayment_Group', 'PriorActivityFK', 'STRING', 'recurring_payment_group_base_temp', 'prior_activity_fk', 'STRING', 'recurring_payment_group_temp', 'prior_activity_id', 'INT', 13, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'RecurringPayment_Group', 'EligibleRMDDate', 'STRING', 'recurring_payment_group_base_temp', 'eligible_rmd_date', 'STRING', 'recurring_payment_group_temp', 'eligible_rmd_timestamp', 'TIMESTAMP', 14, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'RecurringPayment_Group', 'CalculatedAmount', 'STRING', 'recurring_payment_group_base_temp', 'calculated_amount', 'STRING', 'recurring_payment_group_temp', 'calculated_amount', 'DECIMAL(18,4)', 15, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'RecurringPayment_Group', 'GrossNet', 'STRING', 'recurring_payment_group_base_temp', 'gross_net', 'STRING', 'recurring_payment_group_temp', 'gross_net', 'STRING', 16, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE());

-- [16] Note_Group
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'Note_Group', 'NoteGroupPK', 'STRING', 'note_group_base_temp', 'note_group_pk', 'STRING', 'note_group_temp', 'note_group_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Note_Group', 'SourceKey', 'STRING', 'note_group_base_temp', 'source_key', 'STRING', 'note_group_temp', 'source_key', 'BIGINT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Note_Group', 'NoteGroupKey', 'STRING', 'note_group_base_temp', 'note_group_key', 'STRING', 'note_group_temp', 'note_group_key', 'INT', 3, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Note_Group', 'Order', 'STRING', 'note_group_base_temp', 'order', 'STRING', 'note_group_temp', 'sort_order', 'INT', 4, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Note_Group', 'Text', 'STRING', 'note_group_base_temp', 'text', 'STRING', 'note_group_temp', 'note_text', 'STRING', 5, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Note_Group', 'Type', 'STRING', 'note_group_base_temp', 'type', 'STRING', 'note_group_temp', 'note_type', 'STRING', 6, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Note_Group', 'Role', 'STRING', 'note_group_base_temp', 'role', 'STRING', 'note_group_temp', 'role', 'STRING', 7, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Note_Group', 'MaintDate', 'STRING', 'note_group_base_temp', 'maint_date', 'STRING', 'note_group_temp', 'maint_timestamp', 'TIMESTAMP', 8, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Note_Group', 'MaintBy', 'STRING', 'note_group_base_temp', 'maint_by', 'STRING', 'note_group_temp', 'maint_by', 'STRING', 9, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Note_Group', 'Call_ID', 'STRING', 'note_group_base_temp', 'call_id', 'STRING', 'note_group_temp', 'call_id', 'INT', 10, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Note_Group', 'Call_Length', 'STRING', 'note_group_base_temp', 'call_length', 'STRING', 'note_group_temp', 'call_length', 'INT', 11, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Note_Group', 'Call_StartDate', 'STRING', 'note_group_base_temp', 'call_start_date', 'STRING', 'note_group_temp', 'call_start_timestamp', 'TIMESTAMP', 12, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Note_Group', 'Call_InOut', 'STRING', 'note_group_base_temp', 'call_in_out', 'STRING', 'note_group_temp', 'call_direction', 'STRING', 13, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Note_Group', 'Call_Operators', 'STRING', 'note_group_base_temp', 'call_operators', 'STRING', 'note_group_temp', 'call_operators', 'STRING', 14, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Note_Group', 'Call_FilePath', 'STRING', 'note_group_base_temp', 'call_file_path', 'STRING', 'note_group_temp', 'call_file_path', 'STRING', 15, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Note_Group', 'Call_EncryptKey', 'STRING', 'note_group_base_temp', 'call_encrypt_key', 'STRING', 'note_group_temp', 'call_encrypt_key', 'STRING', 16, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE());

-- [17] IndexValue_Group
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'IndexValue_Group', 'IndexValueGroupPK', 'STRING', 'index_value_group_base_temp', 'index_value_group_pk', 'STRING', 'index_value_group_temp', 'index_value_group_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'IndexValue_Group', 'IndexValueGroupKey', 'STRING', 'index_value_group_base_temp', 'index_value_group_key', 'STRING', 'index_value_group_temp', 'index_value_group_key', 'INT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'IndexValue_Group', 'Ticker', 'STRING', 'index_value_group_base_temp', 'ticker', 'STRING', 'index_value_group_temp', 'ticker', 'STRING', 3, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'IndexValue_Group', 'IndexName', 'STRING', 'index_value_group_base_temp', 'index_name', 'STRING', 'index_value_group_temp', 'index_name', 'STRING', 4, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'IndexValue_Group', 'EffectiveDate', 'STRING', 'index_value_group_base_temp', 'effective_date', 'STRING', 'index_value_group_temp', 'effective_timestamp', 'TIMESTAMP', 5, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'IndexValue_Group', 'IndexValue', 'STRING', 'index_value_group_base_temp', 'index_value', 'STRING', 'index_value_group_temp', 'index_value', 'DECIMAL(18,4)', 6, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'IndexValue_Group', 'Change', 'STRING', 'index_value_group_base_temp', 'change', 'STRING', 'index_value_group_temp', 'change_amount', 'DECIMAL(18,4)', 7, 1, 0, 0, '0', 1, GETUTCDATE());

-- [18] ExternalAccount_Group
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'ExternalAccount_Group', 'ExternalAccountGroupPK', 'STRING', 'external_account_group_base_temp', 'external_account_group_pk', 'STRING', 'external_account_group_temp', 'external_account_group_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'ExternalAccount_Group', 'ExternalAccountGroupKey', 'STRING', 'external_account_group_base_temp', 'external_account_group_key', 'STRING', 'external_account_group_temp', 'external_account_group_key', 'INT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'ExternalAccount_Group', 'ExternalAccountType', 'STRING', 'external_account_group_base_temp', 'external_account_type', 'STRING', 'external_account_group_temp', 'external_account_type', 'STRING', 3, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'ExternalAccount_Group', 'Company', 'STRING', 'external_account_group_base_temp', 'company', 'STRING', 'external_account_group_temp', 'company_name', 'STRING', 4, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'ExternalAccount_Group', 'RoutingNumber', 'STRING', 'external_account_group_base_temp', 'routing_number', 'STRING', 'external_account_group_temp', 'routing_number', 'STRING', 5, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'ExternalAccount_Group', 'AccountNumber', 'STRING', 'external_account_group_base_temp', 'account_number', 'STRING', 'external_account_group_temp', 'account_number', 'STRING', 6, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'ExternalAccount_Group', 'VerificationCode', 'STRING', 'external_account_group_base_temp', 'verification_code', 'STRING', 'external_account_group_temp', 'verification_code', 'STRING', 7, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'ExternalAccount_Group', 'VerificationResponse', 'STRING', 'external_account_group_base_temp', 'verification_response', 'STRING', 'external_account_group_temp', 'verification_response', 'STRING', 8, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'ExternalAccount_Group', 'VerificationDate', 'STRING', 'external_account_group_base_temp', 'verification_date', 'STRING', 'external_account_group_temp', 'verification_timestamp', 'TIMESTAMP', 9, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'ExternalAccount_Group', 'Active', 'STRING', 'external_account_group_base_temp', 'active', 'STRING', 'external_account_group_temp', 'is_active', 'BOOLEAN', 10, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'ExternalAccount_Group', 'StartDate', 'STRING', 'external_account_group_base_temp', 'start_date', 'STRING', 'external_account_group_temp', 'start_timestamp', 'TIMESTAMP', 11, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'ExternalAccount_Group', 'EndDate', 'STRING', 'external_account_group_base_temp', 'end_date', 'STRING', 'external_account_group_temp', 'end_timestamp', 'TIMESTAMP', 12, 1, 0, 0, '3000-01-01', 1, GETUTCDATE());

-- [19] ContractValue_Group
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'ContractValue_Group', 'ContractValueGroupPK', 'STRING', 'contract_value_group_base_temp', 'contract_value_group_pk', 'STRING', 'contract_value_group_temp', 'contract_value_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'ContractValue_Group', 'ContractValueGroupKey', 'STRING', 'contract_value_group_base_temp', 'contract_value_group_key', 'STRING', 'contract_value_group_temp', 'contract_value_key', 'INT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'ContractValue_Group', 'ValueType', 'STRING', 'contract_value_group_base_temp', 'value_type', 'STRING', 'contract_value_group_temp', 'value_type', 'STRING', 3, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'ContractValue_Group', 'ValueDate', 'STRING', 'contract_value_group_base_temp', 'value_date', 'STRING', 'contract_value_group_temp', 'value_timestamp', 'TIMESTAMP', 4, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'ContractValue_Group', 'Value', 'STRING', 'contract_value_group_base_temp', 'value', 'STRING', 'contract_value_group_temp', 'value', 'DECIMAL(18,4)', 5, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'ContractValue_Group', 'ValueAsDate', 'STRING', 'contract_value_group_base_temp', 'value_as_date', 'STRING', 'contract_value_group_temp', 'value_as_timestamp', 'TIMESTAMP', 6, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'ContractValue_Group', 'StartDate', 'STRING', 'contract_value_group_base_temp', 'start_date', 'STRING', 'contract_value_group_temp', 'start_timestamp', 'TIMESTAMP', 7, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'ContractValue_Group', 'EndDate', 'STRING', 'contract_value_group_base_temp', 'end_date', 'STRING', 'contract_value_group_temp', 'end_timestamp', 'TIMESTAMP', 8, 1, 0, 0, '3000-01-01', 1, GETUTCDATE());

-- [20] ContractDeposit_Group
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'ContractDeposit_Group', 'ContractDepositGroupPK', 'STRING', 'contract_deposit_group_base_temp', 'contract_deposit_group_pk', 'STRING', 'contract_deposit_group_temp', 'contract_deposit_group_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'ContractDeposit_Group', 'SourceKey', 'STRING', 'contract_deposit_group_base_temp', 'source_key', 'STRING', 'contract_deposit_group_temp', 'source_key', 'BIGINT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'ContractDeposit_Group', 'ContractDepositGroupKey', 'STRING', 'contract_deposit_group_base_temp', 'contract_deposit_group_key', 'STRING', 'contract_deposit_group_temp', 'contract_deposit_group_key', 'INT', 3, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'ContractDeposit_Group', 'DepositType', 'STRING', 'contract_deposit_group_base_temp', 'deposit_type', 'STRING', 'contract_deposit_group_temp', 'deposit_type', 'STRING', 4, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'ContractDeposit_Group', 'DepositSource', 'STRING', 'contract_deposit_group_base_temp', 'deposit_source', 'STRING', 'contract_deposit_group_temp', 'deposit_source', 'STRING', 5, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'ContractDeposit_Group', 'OriginalContract', 'STRING', 'contract_deposit_group_base_temp', 'original_contract', 'STRING', 'contract_deposit_group_temp', 'original_contract', 'STRING', 6, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'ContractDeposit_Group', 'DateReceived', 'STRING', 'contract_deposit_group_base_temp', 'date_received', 'STRING', 'contract_deposit_group_temp', 'date_received_timestamp', 'TIMESTAMP', 7, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'ContractDeposit_Group', 'ProcessDate', 'STRING', 'contract_deposit_group_base_temp', 'process_date', 'STRING', 'contract_deposit_group_temp', 'process_timestamp', 'TIMESTAMP', 8, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'ContractDeposit_Group', 'TaxYear', 'STRING', 'contract_deposit_group_base_temp', 'tax_year', 'STRING', 'contract_deposit_group_temp', 'tax_year', 'INT', 9, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'ContractDeposit_Group', 'ReplacementType', 'STRING', 'contract_deposit_group_base_temp', 'replacement_type', 'STRING', 'contract_deposit_group_temp', 'replacement_type', 'STRING', 10, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'ContractDeposit_Group', 'PremiumType', 'STRING', 'contract_deposit_group_base_temp', 'premium_type', 'STRING', 'contract_deposit_group_temp', 'premium_type', 'STRING', 11, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'ContractDeposit_Group', 'PlannedIndicator', 'STRING', 'contract_deposit_group_base_temp', 'planned_indicator', 'STRING', 'contract_deposit_group_temp', 'planned_indicator', 'STRING', 12, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'ContractDeposit_Group', 'Reference', 'STRING', 'contract_deposit_group_base_temp', 'reference', 'STRING', 'contract_deposit_group_temp', 'reference', 'STRING', 13, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'ContractDeposit_Group', 'AnticipatedAmount', 'STRING', 'contract_deposit_group_base_temp', 'anticipated_amount', 'STRING', 'contract_deposit_group_temp', 'anticipated_amount', 'DECIMAL(18,4)', 14, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'ContractDeposit_Group', 'ActualAmount', 'STRING', 'contract_deposit_group_base_temp', 'actual_amount', 'STRING', 'contract_deposit_group_temp', 'actual_amount', 'DECIMAL(18,4)', 15, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'ContractDeposit_Group', 'CostBasis', 'STRING', 'contract_deposit_group_base_temp', 'cost_basis', 'STRING', 'contract_deposit_group_temp', 'cost_basis', 'DECIMAL(18,4)', 16, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'ContractDeposit_Group', 'RefundAmount', 'STRING', 'contract_deposit_group_base_temp', 'refund_amount', 'STRING', 'contract_deposit_group_temp', 'refund_amount', 'DECIMAL(18,4)', 17, 1, 0, 0, '0', 1, GETUTCDATE());

-- [21] AgentSummary_Group
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'AgentSummary_Group', 'AgentSummaryGroupPK', 'STRING', 'agent_summary_group_base_temp', 'agent_summary_group_pk', 'STRING', 'agent_summary_group_temp', 'agent_summary_group_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'AgentSummary_Group', 'AgentSummaryGroupKey', 'STRING', 'agent_summary_group_base_temp', 'agent_summary_group_key', 'STRING', 'agent_summary_group_temp', 'agent_summary_group_key', 'INT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'AgentSummary_Group', 'SummaryType', 'STRING', 'agent_summary_group_base_temp', 'summary_type', 'STRING', 'agent_summary_group_temp', 'summary_type', 'STRING', 3, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AgentSummary_Group', 'SummaryDate', 'STRING', 'agent_summary_group_base_temp', 'summary_date', 'STRING', 'agent_summary_group_temp', 'summary_timestamp', 'TIMESTAMP', 4, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'AgentSummary_Group', 'SummaryValue', 'STRING', 'agent_summary_group_base_temp', 'summary_value', 'STRING', 'agent_summary_group_temp', 'summary_value', 'DECIMAL(18,4)', 5, 1, 0, 0, '0', 1, GETUTCDATE());

-- [22] AgentPrincipal_Group
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'AgentPrincipal_Group', 'AgentPrincipalGroupPK', 'STRING', 'agent_principal_group_base_temp', 'agent_principal_group_pk', 'STRING', 'agent_principal_group_temp', 'agent_principal_group_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'AgentPrincipal_Group', 'AgentPrincipalGroupKey', 'STRING', 'agent_principal_group_base_temp', 'agent_principal_group_key', 'STRING', 'agent_principal_group_temp', 'agent_principal_group_key', 'INT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'AgentPrincipal_Group', 'PrincipalAgentFK', 'STRING', 'agent_principal_group_base_temp', 'principal_agent_fk', 'STRING', 'agent_principal_group_temp', 'principal_agent_id', 'INT', 3, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'AgentPrincipal_Group', 'StartDate', 'STRING', 'agent_principal_group_base_temp', 'start_date', 'STRING', 'agent_principal_group_temp', 'start_timestamp', 'TIMESTAMP', 4, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'AgentPrincipal_Group', 'EndDate', 'STRING', 'agent_principal_group_base_temp', 'end_date', 'STRING', 'agent_principal_group_temp', 'end_timestamp', 'TIMESTAMP', 5, 1, 0, 0, '3000-01-01', 1, GETUTCDATE());

-- [23] AgentLicense_Group
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'AgentLicense_Group', 'AgentLicenseGroupPK', 'STRING', 'agent_license_group_base_temp', 'agent_license_group_pk', 'STRING', 'agent_license_group_temp', 'agent_license_group_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'AgentLicense_Group', 'SourceKey', 'STRING', 'agent_license_group_base_temp', 'source_key', 'STRING', 'agent_license_group_temp', 'source_key', 'BIGINT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'AgentLicense_Group', 'AgentLicenseGroupKey', 'STRING', 'agent_license_group_base_temp', 'agent_license_group_key', 'STRING', 'agent_license_group_temp', 'agent_license_group_key', 'INT', 3, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'AgentLicense_Group', 'LicenseType', 'STRING', 'agent_license_group_base_temp', 'license_type', 'STRING', 'agent_license_group_temp', 'license_type', 'STRING', 4, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AgentLicense_Group', 'LicenseState', 'STRING', 'agent_license_group_base_temp', 'license_state', 'STRING', 'agent_license_group_temp', 'license_state', 'STRING', 5, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AgentLicense_Group', 'Resident', 'STRING', 'agent_license_group_base_temp', 'resident', 'STRING', 'agent_license_group_temp', 'resident', 'STRING', 6, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AgentLicense_Group', 'LicenseNumber', 'STRING', 'agent_license_group_base_temp', 'license_number', 'STRING', 'agent_license_group_temp', 'license_number', 'STRING', 7, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AgentLicense_Group', 'Status', 'STRING', 'agent_license_group_base_temp', 'status', 'STRING', 'agent_license_group_temp', 'status', 'STRING', 8, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AgentLicense_Group', 'EffectiveDate', 'STRING', 'agent_license_group_base_temp', 'effective_date', 'STRING', 'agent_license_group_temp', 'effective_timestamp', 'TIMESTAMP', 9, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'AgentLicense_Group', 'ExpirationDate', 'STRING', 'agent_license_group_base_temp', 'expiration_date', 'STRING', 'agent_license_group_temp', 'expiration_timestamp', 'TIMESTAMP', 10, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'AgentLicense_Group', 'TerminationDate', 'STRING', 'agent_license_group_base_temp', 'termination_date', 'STRING', 'agent_license_group_temp', 'termination_timestamp', 'TIMESTAMP', 11, 1, 0, 0, '3000-01-01', 1, GETUTCDATE());

-- [24] AdditionalInfo_Group
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'AdditionalInfo_Group', 'AdditionalInfoGroupPK', 'STRING', 'additional_info_group_base_temp', 'additional_info_group_pk', 'STRING', 'additional_info_group_temp', 'additional_info_group_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'AdditionalInfo_Group', 'AdditionalInfoGroupKey', 'STRING', 'additional_info_group_base_temp', 'additional_info_group_key', 'STRING', 'additional_info_group_temp', 'additional_info_group_key', 'INT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'AdditionalInfo_Group', 'AdditionalInfoSource', 'STRING', 'additional_info_group_base_temp', 'additional_info_source', 'STRING', 'additional_info_group_temp', 'additional_info_source', 'STRING', 3, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AdditionalInfo_Group', 'AdditionalInfoType', 'STRING', 'additional_info_group_base_temp', 'additional_info_type', 'STRING', 'additional_info_group_temp', 'additional_info_type', 'STRING', 4, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AdditionalInfo_Group', 'AdditionalInfoDescription', 'STRING', 'additional_info_group_base_temp', 'additional_info_description', 'STRING', 'additional_info_group_temp', 'additional_info_description', 'STRING', 5, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AdditionalInfo_Group', 'AdditionalInfoValue', 'STRING', 'additional_info_group_base_temp', 'additional_info_value', 'STRING', 'additional_info_group_temp', 'additional_info_value', 'STRING', 6, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AdditionalInfo_Group', 'AddressLine1', 'STRING', 'additional_info_group_base_temp', 'address_line1', 'STRING', 'additional_info_group_temp', 'address_line_1', 'STRING', 7, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AdditionalInfo_Group', 'AddressLine2', 'STRING', 'additional_info_group_base_temp', 'address_line2', 'STRING', 'additional_info_group_temp', 'address_line_2', 'STRING', 8, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AdditionalInfo_Group', 'AddressLine3', 'STRING', 'additional_info_group_base_temp', 'address_line3', 'STRING', 'additional_info_group_temp', 'address_line_3', 'STRING', 9, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AdditionalInfo_Group', 'AddressLine4', 'STRING', 'additional_info_group_base_temp', 'address_line4', 'STRING', 'additional_info_group_temp', 'address_line_4', 'STRING', 10, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AdditionalInfo_Group', 'City', 'STRING', 'additional_info_group_base_temp', 'city', 'STRING', 'additional_info_group_temp', 'city', 'STRING', 11, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AdditionalInfo_Group', 'State', 'STRING', 'additional_info_group_base_temp', 'state', 'STRING', 'additional_info_group_temp', 'state', 'STRING', 12, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AdditionalInfo_Group', 'ZipCode', 'STRING', 'additional_info_group_base_temp', 'zip_code', 'STRING', 'additional_info_group_temp', 'zip_code', 'STRING', 13, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AdditionalInfo_Group', 'EffectiveDate', 'STRING', 'additional_info_group_base_temp', 'effective_date', 'STRING', 'additional_info_group_temp', 'effective_timestamp', 'TIMESTAMP', 14, 1, 0, 0, '3000-01-01', 1, GETUTCDATE());

-- [25] AdditionalClient_Group
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'AdditionalClient_Group', 'AdditionalClientGroupPK', 'STRING', 'additional_client_group_base_temp', 'additional_client_group_pk', 'STRING', 'additional_client_group_temp', 'additional_client_group_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'AdditionalClient_Group', 'AdditionalClientGroupKey', 'STRING', 'additional_client_group_base_temp', 'additional_client_group_key', 'STRING', 'additional_client_group_temp', 'additional_client_group_key', 'INT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'AdditionalClient_Group', 'ClientFK', 'STRING', 'additional_client_group_base_temp', 'client_fk', 'STRING', 'additional_client_group_temp', 'client_id', 'INT', 3, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'AdditionalClient_Group', 'AdditionalType', 'STRING', 'additional_client_group_base_temp', 'additional_type', 'STRING', 'additional_client_group_temp', 'additional_type', 'STRING', 4, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AdditionalClient_Group', 'Relation', 'STRING', 'additional_client_group_base_temp', 'relation', 'STRING', 'additional_client_group_temp', 'relation', 'STRING', 5, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AdditionalClient_Group', 'AllocationPercent', 'STRING', 'additional_client_group_base_temp', 'allocation_percent', 'STRING', 'additional_client_group_temp', 'allocation_percent', 'DECIMAL(18,4)', 6, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'AdditionalClient_Group', 'Active', 'STRING', 'additional_client_group_base_temp', 'active', 'STRING', 'additional_client_group_temp', 'is_active', 'BOOLEAN', 7, 1, 0, 0, '0', 1, GETUTCDATE());

-- [26] AccountingReporting_Group
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'AccountingReporting_Group', 'AccountingReportingGroupPK', 'STRING', 'accounting_reporting_group_base_temp', 'accounting_reporting_group_pk', 'STRING', 'accounting_reporting_group_temp', 'accounting_reporting_group_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'AccountingReporting_Group', 'AccountingReportingGroupKey', 'STRING', 'accounting_reporting_group_base_temp', 'accounting_reporting_group_key', 'STRING', 'accounting_reporting_group_temp', 'accounting_reporting_group_key', 'INT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'AccountingReporting_Group', 'ReportingCode', 'STRING', 'accounting_reporting_group_base_temp', 'reporting_code', 'STRING', 'accounting_reporting_group_temp', 'reporting_code', 'STRING', 3, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AccountingReporting_Group', 'ReportingClassCode', 'STRING', 'accounting_reporting_group_base_temp', 'reporting_class_code', 'STRING', 'accounting_reporting_group_temp', 'reporting_class_code', 'STRING', 4, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AccountingReporting_Group', 'ReportingDescription', 'STRING', 'accounting_reporting_group_base_temp', 'reporting_description', 'STRING', 'accounting_reporting_group_temp', 'reporting_description', 'STRING', 5, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE());

-- [27] ProductVariationDetail
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'ProductVariationDetail', 'ProductVariationDetailPK', 'STRING', 'product_variation_detail_base_temp', 'product_variation_detail_pk', 'STRING', 'product_variation_detail_temp', 'product_variation_detail_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'ProductVariationDetail', 'DisclosureText', 'STRING', 'product_variation_detail_base_temp', 'disclosure_text', 'STRING', 'product_variation_detail_temp', 'disclosure_text', 'STRING', 2, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'ProductVariationDetail', 'SortOrder', 'STRING', 'product_variation_detail_base_temp', 'sort_order', 'STRING', 'product_variation_detail_temp', 'sort_order', 'INT', 3, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'ProductVariationDetail', 'Type', 'STRING', 'product_variation_detail_base_temp', 'type', 'STRING', 'product_variation_detail_temp', 'type', 'STRING', 4, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE());

-- [28] ProductStateVariation
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'ProductStateVariation', 'ProductStateVariationPK', 'STRING', 'product_state_variation_base_temp', 'product_state_variation_pk', 'STRING', 'product_state_variation_temp', 'product_state_variation_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'ProductStateVariation', 'ProductFK', 'STRING', 'product_state_variation_base_temp', 'product_fk', 'STRING', 'product_state_variation_temp', 'product_id', 'INT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'ProductStateVariation', 'StateCode', 'STRING', 'product_state_variation_base_temp', 'state_code', 'STRING', 'product_state_variation_temp', 'state_code', 'STRING', 3, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'ProductStateVariation', 'ProductVariationDetailFK', 'STRING', 'product_state_variation_base_temp', 'product_variation_detail_fk', 'STRING', 'product_state_variation_temp', 'product_variation_detail_id', 'INT', 4, 1, 0, 0, '0', 1, GETUTCDATE());

-- [29] ProductStateApprovalDisclosure
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'ProductStateApprovalDisclosure', 'PSADisclosurePK', 'STRING', 'product_state_approval_disclosure_base_temp', 'psa_disclosure_pk', 'STRING', 'product_state_approval_disclosure_temp', 'product_state_approval_disclosure_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'ProductStateApprovalDisclosure', 'ProductStateApprovalFK', 'STRING', 'product_state_approval_disclosure_base_temp', 'product_state_approval_fk', 'STRING', 'product_state_approval_disclosure_temp', 'product_state_approval_id', 'INT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'ProductStateApprovalDisclosure', 'MarketingNameOverride', 'STRING', 'product_state_approval_disclosure_base_temp', 'marketing_name_override', 'STRING', 'product_state_approval_disclosure_temp', 'marketing_name_override', 'STRING', 3, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'ProductStateApprovalDisclosure', 'DisclosureText', 'STRING', 'product_state_approval_disclosure_base_temp', 'disclosure_text', 'STRING', 'product_state_approval_disclosure_temp', 'disclosure_text', 'STRING', 4, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'ProductStateApprovalDisclosure', 'SortOrder', 'STRING', 'product_state_approval_disclosure_base_temp', 'sort_order', 'STRING', 'product_state_approval_disclosure_temp', 'sort_order', 'INT', 5, 1, 0, 0, '0', 1, GETUTCDATE());

-- [30] ProductStateApproval
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'ProductStateApproval', 'ProductStateApprovalPK', 'STRING', 'product_state_approval_base_temp', 'product_state_approval_pk', 'STRING', 'product_state_approval_temp', 'product_state_approval_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'ProductStateApproval', 'ProductFK', 'STRING', 'product_state_approval_base_temp', 'product_fk', 'STRING', 'product_state_approval_temp', 'product_id', 'INT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'ProductStateApproval', 'StateCode', 'STRING', 'product_state_approval_base_temp', 'state_code', 'STRING', 'product_state_approval_temp', 'state_code', 'STRING', 3, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'ProductStateApproval', 'ApprovedInd', 'STRING', 'product_state_approval_base_temp', 'approved_ind', 'STRING', 'product_state_approval_temp', 'is_approved', 'BOOLEAN', 4, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'ProductStateApproval', 'StartDate', 'STRING', 'product_state_approval_base_temp', 'start_date', 'STRING', 'product_state_approval_temp', 'start_timestamp', 'TIMESTAMP', 5, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'ProductStateApproval', 'EndDate', 'STRING', 'product_state_approval_base_temp', 'end_date', 'STRING', 'product_state_approval_temp', 'end_timestamp', 'TIMESTAMP', 6, 1, 0, 0, '3000-01-01', 1, GETUTCDATE());

-- [31] hedge.Ratios
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'Ratios', 'RatiosPK', 'STRING', 'hedge_ratios_base_temp', 'ratios_pk', 'STRING', 'hedge_ratios_temp', 'ratios_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Ratios', 'ContractFK', 'STRING', 'hedge_ratios_base_temp', 'contract_fk', 'STRING', 'hedge_ratios_temp', 'contract_id', 'INT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Ratios', 'ValueDate', 'STRING', 'hedge_ratios_base_temp', 'value_date', 'STRING', 'hedge_ratios_temp', 'value_timestamp', 'TIMESTAMP', 3, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Ratios', 'BaseHedgeRatio', 'STRING', 'hedge_ratios_base_temp', 'base_hedge_ratio', 'STRING', 'hedge_ratios_temp', 'base_hedge_ratio', 'DECIMAL(18,4)', 4, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Ratios', 'BaseSurvivalRatio', 'STRING', 'hedge_ratios_base_temp', 'base_survival_ratio', 'STRING', 'hedge_ratios_temp', 'base_survival_ratio', 'DECIMAL(18,4)', 5, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Ratios', 'StartDate', 'STRING', 'hedge_ratios_base_temp', 'start_date', 'STRING', 'hedge_ratios_temp', 'start_timestamp', 'TIMESTAMP', 6, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Ratios', 'EndDate', 'STRING', 'hedge_ratios_base_temp', 'end_date', 'STRING', 'hedge_ratios_temp', 'end_timestamp', 'TIMESTAMP', 7, 1, 0, 0, '3000-01-01', 1, GETUTCDATE());

-- [32] hedge.Options
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'Options', 'OptionsPK', 'STRING', 'hedge_options_base_temp', 'options_pk', 'STRING', 'hedge_options_temp', 'options_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Options', 'ContractFK', 'STRING', 'hedge_options_base_temp', 'contract_fk', 'STRING', 'hedge_options_temp', 'contract_id', 'INT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Options', 'InvestmentFK', 'STRING', 'hedge_options_base_temp', 'investment_fk', 'STRING', 'hedge_options_temp', 'investment_id', 'INT', 3, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Options', 'RenewalDate', 'STRING', 'hedge_options_base_temp', 'renewal_date', 'STRING', 'hedge_options_temp', 'renewal_timestamp', 'TIMESTAMP', 4, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Options', 'IndexValue', 'STRING', 'hedge_options_base_temp', 'index_value', 'STRING', 'hedge_options_temp', 'index_value', 'DECIMAL(18,4)', 5, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Options', 'HedgingPercentage', 'STRING', 'hedge_options_base_temp', 'hedging_percentage', 'STRING', 'hedge_options_temp', 'hedging_percentage', 'DECIMAL(18,4)', 6, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Options', 'HedgeID1', 'STRING', 'hedge_options_base_temp', 'hedge_id1', 'STRING', 'hedge_options_temp', 'hedge_id_1', 'STRING', 7, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Options', 'HedgeID2', 'STRING', 'hedge_options_base_temp', 'hedge_id2', 'STRING', 'hedge_options_temp', 'hedge_id_2', 'STRING', 8, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Options', 'HedgeRenewalDate', 'STRING', 'hedge_options_base_temp', 'hedge_renewal_date', 'STRING', 'hedge_options_temp', 'hedge_renewal_timestamp', 'TIMESTAMP', 9, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Options', 'ValueDate', 'STRING', 'hedge_options_base_temp', 'value_date', 'STRING', 'hedge_options_temp', 'value_timestamp', 'TIMESTAMP', 10, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Options', 'SeriatimHedgeRatio', 'STRING', 'hedge_options_base_temp', 'seriatim_hedge_ratio', 'STRING', 'hedge_options_temp', 'seriatim_hedge_ratio', 'DECIMAL(18,4)', 11, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Options', 'PresentValue', 'STRING', 'hedge_options_base_temp', 'present_value', 'STRING', 'hedge_options_temp', 'present_value', 'DECIMAL(18,4)', 12, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Options', 'Delta', 'STRING', 'hedge_options_base_temp', 'delta', 'STRING', 'hedge_options_temp', 'delta', 'DECIMAL(18,4)', 13, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Options', 'Gamma', 'STRING', 'hedge_options_base_temp', 'gamma', 'STRING', 'hedge_options_temp', 'gamma', 'DECIMAL(18,4)', 14, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Options', 'Vega', 'STRING', 'hedge_options_base_temp', 'vega', 'STRING', 'hedge_options_temp', 'vega', 'DECIMAL(18,4)', 15, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Options', 'Rho', 'STRING', 'hedge_options_base_temp', 'rho', 'STRING', 'hedge_options_temp', 'rho', 'DECIMAL(18,4)', 16, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Options', 'Theta', 'STRING', 'hedge_options_base_temp', 'theta', 'STRING', 'hedge_options_temp', 'theta', 'DECIMAL(18,4)', 17, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Options', 'NeedsHedged', 'STRING', 'hedge_options_base_temp', 'needs_hedged', 'STRING', 'hedge_options_temp', 'needs_hedged', 'BOOLEAN', 18, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Options', 'IsHedged', 'STRING', 'hedge_options_base_temp', 'is_hedged', 'STRING', 'hedge_options_temp', 'is_hedged', 'BOOLEAN', 19, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Options', 'StartDate', 'STRING', 'hedge_options_base_temp', 'start_date', 'STRING', 'hedge_options_temp', 'start_timestamp', 'TIMESTAMP', 20, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Options', 'EndDate', 'STRING', 'hedge_options_base_temp', 'end_date', 'STRING', 'hedge_options_temp', 'end_timestamp', 'TIMESTAMP', 21, 1, 0, 0, '3000-01-01', 1, GETUTCDATE());

-- [33] State
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'State', 'StateCode', 'STRING', 'state_base_temp', 'state_code', 'STRING', 'state_temp', 'state_code', 'STRING', 1, 1, 1, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'State', 'StateName', 'STRING', 'state_base_temp', 'state_name', 'STRING', 'state_temp', 'state_name', 'STRING', 2, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'State', 'DisplayOrder', 'STRING', 'state_base_temp', 'display_order', 'STRING', 'state_temp', 'display_order', 'INT', 3, 1, 0, 0, '0', 1, GETUTCDATE());

-- [34] Date
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'Date', 'DatePK', 'STRING', 'date_base_temp', 'date_pk', 'STRING', 'date_temp', 'date_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Date', 'Date', 'STRING', 'date_base_temp', 'date', 'STRING', 'date_temp', 'calendar_timestamp', 'TIMESTAMP', 2, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Date', 'DateDisplay', 'STRING', 'date_base_temp', 'date_display', 'STRING', 'date_temp', 'date_display', 'STRING', 3, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Date', 'DayOfMonth', 'STRING', 'date_base_temp', 'day_of_month', 'STRING', 'date_temp', 'day_of_month', 'STRING', 4, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Date', 'DaySuffix', 'STRING', 'date_base_temp', 'day_suffix', 'STRING', 'date_temp', 'day_suffix', 'STRING', 5, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Date', 'DayName', 'STRING', 'date_base_temp', 'day_name', 'STRING', 'date_temp', 'day_name', 'STRING', 6, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Date', 'DayOfWeek', 'STRING', 'date_base_temp', 'day_of_week', 'STRING', 'date_temp', 'day_of_week', 'STRING', 7, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Date', 'DayOfWeekInMonth', 'STRING', 'date_base_temp', 'day_of_week_in_month', 'STRING', 'date_temp', 'day_of_week_in_month', 'STRING', 8, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Date', 'DayOfWeekInYear', 'STRING', 'date_base_temp', 'day_of_week_in_year', 'STRING', 'date_temp', 'day_of_week_in_year', 'STRING', 9, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Date', 'DayOfYear', 'STRING', 'date_base_temp', 'day_of_year', 'STRING', 'date_temp', 'day_of_year', 'STRING', 10, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Date', 'WeekOfMonth', 'STRING', 'date_base_temp', 'week_of_month', 'STRING', 'date_temp', 'week_of_month', 'STRING', 11, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Date', 'WeekOfQuarter', 'STRING', 'date_base_temp', 'week_of_quarter', 'STRING', 'date_temp', 'week_of_quarter', 'STRING', 12, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Date', 'WeekOfYear', 'STRING', 'date_base_temp', 'week_of_year', 'STRING', 'date_temp', 'week_of_year', 'STRING', 13, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Date', 'Month', 'STRING', 'date_base_temp', 'month', 'STRING', 'date_temp', 'month', 'STRING', 14, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Date', 'MonthName', 'STRING', 'date_base_temp', 'month_name', 'STRING', 'date_temp', 'month_name', 'STRING', 15, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Date', 'MonthOfQuarter', 'STRING', 'date_base_temp', 'month_of_quarter', 'STRING', 'date_temp', 'month_of_quarter', 'STRING', 16, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Date', 'Quarter', 'STRING', 'date_base_temp', 'quarter', 'STRING', 'date_temp', 'quarter', 'STRING', 17, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Date', 'QuarterName', 'STRING', 'date_base_temp', 'quarter_name', 'STRING', 'date_temp', 'quarter_name', 'STRING', 18, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Date', 'Year', 'STRING', 'date_base_temp', 'year', 'STRING', 'date_temp', 'year', 'STRING', 19, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Date', 'YearName', 'STRING', 'date_base_temp', 'year_name', 'STRING', 'date_temp', 'year_name', 'STRING', 20, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Date', 'MonthYear', 'STRING', 'date_base_temp', 'month_year', 'STRING', 'date_temp', 'month_year', 'STRING', 21, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Date', 'MMYYYY', 'STRING', 'date_base_temp', 'mmyyyy', 'STRING', 'date_temp', 'mmyyyy', 'STRING', 22, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Date', 'FirstDayOfMonth', 'STRING', 'date_base_temp', 'first_day_of_month', 'STRING', 'date_temp', 'first_day_of_month', 'DATE', 23, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Date', 'LastDayOfMonth', 'STRING', 'date_base_temp', 'last_day_of_month', 'STRING', 'date_temp', 'last_day_of_month', 'DATE', 24, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Date', 'FirstDayOfQuarter', 'STRING', 'date_base_temp', 'first_day_of_quarter', 'STRING', 'date_temp', 'first_day_of_quarter', 'DATE', 25, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Date', 'LastDayOfQuarter', 'STRING', 'date_base_temp', 'last_day_of_quarter', 'STRING', 'date_temp', 'last_day_of_quarter', 'DATE', 26, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Date', 'FirstDayOfYear', 'STRING', 'date_base_temp', 'first_day_of_year', 'STRING', 'date_temp', 'first_day_of_year', 'DATE', 27, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Date', 'LastDayOfYear', 'STRING', 'date_base_temp', 'last_day_of_year', 'STRING', 'date_temp', 'last_day_of_year', 'DATE', 28, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Date', 'IsWeekday', 'STRING', 'date_base_temp', 'is_weekday', 'STRING', 'date_temp', 'is_weekday', 'BOOLEAN', 29, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Date', 'IsHoliday', 'STRING', 'date_base_temp', 'is_holiday', 'STRING', 'date_temp', 'is_holiday', 'BOOLEAN', 30, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Date', 'HolidayName', 'STRING', 'date_base_temp', 'holiday_name', 'STRING', 'date_temp', 'holiday_name', 'STRING', 31, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Date', 'IsLastDayOfMonth', 'STRING', 'date_base_temp', 'is_last_day_of_month', 'STRING', 'date_temp', 'is_last_day_of_month', 'BOOLEAN', 32, 1, 0, 0, '0', 1, GETUTCDATE());

-- [35] TrainingCourse
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'TrainingCourse', 'TrainingCoursePK', 'STRING', 'training_course_base_temp', 'training_course_pk', 'STRING', 'training_course_temp', 'training_course_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'TrainingCourse', 'CourseName', 'STRING', 'training_course_base_temp', 'course_name', 'STRING', 'training_course_temp', 'course_name', 'STRING', 2, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'TrainingCourse', 'Context', 'STRING', 'training_course_base_temp', 'context', 'STRING', 'training_course_temp', 'context', 'STRING', 3, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'TrainingCourse', 'TrainingProductGroupKey', 'STRING', 'training_course_base_temp', 'training_product_group_key', 'STRING', 'training_course_temp', 'training_product_group_key', 'INT', 4, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'TrainingCourse', 'TrainingStateGroupKey', 'STRING', 'training_course_base_temp', 'training_state_group_key', 'STRING', 'training_course_temp', 'training_state_group_key', 'INT', 5, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'TrainingCourse', 'Description', 'STRING', 'training_course_base_temp', 'description', 'STRING', 'training_course_temp', 'description', 'STRING', 6, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE());

-- [36] AgentTraining
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'AgentTraining', 'AgentTrainingPK', 'STRING', 'agent_training_base_temp', 'agent_training_pk', 'STRING', 'agent_training_temp', 'agent_training_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'AgentTraining', 'AgentFK', 'STRING', 'agent_training_base_temp', 'agent_fk', 'STRING', 'agent_training_temp', 'agent_id', 'INT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'AgentTraining', 'TrainingCourseFK', 'STRING', 'agent_training_base_temp', 'training_course_fk', 'STRING', 'agent_training_temp', 'training_course_id', 'INT', 3, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'AgentTraining', 'CompletionDate', 'STRING', 'agent_training_base_temp', 'completion_date', 'STRING', 'agent_training_temp', 'completion_timestamp', 'TIMESTAMP', 4, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'AgentTraining', 'ExpirationDate', 'STRING', 'agent_training_base_temp', 'expiration_date', 'STRING', 'agent_training_temp', 'expiration_timestamp', 'TIMESTAMP', 5, 1, 0, 0, '3000-01-01', 1, GETUTCDATE());

-- [37] Company
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'Company', 'CompanyPK', 'STRING', 'company_base_temp', 'company_pk', 'STRING', 'company_temp', 'company_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Company', 'CompanyCode', 'STRING', 'company_base_temp', 'company_code', 'STRING', 'company_temp', 'company_code', 'STRING', 2, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Company', 'AgentFK', 'STRING', 'company_base_temp', 'agent_fk', 'STRING', 'company_temp', 'agent_id', 'INT', 3, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Company', 'Name', 'STRING', 'company_base_temp', 'name', 'STRING', 'company_temp', 'name', 'STRING', 4, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Company', 'DisplayName', 'STRING', 'company_base_temp', 'display_name', 'STRING', 'company_temp', 'display_name', 'STRING', 5, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Company', 'AddressLine1', 'STRING', 'company_base_temp', 'address_line1', 'STRING', 'company_temp', 'address_line_1', 'STRING', 6, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Company', 'AddressLine2', 'STRING', 'company_base_temp', 'address_line2', 'STRING', 'company_temp', 'address_line_2', 'STRING', 7, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Company', 'City', 'STRING', 'company_base_temp', 'city', 'STRING', 'company_temp', 'city', 'STRING', 8, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Company', 'State', 'STRING', 'company_base_temp', 'state', 'STRING', 'company_temp', 'state', 'STRING', 9, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Company', 'ZipCode', 'STRING', 'company_base_temp', 'zip_code', 'STRING', 'company_temp', 'zip_code', 'STRING', 10, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Company', 'Phone', 'STRING', 'company_base_temp', 'phone', 'STRING', 'company_temp', 'phone', 'STRING', 11, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Company', 'Footer', 'STRING', 'company_base_temp', 'footer', 'STRING', 'company_temp', 'footer', 'STRING', 12, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE());

-- [38] CAPStatusChange
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'CAPStatusChange', 'CAPStatusChangePK', 'STRING', 'cap_status_change_base_temp', 'cap_status_change_pk', 'STRING', 'cap_status_change_temp', 'cap_status_change_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'CAPStatusChange', 'ContractFK', 'STRING', 'cap_status_change_base_temp', 'contract_fk', 'STRING', 'cap_status_change_temp', 'contract_id', 'INT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'CAPStatusChange', 'SourceCompanyFK', 'STRING', 'cap_status_change_base_temp', 'source_company_fk', 'STRING', 'cap_status_change_temp', 'source_company_id', 'INT', 3, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'CAPStatusChange', 'StatusChangeDate', 'STRING', 'cap_status_change_base_temp', 'status_change_date', 'STRING', 'cap_status_change_temp', 'status_change_date', 'TIMESTAMP', 4, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'CAPStatusChange', 'StatusChangeCode', 'STRING', 'cap_status_change_base_temp', 'status_change_code', 'STRING', 'cap_status_change_temp', 'status_change_code', 'STRING', 5, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'CAPStatusChange', 'ProcessDate', 'STRING', 'cap_status_change_base_temp', 'process_date', 'STRING', 'cap_status_change_temp', 'process_date', 'TIMESTAMP', 6, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'CAPStatusChange', 'RenewalPeriod', 'STRING', 'cap_status_change_base_temp', 'renewal_period', 'STRING', 'cap_status_change_temp', 'renewal_period', 'INT', 7, 1, 0, 0, '0', 1, GETUTCDATE());

-- [39] CAPRepayment
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'CAPRepayment', 'CAPRepaymentPK', 'STRING', 'cap_repayment_base_temp', 'cap_repayment_pk', 'STRING', 'cap_repayment_temp', 'cap_repayment_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'CAPRepayment', 'SourceKey', 'STRING', 'cap_repayment_base_temp', 'source_key', 'STRING', 'cap_repayment_temp', 'source_key', 'BIGINT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'CAPRepayment', 'SourceCompanyFK', 'STRING', 'cap_repayment_base_temp', 'source_company_fk', 'STRING', 'cap_repayment_temp', 'source_company_id', 'INT', 3, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'CAPRepayment', 'PlanCode', 'STRING', 'cap_repayment_base_temp', 'plan_code', 'STRING', 'cap_repayment_temp', 'plan_code', 'STRING', 4, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'CAPRepayment', 'PlanCode2', 'STRING', 'cap_repayment_base_temp', 'plan_code2', 'STRING', 'cap_repayment_temp', 'plan_code_2', 'STRING', 5, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'CAPRepayment', 'OwnerResState', 'STRING', 'cap_repayment_base_temp', 'owner_res_state', 'STRING', 'cap_repayment_temp', 'owner_res_state', 'STRING', 6, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'CAPRepayment', 'OwnerCountry', 'STRING', 'cap_repayment_base_temp', 'owner_country', 'STRING', 'cap_repayment_temp', 'owner_country', 'STRING', 7, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'CAPRepayment', 'TerminationDate', 'STRING', 'cap_repayment_base_temp', 'termination_date', 'STRING', 'cap_repayment_temp', 'termination_date', 'TIMESTAMP', 8, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'CAPRepayment', 'FactorTrail', 'STRING', 'cap_repayment_base_temp', 'factor_trail', 'STRING', 'cap_repayment_temp', 'factor_trail', 'DECIMAL(18,4)', 9, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'CAPRepayment', 'RenewalPeriod', 'STRING', 'cap_repayment_base_temp', 'renewal_period', 'STRING', 'cap_repayment_temp', 'renewal_period', 'INT', 10, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'CAPRepayment', 'CommissionableAmount', 'STRING', 'cap_repayment_base_temp', 'commissionable_amount', 'STRING', 'cap_repayment_temp', 'commissionable_amount', 'DECIMAL(18,4)', 11, 1, 0, 0, '0', 1, GETUTCDATE());

-- [40] ActivityType
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'ActivityType', 'ActivityTypePK', 'STRING', 'activity_type_base_temp', 'activity_type_pk', 'STRING', 'activity_type_temp', 'activity_type_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'ActivityType', 'ActivityTypeName', 'STRING', 'activity_type_base_temp', 'activity_type_name', 'STRING', 'activity_type_temp', 'activity_type_name', 'STRING', 2, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'ActivityType', 'ActivityTypeQualifier', 'STRING', 'activity_type_base_temp', 'activity_type_qualifier', 'STRING', 'activity_type_temp', 'activity_type_qualifier', 'STRING', 3, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'ActivityType', 'Source', 'STRING', 'activity_type_base_temp', 'source', 'STRING', 'activity_type_temp', 'source', 'STRING', 4, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'ActivityType', 'ValueType', 'STRING', 'activity_type_base_temp', 'value_type', 'STRING', 'activity_type_temp', 'value_type', 'STRING', 5, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'ActivityType', 'SortOrder', 'STRING', 'activity_type_base_temp', 'sort_order', 'STRING', 'activity_type_temp', 'sort_order', 'INT', 6, 1, 0, 0, '0', 1, GETUTCDATE());

-- [41] ActivityFinancial
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'ActivityFinancial', 'ActivityPK', 'STRING', 'activity_financial_base_temp', 'activity_pk', 'STRING', 'activity_financial_temp', 'activity_id', 'BIGINT', 1, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'ActivityFinancial', 'FreeAmount', 'STRING', 'activity_financial_base_temp', 'free_amount', 'STRING', 'activity_financial_temp', 'free_amount', 'DECIMAL(18,4)', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'ActivityFinancial', 'SurrenderCharge', 'STRING', 'activity_financial_base_temp', 'surrender_charge', 'STRING', 'activity_financial_temp', 'surrender_charge', 'DECIMAL(18,4)', 3, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'ActivityFinancial', 'MVA', 'STRING', 'activity_financial_base_temp', 'mva', 'STRING', 'activity_financial_temp', 'mva', 'DECIMAL(18,4)', 4, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'ActivityFinancial', 'PolicyFee', 'STRING', 'activity_financial_base_temp', 'policy_fee', 'STRING', 'activity_financial_temp', 'policy_fee', 'DECIMAL(18,4)', 5, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'ActivityFinancial', 'COIRefund', 'STRING', 'activity_financial_base_temp', 'coi_refund', 'STRING', 'activity_financial_temp', 'coi_refund', 'DECIMAL(18,4)', 6, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'ActivityFinancial', 'ABRDiscountCharge', 'STRING', 'activity_financial_base_temp', 'abr_discount_charge', 'STRING', 'activity_financial_temp', 'abr_discount_charge', 'DECIMAL(18,4)', 7, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'ActivityFinancial', 'AdminCharge', 'STRING', 'activity_financial_base_temp', 'admin_charge', 'STRING', 'activity_financial_temp', 'admin_charge', 'DECIMAL(18,4)', 8, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'ActivityFinancial', 'FederalTax', 'STRING', 'activity_financial_base_temp', 'federal_tax', 'STRING', 'activity_financial_temp', 'federal_tax', 'DECIMAL(18,4)', 9, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'ActivityFinancial', 'StateTax', 'STRING', 'activity_financial_base_temp', 'state_tax', 'STRING', 'activity_financial_temp', 'state_tax', 'DECIMAL(18,4)', 10, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'ActivityFinancial', 'Rate', 'STRING', 'activity_financial_base_temp', 'rate', 'STRING', 'activity_financial_temp', 'rate', 'DECIMAL(18,4)', 11, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'ActivityFinancial', 'BaseAmount', 'STRING', 'activity_financial_base_temp', 'base_amount', 'STRING', 'activity_financial_temp', 'base_amount', 'DECIMAL(18,4)', 12, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'ActivityFinancial', 'TaxableBenefit', 'STRING', 'activity_financial_base_temp', 'taxable_benefit', 'STRING', 'activity_financial_temp', 'taxable_benefit', 'DECIMAL(18,4)', 13, 1, 0, 0, '0', 1, GETUTCDATE());

-- [42] AccountingDetail
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'AccountingDetail', 'AccountingPK', 'STRING', 'accounting_detail_base_temp', 'accounting_pk', 'STRING', 'accounting_detail_temp', 'accounting_id', 'BIGINT', 1, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'AccountingDetail', 'SourceCode', 'STRING', 'accounting_detail_base_temp', 'source_code', 'STRING', 'accounting_detail_temp', 'source_code', 'STRING', 2, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AccountingDetail', 'ReferenceData', 'STRING', 'accounting_detail_base_temp', 'reference_data', 'STRING', 'accounting_detail_temp', 'reference_data', 'STRING', 3, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AccountingDetail', 'Approval', 'STRING', 'accounting_detail_base_temp', 'approval', 'STRING', 'accounting_detail_temp', 'approval', 'STRING', 4, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AccountingDetail', 'Description', 'STRING', 'accounting_detail_base_temp', 'description', 'STRING', 'accounting_detail_temp', 'description', 'STRING', 5, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AccountingDetail', 'CompanyCode', 'STRING', 'accounting_detail_base_temp', 'company_code', 'STRING', 'accounting_detail_temp', 'company_code', 'STRING', 6, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AccountingDetail', 'DCIndicator', 'STRING', 'accounting_detail_base_temp', 'dc_indicator', 'STRING', 'accounting_detail_temp', 'dc_indicator', 'STRING', 7, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AccountingDetail', 'EntryOperator', 'STRING', 'accounting_detail_base_temp', 'entry_operator', 'STRING', 'accounting_detail_temp', 'entry_operator', 'STRING', 8, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AccountingDetail', 'ApprovalOperator', 'STRING', 'accounting_detail_base_temp', 'approval_operator', 'STRING', 'accounting_detail_temp', 'approval_operator', 'STRING', 9, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AccountingDetail', 'APEXTIndicator', 'STRING', 'accounting_detail_base_temp', 'apext_indicator', 'STRING', 'accounting_detail_temp', 'apext_indicator', 'STRING', 10, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AccountingDetail', 'SuspenseEXTIndicator', 'STRING', 'accounting_detail_base_temp', 'suspense_ext_indicator', 'STRING', 'accounting_detail_temp', 'suspense_ext_indicator', 'STRING', 11, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AccountingDetail', 'EntryGenIndicator', 'STRING', 'accounting_detail_base_temp', 'entry_gen_indicator', 'STRING', 'accounting_detail_temp', 'entry_gen_indicator', 'STRING', 12, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AccountingDetail', 'Treaty', 'STRING', 'accounting_detail_base_temp', 'treaty', 'STRING', 'accounting_detail_temp', 'treaty', 'STRING', 13, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AccountingDetail', 'QualType', 'STRING', 'accounting_detail_base_temp', 'qual_type', 'STRING', 'accounting_detail_temp', 'qual_type', 'STRING', 14, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AccountingDetail', 'SEG_EDITTrxPK', 'STRING', 'accounting_detail_base_temp', 'seg_edit_trx_pk', 'STRING', 'accounting_detail_temp', 'seg_edit_trx_id', 'BIGINT', 15, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'AccountingDetail', 'SEG_PlacedAgentPK', 'STRING', 'accounting_detail_base_temp', 'seg_placed_agent_pk', 'STRING', 'accounting_detail_temp', 'seg_placed_agent_id', 'BIGINT', 16, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'AccountingDetail', 'CostCenter', 'STRING', 'accounting_detail_base_temp', 'cost_center', 'STRING', 'accounting_detail_temp', 'cost_center', 'STRING', 17, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AccountingDetail', 'SuspenseCode', 'STRING', 'accounting_detail_base_temp', 'suspense_code', 'STRING', 'accounting_detail_temp', 'suspense_code', 'STRING', 18, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE());

-- [43] AccountingAccount
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'AccountingAccount', 'AccountingAccountPK', 'STRING', 'accounting_account_base_temp', 'accounting_account_pk', 'STRING', 'accounting_account_temp', 'accounting_account_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'AccountingAccount', 'AccountNumber', 'STRING', 'accounting_account_base_temp', 'account_number', 'STRING', 'accounting_account_temp', 'account_number', 'STRING', 2, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AccountingAccount', 'AccountSource', 'STRING', 'accounting_account_base_temp', 'account_source', 'STRING', 'accounting_account_temp', 'account_source', 'STRING', 3, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AccountingAccount', 'ClassCode', 'STRING', 'accounting_account_base_temp', 'class_code', 'STRING', 'accounting_account_temp', 'class_code', 'STRING', 4, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AccountingAccount', 'CubeDescription', 'STRING', 'accounting_account_base_temp', 'cube_description', 'STRING', 'accounting_account_temp', 'cube_description', 'STRING', 5, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AccountingAccount', 'GroupIndicator', 'STRING', 'accounting_account_base_temp', 'group_indicator', 'STRING', 'accounting_account_temp', 'group_indicator', 'BOOLEAN', 6, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'AccountingAccount', 'CededIndicator', 'STRING', 'accounting_account_base_temp', 'ceded_indicator', 'STRING', 'accounting_account_temp', 'ceded_indicator', 'BOOLEAN', 7, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'AccountingAccount', 'Context', 'STRING', 'accounting_account_base_temp', 'context', 'STRING', 'accounting_account_temp', 'context', 'STRING', 8, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AccountingAccount', 'ActuarialGrouping', 'STRING', 'accounting_account_base_temp', 'actuarial_grouping', 'STRING', 'accounting_account_temp', 'actuarial_grouping', 'STRING', 9, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AccountingAccount', 'AccountDescription', 'STRING', 'accounting_account_base_temp', 'account_description', 'STRING', 'accounting_account_temp', 'account_description', 'STRING', 10, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AccountingAccount', 'AccountingReportingGroupKey', 'STRING', 'accounting_account_base_temp', 'accounting_reporting_group_key', 'STRING', 'accounting_account_temp', 'accounting_reporting_group_key', 'INT', 11, 1, 0, 0, '0', 1, GETUTCDATE());

-- [44] Accounting
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'Accounting', 'AccountingPK', 'STRING', 'accounting_base_temp', 'accounting_pk', 'STRING', 'accounting_temp', 'accounting_id', 'BIGINT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Accounting', 'SourceSystem', 'STRING', 'accounting_base_temp', 'source_system', 'STRING', 'accounting_temp', 'source_system_code', 'STRING', 2, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Accounting', 'TranID', 'STRING', 'accounting_base_temp', 'tran_id', 'STRING', 'accounting_temp', 'transaction_id', 'INT', 3, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Accounting', 'TranDetailID', 'STRING', 'accounting_base_temp', 'tran_detail_id', 'STRING', 'accounting_temp', 'transaction_detail_id', 'BIGINT', 4, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Accounting', 'StatusCode', 'STRING', 'accounting_base_temp', 'status_code', 'STRING', 'accounting_temp', 'status_code', 'STRING', 5, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Accounting', 'StatusIndicator', 'STRING', 'accounting_base_temp', 'status_indicator', 'STRING', 'accounting_temp', 'status_indicator', 'STRING', 6, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Accounting', 'BasisCode', 'STRING', 'accounting_base_temp', 'basis_code', 'STRING', 'accounting_temp', 'basis_code', 'STRING', 7, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Accounting', 'State', 'STRING', 'accounting_base_temp', 'state', 'STRING', 'accounting_temp', 'state_code', 'STRING', 8, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Accounting', 'EffectiveDateFK', 'STRING', 'accounting_base_temp', 'effective_date_fk', 'STRING', 'accounting_temp', 'effective_date_id', 'INT', 9, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Accounting', 'PeriodDateFK', 'STRING', 'accounting_base_temp', 'period_date_fk', 'STRING', 'accounting_temp', 'period_date_id', 'INT', 10, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Accounting', 'AccountingAccountFK', 'STRING', 'accounting_base_temp', 'accounting_account_fk', 'STRING', 'accounting_temp', 'accounting_account_id', 'INT', 11, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Accounting', 'EntryDate', 'STRING', 'accounting_base_temp', 'entry_date', 'STRING', 'accounting_temp', 'entry_date', 'DATE', 12, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Accounting', 'EntryUpdateDate', 'STRING', 'accounting_base_temp', 'entry_update_date', 'STRING', 'accounting_temp', 'entry_update_date', 'DATE', 13, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Accounting', 'ContractFK', 'STRING', 'accounting_base_temp', 'contract_fk', 'STRING', 'accounting_temp', 'contract_id', 'INT', 14, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Accounting', 'InvestmentFK', 'STRING', 'accounting_base_temp', 'investment_fk', 'STRING', 'accounting_temp', 'investment_id', 'INT', 15, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Accounting', 'ProductFK', 'STRING', 'accounting_base_temp', 'product_fk', 'STRING', 'accounting_temp', 'product_id', 'INT', 16, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Accounting', 'AgentFK', 'STRING', 'accounting_base_temp', 'agent_fk', 'STRING', 'accounting_temp', 'agent_id', 'INT', 17, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Accounting', 'Amount', 'STRING', 'accounting_base_temp', 'amount', 'STRING', 'accounting_temp', 'amount', 'DECIMAL(18,4)', 18, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Accounting', 'Block', 'STRING', 'accounting_base_temp', 'block', 'STRING', 'accounting_temp', 'block_code', 'STRING', 19, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE());

-- [45] Surrender
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'Surrender', 'SurrenderPK', 'STRING', 'surrender_base_temp', 'surrender_pk', 'STRING', 'surrender_temp', 'surrender_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Surrender', 'ProductFK', 'STRING', 'surrender_base_temp', 'product_fk', 'STRING', 'surrender_temp', 'product_id', 'INT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Surrender', 'FundNumber', 'STRING', 'surrender_base_temp', 'fund_number', 'STRING', 'surrender_temp', 'fund_number', 'STRING', 3, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Surrender', 'State', 'STRING', 'surrender_base_temp', 'state', 'STRING', 'surrender_temp', 'state_code', 'STRING', 4, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Surrender', 'Gender', 'STRING', 'surrender_base_temp', 'gender', 'STRING', 'surrender_temp', 'gender', 'STRING', 5, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Surrender', 'Class', 'STRING', 'surrender_base_temp', 'class', 'STRING', 'surrender_temp', 'risk_class', 'STRING', 6, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Surrender', 'Age', 'STRING', 'surrender_base_temp', 'age', 'STRING', 'surrender_temp', 'customer_age', 'INT', 7, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Surrender', 'ContractYear', 'STRING', 'surrender_base_temp', 'contract_year', 'STRING', 'surrender_temp', 'policy_year', 'INT', 8, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Surrender', 'SurrenderLength', 'STRING', 'surrender_base_temp', 'surrender_length', 'STRING', 'surrender_temp', 'penalty_duration_years', 'INT', 9, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Surrender', 'Rate', 'STRING', 'surrender_base_temp', 'rate', 'STRING', 'surrender_temp', 'penalty_percentage', 'DECIMAL(18,4)', 10, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Surrender', 'RateAppliedTo', 'STRING', 'surrender_base_temp', 'rate_applied_to', 'STRING', 'surrender_temp', 'rate_calculation_basis', 'STRING', 11, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Surrender', 'EffectiveDate', 'STRING', 'surrender_base_temp', 'effective_date', 'STRING', 'surrender_temp', 'rule_start_date', 'TIMESTAMP', 12, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Surrender', 'EndDate', 'STRING', 'surrender_base_temp', 'end_date', 'STRING', 'surrender_temp', 'rule_end_date', 'TIMESTAMP', 13, 1, 0, 0, '3000-01-01', 1, GETUTCDATE());

-- [46] InvestmentDetail
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'InvestmentDetail', 'InvestmentDetailPK', 'STRING', 'investment_detail_base_temp', 'investment_detail_pk', 'STRING', 'investment_detail_temp', 'investment_detail_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'InvestmentDetail', 'Name', 'STRING', 'investment_detail_base_temp', 'name', 'STRING', 'investment_detail_temp', 'investment_detail_name', 'STRING', 2, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'InvestmentDetail', 'FundType', 'STRING', 'investment_detail_base_temp', 'fund_type', 'STRING', 'investment_detail_temp', 'fund_type', 'STRING', 3, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'InvestmentDetail', 'GroupingName', 'STRING', 'investment_detail_base_temp', 'grouping_name', 'STRING', 'investment_detail_temp', 'grouping_name', 'STRING', 4, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'InvestmentDetail', 'MarketingName', 'STRING', 'investment_detail_base_temp', 'marketing_name', 'STRING', 'investment_detail_temp', 'marketing_name', 'STRING', 5, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'InvestmentDetail', 'AltMarketingName', 'STRING', 'investment_detail_base_temp', 'alt_marketing_name', 'STRING', 'investment_detail_temp', 'alt_marketing_name', 'STRING', 6, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'InvestmentDetail', 'SortOrder', 'STRING', 'investment_detail_base_temp', 'sort_order', 'STRING', 'investment_detail_temp', 'sort_order', 'STRING', 7, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'InvestmentDetail', 'IsCap', 'STRING', 'investment_detail_base_temp', 'is_cap', 'STRING', 'investment_detail_temp', 'is_cap_indicator', 'BOOLEAN', 8, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'InvestmentDetail', 'FundStartDate', 'STRING', 'investment_detail_base_temp', 'fund_start_date', 'STRING', 'investment_detail_temp', 'fund_start_date', 'TIMESTAMP', 9, 1, 0, 0, '3000-01-01', 1, GETUTCDATE());

-- [47] Investment
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'Investment', 'InvestmentPK', 'STRING', 'investment_base_temp', 'investment_pk', 'STRING', 'investment_temp', 'investment_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Investment', 'InvestmentKey', 'STRING', 'investment_base_temp', 'investment_key', 'STRING', 'investment_temp', 'investment_key', 'INT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Investment', 'InvestmentName', 'STRING', 'investment_base_temp', 'investment_name', 'STRING', 'investment_temp', 'investment_name', 'STRING', 3, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Investment', 'InvestmentDescription', 'STRING', 'investment_base_temp', 'investment_description', 'STRING', 'investment_temp', 'investment_description', 'STRING', 4, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Investment', 'EffectiveDate', 'STRING', 'investment_base_temp', 'effective_date', 'STRING', 'investment_temp', 'effective_date', 'TIMESTAMP', 5, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Investment', 'Active', 'STRING', 'investment_base_temp', 'active', 'STRING', 'investment_temp', 'active_indicator', 'BOOLEAN', 6, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Investment', 'StartDate', 'STRING', 'investment_base_temp', 'start_date', 'STRING', 'investment_temp', 'start_timestamp', 'TIMESTAMP', 7, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Investment', 'EndDate', 'STRING', 'investment_base_temp', 'end_date', 'STRING', 'investment_temp', 'end_timestamp', 'TIMESTAMP', 8, 1, 0, 0, '3000-01-01', 1, GETUTCDATE());

-- [48] Activity
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'Activity', 'ActivityPK', 'STRING', 'activity_base_temp', 'activity_pk', 'STRING', 'activity_temp', 'activity_id', 'BIGINT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Activity', 'ActivityTypeFK', 'STRING', 'activity_base_temp', 'activity_type_fk', 'STRING', 'activity_temp', 'activity_type_id', 'INT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Activity', 'CompanyFK', 'STRING', 'activity_base_temp', 'company_fk', 'STRING', 'activity_temp', 'company_id', 'INT', 3, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Activity', 'ContractFK', 'STRING', 'activity_base_temp', 'contract_fk', 'STRING', 'activity_temp', 'contract_id', 'INT', 4, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Activity', 'ProductFK', 'STRING', 'activity_base_temp', 'product_fk', 'STRING', 'activity_temp', 'product_id', 'INT', 5, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Activity', 'InvestmentFK', 'STRING', 'activity_base_temp', 'investment_fk', 'STRING', 'activity_temp', 'investment_id', 'INT', 6, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Activity', 'AccountingFK', 'STRING', 'activity_base_temp', 'accounting_fk', 'STRING', 'activity_temp', 'accounting_id', 'INT', 7, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Activity', 'AccountingAccountFK', 'STRING', 'activity_base_temp', 'accounting_account_fk', 'STRING', 'activity_temp', 'accounting_account_id', 'INT', 8, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Activity', 'CAPRepaymentFK', 'STRING', 'activity_base_temp', 'cap_repayment_fk', 'STRING', 'activity_temp', 'cap_repayment_id', 'INT', 9, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Activity', 'HierarchySetKey', 'STRING', 'activity_base_temp', 'hierarchy_set_key', 'STRING', 'activity_temp', 'hierarchy_set_id', 'INT', 10, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Activity', 'AgentFK', 'STRING', 'activity_base_temp', 'agent_fk', 'STRING', 'activity_temp', 'agent_id', 'INT', 11, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Activity', 'ActivityClientFK', 'STRING', 'activity_base_temp', 'activity_client_fk', 'STRING', 'activity_temp', 'activity_client_id', 'INT', 12, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Activity', 'ActivityPayeeFK', 'STRING', 'activity_base_temp', 'activity_payee_fk', 'STRING', 'activity_temp', 'activity_payee_id', 'INT', 13, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Activity', 'EffectiveDateFK', 'STRING', 'activity_base_temp', 'effective_date_fk', 'STRING', 'activity_temp', 'effective_date_id', 'INT', 14, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Activity', 'ProcessDateFK', 'STRING', 'activity_base_temp', 'process_date_fk', 'STRING', 'activity_temp', 'process_date_id', 'INT', 15, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Activity', 'ReleaseDate', 'STRING', 'activity_base_temp', 'release_date', 'STRING', 'activity_temp', 'release_date', 'TIMESTAMP', 16, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Activity', 'PeriodDate', 'STRING', 'activity_base_temp', 'period_date', 'STRING', 'activity_temp', 'period_date', 'TIMESTAMP', 17, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Activity', 'GrossAmount', 'STRING', 'activity_base_temp', 'gross_amount', 'STRING', 'activity_temp', 'gross_amount', 'DECIMAL(18,4)', 18, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Activity', 'NetAmount', 'STRING', 'activity_base_temp', 'net_amount', 'STRING', 'activity_temp', 'net_amount', 'DECIMAL(18,4)', 19, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Activity', 'CheckAmount', 'STRING', 'activity_base_temp', 'check_amount', 'STRING', 'activity_temp', 'check_amount', 'DECIMAL(18,4)', 20, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Activity', 'DistributionType', 'STRING', 'activity_base_temp', 'distribution_type', 'STRING', 'activity_temp', 'distribution_type', 'STRING', 21, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Activity', 'TextValue', 'STRING', 'activity_base_temp', 'text_value', 'STRING', 'activity_temp', 'activity_notes', 'STRING', 22, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE());

-- [49] AccountValue
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'AccountValue', 'AccountValuePK', 'STRING', 'account_value_base_temp', 'account_value_pk', 'STRING', 'account_value_temp', 'account_value_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'AccountValue', 'ContractFK', 'STRING', 'account_value_base_temp', 'contract_fk', 'STRING', 'account_value_temp', 'contract_id', 'INT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'AccountValue', 'InvestmentFK', 'STRING', 'account_value_base_temp', 'investment_fk', 'STRING', 'account_value_temp', 'investment_id', 'INT', 3, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'AccountValue', 'Value', 'STRING', 'account_value_base_temp', 'value', 'STRING', 'account_value_temp', 'account_value_amount', 'DECIMAL(18,4)', 4, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'AccountValue', 'CurrentInterestRate', 'STRING', 'account_value_base_temp', 'current_interest_rate', 'STRING', 'account_value_temp', 'current_interest_rate', 'DECIMAL(18,4)', 5, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'AccountValue', 'AllocationPercent', 'STRING', 'account_value_base_temp', 'allocation_percent', 'STRING', 'account_value_temp', 'allocation_percentage', 'DECIMAL(18,4)', 6, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'AccountValue', 'DepositDate', 'STRING', 'account_value_base_temp', 'deposit_date', 'STRING', 'account_value_temp', 'deposit_date', 'TIMESTAMP', 7, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'AccountValue', 'RenewalDate', 'STRING', 'account_value_base_temp', 'renewal_date', 'STRING', 'account_value_temp', 'renewal_date', 'TIMESTAMP', 8, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'AccountValue', 'ValuationDate', 'STRING', 'account_value_base_temp', 'valuation_date', 'STRING', 'account_value_temp', 'valuation_date', 'TIMESTAMP', 9, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'AccountValue', 'StartDate', 'STRING', 'account_value_base_temp', 'start_date', 'STRING', 'account_value_temp', 'start_timestamp', 'TIMESTAMP', 10, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'AccountValue', 'EndDate', 'STRING', 'account_value_base_temp', 'end_date', 'STRING', 'account_value_temp', 'end_timestamp', 'TIMESTAMP', 11, 1, 0, 0, '3000-01-01', 1, GETUTCDATE());

-- [50] Product
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'Product', 'ProductPK', 'STRING', 'product_base_temp', 'product_pk', 'STRING', 'product_temp', 'product_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Product', 'ProductName', 'STRING', 'product_base_temp', 'product_name', 'STRING', 'product_temp', 'product_name', 'STRING', 2, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Product', 'MarketingName', 'STRING', 'product_base_temp', 'marketing_name', 'STRING', 'product_temp', 'marketing_name', 'STRING', 3, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Product', 'AltMarketingName', 'STRING', 'product_base_temp', 'alt_marketing_name', 'STRING', 'product_temp', 'alt_marketing_name', 'STRING', 4, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Product', 'GroupName', 'STRING', 'product_base_temp', 'group_name', 'STRING', 'product_temp', 'group_name', 'STRING', 5, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Product', 'AgentCommStatementAbbr', 'STRING', 'product_base_temp', 'agent_comm_statement_abbr', 'STRING', 'product_temp', 'agent_comm_statement_abbr', 'STRING', 6, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Product', 'GLAbbr', 'STRING', 'product_base_temp', 'gl_abbr', 'STRING', 'product_temp', 'gl_abbr', 'STRING', 7, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Product', 'GLLOB', 'STRING', 'product_base_temp', 'gllob', 'STRING', 'product_temp', 'gl_line_of_business', 'STRING', 8, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Product', 'Context', 'STRING', 'product_base_temp', 'context', 'STRING', 'product_temp', 'product_context', 'STRING', 9, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Product', 'ProductType', 'STRING', 'product_base_temp', 'product_type', 'STRING', 'product_temp', 'product_type', 'STRING', 10, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Product', 'CUSIPNumber', 'STRING', 'product_base_temp', 'cusip_number', 'STRING', 'product_temp', 'cusip_number', 'STRING', 11, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Product', 'SortOrder', 'STRING', 'product_base_temp', 'sort_order', 'STRING', 'product_temp', 'sort_order', 'INT', 12, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Product', 'EffectiveDate', 'STRING', 'product_base_temp', 'effective_date', 'STRING', 'product_temp', 'effective_date', 'TIMESTAMP', 13, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Product', 'Status', 'STRING', 'product_base_temp', 'status', 'STRING', 'product_temp', 'status', 'STRING', 14, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE());

-- [51] Agent
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'Agent', 'AgentPK', 'STRING', 'agent_base_temp', 'agent_pk', 'STRING', 'agent_temp', 'agent_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Agent', 'SourceKey', 'STRING', 'agent_base_temp', 'source_key', 'STRING', 'agent_temp', 'source_key', 'BIGINT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Agent', 'ClientFK', 'STRING', 'agent_base_temp', 'client_fk', 'STRING', 'agent_temp', 'client_id', 'INT', 3, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Agent', 'DisplayName', 'STRING', 'agent_base_temp', 'display_name', 'STRING', 'agent_temp', 'display_name', 'STRING', 4, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Agent', 'AgentNumber', 'STRING', 'agent_base_temp', 'agent_number', 'STRING', 'agent_temp', 'agent_number', 'STRING', 5, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Agent', 'NoteGroupKey', 'STRING', 'agent_base_temp', 'note_group_key', 'STRING', 'agent_temp', 'note_group_key', 'INT', 6, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Agent', 'RequirementGroupKey', 'STRING', 'agent_base_temp', 'requirement_group_key', 'STRING', 'agent_temp', 'requirement_group_key', 'INT', 7, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Agent', 'AgentLicenseGroupKey', 'STRING', 'agent_base_temp', 'agent_license_group_key', 'STRING', 'agent_temp', 'agent_license_group_key', 'INT', 8, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Agent', 'AgentPrincipalGroupKey', 'STRING', 'agent_base_temp', 'agent_principal_group_key', 'STRING', 'agent_temp', 'agent_principal_group_key', 'INT', 9, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Agent', 'AgentSummaryGroupKey', 'STRING', 'agent_base_temp', 'agent_summary_group_key', 'STRING', 'agent_temp', 'agent_summary_group_key', 'INT', 10, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Agent', 'NPN', 'STRING', 'agent_base_temp', 'npn', 'STRING', 'agent_temp', 'national_producer_number', 'STRING', 11, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Agent', 'NASD', 'STRING', 'agent_base_temp', 'nasd', 'STRING', 'agent_temp', 'nasd_finra_number', 'STRING', 12, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Agent', 'AgentType', 'STRING', 'agent_base_temp', 'agent_type', 'STRING', 'agent_temp', 'agent_type', 'STRING', 13, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Agent', 'HireDate', 'STRING', 'agent_base_temp', 'hire_date', 'STRING', 'agent_temp', 'hire_date', 'TIMESTAMP', 14, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Agent', 'TerminationDate', 'STRING', 'agent_base_temp', 'termination_date', 'STRING', 'agent_temp', 'termination_date', 'TIMESTAMP', 15, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Agent', 'Status', 'STRING', 'agent_base_temp', 'status', 'STRING', 'agent_temp', 'status', 'STRING', 16, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Agent', 'StartDate', 'STRING', 'agent_base_temp', 'start_date', 'STRING', 'agent_temp', 'start_timestamp', 'TIMESTAMP', 17, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Agent', 'EndDate', 'STRING', 'agent_base_temp', 'end_date', 'STRING', 'agent_temp', 'end_timestamp', 'TIMESTAMP', 18, 1, 0, 0, '3000-01-01', 1, GETUTCDATE());

-- [52] Client
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'Client', 'ClientPK', 'STRING', 'client_base_temp', 'client_pk', 'STRING', 'client_temp', 'client_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Client', 'SourceKey', 'STRING', 'client_base_temp', 'source_key', 'STRING', 'client_temp', 'source_key', 'BIGINT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Client', 'TaxIDHash', 'STRING', 'client_base_temp', 'tax_id_hash', 'STRING', 'client_temp', 'tax_id_hash', 'BINARY', 3, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Client', 'Last4Hash', 'STRING', 'client_base_temp', 'last4_hash', 'STRING', 'client_temp', 'last_4_hash', 'BINARY', 4, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Client', 'Last4Token', 'STRING', 'client_base_temp', 'last4_token', 'STRING', 'client_temp', 'last_4_token', 'STRING', 5, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Client', 'DisplayName', 'STRING', 'client_base_temp', 'display_name', 'STRING', 'client_temp', 'display_name', 'STRING', 6, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Client', 'FirstName', 'STRING', 'client_base_temp', 'first_name', 'STRING', 'client_temp', 'first_name', 'STRING', 7, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Client', 'MiddleName', 'STRING', 'client_base_temp', 'middle_name', 'STRING', 'client_temp', 'middle_name', 'STRING', 8, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Client', 'LastName', 'STRING', 'client_base_temp', 'last_name', 'STRING', 'client_temp', 'last_name', 'STRING', 9, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Client', 'Prefix', 'STRING', 'client_base_temp', 'prefix', 'STRING', 'client_temp', 'prefix', 'STRING', 10, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Client', 'Suffix', 'STRING', 'client_base_temp', 'suffix', 'STRING', 'client_temp', 'suffix', 'STRING', 11, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Client', 'CorporateName', 'STRING', 'client_base_temp', 'corporate_name', 'STRING', 'client_temp', 'corporate_name', 'STRING', 12, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Client', 'Gender', 'STRING', 'client_base_temp', 'gender', 'STRING', 'client_temp', 'gender', 'STRING', 13, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Client', 'Phone', 'STRING', 'client_base_temp', 'phone', 'STRING', 'client_temp', 'phone_number', 'STRING', 14, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Client', 'Email', 'STRING', 'client_base_temp', 'email', 'STRING', 'client_temp', 'email_address', 'STRING', 15, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Client', 'Fax', 'STRING', 'client_base_temp', 'fax', 'STRING', 'client_temp', 'fax_number', 'STRING', 16, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Client', 'BirthDate', 'STRING', 'client_base_temp', 'birth_date', 'STRING', 'client_temp', 'birth_date', 'TIMESTAMP', 17, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Client', 'DateOfDeath', 'STRING', 'client_base_temp', 'date_of_death', 'STRING', 'client_temp', 'date_of_death', 'TIMESTAMP', 18, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Client', 'Status', 'STRING', 'client_base_temp', 'status', 'STRING', 'client_temp', 'status', 'STRING', 19, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Client', 'PayPreference', 'STRING', 'client_base_temp', 'pay_preference', 'STRING', 'client_temp', 'pay_preference', 'STRING', 20, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Client', 'ExternalAccountGroupKey', 'STRING', 'client_base_temp', 'external_account_group_key', 'STRING', 'client_temp', 'external_account_group_key', 'INT', 21, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Client', 'AddressLine1', 'STRING', 'client_base_temp', 'address_line1', 'STRING', 'client_temp', 'address_line_1', 'STRING', 22, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Client', 'AddressLine2', 'STRING', 'client_base_temp', 'address_line2', 'STRING', 'client_temp', 'address_line_2', 'STRING', 23, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Client', 'AddressLine3', 'STRING', 'client_base_temp', 'address_line3', 'STRING', 'client_temp', 'address_line_3', 'STRING', 24, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Client', 'AddressLine4', 'STRING', 'client_base_temp', 'address_line4', 'STRING', 'client_temp', 'address_line_4', 'STRING', 25, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Client', 'City', 'STRING', 'client_base_temp', 'city', 'STRING', 'client_temp', 'city', 'STRING', 26, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Client', 'State', 'STRING', 'client_base_temp', 'state', 'STRING', 'client_temp', 'state_code', 'STRING', 27, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Client', 'ZipCode', 'STRING', 'client_base_temp', 'zip_code', 'STRING', 'client_temp', 'zip_code', 'STRING', 28, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Client', 'County', 'STRING', 'client_base_temp', 'county', 'STRING', 'client_temp', 'county', 'STRING', 29, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Client', 'Country', 'STRING', 'client_base_temp', 'country', 'STRING', 'client_temp', 'country_code', 'STRING', 30, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Client', 'AdditionalInfoGroupKey', 'STRING', 'client_base_temp', 'additional_info_group_key', 'STRING', 'client_temp', 'additional_info_group_key', 'INT', 31, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Client', 'Verification', 'STRING', 'client_base_temp', 'verification', 'STRING', 'client_temp', 'verification_details', 'STRING', 32, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Client', 'NoNewBusinessInd', 'STRING', 'client_base_temp', 'no_new_business_ind', 'STRING', 'client_temp', 'is_no_new_business', 'BOOLEAN', 33, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Client', 'EffectiveDate', 'STRING', 'client_base_temp', 'effective_date', 'STRING', 'client_temp', 'effective_date', 'TIMESTAMP', 34, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Client', 'StartDate', 'STRING', 'client_base_temp', 'start_date', 'STRING', 'client_temp', 'start_timestamp', 'TIMESTAMP', 35, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Client', 'EndDate', 'STRING', 'client_base_temp', 'end_date', 'STRING', 'client_temp', 'end_timestamp', 'TIMESTAMP', 36, 1, 0, 0, '3000-01-01', 1, GETUTCDATE());

-- [53] Contract (Full 51 Columns)
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'Contract', 'ContractPK', 'STRING', 'contract_base_temp', 'contract_pk', 'STRING', 'contract_temp', 'contract_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'ContractNumber', 'STRING', 'contract_base_temp', 'contract_number', 'STRING', 'contract_temp', 'contract_number', 'STRING', 2, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'HierarchyGroupKey', 'STRING', 'contract_base_temp', 'hierarchy_group_key', 'STRING', 'contract_temp', 'hierarchy_group_key', 'INT', 3, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'ContractValueGroupKey', 'STRING', 'contract_base_temp', 'contract_value_group_key', 'STRING', 'contract_temp', 'contract_value_group_key', 'INT', 4, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'SurrenderFK', 'STRING', 'contract_base_temp', 'surrender_fk', 'STRING', 'contract_temp', 'surrender_id', 'INT', 5, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'ProductFK', 'STRING', 'contract_base_temp', 'product_fk', 'STRING', 'contract_temp', 'product_id', 'INT', 6, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'OwnerFK', 'STRING', 'contract_base_temp', 'owner_fk', 'STRING', 'contract_temp', 'owner_client_id', 'INT', 7, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'Owner2FK', 'STRING', 'contract_base_temp', 'owner2_fk', 'STRING', 'contract_temp', 'owner_2_client_id', 'INT', 8, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'AnnuitantInsuredFK', 'STRING', 'contract_base_temp', 'annuitant_insured_fk', 'STRING', 'contract_temp', 'annuitant_insured_client_id', 'INT', 9, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'AnnuitantInsured2FK', 'STRING', 'contract_base_temp', 'annuitant_insured2_fk', 'STRING', 'contract_temp', 'annuitant_insured_2_client_id', 'INT', 10, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'AdditionalClientGroupKey', 'STRING', 'contract_base_temp', 'additional_client_group_key', 'STRING', 'contract_temp', 'additional_client_group_key', 'INT', 11, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'ContractDepositGroupKey', 'STRING', 'contract_base_temp', 'contract_deposit_group_key', 'STRING', 'contract_temp', 'contract_deposit_group_key', 'INT', 12, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'RiderGroupKey', 'STRING', 'contract_base_temp', 'rider_group_key', 'STRING', 'contract_temp', 'rider_group_key', 'INT', 13, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'NoteGroupKey', 'STRING', 'contract_base_temp', 'note_group_key', 'STRING', 'contract_temp', 'note_group_key', 'INT', 14, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'RequirementGroupKey', 'STRING', 'contract_base_temp', 'requirement_group_key', 'STRING', 'contract_temp', 'requirement_group_key', 'INT', 15, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'ReinsuranceGroupKey', 'STRING', 'contract_base_temp', 'reinsurance_group_key', 'STRING', 'contract_temp', 'reinsurance_group_key', 'INT', 16, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'RecurringPaymentGroupKey', 'STRING', 'contract_base_temp', 'recurring_payment_group_key', 'STRING', 'contract_temp', 'recurring_payment_group_key', 'INT', 17, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'ApplicationReceivedDate', 'STRING', 'contract_base_temp', 'application_received_date', 'STRING', 'contract_temp', 'application_received_timestamp', 'TIMESTAMP', 18, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'ApplicationSignedDate', 'STRING', 'contract_base_temp', 'application_signed_date', 'STRING', 'contract_temp', 'application_signed_timestamp', 'TIMESTAMP', 19, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'EffectiveDate', 'STRING', 'contract_base_temp', 'effective_date', 'STRING', 'contract_temp', 'effective_timestamp', 'TIMESTAMP', 20, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'IssueDate', 'STRING', 'contract_base_temp', 'issue_date', 'STRING', 'contract_temp', 'issue_timestamp', 'TIMESTAMP', 21, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'IssueState', 'STRING', 'contract_base_temp', 'issue_state', 'STRING', 'contract_temp', 'issue_state_code', 'STRING', 22, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'IssueAge', 'STRING', 'contract_base_temp', 'issue_age', 'STRING', 'contract_temp', 'issue_age', 'INT', 23, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'AttainedAge', 'STRING', 'contract_base_temp', 'attained_age', 'STRING', 'contract_temp', 'attained_age', 'INT', 24, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'ContractStatus', 'STRING', 'contract_base_temp', 'contract_status', 'STRING', 'contract_temp', 'contract_status_code', 'STRING', 25, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'CostBasis', 'STRING', 'contract_base_temp', 'cost_basis', 'STRING', 'contract_temp', 'cost_basis', 'DECIMAL(18,4)', 26, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'RecoveredCostBasis', 'STRING', 'contract_base_temp', 'recovered_cost_basis', 'STRING', 'contract_temp', 'recovered_cost_basis', 'DECIMAL(18,4)', 27, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'QualInd', 'STRING', 'contract_base_temp', 'qual_ind', 'STRING', 'contract_temp', 'qual_ind', 'STRING', 28, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'QualType', 'STRING', 'contract_base_temp', 'qual_type', 'STRING', 'contract_temp', 'qual_type', 'STRING', 29, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'Option', 'STRING', 'contract_base_temp', 'option', 'STRING', 'contract_temp', 'contract_option', 'STRING', 30, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'CertainPeriod', 'STRING', 'contract_base_temp', 'certain_period', 'STRING', 'contract_temp', 'certain_period', 'INT', 31, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'MECStatus', 'STRING', 'contract_base_temp', 'mec_status', 'STRING', 'contract_temp', 'mec_status_code', 'STRING', 32, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'RelatedContractNumber', 'STRING', 'contract_base_temp', 'related_contract_number', 'STRING', 'contract_temp', 'related_contract_number', 'STRING', 33, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'SpousalContinuationInd', 'STRING', 'contract_base_temp', 'spousal_continuation_ind', 'STRING', 'contract_temp', 'is_spousal_continuation', 'BOOLEAN', 34, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'SupplementalContractInd', 'STRING', 'contract_base_temp', 'supplemental_contract_ind', 'STRING', 'contract_temp', 'is_supplemental_contract', 'BOOLEAN', 35, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'QDROInd', 'STRING', 'contract_base_temp', 'qdro_ind', 'STRING', 'contract_temp', 'is_qdro', 'BOOLEAN', 36, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'RiderClaimInd', 'STRING', 'contract_base_temp', 'rider_claim_ind', 'STRING', 'contract_temp', 'is_rider_claim', 'BOOLEAN', 37, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'ROTHConversionInd', 'STRING', 'contract_base_temp', 'roth_conversion_ind', 'STRING', 'contract_temp', 'is_roth_conversion', 'BOOLEAN', 38, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'InternalReplacementInd', 'STRING', 'contract_base_temp', 'internal_replacement_ind', 'STRING', 'contract_temp', 'is_internal_replacement', 'BOOLEAN', 39, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'PartialTaxConversionInd', 'STRING', 'contract_base_temp', 'partial_tax_conversion_ind', 'STRING', 'contract_temp', 'is_partial_tax_conversion', 'BOOLEAN', 40, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'WaiverInEffectInd', 'STRING', 'contract_base_temp', 'waiver_in_effect_ind', 'STRING', 'contract_temp', 'is_waiver_in_effect', 'BOOLEAN', 41, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'EDeliveryInd', 'STRING', 'contract_base_temp', 'e_delivery_ind', 'STRING', 'contract_temp', 'is_e_delivery', 'BOOLEAN', 42, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'ClassCode', 'STRING', 'contract_base_temp', 'class_code', 'STRING', 'contract_temp', 'class_code', 'STRING', 43, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'UnderwritingClass', 'STRING', 'contract_base_temp', 'underwriting_class', 'STRING', 'contract_temp', 'underwriting_class', 'STRING', 44, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'UnderwritingDate', 'STRING', 'contract_base_temp', 'underwriting_date', 'STRING', 'contract_temp', 'underwriting_timestamp', 'TIMESTAMP', 45, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'CoverageRatio', 'STRING', 'contract_base_temp', 'coverage_ratio', 'STRING', 'contract_temp', 'coverage_ratio', 'DECIMAL(18,4)', 46, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'ContractEndDate', 'STRING', 'contract_base_temp', 'contract_end_date', 'STRING', 'contract_temp', 'contract_end_timestamp', 'TIMESTAMP', 47, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'FundingCompanyFK', 'STRING', 'contract_base_temp', 'funding_company_fk', 'STRING', 'contract_temp', 'funding_company_id', 'INT', 48, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'SourceKey', 'STRING', 'contract_base_temp', 'source_key', 'STRING', 'contract_temp', 'source_key', 'BIGINT', 49, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'StartDate', 'STRING', 'contract_base_temp', 'start_date', 'STRING', 'contract_temp', 'start_timestamp', 'TIMESTAMP', 50, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'EndDate', 'STRING', 'contract_base_temp', 'end_date', 'STRING', 'contract_temp', 'end_timestamp', 'TIMESTAMP', 51, 1, 0, 0, '3000-01-01', 1, GETUTCDATE());
