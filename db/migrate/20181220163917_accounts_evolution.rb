class AccountsEvolution < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :status, :string, limit: 1, default: '?'
    add_column :accounts, :verified_email, :string, limit: 128
    add_column :accounts, :verification_token, :string, limit: 64
    add_column :accounts, :verification_expiration, :datetime
  end
end
