class CreateAccountAccessRequest < ActiveRecord::Migration[5.2]
  def change
    create_table :account_access_requests do |t|
      t.string :first_name
      t.string :last_name
      t.string :title
      t.string :phone_number
      t.string :company_name
      t.text :company_type
      t.text :reason
      t.string :work_email
      t.integer :account_id, null: true
      t.index :account_id
    end
  end
end
