class AccountAccessRequest < ActiveRecord::Base
  include AASM

  COMMUNITY_OWNER = 'Community Owner'.freeze
  COMMUNITY_OPERATOR = 'Community Operator'.freeze

  COMPANY_TYPES = [COMMUNITY_OWNER, COMMUNITY_OPERATOR].freeze

  validates :first_name, :last_name, :title, :phone_number, :company_name, :company_type, :reason, :work_email, presence: true
  validates :first_name, :last_name, :company_name, length: { minimum: 3, maximum: 50 }
  validates :reason, length: { minimum: 140, maximum: 500 }
  validates :company_type, inclusion: { in: COMPANY_TYPES }
  validates :work_email, uniqueness: { case_sensitive: false }
  validates :work_email, format: { with: URI::MailTo::EMAIL_REGEXP }

  belongs_to :account, optional: false
  accepts_nested_attributes_for :account

  has_many :account_access_request_communities
  has_many :communities, through: :account_access_request_communities

  def full_name
    "#{first_name} #{last_name}"
  end

   aasm column: :state do
    state :new, initial: true
    state :pending, :approved, :rejected

    event :submits do
      transitions from: :new, to: :pending
    end

    event :approve do
      transitions from: :pending, to: :approved
    end

    event :reject do
      transitions from: :pending, to: :rejected
    end
  end
end
