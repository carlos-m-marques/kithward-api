class AddCareTypeBooleansToKwSuperClasses < ActiveRecord::Migration[5.2]
  def change
    add_column :kw_super_classes, :independent_living, :boolean, null: false, default: false
    add_column :kw_super_classes, :assisted_living, :boolean, null: false, default: false
    add_column :kw_super_classes, :skilled_nursing, :boolean, null: false, default: false
    add_column :kw_super_classes, :memory_care, :boolean, null: false, default: false

    KwSuperClass.update_all(independent_living: true)

    remove_column :kw_super_classes, :care_type, :string
  end
end
