class PoiSerializer < Blueprinter::Base
  identifier :idstr, name: :id

  fields :name,
    :street, :city, :state, :postal, :country,
    :lat, :lon

  association :poi_category, name: :category, blueprint: PoiCategorySerializer
end
