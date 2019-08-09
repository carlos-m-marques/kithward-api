class GeoPlaceSerializer < Blueprinter::Base
  identifier :idstr, name: :id

  fields :name, :slug, :full_name, :state, :lat, :lon, :geo_type, :reference
end
