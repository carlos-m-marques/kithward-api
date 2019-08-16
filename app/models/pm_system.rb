class PmSystem < ApplicationRecord
  acts_as_paranoid

  has_many :owners, dependent: :nullify

  has_and_belongs_to_many :kw_values

  validates_presence_of :name
end
