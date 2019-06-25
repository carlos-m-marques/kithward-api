class CreateOwners < ActiveRecord::Migration[5.2]
  def change
    create_table :owners do |t|
      t.string :name, required: true 
      t.string :address1
      t.string :address2
      t.string :city
      t.string :state
      t.string :zip
      t.references :pm_system, foreign_key: true, index: true

      t.timestamps
    end
  end
end
