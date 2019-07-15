class CreateKwAttributes < ActiveRecord::Migration[5.2]
  def change
    create_table :kw_attributes do |t|
      t.references :kw_class, foreign_key: true, index: true
      t.string :name, null: false
      t.boolean :is_care_type_il, null: false, default: false
      t.boolean :is_care_type_sn, null: false, default: false
      t.boolean :is_care_type_mc, null: false, default: false
      t.boolean :is_care_type_al, null: false, default: false
      t.boolean :is_owner, null: false, default: false
      t.boolean :is_community, null: false, default: false
      t.boolean :is_building, null: false, default: false
      t.boolean :is_unit, null: false, default: false
      t.boolean :is_unit_type, null: false, default: false

      t.timestamps
    end
  end
end
