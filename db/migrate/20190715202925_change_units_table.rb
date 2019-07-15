class ChangeUnitsTable < ActiveRecord::Migration[5.2]
  def change
    rename_column :units, :description, :name
    rename_column :units, :base_rent, :rent_market
    change_table :units do |t|
      t.change :name, :string,  null: false
      t.string :unit_number
      t.references :building, index: true
      t.references :unit_type, index: true
    end
  end
end
