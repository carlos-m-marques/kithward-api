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
  #   item.name == :new ||
  #   item.name == :edit ||
  #   item.name == :show
  # }
  #
  # action_item :new, priority: 0, only: :index do
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
  #   # actions dropdown: true do |post|
  #   #   item "Preview", admin_preview_post_path(post)
  #   # end
  # end

  belongs_to :kw_super_class
  belongs_to :kw_class
end
