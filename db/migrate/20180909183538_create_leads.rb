class CreateLeads < ActiveRecord::Migration[5.2]
  def change
    create_table :leads do |t|
      t.references :account
      t.references :community

      t.string :name, limit: 256
      t.string :email, limit: 128
      t.string :phone, limit: 128

      t.string :request, limit: 64

      t.text :message

      t.timestamps
    end
  end
end
