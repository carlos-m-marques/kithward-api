class AddUpdateCommunitiesAasm < ActiveRecord::Migration[5.2]
  def change
    status_active    = 'A'
    status_draft     = '?'
    status_deleted   = 'X'

    Community.where(status: status_active).update_all(status: Community::STATE_ACTIVE)
    Community.where(status: status_draft).update_all(status: Community::STATE_DRAFT)
    Community.where(status: status_deleted).each(&:destroy)
  end
end
