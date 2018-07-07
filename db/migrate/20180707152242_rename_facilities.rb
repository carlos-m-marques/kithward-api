class RenameFacilities < ActiveRecord::Migration[5.2]
  def change
    rename_table :facilities, :communities
  end
end
