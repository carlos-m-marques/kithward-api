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
#  data         :jsonb
#
# Indexes
#
#  index_leads_on_account_id    (account_id)
#  index_leads_on_community_id  (community_id)
#

class LeadSerializer < Blueprinter::Base
  identifier :idstr, name: :id

  fields :name, :phone, :email, :account_id, :community_id, :request, :message, :created_at, :updated_at
end
