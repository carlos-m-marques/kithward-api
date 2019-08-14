class PmSystem < ApplicationRecord
  acts_as_paranoid

  has_many :owners, dependent: :nullify

  validates_presence_of :name
end
