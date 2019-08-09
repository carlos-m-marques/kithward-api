require 'tempfile'

module Admin
  class CommunitiesController < ActionController::API
    rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
    # before_action :admin_account_required!

    def index
      page = params[:page] || 1
      per = params[:limit] || 30

      communities = Community.recent.page(page).per(per)
      pagination = {
        total_pages: communities.total_pages,
        current_page: communities.current_page,
        next_page: communities.next_page,
        prev_page: communities.prev_page,
        first_page: communities.first_page?,
        last_page: communities.last_page?,
        per_page: communities.limit_value,
        total: communities.unscoped.count
      }.compact

      render json: { results: Admin::CommunitySerializer.render_as_hash(communities, view: 'list'), meta: pagination }
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

    private

    def community_params
      params.permit(
        :care_type, :status,
        :name, :description,
        :street, :street_more, :city, :state, :postal, :country,
        :lat, :lon, :website, :phone, :fax, :email, :community,
        :classes, :listings, :region, :metro, :borough, :county, :township,
        :data, kw_value_ids: []
      )
    end

    def record_not_found(error)
      render json: { errors: error.message }, status: :unprocessable_entity
    end
  end
end
