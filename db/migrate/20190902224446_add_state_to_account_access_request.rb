class AddStateToAccountAccessRequest < ActiveRecord::Migration[5.2]
  def change
    add_column :account_access_requests, :state, :string
  end
end
