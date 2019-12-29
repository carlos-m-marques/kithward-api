ActiveAdmin.register KwSuperClass, as: 'Super Classes' do
  permit_params :name, :type

  # sidebar "Children", only: [:show, :edit] do
  #   ul do
  #     li link_to "Classes", activeadmin_kw_super_class_kw_classes_path(resource)
  #   end
  # end

  filter :name
  filter :type, as: :select, collection: -> { KwSuperClass::HEIRS_CLASSES }

  index do
    selectable_column
    id_column
    column :name
    tag_column :care_type
    actions
  end

  form do |f|
    f.inputs do
      f.input :name, label: 'Name'
      f.input :type, as: :select, include_blank: false, collection: KwSuperClass::HEIRS_CLASSES
    end

    f.actions
  end
end
