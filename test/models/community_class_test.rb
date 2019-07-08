# == Schema Information
#
# Table name: community_classes
#
#  id               :bigint(8)        not null, primary key
#  name             :string           not null
#  priority         :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  is_care_type_il? :boolean
#  is_care_type_al? :boolean
#  is_care_type_sn? :boolean
#  is_care_type_mc? :boolean
#  is_care_type_un? :boolean
#

require 'test_helper'

class CommunityClassTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
