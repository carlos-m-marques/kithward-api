# == Schema Information
#
# Table name: keywords
#
#  id               :bigint(8)        not null, primary key
#  name             :string(64)
#  label            :string(128)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  keyword_group_id :bigint(8)
#

require 'test_helper'

class KeywordTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
