ActiveAdmin.register AccountAccessRequest do
  permit_params :first_name, :last_name, :title, :phone_number, :company_name, :company_type, :reason, :work_email, :account_id, :state, :account_attributes, community_ids: [], account_attributes: [:email, :name, :password, :password_confirmation, :owner_id]

  index do
    selectable_column
    id_column
    state_column :state
    column :first_name
    column :last_name
    column :work_email
    column :company_name
    column :company_type
    actions
  end

  form do |f|
    f.inputs do
      f.input :community_ids, label: 'Communities', as: :selected_list, url: available_communities_url, response_root: :results, fields: [:name]
    end
    f.inputs do
      f.has_many :account do |b|
        b.input :name
        b.input :email
        # b.input :role, as: :select, include_blank: false, collection: Account::ROLES
        b.input :password
        b.input :password_confirmation
        # b.input :owner
      end
    end
    f.inputs do
      f.input :first_name
      f.input :last_name
      f.input :title
      f.input :phone_number
      f.input :company_name
      f.input :company_type, as: :select, include_blank: false, collection: AccountAccessRequest::COMPANY_TYPES
      f.input :reason
      f.input :work_email
    end

    f.actions
  end
end
