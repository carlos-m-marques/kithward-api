class SimilarNearCommunityService < SearchCommunityByLatAndLonService

  def initialize(community, search_options = nil)
    @community = community
    @communities = []

    return unless @community

    find_communities(@community.lat, @community.lon, search_options, community, 3)
  end

  private 

  def order_params
    [
      {star_rating: @community.cached_data&.dig("star_rating") , distance: '100mi'},
    ]
  end
end