module Admin
  class PermissionsController < ActionController::API
    def subjects
      render json: Permission::KLASSES
    end

    def subject_ids
      render json: params[:subject].constantize.pluck(:id)
    end
  end
end
