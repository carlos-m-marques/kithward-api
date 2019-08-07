# == Schema Information
#
# Table name: owners
#
#  id           :bigint(8)        not null, primary key
#  name         :string           not null
#  address1     :string
#  address2     :string
#  city         :string
#  state        :string
#  zip          :string
#  pm_system_id :bigint(8)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_owners_on_pm_system_id  (pm_system_id)
#
# Foreign Keys
#
#  fk_rails_...  (pm_system_id => pm_systems.id)
#

class Owner < ApplicationRecord
  belongs_to :pm_system
  has_many :communities

  # has_and_belongs_to_many :kw_values
  # has_many :kw_attributes, through: :kw_values
  # has_many :kw_classes, through: :kw_attributes
  # has_many :owner_super_classes, through: :kw_classes, source: :kw_super_class, class_name: 'OwnerSuperClass'

  validates_presence_of :name, :address1, :address2, :city, :state, :zip, :pm_system, presence: true

  def super_classes
    OwnerSuperClass
  end
end
