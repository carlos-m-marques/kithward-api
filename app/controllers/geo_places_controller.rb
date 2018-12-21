
class GeoPlacesController < ApplicationController
  def index
    search_options = {
      fields: ['name'],
      match: :word_start,
      order: {weight: :desc},
      where: {
        state: ['NY', 'NJ', 'CT'],
      },
    }

    search_options[:limit] = params[:limit] || 20
    search_options[:offset] = params[:offset] || 0

    if accessing_account
      search_options[:where][:state] << 'CA'
    end
    
    @places = GeoPlace.search(params[:q], search_options)

    render json: GeoPlaceSerializer.render(@places.to_a)
  end

  def show
    @place = GeoPlace.find(params[:id])

    render json: GeoPlaceSerializer.render(@place)
  end
end
