class Listing < ApplicationRecord  
  has_paper_trail

  belongs_to :community
  has_many :units

  default_scope { order(sort_order: :asc, id: :asc) }
  scope :active, -> { where(status: STATE_ACTIVE) }
  scope :active_or_hidden, -> { where(status: [STATE_ACTIVE, STATUS_HIDDEN]) }

  has_many :listing_images

  STATE_ACTIVE    = 'A'
  STATUS_HIDDEN    = 'H'
  STATUS_DRAFT     = '?'
  STATUS_DELETED   = 'X'

  def field_mapping
    {
      name: name,
      status: status,
      sort_order: sort_order,
      data: data,
    }
  end

  def is_active?
    status == STATE_ACTIVE
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
    status != STATE_ACTIVE
  end

  def is_active!
    self.status = STATE_ACTIVE
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
