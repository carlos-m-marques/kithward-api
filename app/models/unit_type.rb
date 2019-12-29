class UnitType < ApplicationRecord
  include Flaggable

  #acts_as_paranoid

  belongs_to :community
  has_many :units, dependent: :destroy
  has_many :unit_type_images

  has_many :kw_classes, through: :kw_attributes
  has_many :unit_type_super_classes, through: :kw_classes, source: :kw_super_class, class_name: 'UnitTypeSuperClass'

  validates :name, :community, presence: true

  # Account tie-in
  has_one :owner, through: :community
  has_many :accounts, through: :owner

  searchkick  match: :word_start,
          word_start:  ['name'],
          default_fields: ['name'],
          callbacks: :async

  def search_data
    attributes.merge({
      "id" => id,
      "name" => name
    })
  end

  def super_classes
		UnitTypeSuperClass
	end
end
