module Admin
  class PoisController < ApiController
    def index
      page = params[:page] || 1
      per = params[:limit] || 30

      pois = if params[:sort_field] && params[:sort_direction]
        Poi.by_column(params[:sort_field], params[:sort_direction])
      else
         Poi.recent
      end

      pois = pois.only_deleted if params[:deleted]

      total = pois.count
      pois = pois.page(page).per(per)

      pagination = {
        total_pages: pois.total_pages,
        current_page: pois.current_page,
        next_page: pois.next_page,
        prev_page: pois.prev_page,
        first_page: pois.first_page?,
        last_page: pois.last_page?,
        per_page: pois.limit_value,
        total: total
      }.compact

      render json: { results: Admin::PoiSerializer.render_as_hash(pois), meta: pagination }
    end

    def show
      poi = Poi.find(params[:id])
      render json:  Admin::PoiSerializer.render(poi)
    end

    def update
      poi = Poi.find(params[:id])

      if poi.update_attributes(poi_params)
        render json:  Admin::PoiSerializer.render(poi)
      else
        render json: { errors: poi.errors}, status: :unprocessable_entity
      end
    end

    def destroy
      poi = Poi.find(params[:id])

      if poi.destroy!
        head :no_content
      else
        render json: { errors: poi.errors}, status: :unprocessable_entity
      end
    end

    def create
      poi = Poi.new(poi_params)

      if poi.save
        render json:  Admin::PoiSerializer.render(poi)
      else
        render json: { errors: poi.errors}, status: :unprocessable_entity
      end
    end

    private

    def poi_params
      params.permit(:name, :street, :city, :postal, :state, :country, :poi_category_id)
    end
  end
end
