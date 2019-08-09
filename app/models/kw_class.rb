class KwClass < ApplicationRecord
  has_many :kw_attributes
  belongs_to :kw_super_class

  default_scope -> { includes(kw_attributes: [:kw_values]) }

  validates :name, :kw_super_class, presence: true
end
