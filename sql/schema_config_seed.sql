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
('EQ_Warehouse', 'Territory', 'TerritoryPK', 'STRING', 'territory_base', 'territory_id', 'STRING', 'territory', 'territory_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Territory', 'TerritoryName', 'STRING', 'territory_base', 'territory_name', 'STRING', 'territory', 'territory_name', 'STRING', 2, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Territory', 'ClientFK', 'STRING', 'territory_base', 'client_id', 'STRING', 'territory', 'client_id', 'INT', 3, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Territory', 'TerritoryActive', 'STRING', 'territory_base', 'is_territory_active', 'STRING', 'territory', 'is_territory_active', 'BOOLEAN', 4, 1, 0, 0, '0', 1, GETUTCDATE());

-- [02] HierarchyTerritory
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'HierarchyTerritory', 'HierarchyTerritoryPK', 'STRING', 'hierarchy_territory_base', 'hierarchy_territory_id', 'STRING', 'hierarchy_territory', 'hierarchy_territory_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'HierarchyTerritory', 'HierarchySetKey', 'STRING', 'hierarchy_territory_base', 'hierarchy_set_key', 'STRING', 'hierarchy_territory', 'hierarchy_set_key', 'INT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'HierarchyTerritory', 'TerritoryFK', 'STRING', 'hierarchy_territory_base', 'territory_id', 'STRING', 'hierarchy_territory', 'territory_id', 'INT', 3, 1, 0, 0, '0', 1, GETUTCDATE());

-- [03] Hierarchy_SuperHierarchy
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'Hierarchy_SuperHierarchy', 'SuperHierarchyPK', 'STRING', 'hierarchy_super_hierarchy_base', 'super_hierarchy_id', 'STRING', 'hierarchy_super_hierarchy', 'super_hierarchy_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Hierarchy_SuperHierarchy', 'AgentContractFK', 'STRING', 'hierarchy_super_hierarchy_base', 'agent_contract_id', 'STRING', 'hierarchy_super_hierarchy', 'agent_contract_id', 'INT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Hierarchy_SuperHierarchy', 'HierarchySetKey', 'STRING', 'hierarchy_super_hierarchy_base', 'hierarchy_set_key', 'STRING', 'hierarchy_super_hierarchy', 'hierarchy_set_key', 'INT', 3, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Hierarchy_SuperHierarchy', 'ReverseLevel', 'STRING', 'hierarchy_super_hierarchy_base', 'reverse_level', 'STRING', 'hierarchy_super_hierarchy', 'reverse_level', 'DECIMAL(18,4)', 4, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Hierarchy_SuperHierarchy', 'DisplayName', 'STRING', 'hierarchy_super_hierarchy_base', 'display_name', 'STRING', 'hierarchy_super_hierarchy', 'display_name', 'STRING', 5, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE());

-- [04] Hierarchy_Option
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'Hierarchy_Option', 'HierarchyOptionPK', 'STRING', 'hierarchy_option_base', 'hierarchy_option_id', 'STRING', 'hierarchy_option', 'hierarchy_option_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Hierarchy_Option', 'HierarchyBridgeFK', 'STRING', 'hierarchy_option_base', 'hierarchy_bridge_id', 'STRING', 'hierarchy_option', 'hierarchy_bridge_id', 'INT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Hierarchy_Option', 'AgentContractFK', 'STRING', 'hierarchy_option_base', 'agent_contract_id', 'STRING', 'hierarchy_option', 'agent_contract_id', 'INT', 3, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Hierarchy_Option', 'AccessRemovedInd', 'STRING', 'hierarchy_option_base', 'is_access_removed', 'STRING', 'hierarchy_option', 'is_access_removed', 'BOOLEAN', 4, 1, 0, 0, '0', 1, GETUTCDATE());

-- [05] Hierarchy_Bridge
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'Hierarchy_Bridge', 'HierarchyBridgePK', 'STRING', 'hierarchy_bridge_base', 'hierarchy_bridge_id', 'STRING', 'hierarchy_bridge', 'hierarchy_bridge_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Hierarchy_Bridge', 'HierarchyGroupKey', 'STRING', 'hierarchy_bridge_base', 'hierarchy_group_key', 'STRING', 'hierarchy_bridge', 'hierarchy_group_key', 'INT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Hierarchy_Bridge', 'HierarchySetKey', 'STRING', 'hierarchy_bridge_base', 'hierarchy_set_key', 'STRING', 'hierarchy_bridge', 'hierarchy_set_key', 'INT', 3, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Hierarchy_Bridge', 'SplitPercent', 'STRING', 'hierarchy_bridge_base', 'split_percent', 'STRING', 'hierarchy_bridge', 'split_percent', 'DECIMAL(18,4)', 4, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Hierarchy_Bridge', 'ServicingAgentIndicator', 'STRING', 'hierarchy_bridge_base', 'servicing_agent_indicator', 'STRING', 'hierarchy_bridge', 'servicing_agent_indicator', 'STRING', 5, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Hierarchy_Bridge', 'CommissionOnlyIndicator', 'STRING', 'hierarchy_bridge_base', 'commission_only_indicator', 'STRING', 'hierarchy_bridge', 'commission_only_indicator', 'STRING', 6, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Hierarchy_Bridge', 'CommissionOption', 'STRING', 'hierarchy_bridge_base', 'commission_option', 'STRING', 'hierarchy_bridge', 'commission_option', 'STRING', 7, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Hierarchy_Bridge', 'HierarchyOrder', 'STRING', 'hierarchy_bridge_base', 'hierarchy_order', 'STRING', 'hierarchy_bridge', 'hierarchy_order', 'INT', 8, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Hierarchy_Bridge', 'StartDate', 'STRING', 'hierarchy_bridge_base', 'start_timestamp', 'STRING', 'hierarchy_bridge', 'start_timestamp', 'TIMESTAMP', 9, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Hierarchy_Bridge', 'StopDate', 'STRING', 'hierarchy_bridge_base', 'stop_timestamp', 'STRING', 'hierarchy_bridge', 'stop_timestamp', 'TIMESTAMP', 10, 1, 0, 0, '3000-01-01', 1, GETUTCDATE());

-- [06] Hierarchy
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'Hierarchy', 'HierarchyPK', 'STRING', 'hierarchy_base', 'hierarchy_id', 'STRING', 'hierarchy', 'hierarchy_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Hierarchy', 'HierarchySetKey', 'STRING', 'hierarchy_base', 'hierarchy_set_key', 'STRING', 'hierarchy', 'hierarchy_set_key', 'INT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Hierarchy', 'AgentContractFK', 'STRING', 'hierarchy_base', 'agent_contract_id', 'STRING', 'hierarchy', 'agent_contract_id', 'INT', 3, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Hierarchy', 'Level', 'STRING', 'hierarchy_base', 'level', 'STRING', 'hierarchy', 'level', 'INT', 4, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Hierarchy', 'ReverseLevel', 'STRING', 'hierarchy_base', 'reverse_level', 'STRING', 'hierarchy', 'reverse_level', 'INT', 5, 1, 0, 0, '0', 1, GETUTCDATE());

-- [07] CommissionLevelRank
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'CommissionLevelRank', 'CommissionLevelRankPK', 'STRING', 'commission_level_rank_base', 'commission_level_rank_id', 'STRING', 'commission_level_rank', 'commission_level_rank_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'CommissionLevelRank', 'CommissionLevel', 'STRING', 'commission_level_rank_base', 'commission_level', 'STRING', 'commission_level_rank', 'commission_level', 'STRING', 2, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'CommissionLevelRank', 'Rank', 'STRING', 'commission_level_rank_base', 'rank', 'STRING', 'commission_level_rank', 'rank', 'INT', 3, 1, 0, 0, '0', 1, GETUTCDATE());

-- [08] AgentContract
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'AgentContract', 'AgentContractPK', 'STRING', 'agent_contract_base', 'agent_contract_id', 'STRING', 'agent_contract', 'agent_contract_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'AgentContract', 'AgentNumber', 'STRING', 'agent_contract_base', 'agent_number', 'STRING', 'agent_contract', 'agent_number', 'STRING', 2, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AgentContract', 'AgentFK', 'STRING', 'agent_contract_base', 'agent_id', 'STRING', 'agent_contract', 'agent_id', 'INT', 3, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'AgentContract', 'Context', 'STRING', 'agent_contract_base', 'context', 'STRING', 'agent_contract', 'context', 'STRING', 4, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AgentContract', 'Status', 'STRING', 'agent_contract_base', 'status', 'STRING', 'agent_contract', 'status', 'STRING', 5, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AgentContract', 'CommissionLevel', 'STRING', 'agent_contract_base', 'commission_level', 'STRING', 'agent_contract', 'commission_level', 'STRING', 6, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AgentContract', 'SituationCode', 'STRING', 'agent_contract_base', 'situation_code', 'STRING', 'agent_contract', 'situation_code', 'STRING', 7, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AgentContract', 'ContractEffectiveDate', 'STRING', 'agent_contract_base', 'contract_effective_timestamp', 'STRING', 'agent_contract', 'contract_effective_timestamp', 'TIMESTAMP', 8, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'AgentContract', 'ContractTerminationDate', 'STRING', 'agent_contract_base', 'contract_termination_timestamp', 'STRING', 'agent_contract', 'contract_termination_timestamp', 'TIMESTAMP', 9, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'AgentContract', 'CurrentRecord', 'STRING', 'agent_contract_base', 'is_current_record', 'STRING', 'agent_contract', 'is_current_record', 'STRING', 10, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AgentContract', 'SetToCurrentDate', 'STRING', 'agent_contract_base', 'set_to_current_timestamp', 'STRING', 'agent_contract', 'set_to_current_timestamp', 'TIMESTAMP', 11, 1, 0, 0, '3000-01-01', 1, GETUTCDATE());

-- [09] TrainingState_Group
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'TrainingState_Group', 'TrainingStateGroupPK', 'STRING', 'training_state_group_base', 'training_state_group_id', 'STRING', 'training_state_group', 'training_state_group_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'TrainingState_Group', 'TrainingStateGroupKey', 'STRING', 'training_state_group_base', 'training_state_group_key', 'STRING', 'training_state_group', 'training_state_group_key', 'INT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'TrainingState_Group', 'State', 'STRING', 'training_state_group_base', 'state_code', 'STRING', 'training_state_group', 'state_code', 'STRING', 3, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'TrainingState_Group', 'Required', 'STRING', 'training_state_group_base', 'is_required', 'STRING', 'training_state_group', 'is_required', 'BOOLEAN', 4, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'TrainingState_Group', 'EffectiveDate', 'STRING', 'training_state_group_base', 'effective_timestamp', 'STRING', 'training_state_group', 'effective_timestamp', 'TIMESTAMP', 5, 1, 0, 0, '3000-01-01', 1, GETUTCDATE());

-- [10] TrainingProduct_Group
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'TrainingProduct_Group', 'TrainingProductGroupPK', 'STRING', 'training_product_group_base', 'training_product_group_id', 'STRING', 'training_product_group', 'training_product_group_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'TrainingProduct_Group', 'TrainingProductGroupKey', 'STRING', 'training_product_group_base', 'training_product_group_key', 'STRING', 'training_product_group', 'training_product_group_key', 'INT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'TrainingProduct_Group', 'ProductFK', 'STRING', 'training_product_group_base', 'product_id', 'STRING', 'training_product_group', 'product_id', 'INT', 3, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'TrainingProduct_Group', 'Required', 'STRING', 'training_product_group_base', 'is_required', 'STRING', 'training_product_group', 'is_required', 'BOOLEAN', 4, 1, 0, 0, '0', 1, GETUTCDATE());

-- [11] Rider_Group
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'Rider_Group', 'RiderGroupPK', 'STRING', 'rider_group_base', 'rider_group_id', 'STRING', 'rider_group', 'rider_group_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Rider_Group', 'RiderGroupKey', 'STRING', 'rider_group_base', 'rider_group_key', 'STRING', 'rider_group', 'rider_group_key', 'INT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Rider_Group', 'Code', 'STRING', 'rider_group_base', 'rider_code', 'STRING', 'rider_group', 'rider_code', 'STRING', 3, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Rider_Group', 'Description', 'STRING', 'rider_group_base', 'description', 'STRING', 'rider_group', 'description', 'STRING', 4, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Rider_Group', 'BaseValue', 'STRING', 'rider_group_base', 'base_value', 'STRING', 'rider_group', 'base_value', 'DECIMAL(18,4)', 5, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Rider_Group', 'EligibilityDate', 'STRING', 'rider_group_base', 'eligibility_timestamp', 'STRING', 'rider_group', 'eligibility_timestamp', 'TIMESTAMP', 6, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Rider_Group', 'FeePercent', 'STRING', 'rider_group_base', 'fee_percent', 'STRING', 'rider_group', 'fee_percent', 'DECIMAL(18,4)', 7, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Rider_Group', 'Lives', 'STRING', 'rider_group_base', 'lives', 'STRING', 'rider_group', 'lives', 'STRING', 8, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Rider_Group', 'PayValue', 'STRING', 'rider_group_base', 'pay_value', 'STRING', 'rider_group', 'pay_value', 'DECIMAL(18,4)', 9, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Rider_Group', 'Frequency', 'STRING', 'rider_group_base', 'frequency', 'STRING', 'rider_group', 'frequency', 'STRING', 10, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Rider_Group', 'WellnessEnrollment', 'STRING', 'rider_group_base', 'is_wellness_enrollment', 'STRING', 'rider_group', 'is_wellness_enrollment', 'BOOLEAN', 11, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Rider_Group', 'WellnessCredits', 'STRING', 'rider_group_base', 'wellness_credits', 'STRING', 'rider_group', 'wellness_credits', 'DECIMAL(18,4)', 12, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Rider_Group', 'StartAge', 'STRING', 'rider_group_base', 'start_age', 'STRING', 'rider_group', 'start_age', 'INT', 13, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Rider_Group', 'StartDate', 'STRING', 'rider_group_base', 'start_timestamp', 'STRING', 'rider_group', 'start_timestamp', 'TIMESTAMP', 14, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Rider_Group', 'StopDate', 'STRING', 'rider_group_base', 'stop_timestamp', 'STRING', 'rider_group', 'stop_timestamp', 'TIMESTAMP', 15, 1, 0, 0, '3000-01-01', 1, GETUTCDATE());

-- [12] Requirement_Group
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'Requirement_Group', 'RequirementGroupPK', 'STRING', 'requirement_group_base', 'requirement_group_id', 'STRING', 'requirement_group', 'requirement_group_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Requirement_Group', 'RequirementGroupKey', 'STRING', 'requirement_group_base', 'requirement_group_key', 'STRING', 'requirement_group', 'requirement_group_key', 'INT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Requirement_Group', 'Code', 'STRING', 'requirement_group_base', 'requirement_code', 'STRING', 'requirement_group', 'requirement_code', 'STRING', 3, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Requirement_Group', 'Description', 'STRING', 'requirement_group_base', 'description', 'STRING', 'requirement_group', 'description', 'STRING', 4, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Requirement_Group', 'Status', 'STRING', 'requirement_group_base', 'status', 'STRING', 'requirement_group', 'status', 'STRING', 5, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Requirement_Group', 'EffectiveDate', 'STRING', 'requirement_group_base', 'effective_timestamp', 'STRING', 'requirement_group', 'effective_timestamp', 'TIMESTAMP', 6, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Requirement_Group', 'FollowUpDate', 'STRING', 'requirement_group_base', 'follow_up_timestamp', 'STRING', 'requirement_group', 'follow_up_timestamp', 'TIMESTAMP', 7, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Requirement_Group', 'ReceivedDate', 'STRING', 'requirement_group_base', 'received_timestamp', 'STRING', 'requirement_group', 'received_timestamp', 'TIMESTAMP', 8, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Requirement_Group', 'ExecutedDate', 'STRING', 'requirement_group_base', 'executed_timestamp', 'STRING', 'requirement_group', 'executed_timestamp', 'TIMESTAMP', 9, 1, 0, 0, '3000-01-01', 1, GETUTCDATE());

-- [13] RenewalRate_Group
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'RenewalRate_Group', 'RenewalRateGroupPK', 'STRING', 'renewal_rate_group_base', 'renewal_rate_group_id', 'STRING', 'renewal_rate_group', 'renewal_rate_group_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'RenewalRate_Group', 'RenewalRateGroupKey', 'STRING', 'renewal_rate_group_base', 'renewal_rate_group_key', 'STRING', 'renewal_rate_group', 'renewal_rate_group_key', 'INT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'RenewalRate_Group', 'Rate', 'STRING', 'renewal_rate_group_base', 'rate', 'STRING', 'renewal_rate_group', 'rate', 'DECIMAL(18,4)', 3, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'RenewalRate_Group', 'EffectiveDate', 'STRING', 'renewal_rate_group_base', 'effective_timestamp', 'STRING', 'renewal_rate_group', 'effective_timestamp', 'TIMESTAMP', 4, 1, 0, 0, '3000-01-01', 1, GETUTCDATE());

-- [14] Reinsurance_Group
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'Reinsurance_Group', 'ReinsuranceGroupPK', 'STRING', 'reinsurance_group_base', 'reinsurance_group_id', 'STRING', 'reinsurance_group', 'reinsurance_group_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Reinsurance_Group', 'ReinsuranceGroupKey', 'STRING', 'reinsurance_group_base', 'reinsurance_group_key', 'STRING', 'reinsurance_group', 'reinsurance_group_key', 'INT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Reinsurance_Group', 'TreatyCode', 'STRING', 'reinsurance_group_base', 'treaty_code', 'STRING', 'reinsurance_group', 'treaty_code', 'STRING', 3, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Reinsurance_Group', 'CoinsurancePercentage', 'STRING', 'reinsurance_group_base', 'coinsurance_percentage', 'STRING', 'reinsurance_group', 'coinsurance_percentage', 'DECIMAL(18,4)', 4, 1, 0, 0, '0', 1, GETUTCDATE());

-- [15] RecurringPayment_Group
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'RecurringPayment_Group', 'RecurringPaymentGroupPK', 'STRING', 'recurring_payment_group_base', 'recurring_payment_group_id', 'STRING', 'recurring_payment_group', 'recurring_payment_group_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'RecurringPayment_Group', 'RecurringPaymentGroupKey', 'STRING', 'recurring_payment_group_base', 'recurring_payment_group_key', 'STRING', 'recurring_payment_group', 'recurring_payment_group_key', 'INT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'RecurringPayment_Group', 'ActivityTypeFK', 'STRING', 'recurring_payment_group_base', 'activity_type_id', 'STRING', 'recurring_payment_group', 'activity_type_id', 'INT', 3, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'RecurringPayment_Group', 'PayeeFK', 'STRING', 'recurring_payment_group_base', 'payee_id', 'STRING', 'recurring_payment_group', 'payee_id', 'INT', 4, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'RecurringPayment_Group', 'NextEffectiveDate', 'STRING', 'recurring_payment_group_base', 'next_effective_timestamp', 'STRING', 'recurring_payment_group', 'next_effective_timestamp', 'TIMESTAMP', 5, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'RecurringPayment_Group', 'PausedInd', 'STRING', 'recurring_payment_group_base', 'is_paused', 'STRING', 'recurring_payment_group', 'is_paused', 'BOOLEAN', 6, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'RecurringPayment_Group', 'DistributionType', 'STRING', 'recurring_payment_group_base', 'distribution_type', 'STRING', 'recurring_payment_group', 'distribution_type', 'STRING', 7, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'RecurringPayment_Group', 'Lives', 'STRING', 'recurring_payment_group_base', 'lives', 'STRING', 'recurring_payment_group', 'lives', 'STRING', 8, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'RecurringPayment_Group', 'Frequency', 'STRING', 'recurring_payment_group_base', 'frequency', 'STRING', 'recurring_payment_group', 'frequency', 'STRING', 9, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'RecurringPayment_Group', 'WithdrawalType', 'STRING', 'recurring_payment_group_base', 'withdrawal_type', 'STRING', 'recurring_payment_group', 'withdrawal_type', 'STRING', 10, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'RecurringPayment_Group', 'FirstDate', 'STRING', 'recurring_payment_group_base', 'first_timestamp', 'STRING', 'recurring_payment_group', 'first_timestamp', 'TIMESTAMP', 11, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'RecurringPayment_Group', 'PriorDate', 'STRING', 'recurring_payment_group_base', 'prior_timestamp', 'STRING', 'recurring_payment_group', 'prior_timestamp', 'TIMESTAMP', 12, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'RecurringPayment_Group', 'PriorActivityFK', 'STRING', 'recurring_payment_group_base', 'prior_activity_id', 'STRING', 'recurring_payment_group', 'prior_activity_id', 'INT', 13, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'RecurringPayment_Group', 'EligibleRMDDate', 'STRING', 'recurring_payment_group_base', 'eligible_rmd_timestamp', 'STRING', 'recurring_payment_group', 'eligible_rmd_timestamp', 'TIMESTAMP', 14, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'RecurringPayment_Group', 'CalculatedAmount', 'STRING', 'recurring_payment_group_base', 'calculated_amount', 'STRING', 'recurring_payment_group', 'calculated_amount', 'DECIMAL(18,4)', 15, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'RecurringPayment_Group', 'GrossNet', 'STRING', 'recurring_payment_group_base', 'gross_net', 'STRING', 'recurring_payment_group', 'gross_net', 'STRING', 16, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE());

