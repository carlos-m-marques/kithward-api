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

    if params[:geo]
      geo = GeoPlace.find_by_id(params[:geo])
      if geo
        search_options[:where][:location] = {near: {lat: geo.lat, lon: geo.lon}}
        if params[:distance]
          search_options[:where][:location][:within] = params[:distance]
        else
          search_options[:where][:location][:within] = "20mi"
        end
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

    search_options[:limit] = params[:limit] || 20
    search_options[:offset] = params[:offset] || 0

    @communities = Community.search(params[:q] || "*", search_options)

    render json: CommunitySerializer.render(@communities.to_a, view: (params[:view] || 'simple'))
  end

  def show
    @community = Community.find(params[:id])

    if @community.is_active? or (accessing_account and accessing_account.is_admin?)
      render json: CommunitySerializer.render(@community, view: 'complete')
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def update
    @community = Community.find(params[:id])

    @community.attributes = params.permit(
      :care_type, :status,
      :name, :description,
      :street, :street_more, :city, :state, :postal, :country,
      :lat, :lon, :website, :phone, :fax, :email
    )

    if params[:data]
      params[:data].permit!
      @community.data = @community.data.merge(params[:data])
    end

    if params[:images]
      for data in params[:images]
        if data && data[:id] && data[:id] > 0
          image = @community.community_images.find_by_id(data[:id])
          if data[:deleted] == 'deleted'
            image.destroy
          else
            image && image.update_attributes(data.permit(:caption, :tags, :sort_order))
          end
        elsif data && data[:data] && data[:data] =~ /^data:(.*)/
          content_type = data[:data][/(image\/[a-z]{3,4})|(application\/[a-z]{3,4})/]
          content_type = content_type[/\b(?!.*\/).*/]

          encoded_data = data[:data].gsub(/data:((image|application)\/.{3,}),/, '')
          decoded_data = Base64.decode64(encoded_data).force_encoding("ASCII-8BIT")

          filename = 'image_' + Time.now.to_s + '.' + content_type
          tempfile = Tempfile.new(filename, encoding: "ASCII-8BIT")
          tempfile.write(decoded_data)
          tempfile.rewind
          image = @community.community_images.create(data.permit(:caption, :tags, :sort_order))
          image.image.attach(io: tempfile, filename: filename)
          tempfile.close
          tempfile.unlink
        end
      end
      
      @community.community_images.reload
      @community.update_cached_image_url!
    end

    @community.save

    if @community.errors.any?
      render json: { errors: @community.errors}, status: :unprocessable_entity
    else
      render json: CommunitySerializer.render(@community, view: 'complete')
    end
  end

  def create
    @community = Community.new

    @community.attributes = params.permit(
      :care_type, :status,
      :name, :description,
      :street, :street_more, :city, :state, :postal, :country,
      :lat, :lon, :website, :phone, :fax, :email
    )

    if params[:data]
      params[:data].permit!
      @community.data = (@community.data || {}).merge(params[:data])
    end

    @community.save

    if @community.errors.any?
      render json: { errors: @community.errors}, status: :unprocessable_entity
    else
      render json: CommunitySerializer.render(@community, view: 'complete')
    end
  end

  def dictionary
    render json: DataDictionary::Community.to_h
  end

end
