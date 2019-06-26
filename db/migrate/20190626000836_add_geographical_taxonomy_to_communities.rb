class AddGeographicalTaxonomyToCommunities < ActiveRecord::Migration[5.2]
  def up
    change_table(:communities) do |t|
      t.string :region, :metro, :borough, :county, :township
    end

    [:country, :region, :state, :county, :city, :postal].each do |required_field|
      Community.where(required_field => nil).update_all(required_field => 'N/A')
      change_column_null :communities, required_field, false
    end
  end

  def down
    change_table(:communities) do |t|
      t.remove :region, :metro, :borough, :county, :township
      [:country, :state, :city, :postal].each do |required_field|
        change_column_null :communities, required_field, true 
      end
    end    
  end
end
