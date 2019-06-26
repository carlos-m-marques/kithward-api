class CreateCommunityClasses < ActiveRecord::Migration[5.2]
  def change
    create_table :community_classes do |t|
      t.string :name, null: false
      t.integer :priority, null: false
      t.boolean :is_required, null: false, default: false
      t.timestamps
    end
  end
end
