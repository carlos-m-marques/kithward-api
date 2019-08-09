class KwValue < ApplicationRecord
  belongs_to :kw_attribute

  has_and_belongs_to_many :communities
  has_and_belongs_to_many :buildings
  has_and_belongs_to_many :units
  has_and_belongs_to_many :unit_types

  validates :name, :kw_attribute, presence: true
end
