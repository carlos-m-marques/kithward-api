require 'active_support/concern'

module Flaggable
  extend ActiveSupport::Concern

  included do
    scope :flagged, -> { where.not(flagged_at: nil) }
    scope :unflagged, -> { where(flagged_at: nil) }

    # validates :flagged_for, presence: true, if: :flagged?
  end

  def flag!(reason:)
    update_columns(flagged_at: Time.current, flagged_for: reason)
  end

  def unflag!
    update_columns(flagged_at: nil, flagged_for: nil)
  end

  # Redundant conditionals are for verbosity
  # def toggle_flag!(reason: nil)
  #   return flag! unless flagged?
  #   return unflag! if flagged?
  # end

  def flagged?
    flagged_at.present?
  end
end
