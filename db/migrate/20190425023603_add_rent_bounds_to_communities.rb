class AddRentBoundsToCommunities < ActiveRecord::Migration[5.2]
  def change
    add_column :communities, :monthly_rent_lower_bound, :float
    add_column :communities, :monthly_rent_upper_bound, :float

   
  end
end