-- [16] Note_Group
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'Note_Group', 'NoteGroupPK', 'STRING', 'note_group_base', 'note_group_id', 'STRING', 'note_group', 'note_group_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Note_Group', 'SourceKey', 'STRING', 'note_group_base', 'source_key', 'STRING', 'note_group', 'source_key', 'BIGINT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Note_Group', 'NoteGroupKey', 'STRING', 'note_group_base', 'note_group_key', 'STRING', 'note_group', 'note_group_key', 'INT', 3, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Note_Group', 'Order', 'STRING', 'note_group_base', 'sort_order', 'STRING', 'note_group', 'sort_order', 'INT', 4, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Note_Group', 'Text', 'STRING', 'note_group_base', 'note_text', 'STRING', 'note_group', 'note_text', 'STRING', 5, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Note_Group', 'Type', 'STRING', 'note_group_base', 'note_type', 'STRING', 'note_group', 'note_type', 'STRING', 6, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Note_Group', 'Role', 'STRING', 'note_group_base', 'role', 'STRING', 'note_group', 'role', 'STRING', 7, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Note_Group', 'MaintDate', 'STRING', 'note_group_base', 'maint_timestamp', 'STRING', 'note_group', 'maint_timestamp', 'TIMESTAMP', 8, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Note_Group', 'MaintBy', 'STRING', 'note_group_base', 'maint_by', 'STRING', 'note_group', 'maint_by', 'STRING', 9, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Note_Group', 'Call_ID', 'STRING', 'note_group_base', 'call_id', 'STRING', 'note_group', 'call_id', 'INT', 10, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Note_Group', 'Call_Length', 'STRING', 'note_group_base', 'call_length', 'STRING', 'note_group', 'call_length', 'INT', 11, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Note_Group', 'Call_StartDate', 'STRING', 'note_group_base', 'call_start_timestamp', 'STRING', 'note_group', 'call_start_timestamp', 'TIMESTAMP', 12, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Note_Group', 'Call_InOut', 'STRING', 'note_group_base', 'call_direction', 'STRING', 'note_group', 'call_direction', 'STRING', 13, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Note_Group', 'Call_Operators', 'STRING', 'note_group_base', 'call_operators', 'STRING', 'note_group', 'call_operators', 'STRING', 14, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Note_Group', 'Call_FilePath', 'STRING', 'note_group_base', 'call_file_path', 'STRING', 'note_group', 'call_file_path', 'STRING', 15, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Note_Group', 'Call_EncryptKey', 'STRING', 'note_group_base', 'call_encrypt_key', 'STRING', 'note_group', 'call_encrypt_key', 'STRING', 16, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE());

-- [17] IndexValue_Group
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'IndexValue_Group', 'IndexValueGroupPK', 'STRING', 'index_value_group_base', 'index_value_group_id', 'STRING', 'index_value_group', 'index_value_group_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'IndexValue_Group', 'IndexValueGroupKey', 'STRING', 'index_value_group_base', 'index_value_group_key', 'STRING', 'index_value_group', 'index_value_group_key', 'INT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'IndexValue_Group', 'Ticker', 'STRING', 'index_value_group_base', 'ticker', 'STRING', 'index_value_group', 'ticker', 'STRING', 3, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'IndexValue_Group', 'IndexName', 'STRING', 'index_value_group_base', 'index_name', 'STRING', 'index_value_group', 'index_name', 'STRING', 4, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'IndexValue_Group', 'EffectiveDate', 'STRING', 'index_value_group_base', 'effective_timestamp', 'STRING', 'index_value_group', 'effective_timestamp', 'TIMESTAMP', 5, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'IndexValue_Group', 'IndexValue', 'STRING', 'index_value_group_base', 'index_value', 'STRING', 'index_value_group', 'index_value', 'DECIMAL(18,4)', 6, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'IndexValue_Group', 'Change', 'STRING', 'index_value_group_base', 'change_amount', 'STRING', 'index_value_group', 'change_amount', 'DECIMAL(18,4)', 7, 1, 0, 0, '0', 1, GETUTCDATE());

-- [18] ExternalAccount_Group
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'ExternalAccount_Group', 'ExternalAccountGroupPK', 'STRING', 'external_account_group_base', 'external_account_group_id', 'STRING', 'external_account_group', 'external_account_group_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'ExternalAccount_Group', 'ExternalAccountGroupKey', 'STRING', 'external_account_group_base', 'external_account_group_key', 'STRING', 'external_account_group', 'external_account_group_key', 'INT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'ExternalAccount_Group', 'ExternalAccountType', 'STRING', 'external_account_group_base', 'external_account_type', 'STRING', 'external_account_group', 'external_account_type', 'STRING', 3, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'ExternalAccount_Group', 'Company', 'STRING', 'external_account_group_base', 'company_name', 'STRING', 'external_account_group', 'company_name', 'STRING', 4, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'ExternalAccount_Group', 'RoutingNumber', 'STRING', 'external_account_group_base', 'routing_number', 'STRING', 'external_account_group', 'routing_number', 'STRING', 5, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'ExternalAccount_Group', 'AccountNumber', 'STRING', 'external_account_group_base', 'account_number', 'STRING', 'external_account_group', 'account_number', 'STRING', 6, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'ExternalAccount_Group', 'VerificationCode', 'STRING', 'external_account_group_base', 'verification_code', 'STRING', 'external_account_group', 'verification_code', 'STRING', 7, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'ExternalAccount_Group', 'VerificationResponse', 'STRING', 'external_account_group_base', 'verification_response', 'STRING', 'external_account_group', 'verification_response', 'STRING', 8, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'ExternalAccount_Group', 'VerificationDate', 'STRING', 'external_account_group_base', 'verification_timestamp', 'STRING', 'external_account_group', 'verification_timestamp', 'TIMESTAMP', 9, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'ExternalAccount_Group', 'Active', 'STRING', 'external_account_group_base', 'is_active', 'STRING', 'external_account_group', 'is_active', 'BOOLEAN', 10, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'ExternalAccount_Group', 'StartDate', 'STRING', 'external_account_group_base', 'start_timestamp', 'STRING', 'external_account_group', 'start_timestamp', 'TIMESTAMP', 11, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'ExternalAccount_Group', 'EndDate', 'STRING', 'external_account_group_base', 'end_timestamp', 'STRING', 'external_account_group', 'end_timestamp', 'TIMESTAMP', 12, 1, 0, 0, '3000-01-01', 1, GETUTCDATE());

-- [19] ContractValue_Group
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'ContractValue_Group', 'ContractValueGroupPK', 'STRING', 'contract_value_group_base', 'contract_value_id', 'STRING', 'contract_value_group', 'contract_value_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'ContractValue_Group', 'ContractValueGroupKey', 'STRING', 'contract_value_group_base', 'contract_value_key', 'STRING', 'contract_value_group', 'contract_value_key', 'INT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'ContractValue_Group', 'ValueType', 'STRING', 'contract_value_group_base', 'value_type', 'STRING', 'contract_value_group', 'value_type', 'STRING', 3, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'ContractValue_Group', 'ValueDate', 'STRING', 'contract_value_group_base', 'value_timestamp', 'STRING', 'contract_value_group', 'value_timestamp', 'TIMESTAMP', 4, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'ContractValue_Group', 'Value', 'STRING', 'contract_value_group_base', 'value', 'STRING', 'contract_value_group', 'value', 'DECIMAL(18,4)', 5, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'ContractValue_Group', 'ValueAsDate', 'STRING', 'contract_value_group_base', 'value_as_timestamp', 'STRING', 'contract_value_group', 'value_as_timestamp', 'TIMESTAMP', 6, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'ContractValue_Group', 'StartDate', 'STRING', 'contract_value_group_base', 'start_timestamp', 'STRING', 'contract_value_group', 'start_timestamp', 'TIMESTAMP', 7, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'ContractValue_Group', 'EndDate', 'STRING', 'contract_value_group_base', 'end_timestamp', 'STRING', 'contract_value_group', 'end_timestamp', 'TIMESTAMP', 8, 1, 0, 0, '3000-01-01', 1, GETUTCDATE());

-- [20] ContractDeposit_Group
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'ContractDeposit_Group', 'ContractDepositGroupPK', 'STRING', 'contract_deposit_group_base', 'contract_deposit_group_id', 'STRING', 'contract_deposit_group', 'contract_deposit_group_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'ContractDeposit_Group', 'SourceKey', 'STRING', 'contract_deposit_group_base', 'source_key', 'STRING', 'contract_deposit_group', 'source_key', 'BIGINT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'ContractDeposit_Group', 'ContractDepositGroupKey', 'STRING', 'contract_deposit_group_base', 'contract_deposit_group_key', 'STRING', 'contract_deposit_group', 'contract_deposit_group_key', 'INT', 3, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'ContractDeposit_Group', 'DepositType', 'STRING', 'contract_deposit_group_base', 'deposit_type', 'STRING', 'contract_deposit_group', 'deposit_type', 'STRING', 4, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'ContractDeposit_Group', 'DepositSource', 'STRING', 'contract_deposit_group_base', 'deposit_source', 'STRING', 'contract_deposit_group', 'deposit_source', 'STRING', 5, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'ContractDeposit_Group', 'OriginalContract', 'STRING', 'contract_deposit_group_base', 'original_contract', 'STRING', 'contract_deposit_group', 'original_contract', 'STRING', 6, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'ContractDeposit_Group', 'DateReceived', 'STRING', 'contract_deposit_group_base', 'date_received_timestamp', 'STRING', 'contract_deposit_group', 'date_received_timestamp', 'TIMESTAMP', 7, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'ContractDeposit_Group', 'ProcessDate', 'STRING', 'contract_deposit_group_base', 'process_timestamp', 'STRING', 'contract_deposit_group', 'process_timestamp', 'TIMESTAMP', 8, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'ContractDeposit_Group', 'TaxYear', 'STRING', 'contract_deposit_group_base', 'tax_year', 'STRING', 'contract_deposit_group', 'tax_year', 'INT', 9, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'ContractDeposit_Group', 'ReplacementType', 'STRING', 'contract_deposit_group_base', 'replacement_type', 'STRING', 'contract_deposit_group', 'replacement_type', 'STRING', 10, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'ContractDeposit_Group', 'PremiumType', 'STRING', 'contract_deposit_group_base', 'premium_type', 'STRING', 'contract_deposit_group', 'premium_type', 'STRING', 11, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'ContractDeposit_Group', 'PlannedIndicator', 'STRING', 'contract_deposit_group_base', 'planned_indicator', 'STRING', 'contract_deposit_group', 'planned_indicator', 'STRING', 12, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'ContractDeposit_Group', 'Reference', 'STRING', 'contract_deposit_group_base', 'reference', 'STRING', 'contract_deposit_group', 'reference', 'STRING', 13, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'ContractDeposit_Group', 'AnticipatedAmount', 'STRING', 'contract_deposit_group_base', 'anticipated_amount', 'STRING', 'contract_deposit_group', 'anticipated_amount', 'DECIMAL(18,4)', 14, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'ContractDeposit_Group', 'ActualAmount', 'STRING', 'contract_deposit_group_base', 'actual_amount', 'STRING', 'contract_deposit_group', 'actual_amount', 'DECIMAL(18,4)', 15, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'ContractDeposit_Group', 'CostBasis', 'STRING', 'contract_deposit_group_base', 'cost_basis', 'STRING', 'contract_deposit_group', 'cost_basis', 'DECIMAL(18,4)', 16, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'ContractDeposit_Group', 'RefundAmount', 'STRING', 'contract_deposit_group_base', 'refund_amount', 'STRING', 'contract_deposit_group', 'refund_amount', 'DECIMAL(18,4)', 17, 1, 0, 0, '0', 1, GETUTCDATE());

-- [21] AgentSummary_Group
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'AgentSummary_Group', 'AgentSummaryGroupPK', 'STRING', 'agent_summary_group_base', 'agent_summary_group_id', 'STRING', 'agent_summary_group', 'agent_summary_group_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'AgentSummary_Group', 'AgentSummaryGroupKey', 'STRING', 'agent_summary_group_base', 'agent_summary_group_key', 'STRING', 'agent_summary_group', 'agent_summary_group_key', 'INT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'AgentSummary_Group', 'SummaryType', 'STRING', 'agent_summary_group_base', 'summary_type', 'STRING', 'agent_summary_group', 'summary_type', 'STRING', 3, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AgentSummary_Group', 'SummaryDate', 'STRING', 'agent_summary_group_base', 'summary_timestamp', 'STRING', 'agent_summary_group', 'summary_timestamp', 'TIMESTAMP', 4, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'AgentSummary_Group', 'SummaryValue', 'STRING', 'agent_summary_group_base', 'summary_value', 'STRING', 'agent_summary_group', 'summary_value', 'DECIMAL(18,4)', 5, 1, 0, 0, '0', 1, GETUTCDATE());

-- [22] AgentPrincipal_Group
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'AgentPrincipal_Group', 'AgentPrincipalGroupPK', 'STRING', 'agent_principal_group_base', 'agent_principal_group_id', 'STRING', 'agent_principal_group', 'agent_principal_group_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'AgentPrincipal_Group', 'AgentPrincipalGroupKey', 'STRING', 'agent_principal_group_base', 'agent_principal_group_key', 'STRING', 'agent_principal_group', 'agent_principal_group_key', 'INT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'AgentPrincipal_Group', 'PrincipalAgentFK', 'STRING', 'agent_principal_group_base', 'principal_agent_id', 'STRING', 'agent_principal_group', 'principal_agent_id', 'INT', 3, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'AgentPrincipal_Group', 'StartDate', 'STRING', 'agent_principal_group_base', 'start_timestamp', 'STRING', 'agent_principal_group', 'start_timestamp', 'TIMESTAMP', 4, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'AgentPrincipal_Group', 'EndDate', 'STRING', 'agent_principal_group_base', 'end_timestamp', 'STRING', 'agent_principal_group', 'end_timestamp', 'TIMESTAMP', 5, 1, 0, 0, '3000-01-01', 1, GETUTCDATE());

-- [23] AgentLicense_Group
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'AgentLicense_Group', 'AgentLicenseGroupPK', 'STRING', 'agent_license_group_base', 'agent_license_group_id', 'STRING', 'agent_license_group', 'agent_license_group_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'AgentLicense_Group', 'SourceKey', 'STRING', 'agent_license_group_base', 'source_key', 'STRING', 'agent_license_group', 'source_key', 'BIGINT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'AgentLicense_Group', 'AgentLicenseGroupKey', 'STRING', 'agent_license_group_base', 'agent_license_group_key', 'STRING', 'agent_license_group', 'agent_license_group_key', 'INT', 3, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'AgentLicense_Group', 'LicenseType', 'STRING', 'agent_license_group_base', 'license_type', 'STRING', 'agent_license_group', 'license_type', 'STRING', 4, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AgentLicense_Group', 'LicenseState', 'STRING', 'agent_license_group_base', 'license_state', 'STRING', 'agent_license_group', 'license_state', 'STRING', 5, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AgentLicense_Group', 'Resident', 'STRING', 'agent_license_group_base', 'resident', 'STRING', 'agent_license_group', 'resident', 'STRING', 6, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AgentLicense_Group', 'LicenseNumber', 'STRING', 'agent_license_group_base', 'license_number', 'STRING', 'agent_license_group', 'license_number', 'STRING', 7, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AgentLicense_Group', 'Status', 'STRING', 'agent_license_group_base', 'status', 'STRING', 'agent_license_group', 'status', 'STRING', 8, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AgentLicense_Group', 'EffectiveDate', 'STRING', 'agent_license_group_base', 'effective_timestamp', 'STRING', 'agent_license_group', 'effective_timestamp', 'TIMESTAMP', 9, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'AgentLicense_Group', 'ExpirationDate', 'STRING', 'agent_license_group_base', 'expiration_timestamp', 'STRING', 'agent_license_group', 'expiration_timestamp', 'TIMESTAMP', 10, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'AgentLicense_Group', 'TerminationDate', 'STRING', 'agent_license_group_base', 'termination_timestamp', 'STRING', 'agent_license_group', 'termination_timestamp', 'TIMESTAMP', 11, 1, 0, 0, '3000-01-01', 1, GETUTCDATE());

-- [24] AdditionalInfo_Group
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'AdditionalInfo_Group', 'AdditionalInfoGroupPK', 'STRING', 'additional_info_group_base', 'additional_info_group_id', 'STRING', 'additional_info_group', 'additional_info_group_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'AdditionalInfo_Group', 'AdditionalInfoGroupKey', 'STRING', 'additional_info_group_base', 'additional_info_group_key', 'STRING', 'additional_info_group', 'additional_info_group_key', 'INT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'AdditionalInfo_Group', 'AdditionalInfoSource', 'STRING', 'additional_info_group_base', 'additional_info_source', 'STRING', 'additional_info_group', 'additional_info_source', 'STRING', 3, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AdditionalInfo_Group', 'AdditionalInfoType', 'STRING', 'additional_info_group_base', 'additional_info_type', 'STRING', 'additional_info_group', 'additional_info_type', 'STRING', 4, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AdditionalInfo_Group', 'AdditionalInfoDescription', 'STRING', 'additional_info_group_base', 'additional_info_description', 'STRING', 'additional_info_group', 'additional_info_description', 'STRING', 5, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AdditionalInfo_Group', 'AdditionalInfoValue', 'STRING', 'additional_info_group_base', 'additional_info_value', 'STRING', 'additional_info_group', 'additional_info_value', 'STRING', 6, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AdditionalInfo_Group', 'AddressLine1', 'STRING', 'additional_info_group_base', 'address_line_1', 'STRING', 'additional_info_group', 'address_line_1', 'STRING', 7, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AdditionalInfo_Group', 'AddressLine2', 'STRING', 'additional_info_group_base', 'address_line_2', 'STRING', 'additional_info_group', 'address_line_2', 'STRING', 8, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AdditionalInfo_Group', 'AddressLine3', 'STRING', 'additional_info_group_base', 'address_line_3', 'STRING', 'additional_info_group', 'address_line_3', 'STRING', 9, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AdditionalInfo_Group', 'AddressLine4', 'STRING', 'additional_info_group_base', 'address_line_4', 'STRING', 'additional_info_group', 'address_line_4', 'STRING', 10, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AdditionalInfo_Group', 'City', 'STRING', 'additional_info_group_base', 'city', 'STRING', 'additional_info_group', 'city', 'STRING', 11, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AdditionalInfo_Group', 'State', 'STRING', 'additional_info_group_base', 'state', 'STRING', 'additional_info_group', 'state', 'STRING', 12, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AdditionalInfo_Group', 'ZipCode', 'STRING', 'additional_info_group_base', 'zip_code', 'STRING', 'additional_info_group', 'zip_code', 'STRING', 13, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AdditionalInfo_Group', 'EffectiveDate', 'STRING', 'additional_info_group_base', 'effective_timestamp', 'STRING', 'additional_info_group', 'effective_timestamp', 'TIMESTAMP', 14, 1, 0, 0, '3000-01-01', 1, GETUTCDATE());

