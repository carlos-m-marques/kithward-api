class CreateJoinTablePmSystemsKwValues < ActiveRecord::Migration[5.2]
  def change
    create_join_table :pm_systems, :kw_values do |t|
      t.index [:pm_system_id, :kw_value_id]
      t.index [:kw_value_id, :pm_system_id]
    end
  end
end
