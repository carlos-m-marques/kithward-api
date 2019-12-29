class AddCommunityIdToKwValue < ActiveRecord::Migration[5.2]
  def change
    add_column :kw_values, :community_id, :integer
    add_column :kw_values, :deleted_at, :datetime
    add_column :kw_attributes, :deleted_at, :datetime
  end
end
