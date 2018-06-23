
class AccountsController < ApplicationController
  before_action :authentication_required!, except: [:create]

  def index
  end

  def show
    @account = Account.find(params[:id])
    if @account.id == accessing_account.id || accessing_account.is_admin?
      render json: AccountSerializer.new(@account)
    else
      render json: { errors: ['Not Authenticated'] }, status: :unauthorized
    end
  end

  def create
    @account = Account.create(params.permit(
      :email, :name, :password, :password_confirmation
    ))

    render json: AccountSerializer.new(@account)
  end

  def update
    @account = Account.find(params[:id])
    if @account.id == accessing_account.id || accessing_account.is_admin?
      @account.update_attributes(params.permit(
        :name, :password, :password_confirmation
      ))

      render json: AccountSerializer.new(@account)
    else
      render json: { errors: ['Not Authenticated'] }, status: :unauthorized
    end
  end
end
