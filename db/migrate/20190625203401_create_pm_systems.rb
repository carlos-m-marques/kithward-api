class CreatePmSystems < ActiveRecord::Migration[5.2]
  def change
    create_table :pm_systems do |t|
      t.string :name, null: false

      t.timestamps
    end
  end
end
