class KwAttribute < ApplicationRecord
  belongs_to :kw_class
  has_many :kw_values

  validates :name, :kw_class, presence: true
end
