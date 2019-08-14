module Admin
  class PmSystemsController < ActionController::API
    rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
    # before_action :admin_account_required!

    def index
      page = params[:page] || 1
      per = params[:limit] || 30

      pm_systems = PmSystem
      pm_systems = pm_systems.only_deleted if params[:deleted]
      # pm_systems = pm_systems.flagged if params[:flagged]

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
      # pm_system = PmSystem.find(params[:id])
      #
      # if pm_system.destroy!
      #   head :no_content
      # else
      #   render json: { errors: pm_system.errors}, status: :unprocessable_entity
      # end
      head :no_content
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
      params.permit(:name)
    end

    def record_not_found(error)
      render json: { errors: error.message }, status: :unprocessable_entity
    end
  end
end
