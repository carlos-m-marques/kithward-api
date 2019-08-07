# == Schema Information
#
# Table name: kw_values
#
#  id              :bigint(8)        not null, primary key
#  kw_attribute_id :bigint(8)
#  name            :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_kw_values_on_kw_attribute_id  (kw_attribute_id)
#
# Foreign Keys
#
#  fk_rails_...  (kw_attribute_id => kw_attributes.id)
#

class KwValue < ApplicationRecord
  belongs_to :kw_attribute

  has_and_belongs_to_many :communities
  has_and_belongs_to_many :buildings
  has_and_belongs_to_many :units
  has_and_belongs_to_many :unit_types

  validates :name, :kw_attribute, presence: true
end
