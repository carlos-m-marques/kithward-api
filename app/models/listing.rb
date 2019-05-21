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

class Listing < ApplicationRecord
  has_paper_trail

  belongs_to :community
  has_many :units

  default_scope { order(sort_order: :asc, id: :asc) }
  scope :active, -> { where(status: STATUS_ACTIVE) }
  scope :active_or_hidden, -> { where(status: [STATUS_ACTIVE, STATUS_HIDDEN]) }

  has_many :listing_images

  STATUS_ACTIVE    = 'A'
  STATUS_HIDDEN    = 'H'
  STATUS_DRAFT     = '?'
  STATUS_DELETED   = 'X'

  def is_active?
    status == STATUS_ACTIVE
  end

  def is_hidden?
    status == STATUS_HIDDEN
  end

  def is_draft?
    status == STATUS_DRAFT
  end

  def is_deleted?
    status == STATUS_DELETED
  end

  def not_active?
    status != STATUS_ACTIVE
  end

  def is_active!
    self.status = STATUS_ACTIVE
  end

  def is_hidden!
    self.status = STATUS_HIDDEN
  end

  def is_draft!
    self.status = STATUS_DRAFT
  end

  def is_deleted!
    self.status = STATUS_DELETED
  end

  def data
    self[:data] ||= {}
  end
end
