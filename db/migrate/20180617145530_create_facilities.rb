class CreateFacilities < ActiveRecord::Migration[5.2]
  def change
    create_table :facilities do |t|
      t.string :name, limit: 1024
      t.text   :description

      t.boolean :is_independent,  default: false
      t.boolean :is_assisted,     default: false
      t.boolean :is_nursing,      default: false
      t.boolean :is_memory,       default: false
      t.boolean :is_ccrc,         default: false

      t.string :address,        limit: 1024
      t.string :address_more,   limit: 1024
      t.string :city,           limit: 256
      t.string :state,          limit: 128
      t.string :postal,         limit: 32
      t.string :country,        limit: 64

      t.float :lat
      t.float :lon

      t.string :website,        limit: 1024
      t.string :phone,          limit: 64
      t.string :fax,            limit: 64
      t.string :email,          limit: 256

      t.jsonb :data

      t.timestamps
    end
  end
end
