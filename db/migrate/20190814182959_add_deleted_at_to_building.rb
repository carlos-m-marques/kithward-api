class AddDeletedAtToBuilding < ActiveRecord::Migration[5.2]
  def change
    add_column :buildings, :deleted_at, :datetime
    add_index :buildings, :deleted_at
  end
end
