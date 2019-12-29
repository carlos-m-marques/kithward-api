class Unit < ApplicationRecord
	include Flaggable

	#acts_as_paranoid

	belongs_to :building
	belongs_to :unit_type

	has_one :community, through: :unit_type

  has_many :kw_classes, through: :kw_attributes
  has_many :unit_super_classes, through: :kw_classes, source: :kw_super_class, class_name: 'UnitSuperClass'

	scope :available, -> { where(is_available: true) }

	validates :name, :building, :unit_number, presence: true

	delegate :community, to: :building

  has_one :owner, through: :community
  has_many :accounts, through: :owner

  searchkick  match: :word_start,
          word_start:  ['name'],
          default_fields: ['name'],
          callbacks: :async

  def search_data
    attributes.merge({
      "id" => id,
      "name" => name,
      "availbale" => is_available,
      "unit_number" => unit_number
    })
  end

	def super_classes
		UnitSuperClass
	end
end
