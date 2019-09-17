class AddDeletedAtToCommunityImages < ActiveRecord::Migration[5.2]
  def change
    add_column :community_images, :deleted_at, :datetime
    add_index :community_images, ["deleted_at", "id"]
  end
end
