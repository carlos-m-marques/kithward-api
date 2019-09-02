
class AccountsController < ApiController
  load_and_authorize_resource

  def favorites
    communities = current_account.favorites
    total = communities.count

    page = params[:page] || 1
    per = params[:limit] || 30

    communities = communities.page(page).per(per)

    pagination = {
      total_pages: communities.total_pages,
      current_page: communities.current_page,
      next_page: communities.next_page,
      prev_page: communities.prev_page,
      first_page: communities.first_page?,
      last_page: communities.last_page?,
      per_page: communities.limit_value,
      total: total
    }.compact

    render json: { results: CommunitySerializer.render_as_hash(communities, view: 'simple'), meta: pagination }
  end

  def account_favorites
    @account = Account.find(params[:id])

    communities = @account.favorites
    total = communities.count

    page = params[:page] || 1
    per = params[:limit] || 30

    communities = communities.page(page).per(per)

    pagination = {
      total_pages: communities.total_pages,
      current_page: communities.current_page,
      next_page: communities.next_page,
      prev_page: communities.prev_page,
      first_page: communities.first_page?,
      last_page: communities.last_page?,
      per_page: communities.limit_value,
      total: total
    }.compact

    render json: { results: CommunitySerializer.render_as_hash(communities, view: 'simple'), meta: pagination }
  end

  def index
    page = params[:page] || 1
    per = params[:limit] || 30

    @accounts = Account.accessible_by(current_ability)

    total = @accounts.count
    @accounts = @accounts.page(page).per(per)

    pagination = {
      total_pages: @accounts.total_pages,
      current_page: @accounts.current_page,
      next_page: @accounts.next_page,
      prev_page: @accounts.prev_page,
      first_page: @accounts.first_page?,
      last_page: @accounts.last_page?,
      per_page: @accounts.limit_value,
      total: total
    }.compact

    render json: { results: AccountSerializer.render_as_hash(@accounts), meta: pagination }
  end

  def exception
    raise "Test Exception"
  end

  def show
    if params[:id] == 'self'
      params[:id] = current_account.id
    end

    @account = Account.find(params[:id])
    render json: AccountSerializer.render(@account, view: 'show')
  end

  def create
    account = Account.create(account_params)

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


    if params[:id] == current_account.id || current_account.is_admin?
      @account = Account.find(params[:id])
      @account.update_attributes(account_params)

      if @account.errors.any?
        render json: { errors: @account.errors}, status: :unprocessable_entity
      else
        render json: AccountSerializer.render(@account)
      end
    else
      render json: { errors: ['Not Authorized'] }, status: :unauthorized
    end
  end

  def account_params
    allowed_params = [:email, :name, :password, :password_confirmation]

    allowed_params.push(:role) if can? :manage, Account

    params.permit allowed_params
  end
end
