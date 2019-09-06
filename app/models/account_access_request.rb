class AccountAccessRequest < ActiveRecord::Base
  attribute :first_name, :string
  attribute :last_name, :string

  include AASM

  COMMUNITY_OWNER = 'Community Owner'.freeze
  COMMUNITY_OPERATOR = 'Community Operator'.freeze

  COMPANY_TYPES = [COMMUNITY_OWNER, COMMUNITY_OPERATOR].freeze

  validates :first_name, :last_name, :title, :phone_number, :company_name, :company_type, :reason, presence: true
  validates :company_name, length: { minimum: 3, maximum: 50 }
  validates :first_name, :last_name, length: { minimum: 1, maximum: 50 }
  validates :reason, length: { maximum: 500 }
  validates :company_type, inclusion: { in: COMPANY_TYPES }
  validate :should_have_at_least_one_community

  belongs_to :account, optional: false
  accepts_nested_attributes_for :account

  has_many :account_access_request_communities
  has_many :communities, through: :account_access_request_communities

  has_many :owners, through: :communities

  def full_name
    "#{self.first_name} #{self.last_name}"
  end

  def account_attributes=(attrs)
    attrs.merge!(name: full_name)

    super(attrs)
  end

  def should_have_at_least_one_community
    errors.add(:community_ids, 'At least 1 (one) Community should be associated') if self.community_ids.count < 1
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
