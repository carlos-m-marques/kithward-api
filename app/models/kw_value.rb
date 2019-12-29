class KwValue < ApplicationRecord
  #acts_as_paranoid
  
  belongs_to :kw_attribute
  belongs_to :community

  has_one :kw_class, through: :kw_attribute
  has_one :kw_super_class, through: :kw_class

  validates :name, :kw_attribute, :community, presence: true
end
