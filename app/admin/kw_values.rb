ActiveAdmin.register KwValue, as: 'Values' do
  menu parent: 'Super Classes'

  permit_params :name, :kw_attribute_id

  filter :name
  #
  # form do |f|
  #   f.inputs do
  #     f.input :name, label: 'Name'
  #     f.input :kw_attribute
  #   end
  #
  #   f.actions
  # end
  index do
    selectable_column
    id_column
    column :name
    column :kw_class
    column :kw_super_class
    column :kw_attribute
    column :community
    actions
  end
end
