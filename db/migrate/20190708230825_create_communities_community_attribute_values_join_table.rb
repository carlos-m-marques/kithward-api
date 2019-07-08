class CreateCommunitiesCommunityAttributeValuesJoinTable < ActiveRecord::Migration[5.2]
  def change
    create_join_table :communities, :community_attribute_values do |t|
      t.index :community_id
      t.index :community_attribute_value_id, name: 'index_communities_cav_join_table_on_comunity_attribute_value_id'
    end
  end
end
