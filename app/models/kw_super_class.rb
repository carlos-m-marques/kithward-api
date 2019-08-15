class KwSuperClass < ApplicationRecord
  HEIRS_CLASSES = %w(BuildingSuperClass CommunitySuperClass OwnerSuperClass UnitSuperClass UnitTypeSuperClass).freeze

  has_many :kw_classes, dependent: :destroy
  has_many :kw_attributes, through: :kw_classes

  accepts_nested_attributes_for :kw_classes

  default_scope -> { includes(kw_classes: { kw_attributes: [:kw_values] }) }

  scope :independent_living, ->{ where(independent_living: true) }
  scope :assisted_living, ->{ where(assisted_living: true) }
  scope :skilled_nursing, ->{ where(skilled_nursing: true) }
  scope :memory_care, ->{ where(memory_care: true) }

  validates :name, :type, presence: true
  validates :type, inclusion: { in: HEIRS_CLASSES }

  def self.care_type_attribute(care_type)
    case care_type
    when Community::TYPE_INDEPENDENT then :independent_living
    when Community::TYPE_ASSISTED then :assisted_living
    when Community::TYPE_NURSING then :skilled_nursing
    when Community::TYPE_MEMORY then :memory_care
    end
  end
end
