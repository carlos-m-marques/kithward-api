class Ability
  include CanCan::Ability

  def initialize(account)
    # can :read, Community # permissions for every user, even if not logged in

    if account.present?
      # All users can manager their own accounts.
      can :manage, Account, id: account.id

      if account.admin?
        can :manage, :all
      end

      if account.manager?
        can :update, Community, owner: { accounts: { id: account.id } }
        can :read, Community, owner: { accounts: { id: account.id } }
        can :read_admin, Community
      end
    end
  end
end
