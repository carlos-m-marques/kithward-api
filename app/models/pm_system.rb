class PmSystem < ApplicationRecord
  #acts_as_paranoid

  has_many :owners, dependent: :nullify
  has_many :accounts, through: :owners

  validates_presence_of :name
end
