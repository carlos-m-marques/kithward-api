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

class Account < ApplicationRecord
  has_secure_password(validations: false)
  has_paper_trail

  validates :email, presence: true, uniqueness: true

  STATUS_PSEUDO    = '?'
  STATUS_REAL      = 'R'
  STATUS_DELETED   = 'X'

  def is_pseudo?
    status == STATUS_PSEUDO
  end

  def is_real?
    status == STATUS_REAL
  end

  def is_valid?
    is_pseudo? or is_real?
  end

  def is_deleted?
    status == STATUS_DELETED
  end

  def delete!
    update_attributes(status: STATUS_DELETED, password_digest: "DELETED-#{password_digest}")
  end

  def undelete!
    update_attributes(status: STATUS_REAL, password_digest: password_digest.gsub("DELETED-", ""))
  end

  def intercom_hash
    OpenSSL::HMAC.hexdigest('sha256', Rails.application.credentials.dig(:intercom, :secret_key), self.id.to_s)
  end

  def generate_verification_email
    self.verification_token = SecureRandom.base58(48)
    self.verification_expiration = 24.hours.from_now
    self.save!

    # TODO: SEND EMAIL
  end

  def verify_email(token)
    if token == self.verification_token and Date.now < self.verification_expiration
      self.verified_email = true
      self.verification_token = nil
      self.verification_expiration = nil
      if is_pseudo?
        self.status = STATUS_REAL
      end
      return true
    end
    return false
  end
end
