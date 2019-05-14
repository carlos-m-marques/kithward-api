class CreateUnits < ActiveRecord::Migration[5.2]
  def change
    create_table :units do |t|

      t.string :description
      t.boolean :availability, default: false
      t.date :availability_date
      t.decimal :rent, precision: 18, scale: 2
      t.belongs_to :listing, index: true

      t.timestamps
    end
  end
end
