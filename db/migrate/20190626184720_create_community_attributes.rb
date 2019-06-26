class CreateCommunityAttributes < ActiveRecord::Migration[5.2]
  def change
    create_table :community_attributes do |t|
      t.string :name, null: false
      t.integer :priority, null: false
      t.references :community_class, null: false, index: true
      t.boolean :is_required, null: false, default: false
      t.integer :data_type, null: false, index: true

      t.timestamps
    end
  end
end
