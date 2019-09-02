class CreateJoinTableAccountCommunity < ActiveRecord::Migration[5.2]
  def change
    create_join_table :accounts, :communities do |t|
      t.index [:account_id, :community_id]
      t.index [:community_id, :account_id]
    end
  end
end