-- [25] AdditionalClient_Group
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'AdditionalClient_Group', 'AdditionalClientGroupPK', 'STRING', 'additional_client_group_base', 'additional_client_group_id', 'STRING', 'additional_client_group', 'additional_client_group_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'AdditionalClient_Group', 'AdditionalClientGroupKey', 'STRING', 'additional_client_group_base', 'additional_client_group_key', 'STRING', 'additional_client_group', 'additional_client_group_key', 'INT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'AdditionalClient_Group', 'ClientFK', 'STRING', 'additional_client_group_base', 'client_id', 'STRING', 'additional_client_group', 'client_id', 'INT', 3, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'AdditionalClient_Group', 'AdditionalType', 'STRING', 'additional_client_group_base', 'additional_type', 'STRING', 'additional_client_group', 'additional_type', 'STRING', 4, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AdditionalClient_Group', 'Relation', 'STRING', 'additional_client_group_base', 'relation', 'STRING', 'additional_client_group', 'relation', 'STRING', 5, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AdditionalClient_Group', 'AllocationPercent', 'STRING', 'additional_client_group_base', 'allocation_percent', 'STRING', 'additional_client_group', 'allocation_percent', 'DECIMAL(18,4)', 6, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'AdditionalClient_Group', 'Active', 'STRING', 'additional_client_group_base', 'is_active', 'STRING', 'additional_client_group', 'is_active', 'BOOLEAN', 7, 1, 0, 0, '0', 1, GETUTCDATE());

-- [26] AccountingReporting_Group
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'AccountingReporting_Group', 'AccountingReportingGroupPK', 'STRING', 'accounting_reporting_group_base', 'accounting_reporting_group_id', 'STRING', 'accounting_reporting_group', 'accounting_reporting_group_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'AccountingReporting_Group', 'AccountingReportingGroupKey', 'STRING', 'accounting_reporting_group_base', 'accounting_reporting_group_key', 'STRING', 'accounting_reporting_group', 'accounting_reporting_group_key', 'INT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'AccountingReporting_Group', 'ReportingCode', 'STRING', 'accounting_reporting_group_base', 'reporting_code', 'STRING', 'accounting_reporting_group', 'reporting_code', 'STRING', 3, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AccountingReporting_Group', 'ReportingClassCode', 'STRING', 'accounting_reporting_group_base', 'reporting_class_code', 'STRING', 'accounting_reporting_group', 'reporting_class_code', 'STRING', 4, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AccountingReporting_Group', 'ReportingDescription', 'STRING', 'accounting_reporting_group_base', 'reporting_description', 'STRING', 'accounting_reporting_group', 'reporting_description', 'STRING', 5, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE());

-- [27] ProductVariationDetail
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'ProductVariationDetail', 'ProductVariationDetailPK', 'STRING', 'product_variation_detail_base', 'product_variation_detail_id', 'STRING', 'product_variation_detail', 'product_variation_detail_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'ProductVariationDetail', 'DisclosureText', 'STRING', 'product_variation_detail_base', 'disclosure_text', 'STRING', 'product_variation_detail', 'disclosure_text', 'STRING', 2, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'ProductVariationDetail', 'SortOrder', 'STRING', 'product_variation_detail_base', 'sort_order', 'STRING', 'product_variation_detail', 'sort_order', 'INT', 3, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'ProductVariationDetail', 'Type', 'STRING', 'product_variation_detail_base', 'type', 'STRING', 'product_variation_detail', 'type', 'STRING', 4, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE());

-- [28] ProductStateVariation
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'ProductStateVariation', 'ProductStateVariationPK', 'STRING', 'product_state_variation_base', 'product_state_variation_id', 'STRING', 'product_state_variation', 'product_state_variation_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'ProductStateVariation', 'ProductFK', 'STRING', 'product_state_variation_base', 'product_id', 'STRING', 'product_state_variation', 'product_id', 'INT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'ProductStateVariation', 'StateCode', 'STRING', 'product_state_variation_base', 'state_code', 'STRING', 'product_state_variation', 'state_code', 'STRING', 3, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'ProductStateVariation', 'ProductVariationDetailFK', 'STRING', 'product_state_variation_base', 'product_variation_detail_id', 'STRING', 'product_state_variation', 'product_variation_detail_id', 'INT', 4, 1, 0, 0, '0', 1, GETUTCDATE());

-- [29] ProductStateApprovalDisclosure
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'ProductStateApprovalDisclosure', 'PSADisclosurePK', 'STRING', 'product_state_approval_disclosure_base', 'product_state_approval_disclosure_id', 'STRING', 'product_state_approval_disclosure', 'product_state_approval_disclosure_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'ProductStateApprovalDisclosure', 'ProductStateApprovalFK', 'STRING', 'product_state_approval_disclosure_base', 'product_state_approval_id', 'STRING', 'product_state_approval_disclosure', 'product_state_approval_id', 'INT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'ProductStateApprovalDisclosure', 'MarketingNameOverride', 'STRING', 'product_state_approval_disclosure_base', 'marketing_name_override', 'STRING', 'product_state_approval_disclosure', 'marketing_name_override', 'STRING', 3, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'ProductStateApprovalDisclosure', 'DisclosureText', 'STRING', 'product_state_approval_disclosure_base', 'disclosure_text', 'STRING', 'product_state_approval_disclosure', 'disclosure_text', 'STRING', 4, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'ProductStateApprovalDisclosure', 'SortOrder', 'STRING', 'product_state_approval_disclosure_base', 'sort_order', 'STRING', 'product_state_approval_disclosure', 'sort_order', 'INT', 5, 1, 0, 0, '0', 1, GETUTCDATE());

-- [30] ProductStateApproval
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'ProductStateApproval', 'ProductStateApprovalPK', 'STRING', 'product_state_approval_base', 'product_state_approval_id', 'STRING', 'product_state_approval', 'product_state_approval_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'ProductStateApproval', 'ProductFK', 'STRING', 'product_state_approval_base', 'product_id', 'STRING', 'product_state_approval', 'product_id', 'INT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'ProductStateApproval', 'StateCode', 'STRING', 'product_state_approval_base', 'state_code', 'STRING', 'product_state_approval', 'state_code', 'STRING', 3, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'ProductStateApproval', 'ApprovedInd', 'STRING', 'product_state_approval_base', 'is_approved', 'STRING', 'product_state_approval', 'is_approved', 'BOOLEAN', 4, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'ProductStateApproval', 'StartDate', 'STRING', 'product_state_approval_base', 'start_timestamp', 'STRING', 'product_state_approval', 'start_timestamp', 'TIMESTAMP', 5, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'ProductStateApproval', 'EndDate', 'STRING', 'product_state_approval_base', 'end_timestamp', 'STRING', 'product_state_approval', 'end_timestamp', 'TIMESTAMP', 6, 1, 0, 0, '3000-01-01', 1, GETUTCDATE());

-- [31] hedge.Ratios
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'Ratios', 'RatiosPK', 'STRING', 'hedge_ratios_base', 'ratios_id', 'STRING', 'hedge_ratios', 'ratios_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Ratios', 'ContractFK', 'STRING', 'hedge_ratios_base', 'contract_id', 'STRING', 'hedge_ratios', 'contract_id', 'INT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Ratios', 'ValueDate', 'STRING', 'hedge_ratios_base', 'value_timestamp', 'STRING', 'hedge_ratios', 'value_timestamp', 'TIMESTAMP', 3, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Ratios', 'BaseHedgeRatio', 'STRING', 'hedge_ratios_base', 'base_hedge_ratio', 'STRING', 'hedge_ratios', 'base_hedge_ratio', 'DECIMAL(18,4)', 4, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Ratios', 'BaseSurvivalRatio', 'STRING', 'hedge_ratios_base', 'base_survival_ratio', 'STRING', 'hedge_ratios', 'base_survival_ratio', 'DECIMAL(18,4)', 5, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Ratios', 'StartDate', 'STRING', 'hedge_ratios_base', 'start_timestamp', 'STRING', 'hedge_ratios', 'start_timestamp', 'TIMESTAMP', 6, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Ratios', 'EndDate', 'STRING', 'hedge_ratios_base', 'end_timestamp', 'STRING', 'hedge_ratios', 'end_timestamp', 'TIMESTAMP', 7, 1, 0, 0, '3000-01-01', 1, GETUTCDATE());

-- [32] hedge.Options
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'Options', 'OptionsPK', 'STRING', 'hedge_options_base', 'options_id', 'STRING', 'hedge_options', 'options_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Options', 'ContractFK', 'STRING', 'hedge_options_base', 'contract_id', 'STRING', 'hedge_options', 'contract_id', 'INT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Options', 'InvestmentFK', 'STRING', 'hedge_options_base', 'investment_id', 'STRING', 'hedge_options', 'investment_id', 'INT', 3, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Options', 'RenewalDate', 'STRING', 'hedge_options_base', 'renewal_timestamp', 'STRING', 'hedge_options', 'renewal_timestamp', 'TIMESTAMP', 4, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Options', 'IndexValue', 'STRING', 'hedge_options_base', 'index_value', 'STRING', 'hedge_options', 'index_value', 'DECIMAL(18,4)', 5, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Options', 'HedgingPercentage', 'STRING', 'hedge_options_base', 'hedging_percentage', 'STRING', 'hedge_options', 'hedging_percentage', 'DECIMAL(18,4)', 6, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Options', 'HedgeID1', 'STRING', 'hedge_options_base', 'hedge_id_1', 'STRING', 'hedge_options', 'hedge_id_1', 'STRING', 7, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Options', 'HedgeID2', 'STRING', 'hedge_options_base', 'hedge_id_2', 'STRING', 'hedge_options', 'hedge_id_2', 'STRING', 8, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Options', 'HedgeRenewalDate', 'STRING', 'hedge_options_base', 'hedge_renewal_timestamp', 'STRING', 'hedge_options', 'hedge_renewal_timestamp', 'TIMESTAMP', 9, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Options', 'ValueDate', 'STRING', 'hedge_options_base', 'value_timestamp', 'STRING', 'hedge_options', 'value_timestamp', 'TIMESTAMP', 10, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Options', 'SeriatimHedgeRatio', 'STRING', 'hedge_options_base', 'seriatim_hedge_ratio', 'STRING', 'hedge_options', 'seriatim_hedge_ratio', 'DECIMAL(18,4)', 11, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Options', 'PresentValue', 'STRING', 'hedge_options_base', 'present_value', 'STRING', 'hedge_options', 'present_value', 'DECIMAL(18,4)', 12, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Options', 'Delta', 'STRING', 'hedge_options_base', 'delta', 'STRING', 'hedge_options', 'delta', 'DECIMAL(18,4)', 13, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Options', 'Gamma', 'STRING', 'hedge_options_base', 'gamma', 'STRING', 'hedge_options', 'gamma', 'DECIMAL(18,4)', 14, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Options', 'Vega', 'STRING', 'hedge_options_base', 'vega', 'STRING', 'hedge_options', 'vega', 'DECIMAL(18,4)', 15, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Options', 'Rho', 'STRING', 'hedge_options_base', 'rho', 'STRING', 'hedge_options', 'rho', 'DECIMAL(18,4)', 16, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Options', 'Theta', 'STRING', 'hedge_options_base', 'theta', 'STRING', 'hedge_options', 'theta', 'DECIMAL(18,4)', 17, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Options', 'NeedsHedged', 'STRING', 'hedge_options_base', 'needs_hedged', 'STRING', 'hedge_options', 'needs_hedged', 'BOOLEAN', 18, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Options', 'IsHedged', 'STRING', 'hedge_options_base', 'is_hedged', 'STRING', 'hedge_options', 'is_hedged', 'BOOLEAN', 19, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Options', 'StartDate', 'STRING', 'hedge_options_base', 'start_timestamp', 'STRING', 'hedge_options', 'start_timestamp', 'TIMESTAMP', 20, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Options', 'EndDate', 'STRING', 'hedge_options_base', 'end_timestamp', 'STRING', 'hedge_options', 'end_timestamp', 'TIMESTAMP', 21, 1, 0, 0, '3000-01-01', 1, GETUTCDATE());

-- [33] State
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'State', 'StateCode', 'STRING', 'state_base', 'state_code', 'STRING', 'state', 'state_code', 'STRING', 1, 1, 1, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'State', 'StateName', 'STRING', 'state_base', 'state_name', 'STRING', 'state', 'state_name', 'STRING', 2, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'State', 'DisplayOrder', 'STRING', 'state_base', 'display_order', 'STRING', 'state', 'display_order', 'INT', 3, 1, 0, 0, '0', 1, GETUTCDATE());

-- [34] Date
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'Date', 'DatePK', 'STRING', 'date_base', 'date_id', 'STRING', 'date', 'date_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Date', 'Date', 'STRING', 'date_base', 'calendar_timestamp', 'STRING', 'date', 'calendar_timestamp', 'TIMESTAMP', 2, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Date', 'DateDisplay', 'STRING', 'date_base', 'date_display', 'STRING', 'date', 'date_display', 'STRING', 3, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Date', 'DayOfMonth', 'STRING', 'date_base', 'day_of_month', 'STRING', 'date', 'day_of_month', 'STRING', 4, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Date', 'DaySuffix', 'STRING', 'date_base', 'day_suffix', 'STRING', 'date', 'day_suffix', 'STRING', 5, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Date', 'DayName', 'STRING', 'date_base', 'day_name', 'STRING', 'date', 'day_name', 'STRING', 6, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Date', 'DayOfWeek', 'STRING', 'date_base', 'day_of_week', 'STRING', 'date', 'day_of_week', 'STRING', 7, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Date', 'DayOfWeekInMonth', 'STRING', 'date_base', 'day_of_week_in_month', 'STRING', 'date', 'day_of_week_in_month', 'STRING', 8, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Date', 'DayOfWeekInYear', 'STRING', 'date_base', 'day_of_week_in_year', 'STRING', 'date', 'day_of_week_in_year', 'STRING', 9, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Date', 'DayOfYear', 'STRING', 'date_base', 'day_of_year', 'STRING', 'date', 'day_of_year', 'STRING', 10, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Date', 'WeekOfMonth', 'STRING', 'date_base', 'week_of_month', 'STRING', 'date', 'week_of_month', 'STRING', 11, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Date', 'WeekOfQuarter', 'STRING', 'date_base', 'week_of_quarter', 'STRING', 'date', 'week_of_quarter', 'STRING', 12, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Date', 'WeekOfYear', 'STRING', 'date_base', 'week_of_year', 'STRING', 'date', 'week_of_year', 'STRING', 13, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Date', 'Month', 'STRING', 'date_base', 'month', 'STRING', 'date', 'month', 'STRING', 14, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Date', 'MonthName', 'STRING', 'date_base', 'month_name', 'STRING', 'date', 'month_name', 'STRING', 15, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Date', 'MonthOfQuarter', 'STRING', 'date_base', 'month_of_quarter', 'STRING', 'date', 'month_of_quarter', 'STRING', 16, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Date', 'Quarter', 'STRING', 'date_base', 'quarter', 'STRING', 'date', 'quarter', 'STRING', 17, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Date', 'QuarterName', 'STRING', 'date_base', 'quarter_name', 'STRING', 'date', 'quarter_name', 'STRING', 18, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Date', 'Year', 'STRING', 'date_base', 'year', 'STRING', 'date', 'year', 'STRING', 19, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Date', 'YearName', 'STRING', 'date_base', 'year_name', 'STRING', 'date', 'year_name', 'STRING', 20, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Date', 'MonthYear', 'STRING', 'date_base', 'month_year', 'STRING', 'date', 'month_year', 'STRING', 21, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Date', 'MMYYYY', 'STRING', 'date_base', 'mmyyyy', 'STRING', 'date', 'mmyyyy', 'STRING', 22, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Date', 'FirstDayOfMonth', 'STRING', 'date_base', 'first_day_of_month', 'STRING', 'date', 'first_day_of_month', 'DATE', 23, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Date', 'LastDayOfMonth', 'STRING', 'date_base', 'last_day_of_month', 'STRING', 'date', 'last_day_of_month', 'DATE', 24, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Date', 'FirstDayOfQuarter', 'STRING', 'date_base', 'first_day_of_quarter', 'STRING', 'date', 'first_day_of_quarter', 'DATE', 25, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Date', 'LastDayOfQuarter', 'STRING', 'date_base', 'last_day_of_quarter', 'STRING', 'date', 'last_day_of_quarter', 'DATE', 26, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Date', 'FirstDayOfYear', 'STRING', 'date_base', 'first_day_of_year', 'STRING', 'date', 'first_day_of_year', 'DATE', 27, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Date', 'LastDayOfYear', 'STRING', 'date_base', 'last_day_of_year', 'STRING', 'date', 'last_day_of_year', 'DATE', 28, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Date', 'IsWeekday', 'STRING', 'date_base', 'is_weekday', 'STRING', 'date', 'is_weekday', 'BOOLEAN', 29, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Date', 'IsHoliday', 'STRING', 'date_base', 'is_holiday', 'STRING', 'date', 'is_holiday', 'BOOLEAN', 30, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Date', 'HolidayName', 'STRING', 'date_base', 'holiday_name', 'STRING', 'date', 'holiday_name', 'STRING', 31, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Date', 'IsLastDayOfMonth', 'STRING', 'date_base', 'is_last_day_of_month', 'STRING', 'date', 'is_last_day_of_month', 'BOOLEAN', 32, 1, 0, 0, '0', 1, GETUTCDATE());

-- [35] TrainingCourse
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'TrainingCourse', 'TrainingCoursePK', 'STRING', 'training_course_base', 'training_course_id', 'STRING', 'training_course', 'training_course_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'TrainingCourse', 'CourseName', 'STRING', 'training_course_base', 'course_name', 'STRING', 'training_course', 'course_name', 'STRING', 2, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'TrainingCourse', 'Context', 'STRING', 'training_course_base', 'context', 'STRING', 'training_course', 'context', 'STRING', 3, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'TrainingCourse', 'TrainingProductGroupKey', 'STRING', 'training_course_base', 'training_product_group_key', 'STRING', 'training_course', 'training_product_group_key', 'INT', 4, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'TrainingCourse', 'TrainingStateGroupKey', 'STRING', 'training_course_base', 'training_state_group_key', 'STRING', 'training_course', 'training_state_group_key', 'INT', 5, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'TrainingCourse', 'Description', 'STRING', 'training_course_base', 'description', 'STRING', 'training_course', 'description', 'STRING', 6, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE());

-- [36] AgentTraining
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'AgentTraining', 'AgentTrainingPK', 'STRING', 'agent_training_base', 'agent_training_id', 'STRING', 'agent_training', 'agent_training_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'AgentTraining', 'AgentFK', 'STRING', 'agent_training_base', 'agent_id', 'STRING', 'agent_training', 'agent_id', 'INT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'AgentTraining', 'TrainingCourseFK', 'STRING', 'agent_training_base', 'training_course_id', 'STRING', 'agent_training', 'training_course_id', 'INT', 3, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'AgentTraining', 'CompletionDate', 'STRING', 'agent_training_base', 'completion_timestamp', 'STRING', 'agent_training', 'completion_timestamp', 'TIMESTAMP', 4, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'AgentTraining', 'ExpirationDate', 'STRING', 'agent_training_base', 'expiration_timestamp', 'STRING', 'agent_training', 'expiration_timestamp', 'TIMESTAMP', 5, 1, 0, 0, '3000-01-01', 1, GETUTCDATE());

-- [37] Company
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'Company', 'CompanyPK', 'STRING', 'company_base', 'company_id', 'STRING', 'company', 'company_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Company', 'CompanyCode', 'STRING', 'company_base', 'company_code', 'STRING', 'company', 'company_code', 'STRING', 2, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Company', 'AgentFK', 'STRING', 'company_base', 'agent_id', 'STRING', 'company', 'agent_id', 'INT', 3, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Company', 'Name', 'STRING', 'company_base', 'name', 'STRING', 'company', 'name', 'STRING', 4, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Company', 'DisplayName', 'STRING', 'company_base', 'display_name', 'STRING', 'company', 'display_name', 'STRING', 5, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Company', 'AddressLine1', 'STRING', 'company_base', 'address_line_1', 'STRING', 'company', 'address_line_1', 'STRING', 6, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Company', 'AddressLine2', 'STRING', 'company_base', 'address_line_2', 'STRING', 'company', 'address_line_2', 'STRING', 7, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Company', 'City', 'STRING', 'company_base', 'city', 'STRING', 'company', 'city', 'STRING', 8, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Company', 'State', 'STRING', 'company_base', 'state', 'STRING', 'company', 'state', 'STRING', 9, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Company', 'ZipCode', 'STRING', 'company_base', 'zip_code', 'STRING', 'company', 'zip_code', 'STRING', 10, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Company', 'Phone', 'STRING', 'company_base', 'phone', 'STRING', 'company', 'phone', 'STRING', 11, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Company', 'Footer', 'STRING', 'company_base', 'footer', 'STRING', 'company', 'footer', 'STRING', 12, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE());

