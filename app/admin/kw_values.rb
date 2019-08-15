ActiveAdmin.register KwValue do
  permit_params :name, :kw_attribute_id

  filter :name

  form do |f|
    f.inputs do
      f.input :name, label: 'Name'
      f.input :kw_attribute
    end

    f.actions
  end

  # belongs_to :kw_attribute, optional: true
end
