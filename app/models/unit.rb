# == Schema Information
#
# Table name: units
#
#  id             :bigint(8)        not null, primary key
#  name           :string           not null
#  is_available   :boolean          default(FALSE)
#  date_available :date
#  rent_market    :decimal(18, 2)
#  listing_id     :bigint(8)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  unit_number    :string
#  building_id    :bigint(8)
#  unit_type_id   :bigint(8)
#
# Indexes
#
#  index_units_on_building_id   (building_id)
#  index_units_on_listing_id    (listing_id)
#  index_units_on_unit_type_id  (unit_type_id)
#

class Unit < ApplicationRecord
	belongs_to :listing
	belongs_to :building
	belongs_to :unit_type

	has_and_belongs_to_many :kw_values
  has_many :kw_attributes, through: :kw_values
  has_many :kw_classes, through: :kw_attributes
  has_many :unit_super_classes, through: :kw_classes, source: :kw_super_class, class_name: 'UnitSuperClass'

	scope :available, -> { where(is_available: true) }

	accepts_nested_attributes_for :listing

	validates :name, :building, :unit, :unit_number, presence: true

	delegate :community, to: :building

	def super_classes
		UnitSuperClass
	end
end
