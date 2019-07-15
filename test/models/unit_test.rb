# == Schema Information
#
# Table name: units
#
#  id             :bigint(8)        not null, primary key
#  name           :string           not null
#  is_available   :boolean          default(FALSE)
#  date_available :date
#  rent_market    :decimal(18, 2)
#  listing_id     :bigint(8)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  unit_number    :string
#  building_id    :bigint(8)
#  unit_type_id   :bigint(8)
#
# Indexes
#
#  index_units_on_building_id   (building_id)
#  index_units_on_listing_id    (listing_id)
#  index_units_on_unit_type_id  (unit_type_id)
#

require 'test_helper'

class UnitTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
