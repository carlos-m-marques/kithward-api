class Ability
  ENTITIES = {
    Account => %i(index show update create destroy),
    Owner => %i(index show update create destroy flag super_classes),
    PmSystem => %i(index show update create destroy flag super_classes),
    Community => %i(index show update create destroy flag super_classes),
    Poi => %i(index show update create destroy flag super_classes),
    PoiCategory => %i(index show update create destroy flag super_classes),
    CommunityImage => %i(index show update create destroy flag super_classes),
    UnitTypeImage => %i(index show update create destroy flag super_classes),
    Building => %i(index show update create destroy flag super_classes),
    UnitType => %i(index show update create destroy flag super_classes),
    Unit => %i(index show update create destroy flag super_classes)
  }.freeze

  include CanCan::Ability

  def initialize(account)
    @account ||= account

    alias_action :flag, to: :update
    alias_action :file, to: :read
    alias_action :super_classes, to: :read

    can :create, Account unless account.present?

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
      can :index, Owner, id: account.owner_id
      can :show, Owner, id: account.owner_id
      can :show, PmSystem, owners: { id: account.owner_id }

      can :update, Community, owner: { accounts: { id: account.id } }
      can :read, Community, owner: { accounts: { id: account.id } }

      can :read, Poi
      can :create, Poi

      can :read, PoiCategory
      can :create, PoiCategory

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
      can :show, Owner, id: account.owner_id
      can :show, PmSystem, owners: { id: account.owner_id }

      can :read, Community, owner: { accounts: { id: account.id } }
      can :super_classes, Community

      can :update, Building, community: { owner: { accounts: { id: account.id } } }
      can :read, Building, community: { owner: { accounts: { id: account.id } } }
      can :create, Building, community: { owner: { accounts: { id: account.id } } }
      can :destroy, Building, community: { owner: { accounts: { id: account.id } } }

      can :update, Unit, building: { community: { owner: { accounts: { id: account.id } } } }
      can :read, Unit, building: { community: { owner: { accounts: { id: account.id } } } }
    end

    if account.units_manager?
      can :show, Owner, id: account.owner_id
      can :show, PmSystem, owners: { id: account.owner_id }

      can :read, Community, owner: { accounts: { id: account.id } }
      can :super_classes, Community

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

  def entity_privileges
    ENTITIES.map do |entity, actions|
      [
        entity,
        actions.map{ |action| [action, self.can?(action, entity)] }.to_h
      ]
    end.to_h
  end
end
