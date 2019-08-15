ActiveAdmin.register KwClass do
  permit_params :name, :kw_super_class_id

  filter :name

  sidebar "Children", only: [:show, :edit] do
    ul do
      li link_to "Attributes", activeadmin_kw_super_class_kw_class_kw_attributes_path(kw_class_id: resource.id, kw_super_class_id: resource.kw_super_class_id)
    end
  end

  form do |f|
    f.inputs do
      f.input :name, label: 'Name'
      f.input :kw_super_class
    end

    f.actions
  end

  belongs_to :kw_super_class
end
