require 'tempfile'

module Admin
  class CommunitiesController < ActionController::API
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

      if community.is_active? or (accessing_account and accessing_account.is_admin?)
        render json: CommunitySerializer.render(community, view: 'complete')
      else
        raise ActiveRecord::RecordNotFound
      end
    end

    def update
      community = Community.find(params[:id])

      community.attributes = params.permit(
        :care_type, :status,
        :name, :description,
        :street, :street_more, :city, :state, :postal, :country,
        :lat, :lon, :website, :phone, :fax, :email, :community,
        :classes, :listings, :region, :metro, :borough, :county, :township
      )

      if params[:data]
        params[:data].permit!
        community.data = (community.data || {}).merge(params[:data])
      end

      if params[:pois]
        params[:pois].each {|data| CommunityPoisController.process_one_poi(community, data) }

        community.pois.reload
      end

      if params[:images]
        params[:images].each {|data| CommunityImagesController.process_one_image(community, data) }

        community.community_images.reload
        community.update_cached_image_url!
      end

      community.save

      if params[:listings]
        params[:listings].each {|data| ListingsController.process_one_listing(community, data) }

        community.listings.reload
        community.update_reflected_attributes_from_listings
      end

      if community.errors.any?
        render json: { errors: community.errors}, status: :unprocessable_entity
      else
        community.reindex
        render json: CommunitySerializer.render(community, view: 'complete')
      end
    end

    def create
      community = Community.new

      community.attributes = params.permit(
        :care_type, :status,
        :name, :description,
        :street, :street_more, :city, :state, :postal, :country,
        :lat, :lon, :website, :phone, :fax, :email, kw_values_ids: []
      )

      if params[:data]
        params[:data].permit!
        community.data = (community.data || {}).merge(params[:data])
      end

      community.save

      if params[:images]
        params[:images].each {|data| CommunityImagesController.process_one_image(community, data) }

        community.community_images.reload
        community.update_cached_image_url!
      end

      if params[:listings]
        params[:listings].each {|data| ListingsController.process_one_listing(community, data) }

        community.listings.reload
        community.update_reflected_attributes_from_listings
      end

      if community.errors.any?
        render json: { errors: community.errors}, status: :unprocessable_entity
      else
        community.reindex
        render json: CommunitySerializer.render(community, view: 'complete')
      end
    end

    def dictionary
      render json: {community: DataDictionary::Community.to_h, listing: DataDictionary::Listing.to_h}
    end

    def import
      # parameters:
      # - data
      # or
      # - entries, attrs (as returned by previous calls with 'data')
      #
      # - dry_run: don't save anything
      # - force_import: process entries matched by geolocation and simplified name, instead of just id or name

      params.permit!
      importer = CommunityImporter.new params

      unless params[:dryrun] || params[:dry_run]
        importer.import
      else
        importer.compare
      end

      render json: importer.to_h
    end

    def near_by_ip
      near_by_ip_service = NearByIpService.new(request.remote_ip, default_search_options)
      render json: CommunitySerializer.render(near_by_ip_service.communities.sample(2), view: 'simple')
    end

    def similar_near
      similar_near_community_service = SimilarNearCommunityService.new(Community.find(params[:id]), default_search_options)
      render json: CommunitySerializer.render(similar_near_community_service.communities, view: 'simple')
    end

    def by_area
      by_area_service = Community::ByAreaService.search(type: params[:type].to_s, value: params[:value], params: params)
      render json: { errors: by_area_service.error }, status: 404 and return unless by_area_service.valid?
      render json: by_area_service.values
    end

    private

    def default_search_options
      {
        fields: ['name', 'description'],
        match: :word_start,
        where: {
          status: Community::STATUS_ACTIVE,
        },
        includes: [:community_images]

      }
    end


  end
end
