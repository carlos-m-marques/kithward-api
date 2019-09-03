module Admin
  class PmSystemsController < ApiController
    load_and_authorize_resource

    def permissions
      allowed = Ability::PERMISSIONS.map do |action|
        [action, can?(action, PmSystem)]
      end.to_h

      render json: allowed
    end

    def resource_permissions
      unit_layout = PmSystem.find(params[:id])

      allowed = Ability::PERMISSIONS.map do |action|
        [action, can?(action, unit_layout)]
      end.to_h

      render json: allowed
    end

    def index
      page = params[:page] || 1
      per = params[:limit] || 30

      pm_systems = PmSystem
      pm_systems = pm_systems.only_deleted if params[:deleted]

      total = pm_systems.count
      pm_systems = pm_systems.page(page).per(per)

      pagination = {
        total_pages: pm_systems.total_pages,
        current_page: pm_systems.current_page,
        next_page: pm_systems.next_page,
        prev_page: pm_systems.prev_page,
        first_page: pm_systems.first_page?,
        last_page: pm_systems.last_page?,
        per_page: pm_systems.limit_value,
        total: total
      }.compact

      render json: { results: Admin::PmSystemSerializer.render_as_hash(pm_systems, view: 'list'), meta: pagination }
    end

    def super_classes
      page = params[:page] || 1
      per = params[:limit] || 30

      total = PmSystemSuperClass.count
      super_classes = PmSystemSuperClass.page(page).per(per)

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
      pm_system = PmSystem.find(params[:id])
      render json:  Admin::PmSystemSerializer.render(pm_system, view: 'complete')
    end

    def update
      pm_system = PmSystem.find(params[:id])

      if pm_system.update_attributes(pm_system_params)
        render json:  Admin::PmSystemSerializer.render(pm_system, view: 'complete')
      else
        render json: { errors: pm_system.errors}, status: :unprocessable_entity
      end
    end

    def destroy
      pm_system = PmSystem.find(params[:id])

      if pm_system.destroy!
        head :no_content
      else
        render json: { errors: pm_system.errors}, status: :unprocessable_entity
      end
    end

    def create
      pm_system = PmSystem.new(pm_system_params)

      if pm_system.save
        render json:  Admin::PmSystemSerializer.render(pm_system, view: 'complete')
      else
        render json: { errors: pm_system.errors}, status: :unprocessable_entity
      end
    end

    private

    def pm_system_params
      params.permit(:name, kw_value_ids: [])
    end
  end
end
