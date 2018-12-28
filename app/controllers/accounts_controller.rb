
class AccountsController < ApplicationController
  before_action :authentication_required!, except: [:create, :exception]

  def index
  end

  def exception
    raise "Test Exception"
  end

  def show
    if params[:id] == 'self'
      params[:id] = accessing_account.id
    end

    @account = Account.find(params[:id])
    if @account.id == accessing_account.id || accessing_account.is_admin?
      render json: AccountSerializer.render(@account)
    else
      render json: { errors: ['Not Authorized'] }, status: :unauthorized
    end
  end

  def create
    @account = Account.create(params.permit(
      :email, :name, :password, :password_confirmation
    ))

    if @account.errors.any?
      render json: { errors: @account.errors}, status: :unprocessable_entity
    else
      render json: AccountSerializer.render(@account)
    end
  end

  def update
    if params[:id] == 'self'
      params[:id] = accessing_account.id
    end

    @account = Account.find(params[:id])
    if @account.id == accessing_account.id || accessing_account.is_admin?
      @account.update_attributes(params.permit(
        :name, :password, :password_confirmation
      ))

      if @account.errors.any?
        render json: { errors: @account.errors}, status: :unprocessable_entity
      else
        render json: AccountSerializer.render(@account)
      end
    else
      render json: { errors: ['Not Authorized'] }, status: :unauthorized
    end
  end
end
