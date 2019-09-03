class CreateAccountAccessRequestCommunity < ActiveRecord::Migration[5.2]
  def change
    create_table :account_access_request_communities do |t|
      t.references :account_access_request, foreign_key: true, index: { name: :index_aar_communities_on_account_access_request_id }
      t.references :community, foreign_key: true, index: { name: :index_aar_communities_on_community_id }
    end
  end
end
