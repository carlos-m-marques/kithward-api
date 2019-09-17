class AddIndexesAllAround < ActiveRecord::Migration[5.2]
  def up
    add_index :communities, ["deleted_at", "id"]
    add_index :communities, ["deleted_at", "slug"]
    add_index :accounts, :password_digest
    add_index :accounts, :role
    add_index :kw_super_classes, ['type', "independent_living"]
    add_index :kw_super_classes, ['type', "assisted_living"]
    add_index :kw_super_classes, ['type', "skilled_nursing"]
    add_index :kw_super_classes, ['type', "memory_care"]
    add_index :kw_super_classes, ['id', "type"]
  end

  def down
    remove_index :kw_super_classes, ['type', "independent_living"]
    remove_index :kw_super_classes, ['type', "assisted_living"]
    remove_index :kw_super_classes, ['type', "skilled_nursing"]
    remove_index :kw_super_classes, ['type', "memory_care"]
    remove_index :kw_super_classes, ['id', "type"]
    remove_index :communities, ["deleted_at", "id"]
    remove_index :communities, ["deleted_at", "slug"]
    remove_index :accounts, :password_digest
    remove_index :accounts, :role
  rescue => e
    ap e
  end
end