-- [38] CAPStatusChange
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'CAPStatusChange', 'CAPStatusChangePK', 'STRING', 'cap_status_change_base', 'cap_status_change_id', 'STRING', 'cap_status_change', 'cap_status_change_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'CAPStatusChange', 'ContractFK', 'STRING', 'cap_status_change_base', 'contract_id', 'STRING', 'cap_status_change', 'contract_id', 'INT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'CAPStatusChange', 'SourceCompanyFK', 'STRING', 'cap_status_change_base', 'source_company_id', 'STRING', 'cap_status_change', 'source_company_id', 'INT', 3, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'CAPStatusChange', 'StatusChangeDate', 'STRING', 'cap_status_change_base', 'status_change_date', 'STRING', 'cap_status_change', 'status_change_date', 'TIMESTAMP', 4, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'CAPStatusChange', 'StatusChangeCode', 'STRING', 'cap_status_change_base', 'status_change_code', 'STRING', 'cap_status_change', 'status_change_code', 'STRING', 5, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'CAPStatusChange', 'ProcessDate', 'STRING', 'cap_status_change_base', 'process_date', 'STRING', 'cap_status_change', 'process_date', 'TIMESTAMP', 6, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'CAPStatusChange', 'RenewalPeriod', 'STRING', 'cap_status_change_base', 'renewal_period', 'STRING', 'cap_status_change', 'renewal_period', 'INT', 7, 1, 0, 0, '0', 1, GETUTCDATE());

-- [39] CAPRepayment
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'CAPRepayment', 'CAPRepaymentPK', 'STRING', 'cap_repayment_base', 'cap_repayment_id', 'STRING', 'cap_repayment', 'cap_repayment_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'CAPRepayment', 'SourceKey', 'STRING', 'cap_repayment_base', 'source_key', 'STRING', 'cap_repayment', 'source_key', 'BIGINT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'CAPRepayment', 'SourceCompanyFK', 'STRING', 'cap_repayment_base', 'source_company_id', 'STRING', 'cap_repayment', 'source_company_id', 'INT', 3, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'CAPRepayment', 'PlanCode', 'STRING', 'cap_repayment_base', 'plan_code', 'STRING', 'cap_repayment', 'plan_code', 'STRING', 4, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'CAPRepayment', 'PlanCode2', 'STRING', 'cap_repayment_base', 'plan_code_2', 'STRING', 'cap_repayment', 'plan_code_2', 'STRING', 5, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'CAPRepayment', 'OwnerResState', 'STRING', 'cap_repayment_base', 'owner_res_state', 'STRING', 'cap_repayment', 'owner_res_state', 'STRING', 6, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'CAPRepayment', 'OwnerCountry', 'STRING', 'cap_repayment_base', 'owner_country', 'STRING', 'cap_repayment', 'owner_country', 'STRING', 7, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'CAPRepayment', 'TerminationDate', 'STRING', 'cap_repayment_base', 'termination_date', 'STRING', 'cap_repayment', 'termination_date', 'TIMESTAMP', 8, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'CAPRepayment', 'FactorTrail', 'STRING', 'cap_repayment_base', 'factor_trail', 'STRING', 'cap_repayment', 'factor_trail', 'DECIMAL(18,4)', 9, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'CAPRepayment', 'RenewalPeriod', 'STRING', 'cap_repayment_base', 'renewal_period', 'STRING', 'cap_repayment', 'renewal_period', 'INT', 10, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'CAPRepayment', 'CommissionableAmount', 'STRING', 'cap_repayment_base', 'commissionable_amount', 'STRING', 'cap_repayment', 'commissionable_amount', 'DECIMAL(18,4)', 11, 1, 0, 0, '0', 1, GETUTCDATE());

-- [40] ActivityType
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'ActivityType', 'ActivityTypePK', 'STRING', 'activity_type_base', 'activity_type_id', 'STRING', 'activity_type', 'activity_type_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'ActivityType', 'ActivityTypeName', 'STRING', 'activity_type_base', 'activity_type_name', 'STRING', 'activity_type', 'activity_type_name', 'STRING', 2, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'ActivityType', 'ActivityTypeQualifier', 'STRING', 'activity_type_base', 'activity_type_qualifier', 'STRING', 'activity_type', 'activity_type_qualifier', 'STRING', 3, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'ActivityType', 'Source', 'STRING', 'activity_type_base', 'source', 'STRING', 'activity_type', 'source', 'STRING', 4, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'ActivityType', 'ValueType', 'STRING', 'activity_type_base', 'value_type', 'STRING', 'activity_type', 'value_type', 'STRING', 5, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'ActivityType', 'SortOrder', 'STRING', 'activity_type_base', 'sort_order', 'STRING', 'activity_type', 'sort_order', 'INT', 6, 1, 0, 0, '0', 1, GETUTCDATE());

-- [41] ActivityFinancial
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'ActivityFinancial', 'ActivityPK', 'STRING', 'activity_financial_base', 'activity_id', 'STRING', 'activity_financial', 'activity_id', 'BIGINT', 1, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'ActivityFinancial', 'FreeAmount', 'STRING', 'activity_financial_base', 'free_amount', 'STRING', 'activity_financial', 'free_amount', 'DECIMAL(18,4)', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'ActivityFinancial', 'SurrenderCharge', 'STRING', 'activity_financial_base', 'surrender_charge', 'STRING', 'activity_financial', 'surrender_charge', 'DECIMAL(18,4)', 3, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'ActivityFinancial', 'MVA', 'STRING', 'activity_financial_base', 'mva', 'STRING', 'activity_financial', 'mva', 'DECIMAL(18,4)', 4, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'ActivityFinancial', 'PolicyFee', 'STRING', 'activity_financial_base', 'policy_fee', 'STRING', 'activity_financial', 'policy_fee', 'DECIMAL(18,4)', 5, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'ActivityFinancial', 'COIRefund', 'STRING', 'activity_financial_base', 'coi_refund', 'STRING', 'activity_financial', 'coi_refund', 'DECIMAL(18,4)', 6, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'ActivityFinancial', 'ABRDiscountCharge', 'STRING', 'activity_financial_base', 'abr_discount_charge', 'STRING', 'activity_financial', 'abr_discount_charge', 'DECIMAL(18,4)', 7, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'ActivityFinancial', 'AdminCharge', 'STRING', 'activity_financial_base', 'admin_charge', 'STRING', 'activity_financial', 'admin_charge', 'DECIMAL(18,4)', 8, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'ActivityFinancial', 'FederalTax', 'STRING', 'activity_financial_base', 'federal_tax', 'STRING', 'activity_financial', 'federal_tax', 'DECIMAL(18,4)', 9, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'ActivityFinancial', 'StateTax', 'STRING', 'activity_financial_base', 'state_tax', 'STRING', 'activity_financial', 'state_tax', 'DECIMAL(18,4)', 10, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'ActivityFinancial', 'Rate', 'STRING', 'activity_financial_base', 'rate', 'STRING', 'activity_financial', 'rate', 'DECIMAL(18,4)', 11, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'ActivityFinancial', 'BaseAmount', 'STRING', 'activity_financial_base', 'base_amount', 'STRING', 'activity_financial', 'base_amount', 'DECIMAL(18,4)', 12, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'ActivityFinancial', 'TaxableBenefit', 'STRING', 'activity_financial_base', 'taxable_benefit', 'STRING', 'activity_financial', 'taxable_benefit', 'DECIMAL(18,4)', 13, 1, 0, 0, '0', 1, GETUTCDATE());

-- [42] AccountingDetail
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'AccountingDetail', 'AccountingPK', 'STRING', 'accounting_detail_base', 'accounting_id', 'STRING', 'accounting_detail', 'accounting_id', 'BIGINT', 1, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'AccountingDetail', 'SourceCode', 'STRING', 'accounting_detail_base', 'source_code', 'STRING', 'accounting_detail', 'source_code', 'STRING', 2, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AccountingDetail', 'ReferenceData', 'STRING', 'accounting_detail_base', 'reference_data', 'STRING', 'accounting_detail', 'reference_data', 'STRING', 3, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AccountingDetail', 'Approval', 'STRING', 'accounting_detail_base', 'approval', 'STRING', 'accounting_detail', 'approval', 'STRING', 4, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AccountingDetail', 'Description', 'STRING', 'accounting_detail_base', 'description', 'STRING', 'accounting_detail', 'description', 'STRING', 5, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AccountingDetail', 'CompanyCode', 'STRING', 'accounting_detail_base', 'company_code', 'STRING', 'accounting_detail', 'company_code', 'STRING', 6, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AccountingDetail', 'DCIndicator', 'STRING', 'accounting_detail_base', 'dc_indicator', 'STRING', 'accounting_detail', 'dc_indicator', 'STRING', 7, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AccountingDetail', 'EntryOperator', 'STRING', 'accounting_detail_base', 'entry_operator', 'STRING', 'accounting_detail', 'entry_operator', 'STRING', 8, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AccountingDetail', 'ApprovalOperator', 'STRING', 'accounting_detail_base', 'approval_operator', 'STRING', 'accounting_detail', 'approval_operator', 'STRING', 9, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AccountingDetail', 'APEXTIndicator', 'STRING', 'accounting_detail_base', 'apext_indicator', 'STRING', 'accounting_detail', 'apext_indicator', 'STRING', 10, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AccountingDetail', 'SuspenseEXTIndicator', 'STRING', 'accounting_detail_base', 'suspense_ext_indicator', 'STRING', 'accounting_detail', 'suspense_ext_indicator', 'STRING', 11, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AccountingDetail', 'EntryGenIndicator', 'STRING', 'accounting_detail_base', 'entry_gen_indicator', 'STRING', 'accounting_detail', 'entry_gen_indicator', 'STRING', 12, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AccountingDetail', 'Treaty', 'STRING', 'accounting_detail_base', 'treaty', 'STRING', 'accounting_detail', 'treaty', 'STRING', 13, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AccountingDetail', 'QualType', 'STRING', 'accounting_detail_base', 'qual_type', 'STRING', 'accounting_detail', 'qual_type', 'STRING', 14, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AccountingDetail', 'SEG_EDITTrxPK', 'STRING', 'accounting_detail_base', 'seg_edit_trx_id', 'STRING', 'accounting_detail', 'seg_edit_trx_id', 'BIGINT', 15, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'AccountingDetail', 'SEG_PlacedAgentPK', 'STRING', 'accounting_detail_base', 'seg_placed_agent_id', 'STRING', 'accounting_detail', 'seg_placed_agent_id', 'BIGINT', 16, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'AccountingDetail', 'CostCenter', 'STRING', 'accounting_detail_base', 'cost_center', 'STRING', 'accounting_detail', 'cost_center', 'STRING', 17, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AccountingDetail', 'SuspenseCode', 'STRING', 'accounting_detail_base', 'suspense_code', 'STRING', 'accounting_detail', 'suspense_code', 'STRING', 18, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE());

-- [43] AccountingAccount
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'AccountingAccount', 'AccountingAccountPK', 'STRING', 'accounting_account_base', 'accounting_account_id', 'STRING', 'accounting_account', 'accounting_account_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'AccountingAccount', 'AccountNumber', 'STRING', 'accounting_account_base', 'account_number', 'STRING', 'accounting_account', 'account_number', 'STRING', 2, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AccountingAccount', 'AccountSource', 'STRING', 'accounting_account_base', 'account_source', 'STRING', 'accounting_account', 'account_source', 'STRING', 3, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AccountingAccount', 'ClassCode', 'STRING', 'accounting_account_base', 'class_code', 'STRING', 'accounting_account', 'class_code', 'STRING', 4, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AccountingAccount', 'CubeDescription', 'STRING', 'accounting_account_base', 'cube_description', 'STRING', 'accounting_account', 'cube_description', 'STRING', 5, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AccountingAccount', 'GroupIndicator', 'STRING', 'accounting_account_base', 'group_indicator', 'STRING', 'accounting_account', 'group_indicator', 'BOOLEAN', 6, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'AccountingAccount', 'CededIndicator', 'STRING', 'accounting_account_base', 'ceded_indicator', 'STRING', 'accounting_account', 'ceded_indicator', 'BOOLEAN', 7, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'AccountingAccount', 'Context', 'STRING', 'accounting_account_base', 'context', 'STRING', 'accounting_account', 'context', 'STRING', 8, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AccountingAccount', 'ActuarialGrouping', 'STRING', 'accounting_account_base', 'actuarial_grouping', 'STRING', 'accounting_account', 'actuarial_grouping', 'STRING', 9, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AccountingAccount', 'AccountDescription', 'STRING', 'accounting_account_base', 'account_description', 'STRING', 'accounting_account', 'account_description', 'STRING', 10, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'AccountingAccount', 'AccountingReportingGroupKey', 'STRING', 'accounting_account_base', 'accounting_reporting_group_key', 'STRING', 'accounting_account', 'accounting_reporting_group_key', 'INT', 11, 1, 0, 0, '0', 1, GETUTCDATE());

-- [44] Accounting
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'Accounting', 'AccountingPK', 'STRING', 'accounting_base', 'accounting_id', 'STRING', 'accounting', 'accounting_id', 'BIGINT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Accounting', 'SourceSystem', 'STRING', 'accounting_base', 'source_system_code', 'STRING', 'accounting', 'source_system_code', 'STRING', 2, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Accounting', 'TranID', 'STRING', 'accounting_base', 'transaction_id', 'STRING', 'accounting', 'transaction_id', 'INT', 3, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Accounting', 'TranDetailID', 'STRING', 'accounting_base', 'transaction_detail_id', 'STRING', 'accounting', 'transaction_detail_id', 'BIGINT', 4, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Accounting', 'StatusCode', 'STRING', 'accounting_base', 'status_code', 'STRING', 'accounting', 'status_code', 'STRING', 5, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Accounting', 'StatusIndicator', 'STRING', 'accounting_base', 'status_indicator', 'STRING', 'accounting', 'status_indicator', 'STRING', 6, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Accounting', 'BasisCode', 'STRING', 'accounting_base', 'basis_code', 'STRING', 'accounting', 'basis_code', 'STRING', 7, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Accounting', 'State', 'STRING', 'accounting_base', 'state_code', 'STRING', 'accounting', 'state_code', 'STRING', 8, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Accounting', 'EffectiveDateFK', 'STRING', 'accounting_base', 'effective_date_id', 'STRING', 'accounting', 'effective_date_id', 'INT', 9, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Accounting', 'PeriodDateFK', 'STRING', 'accounting_base', 'period_date_id', 'STRING', 'accounting', 'period_date_id', 'INT', 10, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Accounting', 'AccountingAccountFK', 'STRING', 'accounting_base', 'accounting_account_id', 'STRING', 'accounting', 'accounting_account_id', 'INT', 11, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Accounting', 'EntryDate', 'STRING', 'accounting_base', 'entry_date', 'STRING', 'accounting', 'entry_date', 'DATE', 12, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Accounting', 'EntryUpdateDate', 'STRING', 'accounting_base', 'entry_update_date', 'STRING', 'accounting', 'entry_update_date', 'DATE', 13, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Accounting', 'ContractFK', 'STRING', 'accounting_base', 'contract_id', 'STRING', 'accounting', 'contract_id', 'INT', 14, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Accounting', 'InvestmentFK', 'STRING', 'accounting_base', 'investment_id', 'STRING', 'accounting', 'investment_id', 'INT', 15, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Accounting', 'ProductFK', 'STRING', 'accounting_base', 'product_id', 'STRING', 'accounting', 'product_id', 'INT', 16, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Accounting', 'AgentFK', 'STRING', 'accounting_base', 'agent_id', 'STRING', 'accounting', 'agent_id', 'INT', 17, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Accounting', 'Amount', 'STRING', 'accounting_base', 'amount', 'STRING', 'accounting', 'amount', 'DECIMAL(18,4)', 18, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Accounting', 'Block', 'STRING', 'accounting_base', 'block_code', 'STRING', 'accounting', 'block_code', 'STRING', 19, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE());

-- [45] Surrender
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'Surrender', 'SurrenderPK', 'STRING', 'surrender_base', 'surrender_id', 'STRING', 'surrender', 'surrender_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Surrender', 'ProductFK', 'STRING', 'surrender_base', 'product_id', 'STRING', 'surrender', 'product_id', 'INT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Surrender', 'FundNumber', 'STRING', 'surrender_base', 'fund_number', 'STRING', 'surrender', 'fund_number', 'STRING', 3, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Surrender', 'State', 'STRING', 'surrender_base', 'state_code', 'STRING', 'surrender', 'state_code', 'STRING', 4, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Surrender', 'Gender', 'STRING', 'surrender_base', 'gender', 'STRING', 'surrender', 'gender', 'STRING', 5, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Surrender', 'Class', 'STRING', 'surrender_base', 'risk_class', 'STRING', 'surrender', 'risk_class', 'STRING', 6, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Surrender', 'Age', 'STRING', 'surrender_base', 'customer_age', 'STRING', 'surrender', 'customer_age', 'INT', 7, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Surrender', 'ContractYear', 'STRING', 'surrender_base', 'policy_year', 'STRING', 'surrender', 'policy_year', 'INT', 8, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Surrender', 'SurrenderLength', 'STRING', 'surrender_base', 'penalty_duration_years', 'STRING', 'surrender', 'penalty_duration_years', 'INT', 9, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Surrender', 'Rate', 'STRING', 'surrender_base', 'penalty_percentage', 'STRING', 'surrender', 'penalty_percentage', 'DECIMAL(18,4)', 10, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Surrender', 'RateAppliedTo', 'STRING', 'surrender_base', 'rate_calculation_basis', 'STRING', 'surrender', 'rate_calculation_basis', 'STRING', 11, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Surrender', 'EffectiveDate', 'STRING', 'surrender_base', 'rule_start_date', 'STRING', 'surrender', 'rule_start_date', 'TIMESTAMP', 12, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Surrender', 'EndDate', 'STRING', 'surrender_base', 'rule_end_date', 'STRING', 'surrender', 'rule_end_date', 'TIMESTAMP', 13, 1, 0, 0, '3000-01-01', 1, GETUTCDATE());

-- [46] InvestmentDetail
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'InvestmentDetail', 'InvestmentDetailPK', 'STRING', 'investment_detail_base', 'investment_detail_id', 'STRING', 'investment_detail', 'investment_detail_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'InvestmentDetail', 'Name', 'STRING', 'investment_detail_base', 'investment_detail_name', 'STRING', 'investment_detail', 'investment_detail_name', 'STRING', 2, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'InvestmentDetail', 'FundType', 'STRING', 'investment_detail_base', 'fund_type', 'STRING', 'investment_detail', 'fund_type', 'STRING', 3, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'InvestmentDetail', 'GroupingName', 'STRING', 'investment_detail_base', 'grouping_name', 'STRING', 'investment_detail', 'grouping_name', 'STRING', 4, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'InvestmentDetail', 'MarketingName', 'STRING', 'investment_detail_base', 'marketing_name', 'STRING', 'investment_detail', 'marketing_name', 'STRING', 5, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'InvestmentDetail', 'AltMarketingName', 'STRING', 'investment_detail_base', 'alt_marketing_name', 'STRING', 'investment_detail', 'alt_marketing_name', 'STRING', 6, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'InvestmentDetail', 'SortOrder', 'STRING', 'investment_detail_base', 'sort_order', 'STRING', 'investment_detail', 'sort_order', 'STRING', 7, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'InvestmentDetail', 'IsCap', 'STRING', 'investment_detail_base', 'is_cap_indicator', 'STRING', 'investment_detail', 'is_cap_indicator', 'BOOLEAN', 8, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'InvestmentDetail', 'FundStartDate', 'STRING', 'investment_detail_base', 'fund_start_date', 'STRING', 'investment_detail', 'fund_start_date', 'TIMESTAMP', 9, 1, 0, 0, '3000-01-01', 1, GETUTCDATE());

