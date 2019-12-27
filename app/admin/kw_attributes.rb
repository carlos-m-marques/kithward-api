ActiveAdmin.register KwAttribute, as: 'Attributes' do
  menu parent: 'Super Classes'

  permit_params :name, :ui_type, :kw_class_id, :required, :hidden

  filter :name
  filter :kw_super_class
  filter :required
  filter :ui_type, as: :check_boxes, collection: -> { KwAttribute::UI_TYPES }

  index do
    selectable_column
    id_column
    column :name
    toggle_bool_column :required
    toggle_bool_column :hidden
    column :created_at
    column :updated_at
    column :kw_class
    column :kw_super_class
    actions
  end

  # form do |f|
  #   f.inputs do
  #     f.input :name
  #     f.input :ui_type, as: :select, include_blank: false, collection: KwAttribute::UI_TYPES
  #     f.input :kw_class
  #     f.input :required
  #     f.input :hidden
  #   end
  #
  #   f.actions
  # end
  # belongs_to :kw_class, optional: true
end
