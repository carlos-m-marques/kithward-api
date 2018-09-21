class CachedThumbnailForCommunities < ActiveRecord::Migration[5.2]
  def change
    add_column :communities, :cached_image_url, :string, limit: 128

    Community.reset_column_information
    Community.find_each do |c|
      c.update_cached_image_url!
    end
  end
end
