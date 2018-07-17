# == Schema Information
#
# Table name: geo_places
#
#  id         :bigint(8)        not null, primary key
#  reference  :string(128)
#  geo_type   :string(10)
#  name       :string(255)
#  full_name  :string(255)
#  state      :string(128)
#  lat        :float
#  lon        :float
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class GeoPlaceTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
