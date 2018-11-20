Geocoder.configure(
  lookup: :mapbox,
  api_key: Rails.application.credentials.dig(:mapbox, :api_key),
  units: :mi,
  mapbox: {
    dataset: "mapbox.places-permanent",
  },
)
