class CreateUnits < ActiveRecord::Migration[5.2]
  def change
    create_table :units do |t|

      t.string :description
      t.boolean :is_available, default: false
      t.date :date_available
      t.decimal :base_rent, precision: 18, scale: 2
      t.belongs_to :listing, index: true

      t.timestamps
    end
  end
end
