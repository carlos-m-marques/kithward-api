class AddFlaggedAtToUnitType < ActiveRecord::Migration[5.2]
  def change
    add_column :unit_types, :flagged_at, :datetime
    add_index :unit_types, :flagged_at
  end
end
