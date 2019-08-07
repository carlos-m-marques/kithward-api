# == Schema Information
#
# Table name: kw_values
#
#  id              :bigint(8)        not null, primary key
#  kw_attribute_id :bigint(8)
#  name            :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_kw_values_on_kw_attribute_id  (kw_attribute_id)
#
# Foreign Keys
#
#  fk_rails_...  (kw_attribute_id => kw_attributes.id)
#

require 'test_helper'

class KwValueTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