-- [47] Investment
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'Investment', 'InvestmentPK', 'STRING', 'investment_base', 'investment_id', 'STRING', 'investment', 'investment_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Investment', 'InvestmentKey', 'STRING', 'investment_base', 'investment_key', 'STRING', 'investment', 'investment_key', 'INT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Investment', 'InvestmentName', 'STRING', 'investment_base', 'investment_name', 'STRING', 'investment', 'investment_name', 'STRING', 3, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Investment', 'InvestmentDescription', 'STRING', 'investment_base', 'investment_description', 'STRING', 'investment', 'investment_description', 'STRING', 4, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Investment', 'EffectiveDate', 'STRING', 'investment_base', 'effective_date', 'STRING', 'investment', 'effective_date', 'TIMESTAMP', 5, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Investment', 'Active', 'STRING', 'investment_base', 'active_indicator', 'STRING', 'investment', 'active_indicator', 'BOOLEAN', 6, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Investment', 'StartDate', 'STRING', 'investment_base', 'start_timestamp', 'STRING', 'investment', 'start_timestamp', 'TIMESTAMP', 7, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Investment', 'EndDate', 'STRING', 'investment_base', 'end_timestamp', 'STRING', 'investment', 'end_timestamp', 'TIMESTAMP', 8, 1, 0, 0, '3000-01-01', 1, GETUTCDATE());

-- [48] Activity
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'Activity', 'ActivityPK', 'STRING', 'activity_base', 'activity_id', 'STRING', 'activity', 'activity_id', 'BIGINT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Activity', 'ActivityTypeFK', 'STRING', 'activity_base', 'activity_type_id', 'STRING', 'activity', 'activity_type_id', 'INT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Activity', 'CompanyFK', 'STRING', 'activity_base', 'company_id', 'STRING', 'activity', 'company_id', 'INT', 3, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Activity', 'ContractFK', 'STRING', 'activity_base', 'contract_id', 'STRING', 'activity', 'contract_id', 'INT', 4, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Activity', 'ProductFK', 'STRING', 'activity_base', 'product_id', 'STRING', 'activity', 'product_id', 'INT', 5, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Activity', 'InvestmentFK', 'STRING', 'activity_base', 'investment_id', 'STRING', 'activity', 'investment_id', 'INT', 6, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Activity', 'AccountingFK', 'STRING', 'activity_base', 'accounting_id', 'STRING', 'activity', 'accounting_id', 'INT', 7, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Activity', 'AccountingAccountFK', 'STRING', 'activity_base', 'accounting_account_id', 'STRING', 'activity', 'accounting_account_id', 'INT', 8, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Activity', 'CAPRepaymentFK', 'STRING', 'activity_base', 'cap_repayment_id', 'STRING', 'activity', 'cap_repayment_id', 'INT', 9, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Activity', 'HierarchySetKey', 'STRING', 'activity_base', 'hierarchy_set_id', 'STRING', 'activity', 'hierarchy_set_id', 'INT', 10, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Activity', 'AgentFK', 'STRING', 'activity_base', 'agent_id', 'STRING', 'activity', 'agent_id', 'INT', 11, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Activity', 'ActivityClientFK', 'STRING', 'activity_base', 'activity_client_id', 'STRING', 'activity', 'activity_client_id', 'INT', 12, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Activity', 'ActivityPayeeFK', 'STRING', 'activity_base', 'activity_payee_id', 'STRING', 'activity', 'activity_payee_id', 'INT', 13, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Activity', 'EffectiveDateFK', 'STRING', 'activity_base', 'effective_date_id', 'STRING', 'activity', 'effective_date_id', 'INT', 14, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Activity', 'ProcessDateFK', 'STRING', 'activity_base', 'process_date_id', 'STRING', 'activity', 'process_date_id', 'INT', 15, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Activity', 'ReleaseDate', 'STRING', 'activity_base', 'release_date', 'STRING', 'activity', 'release_date', 'TIMESTAMP', 16, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Activity', 'PeriodDate', 'STRING', 'activity_base', 'period_date', 'STRING', 'activity', 'period_date', 'TIMESTAMP', 17, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Activity', 'GrossAmount', 'STRING', 'activity_base', 'gross_amount', 'STRING', 'activity', 'gross_amount', 'DECIMAL(18,4)', 18, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Activity', 'NetAmount', 'STRING', 'activity_base', 'net_amount', 'STRING', 'activity', 'net_amount', 'DECIMAL(18,4)', 19, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Activity', 'CheckAmount', 'STRING', 'activity_base', 'check_amount', 'STRING', 'activity', 'check_amount', 'DECIMAL(18,4)', 20, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Activity', 'DistributionType', 'STRING', 'activity_base', 'distribution_type', 'STRING', 'activity', 'distribution_type', 'STRING', 21, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Activity', 'TextValue', 'STRING', 'activity_base', 'activity_notes', 'STRING', 'activity', 'activity_notes', 'STRING', 22, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE());

-- [49] AccountValue
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'AccountValue', 'AccountValuePK', 'STRING', 'account_value_base', 'account_value_id', 'STRING', 'account_value', 'account_value_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'AccountValue', 'ContractFK', 'STRING', 'account_value_base', 'contract_id', 'STRING', 'account_value', 'contract_id', 'INT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'AccountValue', 'InvestmentFK', 'STRING', 'account_value_base', 'investment_id', 'STRING', 'account_value', 'investment_id', 'INT', 3, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'AccountValue', 'Value', 'STRING', 'account_value_base', 'account_value_amount', 'STRING', 'account_value', 'account_value_amount', 'DECIMAL(18,4)', 4, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'AccountValue', 'CurrentInterestRate', 'STRING', 'account_value_base', 'current_interest_rate', 'STRING', 'account_value', 'current_interest_rate', 'DECIMAL(18,4)', 5, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'AccountValue', 'AllocationPercent', 'STRING', 'account_value_base', 'allocation_percentage', 'STRING', 'account_value', 'allocation_percentage', 'DECIMAL(18,4)', 6, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'AccountValue', 'DepositDate', 'STRING', 'account_value_base', 'deposit_date', 'STRING', 'account_value', 'deposit_date', 'TIMESTAMP', 7, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'AccountValue', 'RenewalDate', 'STRING', 'account_value_base', 'renewal_date', 'STRING', 'account_value', 'renewal_date', 'TIMESTAMP', 8, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'AccountValue', 'ValuationDate', 'STRING', 'account_value_base', 'valuation_date', 'STRING', 'account_value', 'valuation_date', 'TIMESTAMP', 9, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'AccountValue', 'StartDate', 'STRING', 'account_value_base', 'start_timestamp', 'STRING', 'account_value', 'start_timestamp', 'TIMESTAMP', 10, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'AccountValue', 'EndDate', 'STRING', 'account_value_base', 'end_timestamp', 'STRING', 'account_value', 'end_timestamp', 'TIMESTAMP', 11, 1, 0, 0, '3000-01-01', 1, GETUTCDATE());

-- [50] Product
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'Product', 'ProductPK', 'STRING', 'product_base', 'product_id', 'STRING', 'product', 'product_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Product', 'ProductName', 'STRING', 'product_base', 'product_name', 'STRING', 'product', 'product_name', 'STRING', 2, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Product', 'MarketingName', 'STRING', 'product_base', 'marketing_name', 'STRING', 'product', 'marketing_name', 'STRING', 3, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Product', 'AltMarketingName', 'STRING', 'product_base', 'alt_marketing_name', 'STRING', 'product', 'alt_marketing_name', 'STRING', 4, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Product', 'GroupName', 'STRING', 'product_base', 'group_name', 'STRING', 'product', 'group_name', 'STRING', 5, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Product', 'AgentCommStatementAbbr', 'STRING', 'product_base', 'agent_comm_statement_abbr', 'STRING', 'product', 'agent_comm_statement_abbr', 'STRING', 6, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Product', 'GLAbbr', 'STRING', 'product_base', 'gl_abbr', 'STRING', 'product', 'gl_abbr', 'STRING', 7, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Product', 'GLLOB', 'STRING', 'product_base', 'gl_line_of_business', 'STRING', 'product', 'gl_line_of_business', 'STRING', 8, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Product', 'Context', 'STRING', 'product_base', 'product_context', 'STRING', 'product', 'product_context', 'STRING', 9, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Product', 'ProductType', 'STRING', 'product_base', 'product_type', 'STRING', 'product', 'product_type', 'STRING', 10, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Product', 'CUSIPNumber', 'STRING', 'product_base', 'cusip_number', 'STRING', 'product', 'cusip_number', 'STRING', 11, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Product', 'SortOrder', 'STRING', 'product_base', 'sort_order', 'STRING', 'product', 'sort_order', 'INT', 12, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Product', 'EffectiveDate', 'STRING', 'product_base', 'effective_date', 'STRING', 'product', 'effective_date', 'TIMESTAMP', 13, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Product', 'Status', 'STRING', 'product_base', 'status', 'STRING', 'product', 'status', 'STRING', 14, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE());

-- [51] Agent
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'Agent', 'AgentPK', 'STRING', 'agent_base', 'agent_id', 'STRING', 'agent', 'agent_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Agent', 'SourceKey', 'STRING', 'agent_base', 'source_key', 'STRING', 'agent', 'source_key', 'BIGINT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Agent', 'ClientFK', 'STRING', 'agent_base', 'client_id', 'STRING', 'agent', 'client_id', 'INT', 3, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Agent', 'DisplayName', 'STRING', 'agent_base', 'display_name', 'STRING', 'agent', 'display_name', 'STRING', 4, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Agent', 'AgentNumber', 'STRING', 'agent_base', 'agent_number', 'STRING', 'agent', 'agent_number', 'STRING', 5, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Agent', 'NoteGroupKey', 'STRING', 'agent_base', 'note_group_key', 'STRING', 'agent', 'note_group_key', 'INT', 6, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Agent', 'RequirementGroupKey', 'STRING', 'agent_base', 'requirement_group_key', 'STRING', 'agent', 'requirement_group_key', 'INT', 7, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Agent', 'AgentLicenseGroupKey', 'STRING', 'agent_base', 'agent_license_group_key', 'STRING', 'agent', 'agent_license_group_key', 'INT', 8, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Agent', 'AgentPrincipalGroupKey', 'STRING', 'agent_base', 'agent_principal_group_key', 'STRING', 'agent', 'agent_principal_group_key', 'INT', 9, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Agent', 'AgentSummaryGroupKey', 'STRING', 'agent_base', 'agent_summary_group_key', 'STRING', 'agent', 'agent_summary_group_key', 'INT', 10, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Agent', 'NPN', 'STRING', 'agent_base', 'national_producer_number', 'STRING', 'agent', 'national_producer_number', 'STRING', 11, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Agent', 'NASD', 'STRING', 'agent_base', 'nasd_finra_number', 'STRING', 'agent', 'nasd_finra_number', 'STRING', 12, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Agent', 'AgentType', 'STRING', 'agent_base', 'agent_type', 'STRING', 'agent', 'agent_type', 'STRING', 13, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Agent', 'HireDate', 'STRING', 'agent_base', 'hire_date', 'STRING', 'agent', 'hire_date', 'TIMESTAMP', 14, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Agent', 'TerminationDate', 'STRING', 'agent_base', 'termination_date', 'STRING', 'agent', 'termination_date', 'TIMESTAMP', 15, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Agent', 'Status', 'STRING', 'agent_base', 'status', 'STRING', 'agent', 'status', 'STRING', 16, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Agent', 'StartDate', 'STRING', 'agent_base', 'start_timestamp', 'STRING', 'agent', 'start_timestamp', 'TIMESTAMP', 17, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Agent', 'EndDate', 'STRING', 'agent_base', 'end_timestamp', 'STRING', 'agent', 'end_timestamp', 'TIMESTAMP', 18, 1, 0, 0, '3000-01-01', 1, GETUTCDATE());

-- [52] Client
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'Client', 'ClientPK', 'STRING', 'client_base', 'client_id', 'STRING', 'client', 'client_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Client', 'SourceKey', 'STRING', 'client_base', 'source_key', 'STRING', 'client', 'source_key', 'BIGINT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Client', 'TaxIDHash', 'STRING', 'client_base', 'tax_id_hash', 'STRING', 'client', 'tax_id_hash', 'BINARY', 3, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Client', 'Last4Hash', 'STRING', 'client_base', 'last_4_hash', 'STRING', 'client', 'last_4_hash', 'BINARY', 4, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Client', 'Last4Token', 'STRING', 'client_base', 'last_4_token', 'STRING', 'client', 'last_4_token', 'STRING', 5, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Client', 'DisplayName', 'STRING', 'client_base', 'display_name', 'STRING', 'client', 'display_name', 'STRING', 6, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Client', 'FirstName', 'STRING', 'client_base', 'first_name', 'STRING', 'client', 'first_name', 'STRING', 7, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Client', 'MiddleName', 'STRING', 'client_base', 'middle_name', 'STRING', 'client', 'middle_name', 'STRING', 8, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Client', 'LastName', 'STRING', 'client_base', 'last_name', 'STRING', 'client', 'last_name', 'STRING', 9, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Client', 'Prefix', 'STRING', 'client_base', 'prefix', 'STRING', 'client', 'prefix', 'STRING', 10, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Client', 'Suffix', 'STRING', 'client_base', 'suffix', 'STRING', 'client', 'suffix', 'STRING', 11, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Client', 'CorporateName', 'STRING', 'client_base', 'corporate_name', 'STRING', 'client', 'corporate_name', 'STRING', 12, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Client', 'Gender', 'STRING', 'client_base', 'gender', 'STRING', 'client', 'gender', 'STRING', 13, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Client', 'Phone', 'STRING', 'client_base', 'phone_number', 'STRING', 'client', 'phone_number', 'STRING', 14, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Client', 'Email', 'STRING', 'client_base', 'email_address', 'STRING', 'client', 'email_address', 'STRING', 15, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Client', 'Fax', 'STRING', 'client_base', 'fax_number', 'STRING', 'client', 'fax_number', 'STRING', 16, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Client', 'BirthDate', 'STRING', 'client_base', 'birth_date', 'STRING', 'client', 'birth_date', 'TIMESTAMP', 17, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Client', 'DateOfDeath', 'STRING', 'client_base', 'date_of_death', 'STRING', 'client', 'date_of_death', 'TIMESTAMP', 18, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Client', 'Status', 'STRING', 'client_base', 'status', 'STRING', 'client', 'status', 'STRING', 19, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Client', 'PayPreference', 'STRING', 'client_base', 'pay_preference', 'STRING', 'client', 'pay_preference', 'STRING', 20, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Client', 'ExternalAccountGroupKey', 'STRING', 'client_base', 'external_account_group_key', 'STRING', 'client', 'external_account_group_key', 'INT', 21, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Client', 'AddressLine1', 'STRING', 'client_base', 'address_line_1', 'STRING', 'client', 'address_line_1', 'STRING', 22, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Client', 'AddressLine2', 'STRING', 'client_base', 'address_line_2', 'STRING', 'client', 'address_line_2', 'STRING', 23, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Client', 'AddressLine3', 'STRING', 'client_base', 'address_line_3', 'STRING', 'client', 'address_line_3', 'STRING', 24, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Client', 'AddressLine4', 'STRING', 'client_base', 'address_line_4', 'STRING', 'client', 'address_line_4', 'STRING', 25, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Client', 'City', 'STRING', 'client_base', 'city', 'STRING', 'client', 'city', 'STRING', 26, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Client', 'State', 'STRING', 'client_base', 'state_code', 'STRING', 'client', 'state_code', 'STRING', 27, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Client', 'ZipCode', 'STRING', 'client_base', 'zip_code', 'STRING', 'client', 'zip_code', 'STRING', 28, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Client', 'County', 'STRING', 'client_base', 'county', 'STRING', 'client', 'county', 'STRING', 29, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Client', 'Country', 'STRING', 'client_base', 'country_code', 'STRING', 'client', 'country_code', 'STRING', 30, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Client', 'AdditionalInfoGroupKey', 'STRING', 'client_base', 'additional_info_group_key', 'STRING', 'client', 'additional_info_group_key', 'INT', 31, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Client', 'Verification', 'STRING', 'client_base', 'verification_details', 'STRING', 'client', 'verification_details', 'STRING', 32, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Client', 'NoNewBusinessInd', 'STRING', 'client_base', 'is_no_new_business', 'STRING', 'client', 'is_no_new_business', 'BOOLEAN', 33, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Client', 'EffectiveDate', 'STRING', 'client_base', 'effective_date', 'STRING', 'client', 'effective_date', 'TIMESTAMP', 34, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Client', 'StartDate', 'STRING', 'client_base', 'start_timestamp', 'STRING', 'client', 'start_timestamp', 'TIMESTAMP', 35, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Client', 'EndDate', 'STRING', 'client_base', 'end_timestamp', 'STRING', 'client', 'end_timestamp', 'TIMESTAMP', 36, 1, 0, 0, '3000-01-01', 1, GETUTCDATE());

