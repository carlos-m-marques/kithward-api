class UnitType < ApplicationRecord
  include Flaggable

  acts_as_paranoid

  belongs_to :community
  has_many :units, dependent: :destroy

  has_and_belongs_to_many :kw_values
  has_many :kw_attributes, through: :kw_values
  has_many :kw_classes, through: :kw_attributes
  has_many :unit_type_super_classes, through: :kw_classes, source: :kw_super_class, class_name: 'UnitTypeSuperClass'

  validates :name, :community, presence: true

  def super_classes
		UnitTypeSuperClass
	end
end
