class AddFlaggedForToCommunity < ActiveRecord::Migration[5.2]
  def change
    add_column :communities, :flagged_for, :string
    add_index :communities, :flagged_for
  end
end
