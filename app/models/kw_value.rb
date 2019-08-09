class KwValue < ApplicationRecord
  belongs_to :kw_attribute

  has_and_belongs_to_many :communities
  has_and_belongs_to_many :buildings
  has_and_belongs_to_many :units
  has_and_belongs_to_many :unit_types

  validates :name, :kw_attribute, presence: true

  delegate :name, to: :kw_attribute, prefix: :attribute
  delegate :id, to: :kw_attribute, prefix: :attribute

  delegate :kw_class_id, to: :kw_attribute

  def super_class_id
    kw_attribute.kw_class.kw_super_class.id
  end

  def kw_class_name
    kw_attribute.kw_class.name
  end
end
