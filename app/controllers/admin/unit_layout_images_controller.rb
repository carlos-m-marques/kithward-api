module Admin
  class UnitLayoutImagesController < ApiController
    before_action :set_community, :set_unit_type
    # load_and_authorize_resource through: :community

    def index
      page = params[:page] || 1
      per = params[:limit] || 30

      unit_type_images = @unit_type.unit_type_images

      total = unit_type_images.count
      unit_type_images = unit_type_images.page(page).per(per)

      pagination = {
        total_pages: unit_type_images.total_pages,
        current_page: unit_type_images.current_page,
        next_page: unit_type_images.next_page,
        prev_page: unit_type_images.prev_page,
        first_page: unit_type_images.first_page?,
        last_page: unit_type_images.last_page?,
        per_page: unit_type_images.limit_value,
        total: total
      }.compact

      render json: { results: Admin::UnitTypeImageSerializer.render_as_hash(unit_type_images, view: 'list'), meta: pagination }
    end


    def show
      unit_type_image = @unit_type.unit_type_images.find(params[:id])
      render json:  Admin::UnitTypeImageSerializer.render(unit_type_image, view: 'complete', file_url: url_for(unit_type_image.image))
    end

    def file
      unit_type_image = @unit_type.unit_type_images.find(params[:id])
      redirect_to url_for(unit_type_image.image)
    end

    def update
      unit_type_image = @unit_type.unit_type_images.find(params[:id])

      if unit_type_image.update_attributes(unit_type_image_params)
        render json:  Admin::UnitTypeImageSerializer.render(unit_type_image, view: 'complete', file_url: url_for(unit_type_image.image))
      else
        render json: { errors: unit_type_image.errors}, status: :unprocessable_entity
      end
    end

    def destroy
      unit_type_image = @unit_type.unit_type_images.find(params[:id])

      if unit_type_image.destroy!
        head :no_content
      else
        render json: { errors: unit_type_image.errors}, status: :unprocessable_entity
      end
    end

    def create
      unit_type_image = @unit_type.unit_type_images.new(unit_type_image_params)

      if unit_type_image.save
        render json:  Admin::UnitTypeImageSerializer.render(unit_type_image, view: 'complete', file_url: url_for(unit_type_image.image))
      else
        render json: { errors: unit_type_image.errors}, status: :unprocessable_entity
      end
    end

    private

    def unit_type_image_params
      params.permit(:unit_type_id, :caption, :tags, :sort_order, :image)
    end

    def set_community
      @community ||= Community.find(params[:community_id])
    end

    def set_unit_type
      @unit_type ||= @community.unit_layouts.find(params[:unit_layout_id])
    end
  end
end
