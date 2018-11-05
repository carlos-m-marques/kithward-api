
class LeadsController < ApplicationController
  before_action :admin_account_required!, except: [:create]

  def create
    @lead = Lead.new(params.permit(
      :name, :phone, :email, :community_id, :request, :message
    ).merge(account_id: accessing_account&.id))

    if params[:data]
      params[:data].permit!
      @lead.data = params[:data]
    end

    @lead.save

    if @lead.errors.any?
      render json: { errors: @lead.errors}, status: :unprocessable_entity
    else
      render json: LeadSerializer.render(@lead)
    end
  end

end
