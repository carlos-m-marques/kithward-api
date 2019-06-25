# == Schema Information
#
# Table name: owners
#
#  id           :bigint(8)        not null, primary key
#  name         :string
#  address1     :string
#  address2     :string
#  city         :string
#  state        :string
#  zip          :string
#  pm_system_id :bigint(8)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_owners_on_pm_system_id  (pm_system_id)
#
# Foreign Keys
#
#  fk_rails_...  (pm_system_id => pm_systems.id)
#

require 'test_helper'

class OwnerTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