-- [53] Contract (Full 51 Columns)
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_Warehouse', 'Contract', 'ContractPK', 'STRING', 'contract_base', 'contract_id', 'STRING', 'contract', 'contract_id', 'INT', 1, 1, 1, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'ContractNumber', 'STRING', 'contract_base', 'contract_number', 'STRING', 'contract', 'contract_number', 'STRING', 2, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'HierarchyGroupKey', 'STRING', 'contract_base', 'hierarchy_group_key', 'STRING', 'contract', 'hierarchy_group_key', 'INT', 3, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'ContractValueGroupKey', 'STRING', 'contract_base', 'contract_value_group_key', 'STRING', 'contract', 'contract_value_group_key', 'INT', 4, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'SurrenderFK', 'STRING', 'contract_base', 'surrender_id', 'STRING', 'contract', 'surrender_id', 'INT', 5, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'ProductFK', 'STRING', 'contract_base', 'product_id', 'STRING', 'contract', 'product_id', 'INT', 6, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'OwnerFK', 'STRING', 'contract_base', 'owner_client_id', 'STRING', 'contract', 'owner_client_id', 'INT', 7, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'Owner2FK', 'STRING', 'contract_base', 'owner_2_client_id', 'STRING', 'contract', 'owner_2_client_id', 'INT', 8, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'AnnuitantInsuredFK', 'STRING', 'contract_base', 'annuitant_insured_client_id', 'STRING', 'contract', 'annuitant_insured_client_id', 'INT', 9, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'AnnuitantInsured2FK', 'STRING', 'contract_base', 'annuitant_insured_2_client_id', 'STRING', 'contract', 'annuitant_insured_2_client_id', 'INT', 10, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'AdditionalClientGroupKey', 'STRING', 'contract_base', 'additional_client_group_key', 'STRING', 'contract', 'additional_client_group_key', 'INT', 11, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'ContractDepositGroupKey', 'STRING', 'contract_base', 'contract_deposit_group_key', 'STRING', 'contract', 'contract_deposit_group_key', 'INT', 12, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'RiderGroupKey', 'STRING', 'contract_base', 'rider_group_key', 'STRING', 'contract', 'rider_group_key', 'INT', 13, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'NoteGroupKey', 'STRING', 'contract_base', 'note_group_key', 'STRING', 'contract', 'note_group_key', 'INT', 14, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'RequirementGroupKey', 'STRING', 'contract_base', 'requirement_group_key', 'STRING', 'contract', 'requirement_group_key', 'INT', 15, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'ReinsuranceGroupKey', 'STRING', 'contract_base', 'reinsurance_group_key', 'STRING', 'contract', 'reinsurance_group_key', 'INT', 16, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'RecurringPaymentGroupKey', 'STRING', 'contract_base', 'recurring_payment_group_key', 'STRING', 'contract', 'recurring_payment_group_key', 'INT', 17, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'ApplicationReceivedDate', 'STRING', 'contract_base', 'application_received_timestamp', 'STRING', 'contract', 'application_received_timestamp', 'TIMESTAMP', 18, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'ApplicationSignedDate', 'STRING', 'contract_base', 'application_signed_timestamp', 'STRING', 'contract', 'application_signed_timestamp', 'TIMESTAMP', 19, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'EffectiveDate', 'STRING', 'contract_base', 'effective_timestamp', 'STRING', 'contract', 'effective_timestamp', 'TIMESTAMP', 20, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'IssueDate', 'STRING', 'contract_base', 'issue_timestamp', 'STRING', 'contract', 'issue_timestamp', 'TIMESTAMP', 21, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'IssueState', 'STRING', 'contract_base', 'issue_state_code', 'STRING', 'contract', 'issue_state_code', 'STRING', 22, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'IssueAge', 'STRING', 'contract_base', 'issue_age', 'STRING', 'contract', 'issue_age', 'INT', 23, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'AttainedAge', 'STRING', 'contract_base', 'attained_age', 'STRING', 'contract', 'attained_age', 'INT', 24, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'ContractStatus', 'STRING', 'contract_base', 'contract_status_code', 'STRING', 'contract', 'contract_status_code', 'STRING', 25, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'CostBasis', 'STRING', 'contract_base', 'cost_basis', 'STRING', 'contract', 'cost_basis', 'DECIMAL(18,4)', 26, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'RecoveredCostBasis', 'STRING', 'contract_base', 'recovered_cost_basis', 'STRING', 'contract', 'recovered_cost_basis', 'DECIMAL(18,4)', 27, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'QualInd', 'STRING', 'contract_base', 'qual_ind', 'STRING', 'contract', 'qual_ind', 'STRING', 28, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'QualType', 'STRING', 'contract_base', 'qual_type', 'STRING', 'contract', 'qual_type', 'STRING', 29, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'Option', 'STRING', 'contract_base', 'contract_option', 'STRING', 'contract', 'contract_option', 'STRING', 30, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'CertainPeriod', 'STRING', 'contract_base', 'certain_period', 'STRING', 'contract', 'certain_period', 'INT', 31, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'MECStatus', 'STRING', 'contract_base', 'mec_status_code', 'STRING', 'contract', 'mec_status_code', 'STRING', 32, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'RelatedContractNumber', 'STRING', 'contract_base', 'related_contract_number', 'STRING', 'contract', 'related_contract_number', 'STRING', 33, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'SpousalContinuationInd', 'STRING', 'contract_base', 'is_spousal_continuation', 'STRING', 'contract', 'is_spousal_continuation', 'BOOLEAN', 34, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'SupplementalContractInd', 'STRING', 'contract_base', 'is_supplemental_contract', 'STRING', 'contract', 'is_supplemental_contract', 'BOOLEAN', 35, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'QDROInd', 'STRING', 'contract_base', 'is_qdro', 'STRING', 'contract', 'is_qdro', 'BOOLEAN', 36, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'RiderClaimInd', 'STRING', 'contract_base', 'is_rider_claim', 'STRING', 'contract', 'is_rider_claim', 'BOOLEAN', 37, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'ROTHConversionInd', 'STRING', 'contract_base', 'is_roth_conversion', 'STRING', 'contract', 'is_roth_conversion', 'BOOLEAN', 38, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'InternalReplacementInd', 'STRING', 'contract_base', 'is_internal_replacement', 'STRING', 'contract', 'is_internal_replacement', 'BOOLEAN', 39, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'PartialTaxConversionInd', 'STRING', 'contract_base', 'is_partial_tax_conversion', 'STRING', 'contract', 'is_partial_tax_conversion', 'BOOLEAN', 40, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'WaiverInEffectInd', 'STRING', 'contract_base', 'is_waiver_in_effect', 'STRING', 'contract', 'is_waiver_in_effect', 'BOOLEAN', 41, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'EDeliveryInd', 'STRING', 'contract_base', 'is_e_delivery', 'STRING', 'contract', 'is_e_delivery', 'BOOLEAN', 42, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'ClassCode', 'STRING', 'contract_base', 'class_code', 'STRING', 'contract', 'class_code', 'STRING', 43, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'UnderwritingClass', 'STRING', 'contract_base', 'underwriting_class', 'STRING', 'contract', 'underwriting_class', 'STRING', 44, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'UnderwritingDate', 'STRING', 'contract_base', 'underwriting_timestamp', 'STRING', 'contract', 'underwriting_timestamp', 'TIMESTAMP', 45, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'CoverageRatio', 'STRING', 'contract_base', 'coverage_ratio', 'STRING', 'contract', 'coverage_ratio', 'DECIMAL(18,4)', 46, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'ContractEndDate', 'STRING', 'contract_base', 'contract_end_timestamp', 'STRING', 'contract', 'contract_end_timestamp', 'TIMESTAMP', 47, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'FundingCompanyFK', 'STRING', 'contract_base', 'funding_company_id', 'STRING', 'contract', 'funding_company_id', 'INT', 48, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'SourceKey', 'STRING', 'contract_base', 'source_key', 'STRING', 'contract', 'source_key', 'BIGINT', 49, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'StartDate', 'STRING', 'contract_base', 'start_timestamp', 'STRING', 'contract', 'start_timestamp', 'TIMESTAMP', 50, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_Warehouse', 'Contract', 'EndDate', 'STRING', 'contract_base', 'end_timestamp', 'STRING', 'contract', 'end_timestamp', 'TIMESTAMP', 51, 1, 0, 0, '3000-01-01', 1, GETUTCDATE());

-- ── [O01] ref_Product  (EQ_ODS.dbo — 9 cols, IDs 3001-3009) ────────────────
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_ODS', 'ref_Product', 'ProductPK', 'STRING', 'ref_product_base', 'product_id', 'STRING', 'ref_product', 'product_id', 'INT', 1, 0, 1, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'ref_Product', 'Product', 'STRING', 'ref_product_base', 'product_name', 'STRING', 'ref_product', 'product_name', 'STRING', 2, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'ref_Product', 'SecondSaleProduct', 'STRING', 'ref_product_base', 'is_second_sale', 'STRING', 'ref_product', 'is_second_sale', 'BOOLEAN', 3, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'ref_Product', 'ProductGroupName', 'STRING', 'ref_product_base', 'product_group_name', 'STRING', 'ref_product', 'product_group_name', 'STRING', 4, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'ref_Product', 'AgentCommStatmentAbbr', 'STRING', 'ref_product_base', 'agent_comm_statement_abbr', 'STRING', 'ref_product', 'agent_comm_statement_abbr', 'STRING', 5, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'ref_Product', 'GLAbbr', 'STRING', 'ref_product_base', 'gl_abbr', 'STRING', 'ref_product', 'gl_abbr', 'STRING', 6, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'ref_Product', 'GLLOB', 'STRING', 'ref_product_base', 'gl_line_of_business', 'STRING', 'ref_product', 'gl_line_of_business', 'STRING', 7, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'ref_Product', 'MarketingName', 'STRING', 'ref_product_base', 'marketing_name', 'STRING', 'ref_product', 'marketing_name', 'STRING', 8, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'ref_Product', 'CUSIPNumber', 'STRING', 'ref_product_base', 'cusip_number', 'STRING', 'ref_product', 'cusip_number', 'STRING', 9, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE());

-- ── [O02] ContractClient  (25 cols, IDs 3010-3034) ──────────────────────────
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_ODS', 'ContractClient', 'ContractClientPK', 'STRING', 'contract_client_base', 'contract_client_id', 'STRING', 'contract_client', 'contract_client_id', 'INT', 1, 0, 1, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'ContractClient', 'ClientRoleFK', 'STRING', 'contract_client_base', 'client_role_id', 'STRING', 'contract_client', 'client_role_id', 'INT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'ContractClient', 'SegmentFK', 'STRING', 'contract_client_base', 'segment_id', 'STRING', 'contract_client', 'segment_id', 'INT', 3, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'ContractClient', 'IssueAge', 'STRING', 'contract_client_base', 'issue_age', 'STRING', 'contract_client', 'issue_age', 'INT', 4, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'ContractClient', 'EffectiveDate', 'STRING', 'contract_client_base', 'effective_date', 'STRING', 'contract_client', 'effective_date', 'TIMESTAMP', 5, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_ODS', 'ContractClient', 'TerminationDate', 'STRING', 'contract_client_base', 'termination_date', 'STRING', 'contract_client', 'termination_date', 'TIMESTAMP', 6, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_ODS', 'ContractClient', 'RelationshipToInsuredCT', 'STRING', 'contract_client_base', 'relationship_to_insured_code', 'STRING', 'contract_client', 'relationship_to_insured_code', 'STRING', 7, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'ContractClient', 'TelephoneAuthorizationCT', 'STRING', 'contract_client_base', 'telephone_authorization_code', 'STRING', 'contract_client', 'telephone_authorization_code', 'STRING', 8, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'ContractClient', 'ClassCT', 'STRING', 'contract_client_base', 'class_code', 'STRING', 'contract_client', 'class_code', 'STRING', 9, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'ContractClient', 'FlatExtra', 'STRING', 'contract_client_base', 'flat_extra', 'STRING', 'contract_client', 'flat_extra', 'DECIMAL(18,4)', 10, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'ContractClient', 'FlatExtraAge', 'STRING', 'contract_client_base', 'flat_extra_age', 'STRING', 'contract_client', 'flat_extra_age', 'INT', 11, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'ContractClient', 'FlatExtraDur', 'STRING', 'contract_client_base', 'flat_extra_duration', 'STRING', 'contract_client', 'flat_extra_duration', 'INT', 12, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'ContractClient', 'PercentExtra', 'STRING', 'contract_client_base', 'percent_extra', 'STRING', 'contract_client', 'percent_extra', 'DECIMAL(18,4)', 13, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'ContractClient', 'PercentExtraAge', 'STRING', 'contract_client_base', 'percent_extra_age', 'STRING', 'contract_client', 'percent_extra_age', 'INT', 14, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'ContractClient', 'PercentExtraDur', 'STRING', 'contract_client_base', 'percent_extra_duration', 'STRING', 'contract_client', 'percent_extra_duration', 'INT', 15, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'ContractClient', 'TableRatingCT', 'STRING', 'contract_client_base', 'table_rating_code', 'STRING', 'contract_client', 'table_rating_code', 'STRING', 16, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'ContractClient', 'DisbursementAddressTypeCT', 'STRING', 'contract_client_base', 'disbursement_address_type_code', 'STRING', 'contract_client', 'disbursement_address_type_code', 'STRING', 17, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'ContractClient', 'CorrespondenceAddressTypeCT', 'STRING', 'contract_client_base', 'correspondence_address_type_code', 'STRING', 'contract_client', 'correspondence_address_type_code', 'STRING', 18, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'ContractClient', 'PendingClassChangeInd', 'STRING', 'contract_client_base', 'is_pending_class_change', 'STRING', 'contract_client', 'is_pending_class_change', 'BOOLEAN', 19, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'ContractClient', 'PayorOfCT', 'STRING', 'contract_client_base', 'payor_of_code', 'STRING', 'contract_client', 'payor_of_code', 'STRING', 20, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'ContractClient', 'RatedGenderCT', 'STRING', 'contract_client_base', 'rated_gender_code', 'STRING', 'contract_client', 'rated_gender_code', 'STRING', 21, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'ContractClient', 'UnderwritingClassCT', 'STRING', 'contract_client_base', 'underwriting_class_code', 'STRING', 'contract_client', 'underwriting_class_code', 'STRING', 22, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'ContractClient', 'TerminationReasonCT', 'STRING', 'contract_client_base', 'termination_reason_code', 'STRING', 'contract_client', 'termination_reason_code', 'STRING', 23, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'ContractClient', 'EDeliveryIndicator', 'STRING', 'contract_client_base', 'is_edelivery', 'STRING', 'contract_client', 'is_edelivery', 'BOOLEAN', 24, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'ContractClient', 'OverrideStatus', 'STRING', 'contract_client_base', 'override_status', 'STRING', 'contract_client', 'override_status', 'STRING', 25, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE());

-- ── [O03] ClientRole  (10 cols, IDs 3035-3044) ──────────────────────────────
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_ODS', 'ClientRole', 'ClientRolePK', 'STRING', 'client_role_base', 'client_role_id', 'STRING', 'client_role', 'client_role_id', 'INT', 1, 0, 1, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'ClientRole', 'ClientDetailFK', 'STRING', 'client_role_base', 'client_detail_id', 'STRING', 'client_role', 'client_detail_id', 'INT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'ClientRole', 'AgentFK', 'STRING', 'client_role_base', 'agent_id', 'STRING', 'client_role', 'agent_id', 'INT', 3, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'ClientRole', 'PreferenceFK', 'STRING', 'client_role_base', 'preference_id', 'STRING', 'client_role', 'preference_id', 'INT', 4, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'ClientRole', 'TaxProfileFK', 'STRING', 'client_role_base', 'tax_profile_id', 'STRING', 'client_role', 'tax_profile_id', 'INT', 5, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'ClientRole', 'RoleTypeCT', 'STRING', 'client_role_base', 'role_type_code', 'STRING', 'client_role', 'role_type_code', 'STRING', 6, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'ClientRole', 'NewIssuesEligibilityStatusCT', 'STRING', 'client_role_base', 'new_issues_eligibility_status_code', 'STRING', 'client_role', 'new_issues_eligibility_status_code', 'STRING', 7, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'ClientRole', 'NewIssuesEligibilityStartDate', 'STRING', 'client_role_base', 'new_issues_eligibility_start_date', 'STRING', 'client_role', 'new_issues_eligibility_start_date', 'TIMESTAMP', 8, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_ODS', 'ClientRole', 'ReferenceID', 'STRING', 'client_role_base', 'reference_id', 'STRING', 'client_role', 'reference_id', 'STRING', 9, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'ClientRole', 'OverrideStatus', 'STRING', 'client_role_base', 'override_status', 'STRING', 'client_role', 'override_status', 'STRING', 10, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE());

-- ── [O04] ClientDetail  (26 cols, IDs 3045-3070) ────────────────────────────
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_ODS', 'ClientDetail', 'ClientDetailPK', 'STRING', 'client_detail_base', 'client_detail_id', 'STRING', 'client_detail', 'client_detail_id', 'INT', 1, 0, 1, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'ClientDetail', 'ClientIdentification', 'STRING', 'client_detail_base', 'client_identification', 'STRING', 'client_detail', 'client_identification', 'STRING', 2, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'ClientDetail', 'TaxIdentification', 'STRING', 'client_detail_base', 'tax_identification', 'STRING', 'client_detail', 'tax_identification', 'STRING', 3, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'ClientDetail', 'LastName', 'STRING', 'client_detail_base', 'last_name', 'STRING', 'client_detail', 'last_name', 'STRING', 4, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'ClientDetail', 'FirstName', 'STRING', 'client_detail_base', 'first_name', 'STRING', 'client_detail', 'first_name', 'STRING', 5, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'ClientDetail', 'MiddleName', 'STRING', 'client_detail_base', 'middle_name', 'STRING', 'client_detail', 'middle_name', 'STRING', 6, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'ClientDetail', 'NamePrefix', 'STRING', 'client_detail_base', 'name_prefix', 'STRING', 'client_detail', 'name_prefix', 'STRING', 7, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'ClientDetail', 'NameSuffix', 'STRING', 'client_detail_base', 'name_suffix', 'STRING', 'client_detail', 'name_suffix', 'STRING', 8, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'ClientDetail', 'CorporateName', 'STRING', 'client_detail_base', 'corporate_name', 'STRING', 'client_detail', 'corporate_name', 'STRING', 9, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'ClientDetail', 'BirthDate', 'STRING', 'client_detail_base', 'birth_date', 'STRING', 'client_detail', 'birth_date', 'TIMESTAMP', 10, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_ODS', 'ClientDetail', 'MothersMaidenName', 'STRING', 'client_detail_base', 'mothers_maiden_name', 'STRING', 'client_detail', 'mothers_maiden_name', 'STRING', 11, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'ClientDetail', 'Occupation', 'STRING', 'client_detail_base', 'occupation', 'STRING', 'client_detail', 'occupation', 'STRING', 12, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'ClientDetail', 'DateOfDeath', 'STRING', 'client_detail_base', 'date_of_death', 'STRING', 'client_detail', 'date_of_death', 'TIMESTAMP', 13, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_ODS', 'ClientDetail', 'Operator', 'STRING', 'client_detail_base', 'operator', 'STRING', 'client_detail', 'operator', 'STRING', 14, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'ClientDetail', 'MaintDateTime', 'STRING', 'client_detail_base', 'maint_datetime', 'STRING', 'client_detail', 'maint_datetime', 'TIMESTAMP', 15, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_ODS', 'ClientDetail', 'GenderCT', 'STRING', 'client_detail_base', 'gender_code', 'STRING', 'client_detail', 'gender_code', 'STRING', 16, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'ClientDetail', 'TrustTypeCT', 'STRING', 'client_detail_base', 'trust_type_code', 'STRING', 'client_detail', 'trust_type_code', 'STRING', 17, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'ClientDetail', 'StatusCT', 'STRING', 'client_detail_base', 'status_code', 'STRING', 'client_detail', 'status_code', 'STRING', 18, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'ClientDetail', 'PrivacyInd', 'STRING', 'client_detail_base', 'is_privacy', 'STRING', 'client_detail', 'is_privacy', 'BOOLEAN', 19, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'ClientDetail', 'LastOFACCheckDate', 'STRING', 'client_detail_base', 'last_ofac_check_date', 'STRING', 'client_detail', 'last_ofac_check_date', 'TIMESTAMP', 20, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_ODS', 'ClientDetail', 'StateOfDeathCT', 'STRING', 'client_detail_base', 'state_of_death_code', 'STRING', 'client_detail', 'state_of_death_code', 'STRING', 21, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'ClientDetail', 'ResidentStateAtDeathCT', 'STRING', 'client_detail_base', 'resident_state_at_death_code', 'STRING', 'client_detail', 'resident_state_at_death_code', 'STRING', 22, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'ClientDetail', 'ProofOfDeathReceivedDate', 'STRING', 'client_detail_base', 'proof_of_death_received_date', 'STRING', 'client_detail', 'proof_of_death_received_date', 'TIMESTAMP', 23, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_ODS', 'ClientDetail', 'CaseTrackingProcess', 'STRING', 'client_detail_base', 'case_tracking_process', 'STRING', 'client_detail', 'case_tracking_process', 'STRING', 24, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'ClientDetail', 'NotificationReceivedDate', 'STRING', 'client_detail_base', 'notification_received_date', 'STRING', 'client_detail', 'notification_received_date', 'TIMESTAMP', 25, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_ODS', 'ClientDetail', 'OverrideStatus', 'STRING', 'client_detail_base', 'override_status', 'STRING', 'client_detail', 'override_status', 'STRING', 26, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE());

-- ── [O05] ContractClientAllocation  (6 cols, IDs 3071-3076) ─────────────────
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_ODS', 'ContractClientAllocation', 'ContractClientAllocationPK', 'STRING', 'contract_client_allocation_base', 'contract_client_allocation_id', 'STRING', 'contract_client_allocation', 'contract_client_allocation_id', 'INT', 1, 0, 1, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'ContractClientAllocation', 'ContractClientFK', 'STRING', 'contract_client_allocation_base', 'contract_client_id', 'STRING', 'contract_client_allocation', 'contract_client_id', 'INT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'ContractClientAllocation', 'AllocationPercent', 'STRING', 'contract_client_allocation_base', 'allocation_percent', 'STRING', 'contract_client_allocation', 'allocation_percent', 'DECIMAL(18,4)', 3, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'ContractClientAllocation', 'AllocationDollars', 'STRING', 'contract_client_allocation_base', 'allocation_dollars', 'STRING', 'contract_client_allocation', 'allocation_dollars', 'DECIMAL(18,4)', 4, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'ContractClientAllocation', 'SplitEqual', 'STRING', 'contract_client_allocation_base', 'is_split_equal', 'STRING', 'contract_client_allocation', 'is_split_equal', 'BOOLEAN', 5, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'ContractClientAllocation', 'OverrideStatus', 'STRING', 'contract_client_allocation_base', 'override_status', 'STRING', 'contract_client_allocation', 'override_status', 'STRING', 6, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE());

