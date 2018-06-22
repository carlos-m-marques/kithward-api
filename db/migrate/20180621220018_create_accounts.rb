class CreateAccounts < ActiveRecord::Migration[5.2]
  def change
    create_table :accounts do |t|
      t.string :email, limit: 128, index: true
      t.string :password_digest, limit: 128

      t.string :name, limit: 128

      t.boolean :is_admin, default: false
      
      t.timestamps
    end
  end
end
