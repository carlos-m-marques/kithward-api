class AddDeletedAtToPoiCategory < ActiveRecord::Migration[5.2]
  def change
    add_column :poi_categories, :deleted_at, :datetime
    add_index :poi_categories, :deleted_at
  end
end