-- ── [O06] Segment  (73 cols, IDs 3077-3149) ─────────────────────────────────
-- Source for both vw_SEG_ContractPrimarySegment (SegmentFK IS NULL) and
-- vw_SEG_ContractRiderSegment (SegmentFK IS NOT NULL) — same table, different filters.
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_ODS', 'Segment', 'SegmentPK', 'STRING', 'segment_base', 'segment_id', 'STRING', 'segment', 'segment_id', 'INT', 1, 0, 1, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'Segment', 'SegmentFK', 'STRING', 'segment_base', 'parent_segment_id', 'STRING', 'segment', 'parent_segment_id', 'INT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'Segment', 'ProductStructureFK', 'STRING', 'segment_base', 'product_structure_id', 'STRING', 'segment', 'product_structure_id', 'INT', 3, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'Segment', 'ContractNumber', 'STRING', 'segment_base', 'contract_number', 'STRING', 'segment', 'contract_number', 'STRING', 4, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'Segment', 'EffectiveDate', 'STRING', 'segment_base', 'effective_date', 'STRING', 'segment', 'effective_date', 'TIMESTAMP', 5, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_ODS', 'Segment', 'Amount', 'STRING', 'segment_base', 'amount', 'STRING', 'segment', 'amount', 'DECIMAL(18,4)', 6, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'Segment', 'QualNonQualCT', 'STRING', 'segment_base', 'qual_non_qual_code', 'STRING', 'segment', 'qual_non_qual_code', 'STRING', 7, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'Segment', 'ExchangeInd', 'STRING', 'segment_base', 'is_exchange', 'STRING', 'segment', 'is_exchange', 'BOOLEAN', 8, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'Segment', 'CostBasis', 'STRING', 'segment_base', 'cost_basis', 'STRING', 'segment', 'cost_basis', 'DECIMAL(18,4)', 9, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'Segment', 'RecoveredCostBasis', 'STRING', 'segment_base', 'recovered_cost_basis', 'STRING', 'segment', 'recovered_cost_basis', 'DECIMAL(18,4)', 10, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'Segment', 'TerminationDate', 'STRING', 'segment_base', 'termination_date', 'STRING', 'segment', 'termination_date', 'TIMESTAMP', 11, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_ODS', 'Segment', 'StatusChangeDate', 'STRING', 'segment_base', 'status_change_date', 'STRING', 'segment', 'status_change_date', 'TIMESTAMP', 12, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_ODS', 'Segment', 'SegmentNameCT', 'STRING', 'segment_base', 'segment_name_code', 'STRING', 'segment', 'segment_name_code', 'STRING', 13, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'Segment', 'SegmentStatusCT', 'STRING', 'segment_base', 'segment_status_code', 'STRING', 'segment', 'segment_status_code', 'STRING', 14, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'Segment', 'OptionCodeCT', 'STRING', 'segment_base', 'option_code', 'STRING', 'segment', 'option_code', 'STRING', 15, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'Segment', 'IssueStateCT', 'STRING', 'segment_base', 'issue_state_code', 'STRING', 'segment', 'issue_state_code', 'STRING', 16, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'Segment', 'QualifiedTypeCT', 'STRING', 'segment_base', 'qualified_type_code', 'STRING', 'segment', 'qualified_type_code', 'STRING', 17, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'Segment', 'QuoteDate', 'STRING', 'segment_base', 'quote_date', 'STRING', 'segment', 'quote_date', 'TIMESTAMP', 18, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_ODS', 'Segment', 'Charges', 'STRING', 'segment_base', 'charges', 'STRING', 'segment', 'charges', 'DECIMAL(18,4)', 19, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'Segment', 'Loads', 'STRING', 'segment_base', 'loads', 'STRING', 'segment', 'loads', 'DECIMAL(18,4)', 20, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'Segment', 'Fees', 'STRING', 'segment_base', 'fees', 'STRING', 'segment', 'fees', 'DECIMAL(18,4)', 21, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'Segment', 'TaxReportingGroup', 'STRING', 'segment_base', 'tax_reporting_group', 'STRING', 'segment', 'tax_reporting_group', 'STRING', 22, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'Segment', 'IssueDate', 'STRING', 'segment_base', 'issue_date', 'STRING', 'segment', 'issue_date', 'TIMESTAMP', 23, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_ODS', 'Segment', 'CashWithAppInd', 'STRING', 'segment_base', 'is_cash_with_app', 'STRING', 'segment', 'is_cash_with_app', 'BOOLEAN', 24, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'Segment', 'WaiverInEffect', 'STRING', 'segment_base', 'is_waiver_in_effect', 'STRING', 'segment', 'is_waiver_in_effect', 'BOOLEAN', 25, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'Segment', 'FreeAmountRemaining', 'STRING', 'segment_base', 'free_amount_remaining', 'STRING', 'segment', 'free_amount_remaining', 'DECIMAL(18,4)', 26, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'Segment', 'FreeAmount', 'STRING', 'segment_base', 'free_amount', 'STRING', 'segment', 'free_amount', 'DECIMAL(18,4)', 27, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'Segment', 'DateInEffect', 'STRING', 'segment_base', 'date_in_effect', 'STRING', 'segment', 'date_in_effect', 'TIMESTAMP', 28, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_ODS', 'Segment', 'CreationOperator', 'STRING', 'segment_base', 'creation_operator', 'STRING', 'segment', 'creation_operator', 'STRING', 29, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'Segment', 'CreationDate', 'STRING', 'segment_base', 'creation_date', 'STRING', 'segment', 'creation_date', 'TIMESTAMP', 30, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_ODS', 'Segment', 'LastAnniversaryDate', 'STRING', 'segment_base', 'last_anniversary_date', 'STRING', 'segment', 'last_anniversary_date', 'TIMESTAMP', 31, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_ODS', 'Segment', 'ApplicationSignedDate', 'STRING', 'segment_base', 'application_signed_date', 'STRING', 'segment', 'application_signed_date', 'TIMESTAMP', 32, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_ODS', 'Segment', 'ApplicationReceivedDate', 'STRING', 'segment_base', 'application_received_date', 'STRING', 'segment', 'application_received_date', 'TIMESTAMP', 33, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_ODS', 'Segment', 'SavingsPercent', 'STRING', 'segment_base', 'savings_percent', 'STRING', 'segment', 'savings_percent', 'DECIMAL(18,4)', 34, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'Segment', 'AnnualInsuranceAmount', 'STRING', 'segment_base', 'annual_insurance_amount', 'STRING', 'segment', 'annual_insurance_amount', 'DECIMAL(18,4)', 35, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'Segment', 'AnnualInvestmentAmount', 'STRING', 'segment_base', 'annual_investment_amount', 'STRING', 'segment', 'annual_investment_amount', 'DECIMAL(18,4)', 36, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'Segment', 'DismembermentPercent', 'STRING', 'segment_base', 'dismemberment_percent', 'STRING', 'segment', 'dismemberment_percent', 'DECIMAL(18,4)', 37, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'Segment', 'PolicyDeliveryDate', 'STRING', 'segment_base', 'policy_delivery_date', 'STRING', 'segment', 'policy_delivery_date', 'TIMESTAMP', 38, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_ODS', 'Segment', 'WaiveFreeLookIndicator', 'STRING', 'segment_base', 'is_waive_free_look', 'STRING', 'segment', 'is_waive_free_look', 'BOOLEAN', 39, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'Segment', 'FreeLookDaysOverride', 'STRING', 'segment_base', 'free_look_days_override', 'STRING', 'segment', 'free_look_days_override', 'INT', 40, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'Segment', 'FreeLookEndDate', 'STRING', 'segment_base', 'free_look_end_date', 'STRING', 'segment', 'free_look_end_date', 'TIMESTAMP', 41, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_ODS', 'Segment', 'PointInScaleIndicator', 'STRING', 'segment_base', 'is_point_in_scale', 'STRING', 'segment', 'is_point_in_scale', 'BOOLEAN', 42, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'Segment', 'ChargeDeductDivisionInd', 'STRING', 'segment_base', 'is_charge_deduct_division', 'STRING', 'segment', 'is_charge_deduct_division', 'BOOLEAN', 43, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'Segment', 'DialableSalesLoadPercentage', 'STRING', 'segment_base', 'dialable_sales_load_percentage', 'STRING', 'segment', 'dialable_sales_load_percentage', 'DECIMAL(18,4)', 44, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'Segment', 'ChargeDeductAmount', 'STRING', 'segment_base', 'charge_deduct_amount', 'STRING', 'segment', 'charge_deduct_amount', 'DECIMAL(18,4)', 45, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'Segment', 'RiderNumber', 'STRING', 'segment_base', 'rider_number', 'STRING', 'segment', 'rider_number', 'INT', 46, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'Segment', 'CommitmentIndicator', 'STRING', 'segment_base', 'is_commitment', 'STRING', 'segment', 'is_commitment', 'BOOLEAN', 47, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'Segment', 'CommitmentAmount', 'STRING', 'segment_base', 'commitment_amount', 'STRING', 'segment', 'commitment_amount', 'DECIMAL(18,4)', 48, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'Segment', 'ChargeCodeStatus', 'STRING', 'segment_base', 'charge_code_status', 'STRING', 'segment', 'charge_code_status', 'STRING', 49, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'Segment', 'ROTHConvInd', 'STRING', 'segment_base', 'is_roth_conversion', 'STRING', 'segment', 'is_roth_conversion', 'BOOLEAN', 50, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'Segment', 'DateOfDeathValue', 'STRING', 'segment_base', 'date_of_death_value', 'STRING', 'segment', 'date_of_death_value', 'DECIMAL(18,4)', 51, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'Segment', 'SuppOriginalContractNumber', 'STRING', 'segment_base', 'supp_original_contract_number', 'STRING', 'segment', 'supp_original_contract_number', 'STRING', 52, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'Segment', 'OpenClaimEndDate', 'STRING', 'segment_base', 'open_claim_end_date', 'STRING', 'segment', 'open_claim_end_date', 'TIMESTAMP', 53, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_ODS', 'Segment', 'AnnuitizationValue', 'STRING', 'segment_base', 'annuitization_value', 'STRING', 'segment', 'annuitization_value', 'DECIMAL(18,4)', 54, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'Segment', 'CasetrackingOptionCT', 'STRING', 'segment_base', 'casetracking_option_code', 'STRING', 'segment', 'casetracking_option_code', 'STRING', 55, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'Segment', 'PrintLine1', 'STRING', 'segment_base', 'print_line_1', 'STRING', 'segment', 'print_line_1', 'STRING', 56, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'Segment', 'PrintLine2', 'STRING', 'segment_base', 'print_line_2', 'STRING', 'segment', 'print_line_2', 'STRING', 57, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'Segment', 'TotalActiveBeneficiaries', 'STRING', 'segment_base', 'total_active_beneficiaries', 'STRING', 'segment', 'total_active_beneficiaries', 'INT', 58, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'Segment', 'RemainingBeneficiaries', 'STRING', 'segment_base', 'remaining_beneficiaries', 'STRING', 'segment', 'remaining_beneficiaries', 'INT', 59, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'Segment', 'SettlementAmount', 'STRING', 'segment_base', 'settlement_amount', 'STRING', 'segment', 'settlement_amount', 'DECIMAL(18,4)', 60, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'Segment', 'LastSettlementValDate', 'STRING', 'segment_base', 'last_settlement_val_date', 'STRING', 'segment', 'last_settlement_val_date', 'TIMESTAMP', 61, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_ODS', 'Segment', 'ContractTypeCT', 'STRING', 'segment_base', 'contract_type_code', 'STRING', 'segment', 'contract_type_code', 'STRING', 62, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'Segment', 'TotalFaceAmount', 'STRING', 'segment_base', 'total_face_amount', 'STRING', 'segment', 'total_face_amount', 'DECIMAL(18,4)', 63, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'Segment', 'IncomeStartDate', 'STRING', 'segment_base', 'income_start_date', 'STRING', 'segment', 'income_start_date', 'TIMESTAMP', 64, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_ODS', 'Segment', 'IncomeStartAge', 'STRING', 'segment_base', 'income_start_age', 'STRING', 'segment', 'income_start_age', 'INT', 65, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'Segment', 'ExtendedIncomePeriodDate', 'STRING', 'segment_base', 'extended_income_period_date', 'STRING', 'segment', 'extended_income_period_date', 'TIMESTAMP', 66, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_ODS', 'Segment', 'BenefitBase', 'STRING', 'segment_base', 'benefit_base', 'STRING', 'segment', 'benefit_base', 'DECIMAL(18,4)', 67, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'Segment', 'BenefitBaseLastValDate', 'STRING', 'segment_base', 'benefit_base_last_val_date', 'STRING', 'segment', 'benefit_base_last_val_date', 'TIMESTAMP', 68, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_ODS', 'Segment', 'IncomeWDAmount', 'STRING', 'segment_base', 'income_wd_amount', 'STRING', 'segment', 'income_wd_amount', 'DECIMAL(18,4)', 69, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'Segment', 'RemainingIncomeWDAmount', 'STRING', 'segment_base', 'remaining_income_wd_amount', 'STRING', 'segment', 'remaining_income_wd_amount', 'DECIMAL(18,4)', 70, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'Segment', 'SysGainAccum', 'STRING', 'segment_base', 'sys_gain_accum', 'STRING', 'segment', 'sys_gain_accum', 'DECIMAL(18,4)', 71, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'Segment', 'BillScheduleFK', 'STRING', 'segment_base', 'bill_schedule_id', 'STRING', 'segment', 'bill_schedule_id', 'INT', 72, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'Segment', 'FirstNotifyDate', 'STRING', 'segment_base', 'first_notify_date', 'STRING', 'segment', 'first_notify_date', 'TIMESTAMP', 73, 1, 0, 0, '3000-01-01', 1, GETUTCDATE());

-- ── [O07] Agent (ODS)  (18 cols, IDs 3150-3167) ─────────────────────────────
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_ODS', 'Agent', 'AgentPK', 'STRING', 'agent_ods_base', 'agent_id', 'STRING', 'agent_ods', 'agent_id', 'INT', 1, 0, 1, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'Agent', 'CompanyFK', 'STRING', 'agent_ods_base', 'company_id', 'STRING', 'agent_ods', 'company_id', 'INT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'Agent', 'HireDate', 'STRING', 'agent_ods_base', 'hire_date', 'STRING', 'agent_ods', 'hire_date', 'TIMESTAMP', 3, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_ODS', 'Agent', 'TerminationDate', 'STRING', 'agent_ods_base', 'termination_date', 'STRING', 'agent_ods', 'termination_date', 'TIMESTAMP', 4, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_ODS', 'Agent', 'AgentStatusCT', 'STRING', 'agent_ods_base', 'agent_status_code', 'STRING', 'agent_ods', 'agent_status_code', 'STRING', 5, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'Agent', 'AgentTypeCT', 'STRING', 'agent_ods_base', 'agent_type_code', 'STRING', 'agent_ods', 'agent_type_code', 'STRING', 6, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'Agent', 'WithholdingStatus', 'STRING', 'agent_ods_base', 'withholding_status', 'STRING', 'agent_ods', 'withholding_status', 'STRING', 7, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'Agent', 'Department', 'STRING', 'agent_ods_base', 'department', 'STRING', 'agent_ods', 'department', 'STRING', 8, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'Agent', 'Region', 'STRING', 'agent_ods_base', 'region', 'STRING', 'agent_ods', 'region', 'STRING', 9, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'Agent', 'Branch', 'STRING', 'agent_ods_base', 'branch', 'STRING', 'agent_ods', 'branch', 'STRING', 10, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'Agent', 'NPN', 'STRING', 'agent_ods_base', 'npn', 'STRING', 'agent_ods', 'npn', 'STRING', 11, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'Agent', 'IntDebitBalStatusCT', 'STRING', 'agent_ods_base', 'int_debit_bal_status_code', 'STRING', 'agent_ods', 'int_debit_bal_status_code', 'STRING', 12, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'Agent', 'HoldCommStatus', 'STRING', 'agent_ods_base', 'hold_comm_status', 'STRING', 'agent_ods', 'hold_comm_status', 'STRING', 13, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'Agent', 'Operator', 'STRING', 'agent_ods_base', 'operator', 'STRING', 'agent_ods', 'operator', 'STRING', 14, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'Agent', 'MaintDateTime', 'STRING', 'agent_ods_base', 'maint_datetime', 'STRING', 'agent_ods', 'maint_datetime', 'TIMESTAMP', 15, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_ODS', 'Agent', 'DisbursementAddressTypeCT', 'STRING', 'agent_ods_base', 'disbursement_address_type_code', 'STRING', 'agent_ods', 'disbursement_address_type_code', 'STRING', 16, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'Agent', 'CorrespondenceAddressTypeCT', 'STRING', 'agent_ods_base', 'correspondence_address_type_code', 'STRING', 'agent_ods', 'correspondence_address_type_code', 'STRING', 17, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'Agent', 'RehireEligibleDate', 'STRING', 'agent_ods_base', 'rehire_eligible_date', 'STRING', 'agent_ods', 'rehire_eligible_date', 'TIMESTAMP', 18, 1, 0, 0, '3000-01-01', 1, GETUTCDATE());

-- ── [O08] ContractTreaty  (20 cols, IDs 3168-3187) ──────────────────────────
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_ODS', 'ContractTreaty', 'ContractTreatyPK', 'STRING', 'contract_treaty_base', 'contract_treaty_id', 'STRING', 'contract_treaty', 'contract_treaty_id', 'INT', 1, 0, 1, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'ContractTreaty', 'SegmentFK', 'STRING', 'contract_treaty_base', 'segment_id', 'STRING', 'contract_treaty', 'segment_id', 'INT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'ContractTreaty', 'TreatyFK', 'STRING', 'contract_treaty_base', 'treaty_id', 'STRING', 'contract_treaty', 'treaty_id', 'INT', 3, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'ContractTreaty', 'ReinsuranceIndicatorCT', 'STRING', 'contract_treaty_base', 'reinsurance_indicator_code', 'STRING', 'contract_treaty', 'reinsurance_indicator_code', 'STRING', 4, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'ContractTreaty', 'EffectiveDate', 'STRING', 'contract_treaty_base', 'effective_date', 'STRING', 'contract_treaty', 'effective_date', 'TIMESTAMP', 5, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_ODS', 'ContractTreaty', 'ReinsuranceClassCT', 'STRING', 'contract_treaty_base', 'reinsurance_class_code', 'STRING', 'contract_treaty', 'reinsurance_class_code', 'STRING', 6, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'ContractTreaty', 'RetentionAmount', 'STRING', 'contract_treaty_base', 'retention_amount', 'STRING', 'contract_treaty', 'retention_amount', 'DECIMAL(18,4)', 7, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'ContractTreaty', 'PoolPercentage', 'STRING', 'contract_treaty_base', 'pool_percentage', 'STRING', 'contract_treaty', 'pool_percentage', 'DECIMAL(18,4)', 8, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'ContractTreaty', 'ReinsuranceTypeCT', 'STRING', 'contract_treaty_base', 'reinsurance_type_code', 'STRING', 'contract_treaty', 'reinsurance_type_code', 'STRING', 9, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'ContractTreaty', 'TableRatingCT', 'STRING', 'contract_treaty_base', 'table_rating_code', 'STRING', 'contract_treaty', 'table_rating_code', 'STRING', 10, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'ContractTreaty', 'FlatExtra', 'STRING', 'contract_treaty_base', 'flat_extra', 'STRING', 'contract_treaty', 'flat_extra', 'DECIMAL(18,4)', 11, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'ContractTreaty', 'FlatExtraAge', 'STRING', 'contract_treaty_base', 'flat_extra_age', 'STRING', 'contract_treaty', 'flat_extra_age', 'INT', 12, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'ContractTreaty', 'FlatExtraDuration', 'STRING', 'contract_treaty_base', 'flat_extra_duration', 'STRING', 'contract_treaty', 'flat_extra_duration', 'INT', 13, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'ContractTreaty', 'PercentExtra', 'STRING', 'contract_treaty_base', 'percent_extra', 'STRING', 'contract_treaty', 'percent_extra', 'DECIMAL(18,4)', 14, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'ContractTreaty', 'PercentExtraAge', 'STRING', 'contract_treaty_base', 'percent_extra_age', 'STRING', 'contract_treaty', 'percent_extra_age', 'INT', 15, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'ContractTreaty', 'PercentExtraDuration', 'STRING', 'contract_treaty_base', 'percent_extra_duration', 'STRING', 'contract_treaty', 'percent_extra_duration', 'INT', 16, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'ContractTreaty', 'MaxReinsuranceAmount', 'STRING', 'contract_treaty_base', 'max_reinsurance_amount', 'STRING', 'contract_treaty', 'max_reinsurance_amount', 'DECIMAL(18,4)', 17, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'ContractTreaty', 'TreatyOverrideInd', 'STRING', 'contract_treaty_base', 'is_treaty_override', 'STRING', 'contract_treaty', 'is_treaty_override', 'BOOLEAN', 18, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'ContractTreaty', 'PolicyOverrideInd', 'STRING', 'contract_treaty_base', 'is_policy_override', 'STRING', 'contract_treaty', 'is_policy_override', 'BOOLEAN', 19, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'ContractTreaty', 'Status', 'STRING', 'contract_treaty_base', 'status', 'STRING', 'contract_treaty', 'status', 'STRING', 20, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE());

