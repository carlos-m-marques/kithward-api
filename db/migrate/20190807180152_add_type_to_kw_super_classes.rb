class AddTypeToKwSuperClasses < ActiveRecord::Migration[5.2]
  def up
    add_column :kw_super_classes, :type, :string
    add_index :kw_super_classes, :type

    add_column :kw_super_classes, :care_type, :string
    add_index :kw_super_classes, :care_type

    remove_column :kw_super_classes, :is_owner?
    remove_column :kw_super_classes, :is_community?
    remove_column :kw_super_classes, :is_building?
    remove_column :kw_super_classes, :is_unit?
    remove_column :kw_super_classes, :is_unit_type?

    remove_column :kw_super_classes, :is_care_type_il?
    remove_column :kw_super_classes, :is_care_type_sn?
    remove_column :kw_super_classes, :is_care_type_mc?
    remove_column :kw_super_classes, :is_care_type_al?


    KwSuperClass.update_all(type: 'CommunitySuperClass')
    KwSuperClass.update_all(care_type: 'I')
  end

  def down
    remove_column :kw_super_classes, :type
    remove_column :kw_super_classes, :care_type

    add_column :kw_super_classes, :is_owner?, :boolean, null: false, default: false
    add_column :kw_super_classes, :is_community?, :boolean, null: false, default: false
    add_column :kw_super_classes, :is_building?, :boolean, null: false, default: false
    add_column :kw_super_classes, :is_unit?, :boolean, null: false, default: false
    add_column :kw_super_classes, :is_unit_type?, :boolean, null: false, default: false

    add_column :kw_super_classes, :is_care_type_il?, null: false, default: false
    add_column :kw_super_classes, :is_care_type_sn?, null: false, default: false
    add_column :kw_super_classes, :is_care_type_mc?, null: false, default: false
    add_column :kw_super_classes, :is_care_type_al?, null: false, default: false
  end
end
