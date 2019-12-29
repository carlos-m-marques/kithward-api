class KwClass < ApplicationRecord
  #acts_as_paranoid

  has_many :kw_attributes

  accepts_nested_attributes_for :kw_attributes

  belongs_to :kw_super_class

  delegate :care_type, to: :kw_super_class

  validates :name, :kw_super_class, presence: true
end
