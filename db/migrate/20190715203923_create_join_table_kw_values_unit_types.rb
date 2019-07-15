class CreateJoinTableKwValuesUnitTypes < ActiveRecord::Migration[5.2]
  def change
    create_join_table :kw_values, :unit_types do |t|
      t.index [:kw_value_id, :unit_type_id]
      t.index [:unit_type_id, :kw_value_id]
    end
  end
end
