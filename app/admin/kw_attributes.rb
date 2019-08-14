ActiveAdmin.register KwAttribute do
  permit_params :name, :ui_type, :kw_class_id

  filter :name
  filter :ui_type, as: :check_boxes, collection: -> { KwAttribute::UI_TYPES }

  sidebar "Children", only: [:show, :edit] do
    ul do
      li link_to "Values", activeadmin_kw_attribute_kw_values_path(resource)
    end
  end

  form do |f|
    f.inputs do
      f.input :name, label: 'Name'
      f.input :ui_type, as: :select, include_blank: false, collection: KwAttribute::UI_TYPES
      f.input :kw_class
    end

    f.actions
  end

  belongs_to :kw_class, optional: true
end
