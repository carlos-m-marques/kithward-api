module Admin
  class UnitsController < ActionController::API
    rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
    before_action :set_community
    # before_action :admin_account_required!

    def index
      page = params[:page] || 1
      per = params[:limit] || 30

      units = @community.units

      units = units.only_deleted if params[:deleted]
      units = units.flagged if params[:flagged]

      total = units.count
      units = units.page(page).per(per)

      pagination = {
        total_pages: units.total_pages,
        current_page: units.current_page,
        next_page: units.next_page,
        prev_page: units.prev_page,
        first_page: units.first_page?,
        last_page: units.last_page?,
        per_page: units.limit_value,
        total: total
      }.compact

      render json: { results: Admin::UnitSerializer.render_as_hash(units, view: 'list'), meta: pagination }
    end

    def super_classes
      page = params[:page] || 1
      per = params[:limit] || 30

      total = UnitSuperClass.count
      super_classes = UnitSuperClass.page(page).per(per)

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
      super_class = UnitSuperClass.find(params[:id])

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
      unit = Unit.find(params[:id])
      render json:  Admin::UnitSerializer.render(unit, view: 'complete')
    end

    def flag
      unit = Unit.find(params[:id])
      if unit.toggle_flag!
        render json: { flag: true }
      else
        render json: { flag: false }
      end
    end

    def update
      unit = Unit.find(params[:id])

      if unit.update_attributes(unit_params)
        render json:  Admin::UnitSerializer.render(unit, view: 'complete')
      else
        render json: { errors: unit.errors}, status: :unprocessable_entity
      end
    end

    def destroy
      # unit = @community.units.find(params[:id])
      #
      # if unit.destroy!
      #   head :no_content
      # else
      #   render json: { errors: unit.errors}, status: :unprocessable_entity
      # end
      head :no_content
    end

    def create
      unit = Unit.new(unit_params)

      if unit.save
        render json:  Admin::UnitSerializer.render(unit, view: 'complete')
      else
        render json: { errors: unit.errors}, status: :unprocessable_entity
      end
    end

    private

    def unit_params
      params.permit(:name, :is_available, :date_available, :rent_market, :unit_number, :building_id, :unit_type_id, kw_value_ids: [])
    end

    def record_not_found(error)
      render json: { errors: error.message }, status: :unprocessable_entity
    end

    def set_community
      @community ||= Community.find(params[:community_id])
    end
  end
end
