class FixJsonField < ActiveRecord::Migration[5.2]
  def change
    rename_column :communities, :data, :old_data
    add_column :communities, :data, :jsonb

    Community.reset_column_information
    Community.find_each do |c|
      c.data = c.old_data
      c.save
    end
  end
end
