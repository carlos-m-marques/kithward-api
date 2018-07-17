
class CreateGeoPlaces < ActiveRecord::Migration[5.2]
  def change
    create_table :geo_places do |t|
      t.string :reference, limit: 128

      t.string :geo_type, limit: 10

      t.string :name, limit: 255
      t.string :full_name, limit: 255
      t.string :state, limit: 128

      t.float :lat
      t.float :lon

      t.timestamps
    end
  end
end
