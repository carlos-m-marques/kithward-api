
class CommunityPoisController < ApplicationController
  before_action :admin_account_required!, except: [:index]

  def index
    community = Community.find(params[:community_id])

    unless community.is_active? or (accessing_account and accessing_account.is_admin?)
      raise ActiveRecord::RecordNotFound
    end

    render json: PoiSerializer.render(community.pois)
  end

  def create
    community = Community.find(params[:community_id])

    unless community.is_active? or (accessing_account and accessing_account.is_admin?)
      raise ActiveRecord::RecordNotFound
    end

    poi = Poi.find(params[:id])

    community.pois << poi unless community.pois.exists?(poi.id)

    render json: PoiSerializer.render(community.pois)
  end

  def destroy
    community = Community.find(params[:community_id])

    unless community.is_active? or (accessing_account and accessing_account.is_admin?)
      raise ActiveRecord::RecordNotFound
    end

    poi = Poi.find(params[:id])

    community.pois.delete(poi.id)

    render json: PoiSerializer.render(community.pois)
  end
end
