class AccountsOptionalOwner < ActiveRecord::Migration[5.2]
  def change
    change_column :accounts, :owner_id, :integer, null: true
  end
end
