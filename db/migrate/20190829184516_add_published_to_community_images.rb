class AddPublishedToCommunityImages < ActiveRecord::Migration[5.2]
  def change
    add_column :community_images, :published, :boolean, default: true
  end
end
