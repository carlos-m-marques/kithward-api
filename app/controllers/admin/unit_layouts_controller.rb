module Admin
  class UnitLayoutsController < ApiController
    before_action :set_community
    # before_action :admin_account_required!

    def index
      page = params[:page] || 1
      per = params[:limit] || 30

      unit_layouts = @community.unit_layouts

      unit_layouts = unit_layouts.only_deleted if params[:deleted]
      unit_layouts = unit_layouts.flagged if params[:flagged]

      total = unit_layouts.count
      unit_layouts = unit_layouts.page(page).per(per)

      pagination = {
        total_pages: unit_layouts.total_pages,
        current_page: unit_layouts.current_page,
        next_page: unit_layouts.next_page,
        prev_page: unit_layouts.prev_page,
        first_page: unit_layouts.first_page?,
        last_page: unit_layouts.last_page?,
        per_page: unit_layouts.limit_value,
        total: total
      }.compact

      render json: { results: Admin::UnitTypeSerializer.render_as_hash(unit_layouts, view: 'list'), meta: pagination }
    end

    def super_classes
      page = params[:page] || 1
      per = params[:limit] || 30

      total = UnitTypeSuperClass.count
      super_classes = UnitTypeSuperClass.page(page).per(per)

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
      super_class = UnitTypeSuperClass.find(params[:id])

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
      unit_layout = @community.unit_layouts.find(params[:id])
      render json:  Admin::UnitTypeSerializer.render(unit_layout, view: 'complete')
    end

    def flag
      unit_layout = @community.unit_layouts.find(params[:id])

      if unit_layout.flagged?
        unit_layout.unflag!
      else
        unit_layout.flag!(reason: unit_layout_params[:reason]) unless unit_layout.flagged?
      end

      render json: { flag: unit_layout.flagged?, reason: unit_layout.flagged_for }.compact
    end

    def update
      unit_layout = @community.unit_layouts.find(params[:id])

      if unit_layout.update_attributes(unit_layout_params)
        render json:  Admin::UnitTypeSerializer.render(unit_layout, view: 'complete')
      else
        render json: { errors: unit_layout.errors}, status: :unprocessable_entity
      end
    end

    def destroy
      unit_layout = @community.unit_layouts.find(params[:id])

      if unit_layout.destroy!
        head :no_content
      else
        render json: { errors: unit_layout.errors}, status: :unprocessable_entity
      end
    end

    def create
      unit_layout = @community.unit_layouts.new(unit_layout_params)

      if unit_layout.save
        render json:  Admin::UnitTypeSerializer.render(unit_layout, view: 'complete')
      else
        render json: { errors: unit_layout.errors}, status: :unprocessable_entity
      end
    end

    private

    def unit_layout_params
      params.permit(:name, :reason, :community_id, kw_value_ids: [])
    end

    def set_community
      @community ||= Community.find(params[:community_id])
    end
  end
end
