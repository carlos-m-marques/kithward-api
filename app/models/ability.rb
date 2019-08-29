class Ability
  ENTITIES = {
    Account => %i(index show update create destroy),
    Owner => %i(index show update create destroy super_classes),
    PmSystem => %i(index show update create destroy super_classes),
    Community => %i(index show update create destroy flag super_classes),
    Poi => %i(index show update create destroy),
    PoiCategory => %i(index show update create destroy),
    CommunityImage => %i(index show update create destroy),
    UnitTypeImage => %i(index show update create destroy),
    Building => %i(index show update create destroy flag super_classes),
    UnitType => %i(index show update create destroy flag super_classes),
    Unit => %i(index show update create destroy flag super_classes)
  }.freeze

  include CanCan::Ability

  # ENTITIES.keys.each do |entity|
  #   can :permissions, entity
  #   can :resource_permissions, entity
  # end
  attr_accessor :account

  def initialize(account)
    self.account = account

    set_aliases

    anonymous_privileges
    user_privileges
    manager_privileges
    buildings_manager_privileges
    units_manager_privileges
    admin_privileges
  end

  def entity_privileges
    ENTITIES.map do |entity, actions|
      [
        entity,
        actions.map{ |action| [action, self.can?(action, entity)] }.to_h
      ]
    end.to_h
  end

  private

  def set_aliases
    alias_action :flag, to: :update
    alias_action [:file, :super_classes], to: :read
  end

  def manager_privileges
    return unless account.try(:manager?)

    operator_read_privileges
    unit_layouts_privileges
    buildings_privileges

    can [:update, :index], Owner, resource_conditions
    can [:update], Community, resource_conditions
    can [:update, :show, :index, :create, :destroy], Poi
    can [:update, :show, :index, :create, :destroy], PoiCategory
    can [:update, :show, :index, :create, :destroy], CommunityImage, resource_conditions
    can [:update, :show, :index, :create, :destroy, :super_classes], Unit, resource_conditions
  end

  def admin_privileges
    return unless account.try(:admin?)

    can :manage, :all
  end

  def operator_read_privileges
    can :show, PmSystem, resource_conditions
    can :show, Owner, resource_conditions
    can [:show, :index], Community, resource_conditions
    can :super_classes, Community
  end

  def unit_layouts_privileges
    can [:update, :show, :index, :create, :destroy, :super_classes], UnitType, resource_conditions
    can [:update, :show, :index, :create, :destroy], UnitTypeImage, resource_conditions
  end

  def units_read_privileges
    can [:update, :show, :index, :super_classes], Unit, resource_conditions
  end

  def buildings_privileges
    can [:update, :show, :index, :create, :destroy, :super_classes], Building, resource_conditions
  end

  def buildings_manager_privileges
    return unless account.try(:buildings_manager?)

    operator_read_privileges
    buildings_privileges
    units_read_privileges
  end

  def units_manager_privileges
    return unless account.try(:units_manager?)

    operator_read_privileges
    unit_layouts_privileges
    units_read_privileges
  end

  def user_privileges
    return unless (account && !account.admin?)

    can [:update, :show, :index], account
  end

  def anonymous_privileges
    return if account

    can :create, Account
  end

  def resource_conditions
    { accounts: { id: account.id } }
  end
end
