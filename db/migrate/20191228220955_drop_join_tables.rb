class DropJoinTables < ActiveRecord::Migration[5.2]
  def change
    drop_join_table :buildings, :kw_values, table_name: :buildings_kw_values
    drop_join_table :owners, :kw_values, table_name: :kw_values_owners
    drop_join_table :pm_systems, :kw_values, table_name: :kw_values_pm_systems
    drop_join_table :unit_types, :kw_values, table_name: :kw_values_unit_types
    drop_join_table :units, :kw_values, table_name: :kw_values_units
  end
end
