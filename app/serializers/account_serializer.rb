class AccountSerializer < Blueprinter::Base
  identifier :idstr, name: :id

  fields :name, :email, :is_admin, :status

  field :meta do |obj, options|
    options[:meta]
  end

  field :intercom_hash

  # field :meta, if: ->(obj, options) {options[:meta]} do |obj, options|
  #   options[:meta]
  # end
end
