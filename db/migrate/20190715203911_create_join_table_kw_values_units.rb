class CreateJoinTableKwValuesUnits < ActiveRecord::Migration[5.2]
  def change
    create_join_table :kw_values, :units do |t|
      t.index [:kw_value_id, :unit_id]
      t.index [:unit_id, :kw_value_id]
    end
  end
end
