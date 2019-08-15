class AddFlaggedForToUnit < ActiveRecord::Migration[5.2]
  def change
    add_column :units, :flagged_for, :string
    add_index :units, :flagged_for
  end
end
