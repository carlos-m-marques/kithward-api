# == Schema Information
#
# Table name: accounts
#
#  id              :bigint(8)        not null, primary key
#  email           :string(128)
#  password_digest :string(128)
#  name            :string(128)
#  is_admin        :boolean          default(FALSE)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_accounts_on_email  (email) UNIQUE
#

class Account < ApplicationRecord
  has_secure_password
  has_paper_trail

  validates :email, presence: true, uniqueness: true

  def intercom_hash
    OpenSSL::HMAC.hexdigest('sha256', Rails.application.credentials.dig(:intercom, :secret_key), self.id.to_s)
  end
end
