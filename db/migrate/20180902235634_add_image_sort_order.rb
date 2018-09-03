class AddImageSortOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :community_images, :sort_order, :integer, default: 9999
  end
end
