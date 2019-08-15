class AddFlaggedForToUnitType < ActiveRecord::Migration[5.2]
  def change
    add_column :unit_types, :flagged_for, :string
    add_index :unit_types, :flagged_for
  end
end
