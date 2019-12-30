class ChangeCareTypeOnKwSuperClasses < ActiveRecord::Migration[5.2]
  def change
    add_column :kw_super_classes, :care_type, :string

    KwSuperClass.all.each do |super_class|
      care_type = 'Independent Living' if super_class.independent_living
      care_type = 'Assisted Living' if super_class.assisted_living
      care_type = 'Skilled Nursing' if super_class.skilled_nursing
      care_type = 'Memory Care' if super_class.memory_care

      super_class.update_attributes(care_type: care_type)
    end

    remove_column :kw_super_classes, :independent_living
    remove_column :kw_super_classes, :assisted_living
    remove_column :kw_super_classes, :skilled_nursing
    remove_column :kw_super_classes, :memory_care
  end
end
