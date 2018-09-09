
class LeadsController < ApplicationController
  before_action :admin_account_required!, except: [:create]

  def create
    @lead = Lead.create(params.permit(
      :name, :phone, :email, :community_id, :request, :message
    ).merge(account_id: accessing_account&.id))


    if @lead.errors.any?
      render json: { errors: @lead.errors}, status: :unprocessable_entity
    else
      render json: LeadSerializer.new(@lead)
    end
  end

end
