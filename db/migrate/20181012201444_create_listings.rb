class CreateListings < ActiveRecord::Migration[5.2]
  def change
    create_table :listings do |t|
      t.references :community

      t.string :name, limit: 1024
      t.string :status, limit: 1, default: "?"
      t.integer :sort_order, default: 9999

      t.jsonb :data

      t.timestamps
    end

    create_table :listing_images do |t|
      t.references :listing
      
      t.string :caption, limit: 1024
      t.string :tags, limit: 1024
      t.integer :sort_order, default: 9999

      t.timestamps
    end
  end
end
