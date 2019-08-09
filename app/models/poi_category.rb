class PoiCategory < ApplicationRecord
  has_paper_trail

  has_many :pois

  validates :name, uniqueness: { case_sensitive: false }
end
