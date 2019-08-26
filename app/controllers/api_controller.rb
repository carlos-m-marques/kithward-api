require 'json_web_token'

class ApiController < ActionController::API
  rescue_from CanCan::AccessDenied, with: :not_allowed
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActionController::ParameterMissing, with: :required_params

  before_action :set_raven_context, :set_paper_trail_whodunnit

  # def current_ability
  #   controller_namespace = params[:controller].split('/').first.camelize
  #   @current_ability ||= Ability.new(current_user, controller_namespace)
  # end

  def access_token_payload
    return {} unless request.headers['Authorization'] || params[:access_token]

    access_token = params[:access_token] || request.headers['Authorization'].split(' ').last

    JsonWebToken.decode(access_token)
  rescue JWT::VerificationError, JWT::DecodeError
    {}
  end

  def current_user; current_account; end

  def current_account
    @current_account ||= begin
      if access_token_payload[:account_id]
        Account.find(access_token_payload[:account_id])
      end
    end
  end

  def authentication_required!
    unless current_account
      render json: { errors: ['Not Authenticated'] }, status: :unauthorized
    end
  end

  def admin_account_required!
    unless current_account && current_account.is_admin?
      render json: { errors: ['Not Authenticated'] }, status: :unauthorized
    end
  end

  protected

  def record_not_found(error)
    render json: { errors: error.message }, status: :not_found
  end

  def not_allowed
    render json: { errors: ['Not Allowed'] }, status: :unauthorized
  end

  def required_params(error)
    render json: { errors: [%&Parameter '#{error.param}' is required for this request.&] }, status: :bad_request
  end

  def user_for_paper_trail
    if current_account
      "#{current_account.id}:#{current_account.email}"
    else
      "anonymous"
    end
  end

  def self.permission
    return name = controller_name.classify.constantize
  end

  def set_raven_context
    Raven.user_context(id: access_token_payload[:account_id]) if current_account
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
  end
end
