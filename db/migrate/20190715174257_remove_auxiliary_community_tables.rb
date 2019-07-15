class RemoveAuxiliaryCommunityTables < ActiveRecord::Migration[5.2]
  def up
    drop_table :community_classes
    drop_table :community_attributes
    drop_join_table :communities, :community_attribute_values
    drop_table :community_attribute_values
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
