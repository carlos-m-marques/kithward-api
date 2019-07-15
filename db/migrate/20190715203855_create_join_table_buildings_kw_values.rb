class CreateJoinTableBuildingsKwValues < ActiveRecord::Migration[5.2]
  def change
    create_join_table :buildings, :kw_values do |t|
      t.index [:building_id, :kw_value_id]
      t.index [:kw_value_id, :building_id]
    end
  end
end
