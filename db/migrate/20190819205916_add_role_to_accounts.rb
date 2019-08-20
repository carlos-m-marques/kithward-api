class AddRoleToAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :role, :string, default: 'user'
    Account.where(is_admin: true).update_all(role: 'admin')
  end
end
