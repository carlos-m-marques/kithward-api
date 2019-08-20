class Permission < ApplicationRecord
  belongs_to :account

  KLASSES = %w(
    Account
    Community
    Building
    Unit
    UnitType
    Owner
    PmSystem
    Poi
  )
end
