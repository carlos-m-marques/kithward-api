# == Schema Information
#
# Table name: listings
#
#  id           :bigint(8)        not null, primary key
#  community_id :bigint(8)
#  name         :string(1024)
#  status       :string(1)        default("?")
#  sort_order   :integer          default(9999)
#  data         :jsonb
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_listings_on_community_id  (community_id)
#

FactoryBot.define do
  factory :listing do
    
  end
end
