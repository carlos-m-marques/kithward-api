# == Schema Information
#
# Table name: community_attributes
#
#  id                 :bigint(8)        not null, primary key
#  name               :string           not null
#  priority           :integer          not null
#  community_class_id :bigint(8)        not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  is_care_type_il?   :boolean
#  is_care_type_al?   :boolean
#  is_care_type_sn?   :boolean
#  is_care_type_mc?   :boolean
#  is_care_type_un?   :boolean
#
# Indexes
#
#  index_community_attributes_on_community_class_id  (community_class_id)
#

require 'test_helper'

class CommunityAttributeTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
