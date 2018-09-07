class AddWeightsToPlaces < ActiveRecord::Migration[5.2]
  def change
    add_column :geo_places, :weight, :integer, default: 0
  end
end
