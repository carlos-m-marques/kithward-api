require 'json_web_token'

class ApplicationController < ActionController::API
  def access_token_payload
    @access_token_payload ||= begin
      access_token = nil
      if request.headers['Authorization'].present?
        access_token = request.headers['Authorization'].split(' ').last
      elsif params[:access_token]
        access_token = params[:access_token]
      end

      JsonWebToken.decode(access_token) || {}
    rescue JWT::VerificationError, JWT::DecodeError
      {}
    end
  end

  def authentication_required!
    unless access_token_payload[:account_id]
      render json: { errors: ['Not Authenticated'] }, status: :unauthorized
    end
  end

  def admin_account_required!
    unless access_token_payload[:account_id] && access_token_payload[:is_admin]
      render json: { errors: ['Not Authenticated'] }, status: :unauthorized
    end
  end
end
