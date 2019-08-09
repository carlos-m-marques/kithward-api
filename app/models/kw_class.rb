class KwClass < ApplicationRecord
  has_many :kw_attributes
  belongs_to :kw_super_class

  validates :name, :kw_super_class, presence: true
end
