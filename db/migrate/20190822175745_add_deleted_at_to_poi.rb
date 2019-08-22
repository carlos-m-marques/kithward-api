class AddDeletedAtToPoi < ActiveRecord::Migration[5.2]
  def change
    add_column :pois, :deleted_at, :datetime
    add_index :pois, :deleted_at
  end
end
