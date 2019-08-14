# ActiveAdmin.register Community do
# # See permitted parameters documentation:
# # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
# #
# # permit_params :list, :of, :attributes, :on, :model
# #
# # or
# #
# # permit_params do
# #   permitted = [:permitted, :attributes]
# #   permitted << :other if params[:action] == 'create' && current_user.admin?
# #   permitted
# # end
#   filter :name
#   filter :created_at
#   filter :updated_at
#   filter :care_type, as: :check_boxes, collection: proc { Community::CARE_TYPES.map{ |ct| [Community::LABEL_FOR_TYPE[ct], ct] } }
#   filter :flagged_at
#
#   index do
#     selectable_column
#     id_column
#     column :id
#     column :name
#     column :created_at
#     column :updated_at
#     actions
#   end
#
#   form do |f|
#     f.inputs do
#       f.input :name
#       f.input :description
#       f.input :kw_values
#     end
#     f.actions
#   end
# end
