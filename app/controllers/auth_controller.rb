require 'digest/sha1'
require 'json_web_token'

class AuthController < ApplicationController
  def login
    account = Account.insensitive_find_by_email(params[:email])
    if params[:password].present?
      if !account && params[:name] # no need for name.present? because it can be blank
        # sign up!
        account = Account.create(params.permit(:email, :name, :password).merge(status: Account::STATUS_REAL))
      elsif account && account.is_valid? && account.authenticate(params[:password])
        # login!
      else
        account = nil
        error = "Invalid Credentials"
      end
    elsif params[:verify].present?
      if account && account.is_valid? && account.verify_email(params[:verify])
        # verified!
        account.save
      else
        account = nil
        error = "Invalid Credentials"
      end
    else
      if account
        if account.is_valid?
          if account.password_digest.present?
            error = "Password Required"
          else
            error = "Verification Required"
          end
        else
          error = "Invalid Credentials"
        end
        account = nil
      else
        # sign up!
        account = Account.create(params.permit(:email, :name).merge(status: Account::STATUS_PSEUDO))
      end
    end

    if account and account.is_valid?
      refresh_token = JsonWebToken.refresh_token_for_account(account, Digest::SHA1.hexdigest(account.password_digest || account.email))
      access_token = JsonWebToken.access_token_for_account(account)

      render json: AccountSerializer.render(account, meta: {access_token: access_token, refresh_token: refresh_token})
    else
      render json: { errors: [error] }, status: :unauthorized
    end
  end

  def request_verification
    account = Account.insensitive_find_by_email(params[:email])
    if account
      account.generate_verification_email(params.permit(:reason))
    end
    
    render json: { messages: ["Email sent!"]}
  end

  def token
    refresh_token = params[:refresh_token]
    refresh_data = JsonWebToken.decode(refresh_token)

    if refresh_data && refresh_data[:account_id]
      account = Account.find(refresh_data[:account_id])
      if account && Digest::SHA1.hexdigest(account.password_digest || account.email) == refresh_data[:digest]
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
