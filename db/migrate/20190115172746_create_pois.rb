class CreatePois < ActiveRecord::Migration[5.2]
  def change
    create_table :poi_categories do |t|
      t.string :name, limit: 128
    end

    create_table :pois do |t|
      t.string :name, limit: 1024
      t.references :poi_category, index: true

      t.string :street,        limit: 1024
      t.string :city,           limit: 256
      t.string :state,          limit: 128
      t.string :postal,         limit: 32
      t.string :country,        limit: 64

      t.float :lat
      t.float :lon

      t.timestamps

      t.references :created_by
    end

    create_join_table :communities, :pois do |t|
      t.index :community_id
      t.index :poi_id
    end

  end
end
