class AddUpdateCommunitiesAasm < ActiveRecord::Migration[5.2]
  def change
    STATUS_ACTIVE    = 'A'
    STATUS_DRAFT     = '?'
    STATUS_DELETED   = 'X'

    Community.where(status: STATUS_ACTIVE).update_all(status: Community::STATE_ACTIVE)
    Community.where(status: STATUS_DRAFT).update_all(status: Community::STATE_DRAFT)
    Community.where(status: STATUS_DELETED).each(&:destroy)
  end
end
