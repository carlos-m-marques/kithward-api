require 'json_web_token'

class SessionController < ApplicationController
  def create
    @account = Account.find_by_email(params[:email])
    if @account && @account.authenticate(params[:password])
      @access_token = JsonWebToken.access_token_for_account(@account)

      render json: AccountSerializer.new(@account, meta: {access_token: @access_token})
    else
      ender json: { errors: ['Invalid Credentials'] }, status: :unauthorized
    end
  end
end
