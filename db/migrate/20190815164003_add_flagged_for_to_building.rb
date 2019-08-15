class AddFlaggedForToBuilding < ActiveRecord::Migration[5.2]
  def change
    add_column :buildings, :flagged_for, :string
    add_index :buildings, :flagged_for
  end
end
