ActiveAdmin.register PoiCategory do
  menu parent: 'Pois'

  permit_params :name
  
  filter :name
end
