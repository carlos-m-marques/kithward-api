class AccountSerializer < Blueprinter::Base
  identifier :idstr, name: :id

  fields :name, :email, :is_admin, :status, :role, :owner_id, :entity_privileges

  field :meta do |obj, options|
    options[:meta]
  end

  field :intercom_hash

  view 'show' do
    fields :name, :email, :role, :created_at, :updated_at, :owner_id
  end
  # field :meta, if: ->(obj, options) {options[:meta]} do |obj, options|
  #   options[:meta]
  # end
end
