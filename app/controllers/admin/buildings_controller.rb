module Admin
  class BuildingsController < ApiController
    load_and_authorize_resource
    before_action :set_community

    def permissions
      allowed = Ability::PERMISSIONS.map do |action|
        [action, can?(action, Building)]
      end.to_h

      render json: allowed
    end

    def resource_permissions
      building = Building.find(params[:id])

      allowed = Ability::PERMISSIONS.map do |action|
        [action, can?(action, building)]
      end.to_h

      render json: allowed
    end

    def index
      page = params[:page] || 1
      per = params[:limit] || 30

      buildings = @community.buildings.accessible_by(current_ability)
      buildings = buildings.only_deleted if params[:deleted]
      buildings = buildings.flagged if params[:flagged]

      total = buildings.count
      buildings = buildings.page(page).per(per)

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

      super_classes = Admin::KwSuperClassSerializer.render_as_hash(super_classes, visible: params[:visible], hidden: params[:hidden])

      render json: { results: super_classes, meta: pagination }
    end

    def show
      building = @community.buildings.find(params[:id])
      render json:  Admin::BuildingSerializer.render(building, view: 'complete')
    end

    def flag
      building = @community.buildings.find(params[:id])

      if building.flagged?
        building.unflag!
      else
        building.flag!(reason: building_params[:reason]) unless building.flagged?
      end

      render json: { flag: building.flagged?, reason: building.flagged_for }.compact
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
      building = @community.buildings.find(params[:id])

      if building.destroy!
        head :no_content
      else
        render json: { errors: building.errors}, status: :unprocessable_entity
      end
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
      params.permit(:name, :community_id, :reason, kw_value_ids: [])
    end

    def set_community
      @community ||= Community.find(params[:community_id])
    end
  end
end
