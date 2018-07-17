class GeoPlaceSerializer
  include FastJsonapi::ObjectSerializer

  attributes :name, :full_name, :state, :lat, :lon, :geo_type, :reference
end
