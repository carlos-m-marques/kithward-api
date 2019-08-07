# == Schema Information
#
# Table name: kw_super_classes
#
#  id         :bigint(8)        not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  type       :string
#  care_type  :string
#
# Indexes
#
#  index_kw_super_classes_on_care_type  (care_type)
#  index_kw_super_classes_on_type       (type)
#

class KwSuperClass < ApplicationRecord
  HEIRS_CLASSES = %w(BuildingSuperClass CommunitySuperClass OwnerSuperClass UnitSuperClass UnitTypeSuperClass).freeze

  attribute :care_type, :string, default: Community::TYPE_INDEPENDENT

  has_many :kw_classes

  scope :with_care_type, ->(care_type) { where(care_type: care_type) }

  validates :name, :type, :care_type, presence: true
  validates :type, inclusion: { in: HEIRS_CLASSES }
  validates :care_type, inclusion: { in: Community::CARE_TYPES }
end
