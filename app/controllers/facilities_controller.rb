
class FacilitiesController < ApplicationController
  before_action :authenticate_request!, except: [:index, :show]

  def index
    @facilities = Facility.all

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

    render json: FacilitySerializer.new(@facility)
  end
end
