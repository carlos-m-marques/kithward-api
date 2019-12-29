class CreateTableRelatedCommunities < ActiveRecord::Migration[5.2]
  def change
    create_table :related_communities do |t|
      t.integer  "community_id"
      t.integer  "related_community_id"
    end
  end
end
