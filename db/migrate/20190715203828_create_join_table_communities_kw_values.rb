class CreateJoinTableCommunitiesKwValues < ActiveRecord::Migration[5.2]
  def change
    create_join_table :communities, :kw_values do |t|
      t.index [:community_id, :kw_value_id]
      t.index [:kw_value_id, :community_id]
    end
  end
end
