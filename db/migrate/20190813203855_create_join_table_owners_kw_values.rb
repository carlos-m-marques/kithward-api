class CreateJoinTableOwnersKwValues < ActiveRecord::Migration[5.2]
  def change
    create_join_table :owners, :kw_values do |t|
      t.index [:owner_id, :kw_value_id]
      t.index [:kw_value_id, :owner_id]
    end
  end
end
