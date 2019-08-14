class AddDeletedAtToPmSystem < ActiveRecord::Migration[5.2]
  def change
    add_column :pm_systems, :deleted_at, :datetime
    add_index :pm_systems, :deleted_at
  end
end
