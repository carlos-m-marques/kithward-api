class CreateKwClasses < ActiveRecord::Migration[5.2]
  def change
    create_table :kw_classes do |t|
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
