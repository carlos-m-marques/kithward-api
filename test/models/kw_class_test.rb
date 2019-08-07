# == Schema Information
#
# Table name: kw_classes
#
#  id                :bigint(8)        not null, primary key
#  name              :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  kw_super_class_id :bigint(8)
#
# Indexes
#
#  index_kw_classes_on_kw_super_class_id  (kw_super_class_id)
#
# Foreign Keys
#
#  fk_rails_...  (kw_super_class_id => kw_super_classes.id)
#

require 'test_helper'

class KwClassTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
