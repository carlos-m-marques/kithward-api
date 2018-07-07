
class CommunitiesController < ApplicationController
  before_action :admin_account_required!, except: [:index, :show, :dictionary]

  def index
    search_options = {
      fields: ['name', 'description'],
      match: :word_start,
    }

    search_options[:limit] = params[:limit] || 20
    search_options[:offset] = params[:offset] || 0

    @communities = Community.search(params[:q], search_options)

    render json: CommunitySerializer.new(@communities)
  end

  def show
    @community = Community.find(params[:id])

    render json: CommunitySerializer.new(@community)
  end

  def update
    @community = Community.find(params[:id])

    @community.update_attributes(params.permit(
      :name, :description,
      :is_independent, :is_assisted, :is_nursing, :is_memory, :is_ccrc,
      :address, :address_more, :city, :state, :postal, :country,
      :lat, :lon, :website, :phone, :fax, :email
    ))

    if @community.errors.any?
      render json: { errors: @community.errors}, status: :unprocessable_entity
    else
      render json: CommunitySerializer.new(@community)
    end
  end

  def dictionary
    render json: DataDictionary::Community.to_h
  end

end
