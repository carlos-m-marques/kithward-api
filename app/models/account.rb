# == Schema Information
#
# Table name: accounts
#
#  id              :bigint(8)        not null, primary key
#  email           :string(128)
#  password_digest :string(128)
#  name            :string(128)
#  is_admin        :boolean          default(FALSE)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_accounts_on_email  (email) UNIQUE
#

class Account < ApplicationRecord
  has_secure_password
  validates :email, presence: true, uniqueness: true
end
