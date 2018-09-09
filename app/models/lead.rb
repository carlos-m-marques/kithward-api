# == Schema Information
#
# Table name: leads
#
#  id           :bigint(8)        not null, primary key
#  account_id   :bigint(8)
#  community_id :bigint(8)
#  name         :string(256)
#  email        :string(128)
#  phone        :string(128)
#  request      :string(64)
#  message      :text
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_leads_on_account_id    (account_id)
#  index_leads_on_community_id  (community_id)
#

class Lead < ApplicationRecord
  belongs_to :account, optional: true

  after_create :post_to_intercom

  def post_to_intercom
  end
end
