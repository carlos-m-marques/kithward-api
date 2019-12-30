class AddIndexesToKwValues < ActiveRecord::Migration[5.2]
  def change
    add_index :kw_values, [:kw_attribute_id , :community_id], unique: false
    add_index :kw_attributes, :name
  end
end
