ActiveAdmin.register Permission do
  permit_params :account_id, :subject_class, :subject_id, :action, :description

  form do |f|
    f.inputs do
      f.input :action
      f.input :account_id
      f.input :description
      f.input :subject_class, as: :select, include_blank: false, collection: Permission::KLASSES
      f.input :subject_id
    end
    f.actions
  end
end
