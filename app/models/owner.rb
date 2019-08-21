class Owner < ApplicationRecord
  acts_as_paranoid

  belongs_to :pm_system
  has_many :communities, dependent: :nullify
  has_many :accounts

  has_and_belongs_to_many :kw_values

  validates_presence_of :name, :address1, :address2, :city, :state, :zip, :pm_system, presence: true

  scope :recent, -> { order(created_at: :desc) }
  scope :recently_updated, -> { order(updated_at: :desc) }
  scope :by_column, ->(column = :created_at, direction = :desc) { order(column => direction) }

  def super_classes
    OwnerSuperClass
  end
end
