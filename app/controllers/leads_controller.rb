
class LeadsController < ApiController
  before_action :admin_account_required!, except: [:create]

  def create
    lead = Lead.create(params.permit(
      :name, :phone, :email, :community_id, :request, :message
    ).merge(account_id: accessing_account&.id)) do |new_lead|
      if params[:data]
        params[:data].permit!
        new_lead.data = params[:data]
      end
    end

    if lead.errors.any?
      render json: { errors: lead.errors}, status: :unprocessable_entity
    else
      render json: LeadSerializer.render(lead)
    end
  end

end
