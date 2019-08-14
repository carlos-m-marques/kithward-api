require 'active_support/concern'

module Flaggable
  extend ActiveSupport::Concern

  included do
    scope :flagged, -> { where.not(flagged_at: nil) }
    scope :unflagged, -> { where(flagged_at: nil) }
  end

  def flag!
    touch(:flagged_at)
    true
  end

  def unflag!
    update_column(:flagged_at, nil)
    false
  end

  def toggle_flag!
    return flag! unless flagged?
    unflag!
  end

  def flagged?
    flagged_at.present?
  end
end
