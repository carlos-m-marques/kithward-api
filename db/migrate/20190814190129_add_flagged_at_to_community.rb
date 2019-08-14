class AddFlaggedAtToCommunity < ActiveRecord::Migration[5.2]
  def change
    add_column :communities, :flagged_at, :datetime
    add_index :communities, :flagged_at
  end
end
