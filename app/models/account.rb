class Account < ApplicationRecord
  ADMIN_ROLE = 'admin'.freeze
  USER_ROLE = 'user'.freeze
  MANAGER_ROLE = 'manager'.freeze
  BUILDINGS_MANAGER_ROLE = 'buildings_manager'.freeze
  UNITS_MANAGER_ROLE = 'units_manager'.freeze

  ROLES = [ADMIN_ROLE, USER_ROLE, MANAGER_ROLE, BUILDINGS_MANAGER_ROLE, UNITS_MANAGER_ROLE].freeze

  attribute :email, :email

  has_secure_password
  has_paper_trail

  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, :password_confirmation, presence: true, unless: -> { password.blank? }

  after_save :send_verification_email_if_needed

  enum role: {
    admin: ADMIN_ROLE,
    user: USER_ROLE,
    manager: MANAGER_ROLE,
    buildings_manager: BUILDINGS_MANAGER_ROLE,
    units_manager: UNITS_MANAGER_ROLE
  }

  belongs_to :owner, optional: true

  STATUS_PSEUDO    = '?'
  STATUS_REAL      = 'R'
  STATUS_DELETED   = 'X'

  def roles
    ROLES
  end

  def admin?
     role == 'admin'
  end

  def user?
     role == 'user'
  end

  def manager?
     role == 'manager'
  end

  def buildings_manager?
     role == 'buildings_manager'
  end

  def units_manager?
     role == 'units_manager'
  end

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

    VerificationMailerWorker.perform_async(self.email, self.verification_token, params[:reason])
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

  def entity_privileges
    ability = Ability.new(self)

    Ability::ENTITIES.map do |entity|
      [
        entity.name.to_s,
        Ability::PERMISSIONS.map { |action| [action, ability.can?(action, entity)] }.to_h
      ]
    end.to_h
  end
end
