class Building < ApplicationRecord
  include Flaggable

  acts_as_paranoid

  belongs_to :community
  has_many :units, dependent: :destroy

  has_and_belongs_to_many :kw_values
  has_many :kw_attributes, through: :kw_values
  has_many :kw_classes, through: :kw_attributes
  has_many :building_super_classes, through: :kw_classes, source: :kw_super_class, class_name: 'BuildingSuperClass'

  validates :name, :community, presence: true

  # Account tie-in
  has_one :owner, through: :community
  has_many :accounts, through: :owner

  def super_classes
    BuildingSuperClass
  end
end
