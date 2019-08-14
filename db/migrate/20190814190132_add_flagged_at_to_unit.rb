class AddFlaggedAtToUnit < ActiveRecord::Migration[5.2]
  def change
    add_column :units, :flagged_at, :datetime
    add_index :units, :flagged_at
  end
end
