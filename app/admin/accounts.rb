ActiveAdmin.register Account do
  permit_params :email, :password, :password_confirmation, :name, :role, :owner_id

  index do
    selectable_column
    id_column
    column :name
    column :email
    # column :owner
    tag_column :role, interactive: true
    column :created_at
    actions
  end

  filter :email
  filter :created_at

  form do |f|
    f.inputs do
      f.input :name
      f.input :email
      # f.input :role, as: :select, include_blank: false, collection: Account::ROLES
      f.input :password
      f.input :password_confirmation
      # f.input :owner
    end
    f.actions
  end
end
