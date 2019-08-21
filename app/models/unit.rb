class Unit < ApplicationRecord
	include Flaggable

	acts_as_paranoid

	belongs_to :building
	belongs_to :unit_type

	has_one :community, through: :unit_type

	has_and_belongs_to_many :kw_values
  has_many :kw_attributes, through: :kw_values
  has_many :kw_classes, through: :kw_attributes
  has_many :unit_super_classes, through: :kw_classes, source: :kw_super_class, class_name: 'UnitSuperClass'

	scope :available, -> { where(is_available: true) }

	validates :name, :building, :unit_number, presence: true

	delegate :community, to: :building

	def super_classes
		UnitSuperClass
	end
end
