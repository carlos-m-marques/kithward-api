# == Schema Information
#
# Table name: kw_attributes
#
#  id          :bigint(8)        not null, primary key
#  kw_class_id :bigint(8)
#  name        :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_kw_attributes_on_kw_class_id  (kw_class_id)
#
# Foreign Keys
#
#  fk_rails_...  (kw_class_id => kw_classes.id)
#

require 'test_helper'

class KwAttributeTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
