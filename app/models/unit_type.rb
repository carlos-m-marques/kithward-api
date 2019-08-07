# == Schema Information
#
# Table name: unit_types
#
#  id           :bigint(8)        not null, primary key
#  name         :string           not null
#  community_id :bigint(8)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_unit_types_on_community_id  (community_id)
#
# Foreign Keys
#
#  fk_rails_...  (community_id => communities.id)
#

class UnitType < ApplicationRecord
  belongs_to :community

  has_and_belongs_to_many :kw_values
  has_many :kw_attributes, through: :kw_values
  has_many :kw_classes, through: :kw_attributes
  has_many :unit_type_super_classes, through: :kw_classes, source: :kw_super_class, class_name: 'UnitTypeSuperClass'

  validates :name, :community, presence: true

  def super_classes
		UnitTypeSuperClass
	end
end
