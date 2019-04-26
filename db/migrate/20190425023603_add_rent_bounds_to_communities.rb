class AddRentBoundsToCommunities < ActiveRecord::Migration[5.2]
  def change
    add_column :communities, :monthly_rent_lower_bound, :float
    add_column :communities, :monthly_rent_upper_bound, :float

    communities_with_rent_data = Community.
      joins(:listings).
      where("listings.data -> 'base_rent' is not null")

    communities_with_rent_data.each do |community|
      base_rents = community.listings.active.map do |listing|
        listing.data["base_rent"]
      end.compact

      lower_bounds = []
      upper_bounds = []
      base_rents.each do |br|
        values = br.split(':').map { |bound| bound.to_i.zero? ? nil : bound.to_i }

        if values.size == 1
          lower_bounds << values.first
        elsif values.size == 2
          lower_bounds << values.first
          upper_bounds << values.last
        end
      end

      community.update_attributes!(
        monthly_rent_lower_bound: lower_bounds.compact.min,
        monthly_rent_upper_bound: upper_bounds.compact.max
      )
    end
  end
end
