# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

["Eating", "Shopping", "Entertainment", "Culture", "Transportation", "Hospital", "Medical Care", "Outdoors", "Golf"].each do |name|
  PoiCategory.create(name: name)
end
hospital = PoiCategory.find_by_name("Hospital")

Poi.create(name: "NewYork-Presbyterian Lower Manhattan Hospital", poi_category: hospital, street: "170 William St", city: "New York", state: "NY", postal: "10038", country: "USA", created_by_id: 1)
Poi.create(name: "Bellevue Hospital Center", poi_category: hospital, street: "462 First Avenue", city: "New York", state: "NY", postal: "10016", country: "USA", created_by_id: 1)
Poi.create(name: "Mount Sinai", poi_category: hospital, street: "425 W 59th St", city: "New York", state: "NY", postal: "10019", country: "USA", created_by_id: 1)
Poi.create(name: "Long Island College Hospital", poi_category: hospital, street: "339 Hicks St", city: "Brooklyn", state: "NY", postal: "11201", country: "USA", created_by_id: 1)
Poi.create(name: "Brooklyn Hospital Center - Downtown", poi_category: hospital, street: "121 Dekalb Ave", city: "Brooklyn", state: "NY", postal: "11201", country: "USA", created_by_id: 1)
