
class GeoPlacesController < ApiController
  def index
    search_options = {
      fields: ['name'],
      match: :word_start,
      order: {weight: :desc},
    }

    search_options[:limit] = params[:limit] || 20
    search_options[:offset] = params[:offset] || 0

    places = GeoPlace.search(params[:q], search_options)

    render json: GeoPlaceSerializer.render(places.to_a)
  end

  def show
    place = GeoPlace.find_by_id(params[:id])

    if place
      render json: GeoPlaceSerializer.render(place)
    else
      if !place && (params[:geoLabel] || params[:geo_label] || params[:label])
        parts = (params[:geoLabel] || params[:geo_label] || params[:label]).split(/[ -]+/).reject {|p| p.blank?}

        geo_search_options = {
          fields: ['name'],
          match: :word_start,
          where: {state: parts[-1].upcase},
          limit: 1
        }

        place = GeoPlace.search(parts[0..-2].join(" "), geo_search_options).first
        if place
          redirect_to geo_place_url(place), :status => :moved_permanently
        else
          render nothing: true, status: 404
        end
      else
        render nothing: true, status: 404
      end
    end
  end
end

search_options = {fields: ['name'],  match: :word_start,  order: {weight: :desc},  where: {    state: ['NY', 'NJ', 'CT'],  },}
