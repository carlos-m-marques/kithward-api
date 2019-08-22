module Admin
  class PoiCategoriesController < ApiController
    def index
      page = params[:page] || 1
      per = params[:limit] || 30

      poi_categories = PoiCategory

      poi_categories = poi_categories.only_deleted if params[:deleted]

      total = poi_categories.count
      poi_categories = poi_categories.page(page).per(per)

      pagination = {
        total_pages: poi_categories.total_pages,
        current_page: poi_categories.current_page,
        next_page: poi_categories.next_page,
        prev_page: poi_categories.prev_page,
        first_page: poi_categories.first_page?,
        last_page: poi_categories.last_page?,
        per_page: poi_categories.limit_value,
        total: total
      }.compact

      render json: { results: Admin::PoiCategorySerializer.render_as_hash(poi_categories), meta: pagination }
    end

    def show
      poi_category = PoiCategory.find(params[:id])
      render json:  Admin::PoiCategorySerializer.render(poi_category)
    end

    def update
      poi_category = PoiCategory.find(params[:id])

      if poi_category.update_attributes(poi_category_params)
        render json:  Admin::PoiCategorySerializer.render(poi_category)
      else
        render json: { errors: poi_category.errors}, status: :unprocessable_entity
      end
    end

    def destroy
      poi_category = PoiCategory.find(params[:id])

      if poi_category.destroy!
        head :no_content
      else
        render json: { errors: poi_category.errors}, status: :unprocessable_entity
      end
    end

    def create
      poi_category = PoiCategory.new(poi_category_params)

      if poi_category.save
        render json:  Admin::PoiCategorySerializer.render(poi_category)
      else
        render json: { errors: poi_category.errors}, status: :unprocessable_entity
      end
    end

    private

    def poi_category_params
      params.permit(:name)
    end
  end
end
