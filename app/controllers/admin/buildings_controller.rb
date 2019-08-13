module Admin
  class BuildingsController < ActionController::API
    rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
    before_action :set_community
    # before_action :admin_account_required!

    def index
      page = params[:page] || 1
      per = params[:limit] || 30

      total = @community.buildings.count
      buildings = @community.buildings.page(page).per(per)

      pagination = {
        total_pages: buildings.total_pages,
        current_page: buildings.current_page,
        next_page: buildings.next_page,
        prev_page: buildings.prev_page,
        first_page: buildings.first_page?,
        last_page: buildings.last_page?,
        per_page: buildings.limit_value,
        total: total
      }.compact

      render json: { results: Admin::BuildingSerializer.render_as_hash(buildings, view: 'list'), meta: pagination }
    end

    def super_classes
      page = params[:page] || 1
      per = params[:limit] || 30

      total = BuildingSuperClass.count
      super_classes = BuildingSuperClass.page(page).per(per)

      pagination = {
        total_pages: super_classes.total_pages,
        current_page: super_classes.current_page,
        next_page: super_classes.next_page,
        prev_page: super_classes.prev_page,
        first_page: super_classes.first_page?,
        last_page: super_classes.last_page?,
        per_page: super_classes.limit_value,
        total: total
      }.compact

      render json: { results: Admin::KwSuperClassSerializer.render_as_hash(super_classes), meta: pagination }
    end

    def kw_classes
      super_class = BuildingSuperClass.find(params[:id])

      page = params[:page] || 1
      per = params[:limit] || 30


      kw_classes = super_class.kw_classes
      total = kw_classes.count

      kw_classes = kw_classes.page(page).per(per)

      pagination = {
        total_pages: kw_classes.total_pages,
        current_page: kw_classes.current_page,
        next_page: kw_classes.next_page,
        prev_page: kw_classes.prev_page,
        first_page: kw_classes.first_page?,
        last_page: kw_classes.last_page?,
        per_page: kw_classes.limit_value,
        total: total
      }.compact

      render json: { results: Admin::KwClassSerializer.render_as_hash(kw_classes), meta: pagination }
    end

    def kw_attributes
      kw_class = KwClass.find(params[:id])

      page = params[:page] || 1
      per = params[:limit] || 30


      kw_attributes = kw_class.kw_attributes
      total = kw_attributes.count

      kw_attributes = kw_attributes.page(page).per(per)

      pagination = {
        total_pages: kw_attributes.total_pages,
        current_page: kw_attributes.current_page,
        next_page: kw_attributes.next_page,
        prev_page: kw_attributes.prev_page,
        first_page: kw_attributes.first_page?,
        last_page: kw_attributes.last_page?,
        per_page: kw_attributes.limit_value,
        total: total
      }.compact

      render json: { results: Admin::KwAttributeSerializer.render_as_hash(kw_attributes), meta: pagination }
    end

    def show
      building = @community.buildings.find(params[:id])
      render json:  Admin::BuildingSerializer.render(building, view: 'complete')
    end

    def update
      building = @community.buildings.find(params[:id])

      if building.update_attributes(building_params)
        render json:  Admin::BuildingSerializer.render(building, view: 'complete')
      else
        render json: { errors: building.errors}, status: :unprocessable_entity
      end
    end

    def destroy
      # building = @community.buildings.find(params[:id])
      #
      # if building.destroy!
      #   head :no_content
      # else
      #   render json: { errors: building.errors}, status: :unprocessable_entity
      # end
      head :no_content
    end

    def create
      building = @community.buildings.new(building_params)

      if building.save
        render json:  Admin::BuildingSerializer.render(building, view: 'complete')
      else
        render json: { errors: building.errors}, status: :unprocessable_entity
      end
    end

    private

    def building_params
      params.permit(:name, :community_id, kw_value_ids: [])
    end

    def record_not_found(error)
      render json: { errors: error.message }, status: :unprocessable_entity
    end

    def set_community
      @community ||= Community.find(params[:community_id])
    end
  end
end
