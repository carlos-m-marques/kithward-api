class DropJoinTableCommunitiesKwValues < ActiveRecord::Migration[5.2]
  def change
    drop_join_table :communities, :kw_values, table_name: :communities_kw_values
  end
end
