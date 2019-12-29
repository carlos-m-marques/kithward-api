class KwSuperClass < ApplicationRecord
  #acts_as_paranoid

  HEIRS_CLASSES = %w(BuildingSuperClass CommunitySuperClass OwnerSuperClass UnitSuperClass UnitTypeSuperClass PmSystemSuperClass).freeze

  has_many :kw_classes
  has_many :kw_attributes, through: :kw_classes

  accepts_nested_attributes_for :kw_classes

  scope :independent_living, ->{ where(independent_living: true) }
  scope :assisted_living, ->{ where(assisted_living: true) }
  scope :skilled_nursing, ->{ where(skilled_nursing: true) }
  scope :memory_care, ->{ where(memory_care: true) }

  validates :name, :type, presence: true
  validates :type, inclusion: { in: HEIRS_CLASSES }

  def care_type
    return 'Independent Living' if independent_living
    return 'Assisted Living' if assisted_living
    return 'Skilled Nursing' if skilled_nursing
    return 'Memory Care' if memory_care
  end
end
