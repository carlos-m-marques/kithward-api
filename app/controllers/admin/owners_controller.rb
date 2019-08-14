module Admin
  class OwnersController < ActionController::API
    rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
    # before_action :admin_account_required!

    def index
      page = params[:page] || 1
      per = params[:limit] || 30

      owners = if params[:sort_field] && params[:sort_direction]
        Owner.by_column(params[:sort_field], params[:sort_direction])
      else
         Owner.recent
      end

      owners = owners.only_deleted if params[:deleted]

      total = owners.count
      owners = owners.page(page).per(per)

      pagination = {
        total_pages: owners.total_pages,
        current_page: owners.current_page,
        next_page: owners.next_page,
        prev_page: owners.prev_page,
        first_page: owners.first_page?,
        last_page: owners.last_page?,
        per_page: owners.limit_value,
        total: total
      }.compact

      render json: { results: Admin::OwnerSerializer.render_as_hash(owners, view: 'list'), meta: pagination }
    end

    def super_classes
      page = params[:page] || 1
      per = params[:limit] || 30

      total = OwnerSuperClass.count
      super_classes = OwnerSuperClass.page(page).per(per)

      pagination = {
        total_pages: super_classes.total_pages,
        current_page: super_classes.current_page,
        next_page: super_classes.next_page,
        prev_page: super_classes.prev_page,
        first_page: super_classes.first_page?,
        last_page: super_classes.last_page?,
        per_page: super_classes.limit_value,
        total: total
      }.compact

      render json: { results: Admin::KwSuperClassSerializer.render_as_hash(super_classes), meta: pagination }
    end

    def kw_classes
      super_class = OwnerSuperClass.find(params[:id])

      page = params[:page] || 1
      per = params[:limit] || 30


      kw_classes = super_class.kw_classes
      total = kw_classes.count

      kw_classes = kw_classes.page(page).per(per)

      pagination = {
        total_pages: kw_classes.total_pages,
        current_page: kw_classes.current_page,
        next_page: kw_classes.next_page,
        prev_page: kw_classes.prev_page,
        first_page: kw_classes.first_page?,
        last_page: kw_classes.last_page?,
        per_page: kw_classes.limit_value,
        total: total
      }.compact

      render json: { results: Admin::KwClassSerializer.render_as_hash(kw_classes), meta: pagination }
    end

    def kw_attributes
      kw_class = KwClass.find(params[:id])

      page = params[:page] || 1
      per = params[:limit] || 30


      kw_attributes = kw_class.kw_attributes
      total = kw_attributes.count

      kw_attributes = kw_attributes.page(page).per(per)

      pagination = {
        total_pages: kw_attributes.total_pages,
        current_page: kw_attributes.current_page,
        next_page: kw_attributes.next_page,
        prev_page: kw_attributes.prev_page,
        first_page: kw_attributes.first_page?,
        last_page: kw_attributes.last_page?,
        per_page: kw_attributes.limit_value,
        total: total
      }.compact

      render json: { results: Admin::KwAttributeSerializer.render_as_hash(kw_attributes), meta: pagination }
    end

    def show
      owner = Owner.find(params[:id])
      render json:  Admin::OwnerSerializer.render(owner, view: 'complete')
    end

    def update
      owner = Owner.find(params[:id])

      if owner.update_attributes(owner_params)
        render json:  Admin::OwnerSerializer.render(owner, view: 'complete')
      else
        render json: { errors: owner.errors}, status: :unprocessable_entity
      end
    end

    def destroy
      owner = Owner.find(params[:id])

      if owner.destroy!
        head :no_content
      else
        render json: { errors: owner.errors}, status: :unprocessable_entity
      end
    end

    def create
      owner = Owner.new(owner_params)

      if owner.save
        render json:  Admin::OwnerSerializer.render(owner, view: 'complete')
      else
        render json: { errors: owner.errors}, status: :unprocessable_entity
      end
    end

    private

    def owner_params
      params.permit(:name, :address1, :address2, :city, :state, :zip, :pm_system_id, kw_value_ids: [])
    end

    def record_not_found(error)
      render json: { errors: error.message }, status: :unprocessable_entity
    end
  end
end
