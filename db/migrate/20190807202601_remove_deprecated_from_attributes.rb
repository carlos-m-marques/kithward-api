class RemoveDeprecatedFromAttributes < ActiveRecord::Migration[5.2]
  def change
    remove_column :kw_classes, :is_owner
    remove_column :kw_classes, :is_community
    remove_column :kw_classes, :is_building
    remove_column :kw_classes, :is_unit
    remove_column :kw_classes, :is_unit_type
    remove_column :kw_classes, :is_care_type_il
    remove_column :kw_classes, :is_care_type_sn
    remove_column :kw_classes, :is_care_type_mc
    remove_column :kw_classes, :is_care_type_al

    remove_column :kw_attributes, :is_owner
    remove_column :kw_attributes, :is_community
    remove_column :kw_attributes, :is_building
    remove_column :kw_attributes, :is_unit
    remove_column :kw_attributes, :is_unit_type
    remove_column :kw_attributes, :is_care_type_il
    remove_column :kw_attributes, :is_care_type_sn
    remove_column :kw_attributes, :is_care_type_mc
    remove_column :kw_attributes, :is_care_type_al

    remove_column :kw_values, :is_owner
    remove_column :kw_values, :is_community
    remove_column :kw_values, :is_building
    remove_column :kw_values, :is_unit
    remove_column :kw_values, :is_unit_type
    remove_column :kw_values, :is_care_type_il
    remove_column :kw_values, :is_care_type_sn
    remove_column :kw_values, :is_care_type_mc
    remove_column :kw_values, :is_care_type_al
  end
end
