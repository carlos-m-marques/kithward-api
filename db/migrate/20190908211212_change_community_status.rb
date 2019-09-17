class ChangeCommunityStatus < ActiveRecord::Migration[5.2]
  def change
    change_column :communities, :status, :string
  end
end
