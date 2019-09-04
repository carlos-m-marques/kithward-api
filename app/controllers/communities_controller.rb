require 'tempfile'

class CommunitiesController < ApiController
  before_action :admin_account_required!, except: [:index, :show, :dictionary, :near_by_ip, :similar_near, :by_area, :favorite, :available, :share]

  def share
    @community = Community.find(community_share_params[:id])

    if community_share_params[:to]
      ShareMailerWorker.perform_async(community_share_params.merge(
        community_name: @community.name, community_slug: @community.slug
      ).to_json)

      render json: { results: "Shared with #{community_share_params[:to]}" }
    else
      render json: { errors: "parameter :to required!" }, status: :unprocessable_entity
    end
  end

  def favorite
    @community = Community.find(community_params[:id])

    if @community.favorited_by.find_by(id: current_account.id)
      render json: { errors: { favorited: "#{current_account.id} already favorited this community!" }}, status: :unprocessable_entity
    else
      @community.favorited_by << current_account
      render json: CommunitySerializer.render(@community, favorited_options(view: 'complete'))
    end
  end

  def unfavorite
    @community = Community.find(community_params[:id])
    @community.favorited_by.delete(current_account)

    head :no_content
  end

  def available
    page = params[:page] || 1
    per = params[:limit] || 30
    total = 0

    if params[:query]
      search_params = { groupings: { '0' => { m: 'or',  name_contains: community_available_params[:query] } } }
      @communities = Community.ransack(search_params).result(distinct: true)
      total = @communities.count(:id)
      @communities = @communities.select(:id, :name).page(page).per(per)
    else
      @communities = Community.select(:id, :name).recent.page(page).per(per)
      total = Community.count(:id)
    end



    pagination = {
      total_pages: @communities.total_pages,
      current_page: @communities.current_page,
      next_page: @communities.next_page,
      prev_page: @communities.prev_page,
      first_page: @communities.first_page?,
      last_page: @communities.last_page?,
      per_page: @communities.limit_value,
      total: total
    }.compact


    render json: { results: @communities, meta: pagination }
  end

  def index
    search_options = default_search_options

    if current_account and current_account.is_admin?
      search_options[:where][:status] = [ Community::STATUS_ACTIVE, Community::STATUS_DRAFT ]
    end

    if params[:geo]
      geo = GeoPlace.find_by_id(params[:geo])

      if !geo && (params[:geoLabel] || params[:geo_label])
        parts = (params[:geoLabel] || params[:geo_label]).split(/[ -]+/).reject {|p| p.blank?}

        geo_search_options = {
          fields: ['name'],
          match: :word_start,
          where: {state: parts[-1].upcase},
          limit: 1
        }

        geo = GeoPlace.search(parts[0..-2].join(" "), geo_search_options).first
        if geo
          new_params = params.permit(:care_type, :distance, :geo, :geoLabel, :geo_label, :limit, :offset, :view, :meta)
          new_params[:geo] = geo.id

          redirect_to communities_url(new_params), :status => :moved_permanently
        else
          render nothing: true, status: 404 and return
        end
        return
      end

      if geo
        search_options[:where][:location] = {near: {lat: geo.lat, lon: geo.lon}}
        search_options[:where][:location][:within] = params[:distance] || "20mi"
      end
    end

    if params[:care_type]
      case params[:care_type].downcase
      when 'i', 'independent'
        search_options[:where][:care_type] = Community::TYPE_INDEPENDENT
      when 'a', 'assisted'
        search_options[:where][:care_type] = Community::TYPE_ASSISTED
      when 'n', 'nursing'
        search_options[:where][:care_type] = Community::TYPE_NURSING
      when 'm', 'memory'
        search_options[:where][:care_type] = Community::TYPE_MEMORY
      end
    end

    if params[:units_available]
      search_options[:where][:units_available] = params[:units_available] == 'true'
    end

    search_options[:limit] = params[:limit] || 20
    search_options[:offset] = params[:offset] || 0

    if params[:lower_rent_bound].present? && params[:upper_rent_bound].present?
      search_options[:where][:_or] = [
        {
          monthly_rent_lower_bound: {
            gt: params[:lower_rent_bound].to_i,
            lt: params[:upper_rent_bound].to_i
          }
        },
        {
          monthly_rent_upper_bound: {
            gt: params[:lower_rent_bound].to_i,
            lt: params[:upper_rent_bound].to_i
          }
        }
      ]
    end

    communities = Community.search(params[:q] || "*", search_options).to_a

    if params[:meta]
      result = {
        results: CommunitySerializer.render_as_json(communities, favorited_options(view: (params[:view] || 'simple'))),
        meta: {
          params: {
            query: (params[:q] || "*"),
            limit: (params[:limit] || 20),
            offset: params[:offset] || 0,
          }
        }
      }

      if geo
        result[:meta][:params][:geo] = geo.idstr
        result[:meta][:params][:geo_name] = geo.full_name
        result[:meta][:params][:lat] = geo.lat
        result[:meta][:params][:lon] = geo.lon
        result[:meta][:params][:distance] = params[:distance] || "20mi"
      end
    else
      result = CommunitySerializer.render(communities, favorited_options(view: (params[:view] || 'simple')))
    end

    render json: result
  end

  def show
    community = Community.find(community_share_params[:id])

    if community_share_params[:tracking]
      community.shared!(tracking: community_share_params[:tracking])
    end

    if community.is_active? or (current_account and current_account.is_admin?)
      render json: CommunitySerializer.render(community, favorited_options(view: 'complete'))
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
      render json: CommunitySerializer.render(community, favorited_options(view: 'complete'))
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
      render json: CommunitySerializer.render(community, favorited_options(view: 'complete'))
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
    render json: CommunitySerializer.render(near_by_ip_service.communities.sample(2), favorited_options(view: 'simple'))
  end

  def similar_near
    similar_near_community_service = SimilarNearCommunityService.new(Community.find(params[:id]), default_search_options)
    render json: CommunitySerializer.render(similar_near_community_service.communities, favorited_options(view: 'simple'))
  end

  def by_area
    by_area_service = Community::ByAreaService.search(type: params[:type].to_s, value: params[:value], params: params)
    render json: { errors: by_area_service.error }, status: 404 and return unless by_area_service.valid?
    render json: by_area_service.values
  end

  private

  def favorited_options(options)
    if current_account
      options.merge({ current_account_id: current_account.id })
    else
      options
    end
  end

  def community_params
    params.permit(:id)
  end

  def community_available_params
    params.permit(:limit, :page, :query)
  end

  def community_share_params
    params.permit(:id, :to, :from, :origin, :message, :tracking, tracking: [], tracking: {})
  end

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
