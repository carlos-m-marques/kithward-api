class AddPublishedToUnitTypeImages < ActiveRecord::Migration[5.2]
  def change
    add_column :unit_type_images, :published, :boolean, default: true
  end
end
