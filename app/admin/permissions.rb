ActiveAdmin.register Permission do
  permit_params :account_id, :subject_class, :subject_id, :action, :description
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :account_id, :name, :subject_class, :subject_id, :action, :description
  #
  # or
  #
  # permit_params do
  #   permitted = [:account_id, :name, :subject_class, :subject_id, :action, :description]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  form do |f|
    f.inputs do
      f.input :action
      f.input :subject_class, as: :select, include_blank: false, collection: Permission::KLASSES
      f.input :subject_id
      f.input :account
      f.input :description
    end
    f.actions
  end
end
