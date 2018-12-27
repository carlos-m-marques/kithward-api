# == Schema Information
#
# Table name: accounts
#
#  id                      :bigint(8)        not null, primary key
#  email                   :string(128)
#  password_digest         :string(128)
#  name                    :string(128)
#  is_admin                :boolean          default(FALSE)
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  status                  :string(1)        default("?")
#  verified_email          :string(128)
#  verification_token      :string(64)
#  verification_expiration :datetime
#
# Indexes
#
#  index_accounts_on_email  (email) UNIQUE
#

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
