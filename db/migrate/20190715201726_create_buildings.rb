class CreateBuildings < ActiveRecord::Migration[5.2]
  def change
    create_table :buildings do |t|
      t.string :name, null: false
      t.references :community, foreign_key: true, index:true

      t.timestamps
    end
  end
end
