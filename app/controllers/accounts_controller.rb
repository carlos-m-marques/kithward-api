
class AccountsController < ApiController
  before_action :authentication_required!, except: [:create, :exception]

  def index
    page = params[:page] || 1
    per = params[:limit] || 30

    total = Account.count
    accounts = Account.page(page).per(per)

    pagination = {
      total_pages: accounts.total_pages,
      current_page: accounts.current_page,
      next_page: accounts.next_page,
      prev_page: accounts.prev_page,
      first_page: accounts.first_page?,
      last_page: accounts.last_page?,
      per_page: accounts.limit_value,
      total: total
    }.compact

    render json: { results: AccountSerializer.render_as_hash(accounts), meta: pagination }
  end

  def exception
    raise "Test Exception"
  end

  def show
    if params[:id] == 'self'
      params[:id] = current_account.id
    end

    account = Account.find(params[:id])
    if account.id == current_account.id || current_account.is_admin?
      render json: AccountSerializer.render(account)
    else
      render json: { errors: ['Not Authorized'] }, status: :unauthorized
    end
  end

  def create
    account = Account.create(params.permit(
      :email, :name, :password, :password_confirmation
    ))

    if account.errors.any?
      render json: { errors: account.errors}, status: :unprocessable_entity
    else
      render json: AccountSerializer.render(account)
    end
  end

  def update
    if params[:id] == 'self'
      params[:id] = current_account.id
    end

    account = Account.find(params[:id])
    if account.id == current_account.id || current_account.is_admin?
      account.update_attributes(params.permit(
        :name, :password, :password_confirmation
      ))

      if account.errors.any?
        render json: { errors: account.errors}, status: :unprocessable_entity
      else
        render json: AccountSerializer.render(account)
      end
    else
      render json: { errors: ['Not Authorized'] }, status: :unauthorized
    end
  end
end
