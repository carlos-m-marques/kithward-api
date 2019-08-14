# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

["Dining", "Retail", "Entertainment", "Culture", "Transportation", "Hospitals", "Doctors", "Outdoors", "Sports", "Services"].each do |name|
  PoiCategory.create(name: name)
end
hospitals = PoiCategory.find_by_name("Hospitals")

Poi.create(name: "NewYork-Presbyterian Lower Manhattan Hospital", poi_category: hospitals, street: "170 William St", city: "New York", state: "NY", postal: "10038", country: "USA", created_by_id: 1)
Poi.create(name: "Bellevue Hospital Center", poi_category: hospitals, street: "462 First Avenue", city: "New York", state: "NY", postal: "10016", country: "USA", created_by_id: 1)

Poi.create(name: "Mount Sinai Hospital", poi_category: hospitals, street: "1 Gustave L. Levy Place", city: "New York", state: "NY", postal: "10029", country: "USA", created_by_id: 1)
Poi.create(name: "Mount Sinai West", poi_category: hospitals, street: "1000 Tenth Ave", city: "New York", state: "NY", postal: "10019", country: "USA", created_by_id: 1)
Poi.create(name: "Mount Sinai Beth Israel", poi_category: hospitals, street: "281 First Ave", city: "New York", state: "NY", postal: "10003", country: "USA", created_by_id: 1)
Poi.create(name: "Mount Sinai St. Luke's", poi_category: hospitals, street: "1111 Amsterdam Ave", city: "New York", state: "NY", postal: "10025", country: "USA", created_by_id: 1)
Poi.create(name: "Mount Sinai Queens", poi_category: hospitals, street: "25-10 30th Ave", city: "Astoria", state: "NY", postal: "11102", country: "USA", created_by_id: 1)
Poi.create(name: "Mount Sinai Brooklyn", poi_category: hospitals, street: "3201 Kings Highway", city: "Brooklyn", state: "NY", postal: "11234", country: "USA", created_by_id: 1)

Poi.create(name: "Long Island College Hospital", poi_category: hospitals, street: "339 Hicks St", city: "Brooklyn", state: "NY", postal: "11201", country: "USA", created_by_id: 1)
Poi.create(name: "Brooklyn Hospital Center - Downtown", poi_category: hospitals, street: "121 Dekalb Ave", city: "Brooklyn", state: "NY", postal: "11201", country: "USA", created_by_id: 1)
AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password') if Rails.env.development?