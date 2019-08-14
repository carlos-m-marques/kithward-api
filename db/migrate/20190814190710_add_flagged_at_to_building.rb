class AddFlaggedAtToBuilding < ActiveRecord::Migration[5.2]
  def change
    add_column :buildings, :flagged_at, :datetime
    add_index :buildings, :flagged_at
  end
end
