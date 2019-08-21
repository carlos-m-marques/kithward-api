desc "Seed CanCanCan permissions"
task :seed_permissions => :environment do
  RolePermission.delete_all
  Role.delete_all

  admin_role = Role.create(name: Account::ADMIN_ROLE)
  user_role = Role.create(name: Account::USER_ROLE)
  manager_role = Role.create(name: Account::MANAGER_ROLE)

  admin_role.role_permissions << RolePermission.new(action: 'manage', entity: 'all')

  [
    RolePermission.new(
      action: 'read',
      entity: 'Account',
      conditions: [
        {
          id: '_id'
        }
      ]
    ),
    RolePermission.new(
      action: 'update',
      entity: 'Account',
      conditions: [
        {
          id: '_id'
        }
      ]
    )
  ].each { |permission| user_role.role_permissions << permission }
  [
    RolePermission.new(
      action: 'read',
      entity: 'Community',
      conditions: [
        {
          owner: { accounts: { id: '_id' } }
        }
      ]
    ),
    RolePermission.new(
      action: 'update',
      entity: 'Community',
      conditions: [
        {
          owner: { accounts: { id: '_id' } }
        }
      ]
    )
  ].each { |permission| manager_role.role_permissions << permission }
end
