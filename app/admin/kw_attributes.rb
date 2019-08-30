ActiveAdmin.register KwAttribute, as: 'Attributes' do
  menu parent: 'Super Classes'

  permit_params :name, :ui_type, :kw_class_id, :required

  filter :name
  filter :kw_super_class
  filter :required
  filter :ui_type, as: :check_boxes, collection: -> { KwAttribute::UI_TYPES }

  index do
    selectable_column
    id_column
    column :name
    toggle_bool_column :required
    column :created_at
    column :updated_at
    column :kw_class
    column :kw_super_class
    actions
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :ui_type, as: :select, include_blank: false, collection: KwAttribute::UI_TYPES
      f.input :kw_class
      f.input :required
    end

    f.actions
  end
  # config.action_items.delete_if { |item|
  #   item.name == :show ||
  #   item.name == :edit ||
  #   item.name == :destroy ||
  #   item.name == :new
  # }



  # action_item :new do
  #   link_to 'New', new_activeadmin_kw_super_class_kw_class_kw_attributes_path
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
  belongs_to :kw_class, optional: true
end
