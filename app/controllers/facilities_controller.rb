
class FacilitiesController < ApplicationController
  def index
    @facilities = Facility.all

    render json: FacilitySerializer.new(@facilities)
  end

  def show
    @facility = Facility.find(params[:id])

    render json: FacilitySerializer.new(@facility)
  end
end
