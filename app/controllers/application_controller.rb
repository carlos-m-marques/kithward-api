require 'json_web_token'

class ApplicationController < ActionController::API
  def authenticate_request!
    @jwt_payload = JsonWebToken.decode(authorization_token)

    unless @jwt_payload && @jwt_payload[:account_id]
      render json: { errors: ['Not Authenticated'] }, status: :unauthorized
    end

  rescue JWT::VerificationError, JWT::DecodeError
    render json: { errors: ['Not Authenticated'] }, status: :unauthorized
  end

  def authorization_token
    if request.headers['Authorization'].present?
      request.headers['Authorization'].split(' ').last
    elsif params[:access_token]
      params[:access_token]
    end
  end
end
