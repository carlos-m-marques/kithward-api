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
