# == Schema Information
#
# Table name: accounts
#
#  id                      :bigint(8)        not null, primary key
#  email                   :string(128)
#  password_digest         :string(128)
#  name                    :string(128)
#  is_admin                :boolean          default(FALSE)
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  status                  :string(1)        default("?")
#  verified_email          :string(128)
#  verification_token      :string(64)
#  verification_expiration :datetime
#
# Indexes
#
#  index_accounts_on_email  (email) UNIQUE
#

require 'test_helper'

class AccountTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
