class CreateCommunityAttributeValues < ActiveRecord::Migration[5.2]
  def change
    create_table :community_attribute_values do |t|
      t.string :name, null: false
      t.integer :priority, null: false
      t.references :community_attribute, null: false, index: true
      
      t.timestamps
    end
  end
end
