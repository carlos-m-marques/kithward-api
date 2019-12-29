class DeletedAt < ActiveRecord::Migration[5.2]
  def change
    add_column :kw_classes, :deleted_at, :datetime
    add_column :kw_super_classes, :deleted_at, :datetime
  end
end
