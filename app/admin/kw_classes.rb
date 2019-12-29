ActiveAdmin.register KwClass, as: 'Classes' do
  menu parent: 'Super Classes'

  permit_params :name, :kw_super_class_id
  #
  # filter :name
  #
  sidebar "Children", only: [:show, :edit] do
    ul do
      li link_to "Attributes", activeadmin_kw_class_kw_attributes_path(kw_class_id: resource.id)
    end
  end

  index do
    selectable_column
    id_column
    column :name
    tag_column :care_type
    actions
  end
  #
  # form do |f|
  #   f.inputs do
  #     f.input :name, label: 'Name'
  #     f.input :kw_super_class
  #   end
  #
  #   f.actions
  # end
  # belongs_to :kw_super_class, optional: true
end
