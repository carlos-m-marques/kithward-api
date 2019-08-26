require 'digest/sha1'
require 'json_web_token'

class AuthController < ApiController
  def login
    account = Account.find_by_email(params[:email])

    if account && account.is_valid? && account.authenticate(params[:password])
      refresh_token = JsonWebToken.refresh_token_for_account(account, Digest::SHA1.hexdigest(account.password_digest))
      access_token = JsonWebToken.access_token_for_account(account)

      render json: AccountSerializer.render(account, meta: { access_token: access_token, refresh_token: refresh_token })
    else
      render json: { errors: ['Invalid Credentials!'] }, status: :unauthorized
    end
  end

  def request_verification
    account = Account.find_by_email(params[:email])
    if account
      account.generate_verification_email(params.permit(:reason))
    end

    render json: { messages: ["Email sent!"]}
  end

  def token
    refresh_token = params[:refresh_token]
    refresh_data = JsonWebToken.decode(refresh_token)

    unless params[:refresh_token]
      authentication_required!

      puts "\n\n\n\n\nGood token!\n\n\n\n\n"

      refresh_token = JsonWebToken.refresh_token_for_account(current_account, Digest::SHA1.hexdigest(current_account.password_digest))
      access_token = JsonWebToken.access_token_for_account(current_account)

      render json: AccountSerializer.render(current_account, meta: {access_token: access_token, refresh_token: refresh_token})
    else
      if refresh_data && refresh_data[:account_id]
        account = Account.find(refresh_data[:account_id])
        if account && Digest::SHA1.hexdigest(account.password_digest || account.email) == refresh_data[:digest]

          puts "\n\n\n\n\nGood refresh token!\n\n\n\n\n"

          access_token = JsonWebToken.access_token_for_account(account)

          render json: AccountSerializer.render(account, meta: {access_token: access_token, refresh_token: refresh_token})
        else
          render json: { errors: ['Invalid Token'] }, status: :unauthorized
        end
      else
        render json: { errors: ['Invalid Token'] }, status: :unauthorized
      end
    end
  end
end
