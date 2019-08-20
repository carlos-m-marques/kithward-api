class CreatePermissions < ActiveRecord::Migration[5.2]
  def change
    create_table :permissions do |t|
      t.integer :account_id
      t.string :subject_class
      t.integer :subject_id
      t.string :action
      t.text :description

      t.timestamps
    end
  end
end
