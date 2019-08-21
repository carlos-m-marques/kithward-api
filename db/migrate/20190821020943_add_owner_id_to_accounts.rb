class AddOwnerIdToAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :owner_id, :integer
    add_index :accounts, :owner_id
  end
end
