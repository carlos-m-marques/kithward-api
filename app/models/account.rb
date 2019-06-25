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

require 'mail_tools'

class Account < ApplicationRecord
  has_secure_password(validations: false)
  has_paper_trail

  validates :email, presence: true, uniqueness: {case_sensitive: false}

  after_save :send_verification_email_if_needed

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

  def email=(value)
    if value != self[:email]
      self[:email] = value
      self.verified_email = nil
      self.verification_token = nil
      self.verification_expiration = nil
    end
  end

  def send_verification_email_if_needed
    if !self.verified_email && !self.verification_token
      generate_verification_email(reason: 'verify')
    end
  end

  def generate_verification_email(params)
    self.verification_token = SecureRandom.base58(48)
    self.verification_expiration = 24.hours.from_now
    self.save!

    MailTools.send_template(
      self.email,
      "d-eb98144a7ab2430d9cc0763d70a5e0ea",
      {
        email_address: self.email,
        validation_link: "#{ENV['FRONTEND_URL'] || 'https://kithward.com'}/auth/verify?#{URI.encode_www_form(email: self.email, verify: self.verification_token, reason: params[:reason])}"
      }
    )
  end

  def verify_email(token)
    if token == self.verification_token and Time.now < self.verification_expiration
      self.verified_email = self.email
      self.verification_token = nil
      self.verification_expiration = nil
      if is_pseudo?
        self.status = STATUS_REAL
      end
      return true
    end
    return false
  end

  def self.insensitive_find_by_email(email)
    Account.where("lower(email) = ?", email.downcase).first
  end
end
