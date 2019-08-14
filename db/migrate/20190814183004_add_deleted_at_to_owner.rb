class AddDeletedAtToOwner < ActiveRecord::Migration[5.2]
  def change
    add_column :owners, :deleted_at, :datetime
    add_index :owners, :deleted_at
  end
end
