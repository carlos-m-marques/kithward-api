
class FacilitiesController < ApplicationController
  before_action :admin_account_required!, except: [:index, :show]

  def index
    search_options = {
    }

    search_options[:limit] = params[:limit] || 20
    search_options[:offset] = params[:offset] || 0

    @facilities = Facility.search(params[:q], search_options)

    render json: FacilitySerializer.new(@facilities)
  end

  def show
    @facility = Facility.find(params[:id])

    render json: FacilitySerializer.new(@facility)
  end

  def update
    @facility = Facility.find(params[:id])

    @facility.update_attributes(params.permit(
      :name, :description,
      :is_independent, :is_assisted, :is_nursing, :is_memory, :is_ccrc,
      :address, :address_more, :city, :state, :postal, :country,
      :lat, :lon, :website, :phone, :fax, :email
    ))

    if @facility.errors.any?
      render json: { errors: @facility.errors}, status: :unprocessable_entity
    else
      render json: FacilitySerializer.new(@facility)
    end
  end
end