-- ── [O09] Treaty  (10 cols, IDs 3188-3197) ──────────────────────────────────
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_ODS', 'Treaty', 'TreatyPK', 'STRING', 'treaty_base', 'treaty_id', 'STRING', 'treaty', 'treaty_id', 'INT', 1, 0, 1, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'Treaty', 'TreatyGroupFK', 'STRING', 'treaty_base', 'treaty_group_id', 'STRING', 'treaty', 'treaty_group_id', 'INT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'Treaty', 'StartDate', 'STRING', 'treaty_base', 'start_date', 'STRING', 'treaty', 'start_date', 'TIMESTAMP', 3, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_ODS', 'Treaty', 'StopDate', 'STRING', 'treaty_base', 'stop_date', 'STRING', 'treaty', 'stop_date', 'TIMESTAMP', 4, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_ODS', 'Treaty', 'SettlementPeriod', 'STRING', 'treaty_base', 'settlement_period', 'STRING', 'treaty', 'settlement_period', 'INT', 5, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'Treaty', 'PaymentModeCT', 'STRING', 'treaty_base', 'payment_mode_code', 'STRING', 'treaty', 'payment_mode_code', 'STRING', 6, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'Treaty', 'CalculationModeCT', 'STRING', 'treaty_base', 'calculation_mode_code', 'STRING', 'treaty', 'calculation_mode_code', 'STRING', 7, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'Treaty', 'LastCheckDate', 'STRING', 'treaty_base', 'last_check_date', 'STRING', 'treaty', 'last_check_date', 'TIMESTAMP', 8, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_ODS', 'Treaty', 'ReinsurerBalance', 'STRING', 'treaty_base', 'reinsurer_balance', 'STRING', 'treaty', 'reinsurer_balance', 'DECIMAL(18,4)', 9, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'Treaty', 'CoinsurancePercentage', 'STRING', 'treaty_base', 'coinsurance_percentage', 'STRING', 'treaty', 'coinsurance_percentage', 'DECIMAL(18,4)', 10, 1, 0, 0, '0', 1, GETUTCDATE());

-- ── [O10] TreatyGroup  (2 cols, IDs 3198-3199) ──────────────────────────────
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_ODS', 'TreatyGroup', 'TreatyGroupPK', 'STRING', 'treaty_group_base', 'treaty_group_id', 'STRING', 'treaty_group', 'treaty_group_id', 'INT', 1, 0, 1, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'TreatyGroup', 'TreatyGroupNumber', 'STRING', 'treaty_group_base', 'treaty_group_number', 'STRING', 'treaty_group', 'treaty_group_number', 'STRING', 2, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE());

-- ── [O11] EDITTrx  (38 cols, IDs 3200-3237) ─────────────────────────────────
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_ODS', 'EDITTrx', 'EDITTrxPK', 'STRING', 'edit_trx_base', 'edit_trx_id', 'STRING', 'edit_trx', 'edit_trx_id', 'BIGINT', 1, 0, 1, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'EDITTrx', 'ClientSetupFK', 'STRING', 'edit_trx_base', 'client_setup_id', 'STRING', 'edit_trx', 'client_setup_id', 'INT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'EDITTrx', 'EffectiveDate', 'STRING', 'edit_trx_base', 'effective_date', 'STRING', 'edit_trx', 'effective_date', 'TIMESTAMP', 3, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_ODS', 'EDITTrx', 'Status', 'STRING', 'edit_trx_base', 'status', 'STRING', 'edit_trx', 'status', 'STRING', 4, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'EDITTrx', 'PendingStatus', 'STRING', 'edit_trx_base', 'pending_status', 'STRING', 'edit_trx', 'pending_status', 'STRING', 5, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'EDITTrx', 'SequenceNumber', 'STRING', 'edit_trx_base', 'sequence_number', 'STRING', 'edit_trx', 'sequence_number', 'INT', 6, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'EDITTrx', 'TaxYear', 'STRING', 'edit_trx_base', 'tax_year', 'STRING', 'edit_trx', 'tax_year', 'INT', 7, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'EDITTrx', 'TrxAmount', 'STRING', 'edit_trx_base', 'trx_amount', 'STRING', 'edit_trx', 'trx_amount', 'DECIMAL(18,4)', 8, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'EDITTrx', 'DueDate', 'STRING', 'edit_trx_base', 'due_date', 'STRING', 'edit_trx', 'due_date', 'TIMESTAMP', 9, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_ODS', 'EDITTrx', 'TransactionTypeCT', 'STRING', 'edit_trx_base', 'transaction_type_code', 'STRING', 'edit_trx', 'transaction_type_code', 'STRING', 10, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'EDITTrx', 'TrxIsRescheduledInd', 'STRING', 'edit_trx_base', 'is_trx_rescheduled', 'STRING', 'edit_trx', 'is_trx_rescheduled', 'BOOLEAN', 11, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'EDITTrx', 'ReapplyEDITTrxFK', 'STRING', 'edit_trx_base', 'reapply_edit_trx_id', 'STRING', 'edit_trx', 'reapply_edit_trx_id', 'BIGINT', 12, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'EDITTrx', 'CommissionStatus', 'STRING', 'edit_trx_base', 'commission_status', 'STRING', 'edit_trx', 'commission_status', 'STRING', 13, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'EDITTrx', 'LookBackInd', 'STRING', 'edit_trx_base', 'is_look_back', 'STRING', 'edit_trx', 'is_look_back', 'BOOLEAN', 14, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'EDITTrx', 'OriginatingTrxFK', 'STRING', 'edit_trx_base', 'originating_trx_id', 'STRING', 'edit_trx', 'originating_trx_id', 'BIGINT', 15, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'EDITTrx', 'NoCorrespondenceInd', 'STRING', 'edit_trx_base', 'is_no_correspondence', 'STRING', 'edit_trx', 'is_no_correspondence', 'BOOLEAN', 16, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'EDITTrx', 'NoAccountingInd', 'STRING', 'edit_trx_base', 'is_no_accounting', 'STRING', 'edit_trx', 'is_no_accounting', 'BOOLEAN', 17, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'EDITTrx', 'NoCommissionInd', 'STRING', 'edit_trx_base', 'is_no_commission', 'STRING', 'edit_trx', 'is_no_commission', 'BOOLEAN', 18, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'EDITTrx', 'MaintDateTime', 'STRING', 'edit_trx_base', 'maint_datetime', 'STRING', 'edit_trx', 'maint_datetime', 'TIMESTAMP', 19, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_ODS', 'EDITTrx', 'Operator', 'STRING', 'edit_trx_base', 'operator', 'STRING', 'edit_trx', 'operator', 'STRING', 20, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'EDITTrx', 'NotificationAmount', 'STRING', 'edit_trx_base', 'notification_amount', 'STRING', 'edit_trx', 'notification_amount', 'DECIMAL(18,4)', 21, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'EDITTrx', 'NotificationAmountReceived', 'STRING', 'edit_trx_base', 'notification_amount_received', 'STRING', 'edit_trx', 'notification_amount_received', 'DECIMAL(18,4)', 22, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'EDITTrx', 'TransferTypeCT', 'STRING', 'edit_trx_base', 'transfer_type_code', 'STRING', 'edit_trx', 'transfer_type_code', 'STRING', 23, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'EDITTrx', 'AdvanceNotificationOverride', 'STRING', 'edit_trx_base', 'advance_notification_override', 'STRING', 'edit_trx', 'advance_notification_override', 'INT', 24, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'EDITTrx', 'AccountingPeriod', 'STRING', 'edit_trx_base', 'accounting_period', 'STRING', 'edit_trx', 'accounting_period', 'STRING', 25, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'EDITTrx', 'ReinsuranceStatus', 'STRING', 'edit_trx_base', 'reinsurance_status', 'STRING', 'edit_trx', 'reinsurance_status', 'STRING', 26, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'EDITTrx', 'BonusCommissionAmount', 'STRING', 'edit_trx_base', 'bonus_commission_amount', 'STRING', 'edit_trx', 'bonus_commission_amount', 'DECIMAL(18,4)', 27, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'EDITTrx', 'ExcessBonusCommissionAmount', 'STRING', 'edit_trx_base', 'excess_bonus_commission_amount', 'STRING', 'edit_trx', 'excess_bonus_commission_amount', 'DECIMAL(18,4)', 28, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'EDITTrx', 'DateContributionExcess', 'STRING', 'edit_trx_base', 'date_contribution_excess', 'STRING', 'edit_trx', 'date_contribution_excess', 'TIMESTAMP', 29, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_ODS', 'EDITTrx', 'TransferUnitsType', 'STRING', 'edit_trx_base', 'transfer_units_type', 'STRING', 'edit_trx', 'transfer_units_type', 'STRING', 30, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'EDITTrx', 'NoCheckEFT', 'STRING', 'edit_trx_base', 'is_no_check_eft', 'STRING', 'edit_trx', 'is_no_check_eft', 'BOOLEAN', 31, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'EDITTrx', 'InterestProceedsOverride', 'STRING', 'edit_trx_base', 'interest_proceeds_override', 'STRING', 'edit_trx', 'interest_proceeds_override', 'DECIMAL(18,4)', 32, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'EDITTrx', 'NewPolicyNumber', 'STRING', 'edit_trx_base', 'new_policy_number', 'STRING', 'edit_trx', 'new_policy_number', 'STRING', 33, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'EDITTrx', 'ReversalReasonCodeCT', 'STRING', 'edit_trx_base', 'reversal_reason_code', 'STRING', 'edit_trx', 'reversal_reason_code', 'STRING', 34, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'EDITTrx', 'CheckAdjustmentFK', 'STRING', 'edit_trx_base', 'check_adjustment_id', 'STRING', 'edit_trx', 'check_adjustment_id', 'INT', 35, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'EDITTrx', 'TrxPercent', 'STRING', 'edit_trx_base', 'trx_percent', 'STRING', 'edit_trx', 'trx_percent', 'DECIMAL(18,4)', 36, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'EDITTrx', 'OriginalAccountingPeriod', 'STRING', 'edit_trx_base', 'original_accounting_period', 'STRING', 'edit_trx', 'original_accounting_period', 'STRING', 37, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'EDITTrx', 'BGA', 'STRING', 'edit_trx_base', 'bga', 'STRING', 'edit_trx', 'bga', 'STRING', 38, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE());

-- ── [O12] ClientSetup  (4 cols, IDs 3238-3241) ──────────────────────────────
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_ODS', 'ClientSetup', 'ClientSetupPK', 'STRING', 'client_setup_base', 'client_setup_id', 'STRING', 'client_setup', 'client_setup_id', 'INT', 1, 0, 1, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'ClientSetup', 'ClientRoleFK', 'STRING', 'client_setup_base', 'client_role_id', 'STRING', 'client_setup', 'client_role_id', 'INT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'ClientSetup', 'ContractSetupFK', 'STRING', 'client_setup_base', 'contract_setup_id', 'STRING', 'client_setup', 'contract_setup_id', 'INT', 3, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'ClientSetup', 'ContractClientFK', 'STRING', 'client_setup_base', 'contract_client_id', 'STRING', 'client_setup', 'contract_client_id', 'INT', 4, 1, 0, 0, '0', 1, GETUTCDATE());

-- ── [O13] EDITTrxHistory  (13 cols, IDs 3242-3254) ──────────────────────────
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_ODS', 'EDITTrxHistory', 'EDITTrxHistoryPK', 'STRING', 'edit_trx_history_base', 'edit_trx_history_id', 'STRING', 'edit_trx_history', 'edit_trx_history_id', 'BIGINT', 1, 0, 1, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'EDITTrxHistory', 'EDITTrxFK', 'STRING', 'edit_trx_history_base', 'edit_trx_id', 'STRING', 'edit_trx_history', 'edit_trx_id', 'BIGINT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'EDITTrxHistory', 'CycleDate', 'STRING', 'edit_trx_history_base', 'cycle_date', 'STRING', 'edit_trx_history', 'cycle_date', 'TIMESTAMP', 3, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_ODS', 'EDITTrxHistory', 'OriginalProcessDateTime', 'STRING', 'edit_trx_history_base', 'original_process_datetime', 'STRING', 'edit_trx_history', 'original_process_datetime', 'TIMESTAMP', 4, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_ODS', 'EDITTrxHistory', 'AccountingPendingStatus', 'STRING', 'edit_trx_history_base', 'accounting_pending_status', 'STRING', 'edit_trx_history', 'accounting_pending_status', 'STRING', 5, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'EDITTrxHistory', 'ControlNumber', 'STRING', 'edit_trx_history_base', 'control_number', 'STRING', 'edit_trx_history', 'control_number', 'STRING', 6, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'EDITTrxHistory', 'ReleaseDate', 'STRING', 'edit_trx_history_base', 'release_date', 'STRING', 'edit_trx_history', 'release_date', 'TIMESTAMP', 7, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_ODS', 'EDITTrxHistory', 'ReturnDate', 'STRING', 'edit_trx_history_base', 'return_date', 'STRING', 'edit_trx_history', 'return_date', 'TIMESTAMP', 8, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_ODS', 'EDITTrxHistory', 'CorrespondenceTypeCT', 'STRING', 'edit_trx_history_base', 'correspondence_type_code', 'STRING', 'edit_trx_history', 'correspondence_type_code', 'STRING', 9, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'EDITTrxHistory', 'ProcessID', 'STRING', 'edit_trx_history_base', 'process_id', 'STRING', 'edit_trx_history', 'process_id', 'STRING', 10, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'EDITTrxHistory', 'RealTimeInd', 'STRING', 'edit_trx_history_base', 'is_real_time', 'STRING', 'edit_trx_history', 'is_real_time', 'BOOLEAN', 11, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'EDITTrxHistory', 'AddressTypeCT', 'STRING', 'edit_trx_history_base', 'address_type_code', 'STRING', 'edit_trx_history', 'address_type_code', 'STRING', 12, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'EDITTrxHistory', 'ProcessDateTime', 'STRING', 'edit_trx_history_base', 'process_datetime', 'STRING', 'edit_trx_history', 'process_datetime', 'TIMESTAMP', 13, 1, 0, 0, '3000-01-01', 1, GETUTCDATE());

-- ── [O14] FinancialHistory  (27 cols, IDs 3255-3281) ────────────────────────
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_ODS', 'FinancialHistory', 'FinancialHistoryPK', 'STRING', 'financial_history_base', 'financial_history_id', 'STRING', 'financial_history', 'financial_history_id', 'BIGINT', 1, 0, 1, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'FinancialHistory', 'EDITTrxHistoryFK', 'STRING', 'financial_history_base', 'edit_trx_history_id', 'STRING', 'financial_history', 'edit_trx_history_id', 'BIGINT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'FinancialHistory', 'GrossAmount', 'STRING', 'financial_history_base', 'gross_amount', 'STRING', 'financial_history', 'gross_amount', 'DECIMAL(18,4)', 3, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'FinancialHistory', 'NetAmount', 'STRING', 'financial_history_base', 'net_amount', 'STRING', 'financial_history', 'net_amount', 'DECIMAL(18,4)', 4, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'FinancialHistory', 'CheckAmount', 'STRING', 'financial_history_base', 'check_amount', 'STRING', 'financial_history', 'check_amount', 'DECIMAL(18,4)', 5, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'FinancialHistory', 'FreeAmount', 'STRING', 'financial_history_base', 'free_amount', 'STRING', 'financial_history', 'free_amount', 'DECIMAL(18,4)', 6, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'FinancialHistory', 'TaxableBenefit', 'STRING', 'financial_history_base', 'taxable_benefit', 'STRING', 'financial_history', 'taxable_benefit', 'DECIMAL(18,4)', 7, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'FinancialHistory', 'DisbursementSourceCT', 'STRING', 'financial_history_base', 'disbursement_source_code', 'STRING', 'financial_history', 'disbursement_source_code', 'STRING', 8, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'FinancialHistory', 'Liability', 'STRING', 'financial_history_base', 'liability', 'STRING', 'financial_history', 'liability', 'DECIMAL(18,4)', 9, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'FinancialHistory', 'CommissionableAmount', 'STRING', 'financial_history_base', 'commissionable_amount', 'STRING', 'financial_history', 'commissionable_amount', 'DECIMAL(18,4)', 10, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'FinancialHistory', 'MaxCommissionAmount', 'STRING', 'financial_history_base', 'max_commission_amount', 'STRING', 'financial_history', 'max_commission_amount', 'DECIMAL(18,4)', 11, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'FinancialHistory', 'CostBasis', 'STRING', 'financial_history_base', 'cost_basis', 'STRING', 'financial_history', 'cost_basis', 'DECIMAL(18,4)', 12, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'FinancialHistory', 'AccumulatedValue', 'STRING', 'financial_history_base', 'accumulated_value', 'STRING', 'financial_history', 'accumulated_value', 'DECIMAL(18,4)', 13, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'FinancialHistory', 'SurrenderValue', 'STRING', 'financial_history_base', 'surrender_value', 'STRING', 'financial_history', 'surrender_value', 'DECIMAL(18,4)', 14, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'FinancialHistory', 'GuarAccumulatedValue', 'STRING', 'financial_history_base', 'guar_accumulated_value', 'STRING', 'financial_history', 'guar_accumulated_value', 'DECIMAL(18,4)', 15, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'FinancialHistory', 'PriorDueDate', 'STRING', 'financial_history_base', 'prior_due_date', 'STRING', 'financial_history', 'prior_due_date', 'TIMESTAMP', 16, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_ODS', 'FinancialHistory', 'PriorExtractDate', 'STRING', 'financial_history_base', 'prior_extract_date', 'STRING', 'financial_history', 'prior_extract_date', 'TIMESTAMP', 17, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
('EQ_ODS', 'FinancialHistory', 'PriorFixedAmount', 'STRING', 'financial_history_base', 'prior_fixed_amount', 'STRING', 'financial_history', 'prior_fixed_amount', 'DECIMAL(18,4)', 18, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'FinancialHistory', 'PrevComplexChangeValue', 'STRING', 'financial_history_base', 'prev_complex_change_value', 'STRING', 'financial_history', 'prev_complex_change_value', 'DECIMAL(18,4)', 19, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'FinancialHistory', 'TaxableIndicator', 'STRING', 'financial_history_base', 'is_taxable', 'STRING', 'financial_history', 'is_taxable', 'BOOLEAN', 20, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'FinancialHistory', 'NetAmountAtRisk', 'STRING', 'financial_history_base', 'net_amount_at_risk', 'STRING', 'financial_history', 'net_amount_at_risk', 'DECIMAL(18,4)', 21, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'FinancialHistory', 'DistributionCodeCT', 'STRING', 'financial_history_base', 'distribution_code', 'STRING', 'financial_history', 'distribution_code', 'STRING', 22, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'FinancialHistory', 'NetIncomeAttributable', 'STRING', 'financial_history_base', 'net_income_attributable', 'STRING', 'financial_history', 'net_income_attributable', 'DECIMAL(18,4)', 23, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'FinancialHistory', 'InterestProceeds', 'STRING', 'financial_history_base', 'interest_proceeds', 'STRING', 'financial_history', 'interest_proceeds', 'DECIMAL(18,4)', 24, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'FinancialHistory', 'PriorInitialCYAccumValue', 'STRING', 'financial_history_base', 'prior_initial_cy_accum_value', 'STRING', 'financial_history', 'prior_initial_cy_accum_value', 'DECIMAL(18,4)', 25, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'FinancialHistory', 'InsuranceInforce', 'STRING', 'financial_history_base', 'insurance_inforce', 'STRING', 'financial_history', 'insurance_inforce', 'DECIMAL(18,4)', 26, 1, 0, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'FinancialHistory', 'SevenPayRate', 'STRING', 'financial_history_base', 'seven_pay_rate', 'STRING', 'financial_history', 'seven_pay_rate', 'DECIMAL(18,4)', 27, 1, 0, 0, '0', 1, GETUTCDATE());

-- ── [O15] ProductStructure (SEG_ENGINE)  (4 cols, IDs 3282-3285) ────────────
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
('EQ_ODS', 'ProductStructure', 'ProductStructurePK', 'STRING', 'product_structure_base', 'product_structure_id', 'STRING', 'product_structure', 'product_structure_id', 'INT', 1, 0, 1, 0, '0', 1, GETUTCDATE()),
('EQ_ODS', 'ProductStructure', 'MarketingPackageName', 'STRING', 'product_structure_base', 'marketing_package_name', 'STRING', 'product_structure', 'marketing_package_name', 'STRING', 2, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'ProductStructure', 'BusinessContractName', 'STRING', 'product_structure_base', 'business_contract_name', 'STRING', 'product_structure', 'business_contract_name', 'STRING', 3, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
('EQ_ODS', 'ProductStructure', 'ProductTypeCT', 'STRING', 'product_structure_base', 'product_type_code', 'STRING', 'product_structure', 'product_type_code', 'STRING', 4, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE());

-- Total EQ_ODS: 285 column mappings across 15 base tables (IDs 3001-3285)

