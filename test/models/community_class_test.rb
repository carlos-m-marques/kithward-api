# == Schema Information
#
# Table name: community_classes
#
#  id          :bigint(8)        not null, primary key
#  name        :string           not null
#  priority    :integer
#  is_required :boolean          default(FALSE), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'test_helper'

class CommunityClassTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
