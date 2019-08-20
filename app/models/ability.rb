# frozen_string_literal: true
#
# class Ability
#   include CanCan::Ability
#
#   def initialize(account, namespace)
#     return public_abilities unless account
#
#     can :manage, :all if account.role == "admin"#{} && namespace == 'Admin'
#     can :read, Account, id: account.id
#   end
#
#   def public_abilities
#     can :create, Account
#   end
# end
#

class Ability
  include CanCan::Ability

  def initialize(account)
    can do |action, subject_class, subject|
      account.permissions.where(action: aliases_for_action(action)).any? do |permission|
        permission.subject_class == subject_class.to_s &&
          (subject.nil? || permission.subject_id.nil? || permission.subject_id == subject.id)
      end
    end
  end
end
