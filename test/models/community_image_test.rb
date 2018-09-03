# == Schema Information
#
# Table name: community_images
#
#  id           :bigint(8)        not null, primary key
#  community_id :bigint(8)
#  caption      :string(1024)
#  tags         :string(1024)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  sort_order   :integer          default(9999)
#
# Indexes
#
#  index_community_images_on_community_id  (community_id)
#

require 'test_helper'

class CommunityImageTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
