class AddSlugToCommunities < ActiveRecord::Migration[5.2]
  def change
    add_column :communities, :slug, :string
    add_index :communities, :slug, unique: true
    Community.find_each(&:set_slug!)
  end
end
