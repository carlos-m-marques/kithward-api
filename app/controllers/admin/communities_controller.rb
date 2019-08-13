module Admin
  class CommunitiesController < ActionController::API
    rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
    # before_action :admin_account_required!

    def index
      page = params[:page] || 1
      per = params[:limit] || 30

      communities = if params[:sort_field] && params[:sort_direction]
        Community.by_column(params[:sort_field], params[:sort_direction])
      else
         Community.recent
      end

      total = communities.count
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

      render json: { results: Admin::CommunitySerializer.render_as_hash(communities, view: 'list'), meta: pagination }
    end

    def super_classes
      page = params[:page] || 1
      per = params[:limit] || 30

      super_classes = case params[:care_type]
      when Community::TYPE_INDEPENDENT then CommunitySuperClass.independent_living
      when Community::TYPE_ASSISTED then CommunitySuperClass.assisted_living
      when Community::TYPE_NURSING then CommunitySuperClass.skilled_nursing
      when Community::TYPE_MEMORY then CommunitySuperClass.memory_care
      else
        CommunitySuperClass
      end

      total = super_classes.count
      super_classes = super_classes.page(page).per(per)

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
      super_class = CommunitySuperClass.find(params[:id])

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
      community = Community.find(params[:id])
      render json:  Admin::CommunitySerializer.render(community, view: 'complete')
    end

    def update
      community = Community.find(params[:id])

      if community.update_attributes(community_params)
        # shoud not be here... this should be asynchronous.
        # community.reindex
        render json:  Admin::CommunitySerializer.render(community, view: 'complete')
      else
        render json: { errors: community.errors}, status: :unprocessable_entity
      end
    end

    def destroy
      community = Community.find(params[:id])

      if community.destroy!
        head :no_content
      else
        render json: { errors: community.errors}, status: :unprocessable_entity
      end
    end

    def create
      community = Community.new(community_params)
      community.pm_system = community.owner.pm_system if community.owner

      if community.save
        render json:  Admin::CommunitySerializer.render(community, view: 'complete')
      else
        render json: { errors: community.errors}, status: :unprocessable_entity
      end
    end

    private

    def community_params
      params.permit(
        :care_type, :status,
        :name, :description,
        :street, :street_more, :city, :state, :postal, :country,
        :lat, :lon, :website, :phone, :fax, :email, :community,
        :classes, :listings, :region, :metro, :borough, :county, :township,
        :data, :owner_id, :pm_system_id, kw_value_ids: []
      )
    end

    def record_not_found(error)
      render json: { errors: error.message }, status: :unprocessable_entity
    end
  end
end
