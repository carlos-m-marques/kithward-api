module Admin
  class CommunityImagesController < ApiController
    before_action :set_community
    # before_action :admin_account_required!

    def index
      page = params[:page] || 1
      per = params[:limit] || 30

      community_images = @community.community_images

      total = community_images.count
      community_images = community_images.page(page).per(per)

      pagination = {
        total_pages: community_images.total_pages,
        current_page: community_images.current_page,
        next_page: community_images.next_page,
        prev_page: community_images.prev_page,
        first_page: community_images.first_page?,
        last_page: community_images.last_page?,
        per_page: community_images.limit_value,
        total: total
      }.compact

      render json: { results: Admin::CommunityImageSerializer.render_as_hash(community_images, view: 'list'), meta: pagination }
    end


    def show
      community_image = @community.community_images.find(params[:id])
      render json:  Admin::CommunityImageSerializer.render(community_image, view: 'complete', file_url: url_for(community_image.image))
    end

    def file
      community_image = @community.community_images.find(params[:id])
      redirect_to url_for(community_image.image)
    end

    def update
      community_image = @community.community_images.find(params[:id])

      if community_image.update_attributes(community_image_params)
        render json:  Admin::CommunityImageSerializer.render(community_image, view: 'complete', file_url: url_for(community_image.image))
      else
        render json: { errors: community_image.errors}, status: :unprocessable_entity
      end
    end

    def destroy
      community_image = @community.community_images.find(params[:id])

      if community_image.destroy!
        head :no_content
      else
        render json: { errors: community_image.errors}, status: :unprocessable_entity
      end
    end

    def create
      community_image = @community.community_images.new(community_image_params)

      if community_image.save
        render json:  Admin::CommunityImageSerializer.render(community_image, view: 'complete', file_url: url_for(community_image.image))
      else
        render json: { errors: community_image.errors}, status: :unprocessable_entity
      end
    end

    private

    def community_image_params
      params.permit(:community_id, :caption, :tags, :sort_order, :image)
    end

    def set_community
      @community ||= Community.find(params[:community_id])
    end
  end
end
