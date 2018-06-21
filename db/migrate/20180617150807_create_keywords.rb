class CreateKeywords < ActiveRecord::Migration[5.2]
  def change
    create_table :keyword_groups do |t|
      t.string :name,     limit: 64
      t.string :label,    limit: 128

      t.timestamps

      t.index :name
      t.index :label
    end

    create_table :keywords do |t|
      t.string :name,     limit: 64
      t.string :label,    limit: 128

      t.timestamps

      t.index :name
      t.index :label
    end

    add_reference :keywords, :keyword_group
    add_foreign_key :keywords, :keyword_groups

    create_join_table :facilities, :keywords do |t|
      t.index :facility_id
    end
  end
end
