ActiveAdmin.register Poi do
  permit_params :name, :poi_category_id, :street, :city, :state, :postal, :country

  filter :name
  filter :poi_category
  filter :city
  filter :state
end
