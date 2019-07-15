# == Schema Information
#
# Table name: buildings
#
#  id           :bigint(8)        not null, primary key
#  name         :string           not null
#  community_id :bigint(8)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_buildings_on_community_id  (community_id)
#
# Foreign Keys
#
#  fk_rails_...  (community_id => communities.id)
#

require 'test_helper'

class BuildingTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
