class Ability
  PERMISSIONS = %i(index show update create destroy flag)

  include CanCan::Ability

  def initialize(account)
    alias_action :flag, to: :update
    alias_action :file, to: :read
    alias_action :super_classes, to: :read

    can :create, Account

    can :permissions, :all
    can :resource_permissions, :all

    return unless account.present?

    can :update, Account, id: account.id
    can :read, Account, id: account.id

    if account.admin?
      can :manage, :all
    end

    if account.manager?
      can :update, Owner, id: account.owner_id
      can :read, Owner, id: account.owner_id

      can :update, Community, owner: { accounts: { id: account.id } }
      can :read, Community, owner: { accounts: { id: account.id } }

      can :read, Poi
      can :read, PoiCategory

      can :update, CommunityImage, community: { owner: { accounts: { id: account.id } } }
      can :read, CommunityImage, community: { owner: { accounts: { id: account.id } } }
      can :create, CommunityImage, community: { owner: { accounts: { id: account.id } } }
      can :destroy, CommunityImage, community: { owner: { accounts: { id: account.id } } }

      can :update, UnitTypeImage, unit_type: { community: { owner: { accounts: { id: account.id } } } }
      can :read, UnitTypeImage, unit_type: { community: { owner: { accounts: { id: account.id } } } }
      can :create, UnitTypeImage, unit_type: { community: { owner: { accounts: { id: account.id } } } }
      can :destroy, UnitTypeImage, unit_type: { community: { owner: { accounts: { id: account.id } } } }

      can :update, Building, community: { owner: { accounts: { id: account.id } } }
      can :read, Building, community: { owner: { accounts: { id: account.id } } }
      can :create, Building, community: { owner: { accounts: { id: account.id } } }
      can :destroy, Building, community: { owner: { accounts: { id: account.id } } }

      can :update, UnitType, community: { owner: { accounts: { id: account.id } } }
      can :read, UnitType, community: { owner: { accounts: { id: account.id } } }
      can :create, UnitType, community: { owner: { accounts: { id: account.id } } }
      can :destroy, UnitType, community: { owner: { accounts: { id: account.id } } }

      can :update, Unit, unit_type: { community: { owner: { accounts: { id: account.id } } } }
      can :read, Unit, unit_type: { community: { owner: { accounts: { id: account.id } } } }
      can :create, Unit, unit_type: { community: { owner: { accounts: { id: account.id } } } }
      can :destroy, Unit, unit_type: { community: { owner: { accounts: { id: account.id } } } }
    end

    if account.buildings_manager?
      can :index, Community, owner: { accounts: { id: account.id } }

      can :update, Building, community: { owner: { accounts: { id: account.id } } }
      can :read, Building, community: { owner: { accounts: { id: account.id } } }
      can :create, Building, community: { owner: { accounts: { id: account.id } } }
      can :destroy, Building, community: { owner: { accounts: { id: account.id } } }

      can :update, Unit, building: { community: { owner: { accounts: { id: account.id } } } }
      can :read, Unit, building: { community: { owner: { accounts: { id: account.id } } } }
    end

    if account.units_manager?
      can :index, Community, owner: { accounts: { id: account.id } }

      can :update, UnitTypeImage, unit_type: { community: { owner: { accounts: { id: account.id } } } }
      can :read, UnitTypeImage, unit_type: { community: { owner: { accounts: { id: account.id } } } }
      can :create, UnitTypeImage, unit_type: { community: { owner: { accounts: { id: account.id } } } }
      can :destroy, UnitTypeImage, unit_type: { community: { owner: { accounts: { id: account.id } } } }

      can :update, UnitType, community: { owner: { accounts: { id: account.id } } }
      can :read, UnitType, community: { owner: { accounts: { id: account.id } } }
      can :create, UnitType, community: { owner: { accounts: { id: account.id } } }
      can :destroy, UnitType, community: { owner: { accounts: { id: account.id } } }

      can :update, Unit, unit_type: { community: { owner: { accounts: { id: account.id } } } }
      can :read, Unit, unit_type: { community: { owner: { accounts: { id: account.id } } } }
    end
  end
end
