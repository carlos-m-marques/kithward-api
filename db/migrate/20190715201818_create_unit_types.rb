class CreateUnitTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :unit_types do |t|
      t.string :name, null: false
      t.references :community, foreign_key: true

      t.timestamps
    end
  end
end
