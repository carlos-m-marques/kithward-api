class AddDeletedAtToUnitType < ActiveRecord::Migration[5.2]
  def change
    add_column :unit_types, :deleted_at, :datetime
    add_index :unit_types, :deleted_at
  end
end
