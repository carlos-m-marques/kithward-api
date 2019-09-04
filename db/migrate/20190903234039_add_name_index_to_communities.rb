class AddNameIndexToCommunities < ActiveRecord::Migration[5.2]
  def change
    add_index :communities, :name, using: :gist, opclass: :gist_trgm_ops
  end
end
