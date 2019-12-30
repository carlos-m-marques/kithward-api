class KwSuperClass < ApplicationRecord
  #acts_as_paranoid
  CARE_TYPES = ['Independent Living', 'Assisted Living', 'Skilled Nursing', 'Memory Care'].freeze
  HEIRS_CLASSES = %w(BuildingSuperClass CommunitySuperClass OwnerSuperClass UnitSuperClass UnitTypeSuperClass PmSystemSuperClass).freeze

  has_many :kw_classes
  has_many :kw_attributes, through: :kw_classes

  accepts_nested_attributes_for :kw_classes

  scope :independent_living, ->{ where(care_type: 'Independent Living') }
  scope :assisted_living, ->{ where(care_type: 'Assisted Living') }
  scope :skilled_nursing, ->{ where(care_type: 'Skilled Nursing') }
  scope :memory_care, ->{ where(care_type: 'Memory Care') }

  validates :name, :type, presence: true
  validates :type, inclusion: { in: HEIRS_CLASSES }
  validates :care_type, inclusion: { in: CARE_TYPES }
end
