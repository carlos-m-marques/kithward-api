class AccountAccessRequestsController < ApiController
  load_and_authorize_resource

  rescue_from AASM::InvalidTransition, with: :invalid_transition

  def index
    page = params[:page] || 1
    per = params[:limit] || 30

    @account_access_requests = AccountAccessRequest
    @account_access_requests = AccountAccessRequest.approved if params[:approved]
    @account_access_requests = AccountAccessRequest.rejected if params[:rejected]
    @account_access_requests = AccountAccessRequest.pending if params[:pending]

    total = @account_access_requests.count
    @account_access_requests = @account_access_requests.page(page).per(per)

    pagination = {
      total_pages: @account_access_requests.total_pages,
      current_page: @account_access_requests.current_page,
      next_page: @account_access_requests.next_page,
      prev_page: @account_access_requests.prev_page,
      first_page: @account_access_requests.first_page?,
      last_page: @account_access_requests.last_page?,
      per_page: @account_access_requests.limit_value,
      total: total
    }.compact

    render json: { results:  AccountAccessRequestSerializer.render_as_hash(@account_access_requests), meta: pagination }
  end

  def show
    @account_access_request = AccountAccessRequest.find(account_access_request_params[:id])
    render json: AccountAccessRequestSerializer.render(@account_access_request, view: 'complete')
  end

  def create
    # rec = AccountAccessRequest.new(account_access_request_params)
    #
    # if rec.valid?
    #   File.write("#{Rails.root}/samples/#{params.to_unsafe_h[:controller].titleize.gsub(' ', '_')}-#{params.to_unsafe_h[:action]}.json", account_access_request_params.to_json)
    #
    #   render json: { params: account_access_request_params, data: AccountAccessRequestSerializer.render_as_hash(rec, view: 'complete') }
    # else
    #   render json: { errors: rec.errors}, status: :unprocessable_entity
    # end

    @account_access_request = AccountAccessRequest.create(account_access_request_params)

    if @account_access_request.errors.any?
      render json: { errors: @account_access_request.errors}, status: :unprocessable_entity
    else
      @account_access_request.submits!
      render json: AccountAccessRequestSerializer.render(@account_access_request, view: 'complete')
    end
  end

  def reject
    @account_access_request = AccountAccessRequest.find(params[:id])

    @account_access_request.reject! do
      render json: AccountAccessRequestSerializer.render(@account_access_request, view: 'complete')
    end
  end

  def approve
    @account_access_request = AccountAccessRequest.find(params[:id])

    @account_access_request.approve! do
      render json: AccountAccessRequestSerializer.render(@account_access_request, view: 'complete')
    end
  end

  def destroy
    @account_access_request = AccountAccessRequest.find(account_access_request_params[:id])

    if @account_access_request.destroy!
      head :no_content
    else
      render json: { errors: @account_access_request.errors}, status: :unprocessable_entity
    end
  end

  def update
    @account_access_request = AccountAccessRequest.find(account_access_request_params[:id])
    @account_access_request.update_attributes(account_access_request_params)

    if @account_access_request.errors.any?
      render json: { errors: @account_access_request.errors}, status: :unprocessable_entity
    else
      render json: AccountAccessRequestSerializer.render(@account_access_request, view: 'complete')
    end
  end

  private

  def invalid_transition(error)
    render json: { errors: [error.message] }, status: :unauthorized
  end

  def account_access_request_params
    params.permit(:id, :first_name, :last_name, :title, :phone_number, :company_name, :company_type, :reason, :work_email, community_ids: [], account_attributes: [:email, :name, :password, :password_confirmation, :owner_id])
  end
end
