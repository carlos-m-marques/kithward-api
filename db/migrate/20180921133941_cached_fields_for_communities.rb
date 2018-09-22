class CachedFieldsForCommunities < ActiveRecord::Migration[5.2]
  def change
    add_column :communities, :cached_image_url, :string, limit: 128
    add_column :communities, :cached_data, :jsonb

    Community.reset_column_information
    Community.find_each do |c|
      c.update_cached_image_url!
      c.update_cached_data
      c.save
    end
  end
end
