# == Schema Information
#
# Table name: units
#
#  id             :bigint(8)        not null, primary key
#  description    :string
#  is_available   :boolean          default(FALSE)
#  date_available :date
#  base_rent      :decimal(18, 2)
#  listing_id     :bigint(8)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_units_on_listing_id  (listing_id)
#

class Unit < ApplicationRecord
	belongs_to :listing
	
	delegate :community, to: :listing

	scope :available, -> { where(is_available: true) }

	accepts_nested_attributes_for :listing
end
