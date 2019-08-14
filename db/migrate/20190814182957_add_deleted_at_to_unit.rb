class AddDeletedAtToUnit < ActiveRecord::Migration[5.2]
  def change
    add_column :units, :deleted_at, :datetime
    add_index :units, :deleted_at
  end
end
