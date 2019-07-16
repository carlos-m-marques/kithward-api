class CreateKwSuperClasses < ActiveRecord::Migration[5.2]
  def change
    create_table :kw_super_classes do |t|
      t.string :name, null: false
      t.boolean :is_care_type_il?, null: false, default: false
      t.boolean :is_care_type_sn?, null: false, default: false
      t.boolean :is_care_type_mc?, null: false, default: false
      t.boolean :is_care_type_al?, null: false, default: false
      t.boolean :is_owner?, null: false, default: false
      t.boolean :is_community?, null: false, default: false
      t.boolean :is_building?, null: false, default: false
      t.boolean :is_unit?, null: false, default: false
      t.boolean :is_unit_type?, null: false, default: false

      t.timestamps
    end

    add_reference :kw_classes, :kw_super_class, index: true, foreign_key: true
  end
end
