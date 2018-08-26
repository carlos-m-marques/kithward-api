class AddCommunityStatus < ActiveRecord::Migration[5.2]
  def change
    add_column :communities, :status, :string, limit: 1, default: '?'

    Community.update_all(status: 'A')
  end
end
