class CommunityAttributes < ActiveRecord::Migration[5.2]
  def change
    add_column :communities, :care_type, :string, limit: 1, default: '?'

    remove_column :communities, :is_independent
    remove_column :communities, :is_assisted
    remove_column :communities, :is_nursing
    remove_column :communities, :is_memory
    remove_column :communities, :is_ccrc

    remove_column :communities, :website
    remove_column :communities, :phone
    remove_column :communities, :fax
    remove_column :communities, :email

    rename_column :communities, :address, :street
    rename_column :communities, :address_more, :street_more
  end
end
