require 'json_web_token'

class ApplicationController < ActionController::API
  def authenticate_request!
    JsonWebToken.verify(authorization_token)
  rescue JWT::VerificationError, JWT::DecodeError
    render json: { errors: ['Not Authenticated'] }, status: :unauthorized
  end

  def authorization_token
    if request.headers['Authorization'].present?
      request.headers['Authorization'].split(' ').last
    elsif params[:jwt]
      params[:jwt]
    end
  end
end
