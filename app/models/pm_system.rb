class PmSystem < ApplicationRecord
  has_many :owners

  validates_presence_of :name
end
