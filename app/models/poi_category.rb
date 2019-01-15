# == Schema Information
#
# Table name: poi_categories
#
#  id   :bigint(8)        not null, primary key
#  name :string(128)
#

class PoiCategory < ApplicationRecord
  has_paper_trail

  has_many :pois
end
