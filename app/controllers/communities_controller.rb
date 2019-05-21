require 'tempfile'

class CommunitiesController < ApplicationController
  before_action :admin_account_required!, except: [:index, :show, :dictionary]

  def index
    search_options = {
      fields: ['name', 'description'],
      match: :word_start,
      where: {
        status: Community::STATUS_ACTIVE,
      },
      includes: [:community_images]
    }

    if accessing_account and accessing_account.is_admin?
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
      search_options[:where][:monthly_rent_lower_bound] = {
        gt: params[:lower_rent_bound].to_i,
        lt: params[:upper_rent_bound].to_i
      }
    end

    communities = Community.search(params[:q] || "*", search_options).to_a

    if params[:meta]
      result = {
        results: CommunitySerializer.render_as_json(communities, view: (params[:view] || 'simple')),
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
      result = CommunitySerializer.render(communities, view: (params[:view] || 'simple'))
    end

    render json: result
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
      :lat, :lon, :website, :phone, :fax, :email
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
      render json: CommunitySerializer.render(community, view: 'complete')
    end
  end

  def create
    community = Community.new

    community.attributes = params.permit(
      :care_type, :status,
      :name, :description,
      :street, :street_more, :city, :state, :postal, :country,
      :lat, :lon, :website, :phone, :fax, :email
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
end
