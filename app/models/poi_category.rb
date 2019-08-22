class PoiCategory < ApplicationRecord
  has_paper_trail
  acts_as_paranoid

  has_many :pois

  scope :by_column, ->(column = :created_at, direction = :desc) { order(column => direction) }

  validates :name, uniqueness: { case_sensitive: false }
end
