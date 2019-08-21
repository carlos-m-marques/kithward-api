class CreateUnitTypeImages < ActiveRecord::Migration[5.2]
  def change
    create_table :unit_type_images do |t|
      t.references :unit_type
      t.string :caption, limit: 1024
      t.string :tags, limit: 1024
      t.integer :sort_order, default: 9999

      t.timestamps
    end
  end
end
