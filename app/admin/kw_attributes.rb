ActiveAdmin.register KwAttribute do
  permit_params :name, :ui_type, :kw_class_id

  filter :name
  filter :ui_type, as: :check_boxes, collection: -> { KwAttribute::UI_TYPES }

  # sidebar "Children", only: [:show, :edit] do
  #   ul do
  #     li link_to "Values", activeadmin_kw_attribute_kw_values_path(resource)
  #   end
  # end

  # config.action_items.delete_if { |item|
  #   item.name == :show ||
  #   item.name == :edit ||
  #   item.name == :destroy ||
  #   item.name == :new
  # }



  # action_item :new do
  #   link_to 'New', new_activeadmin_kw_super_class_kw_class_kw_attributes_path
  # end

  # form do |f|
  #   f.inputs do
  #     f.input :name, label: 'Name'
  #     f.input :ui_type, as: :select, include_blank: false, collection: KwAttribute::UI_TYPES
  #     f.input :kw_class
  #   end
  #
  #   f.actions
  # end

  # index do
  #   selectable_column
  #   id_column
  #   column :name
  #   column :created_at
  #   column :updated_at
  #   # activeadmin_kw_super_class_kw_class_kw_attribute
  #   # edit_activeadmin_kw_super_class_kw_class_kw_attribute
  #   # activeadmin_kw_super_class_kw_class_kw_attribute
  #   actions defaults: false, dropdown: true do |record|
  #     item "View", activeadmin_kw_super_class_kw_class_kw_attribute_path(id: record.id)
  #     item "Edit", edit_activeadmin_kw_super_class_kw_class_kw_attribute_path(id: record.id)
  #     item "Delete", activeadmin_kw_super_class_kw_class_kw_attribute_path(id: record.id)
  #   end
  # end
  controller do
    belongs_to :kw_class do
      belongs_to :kw_super_class
    end
  end
end
