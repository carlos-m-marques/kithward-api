class SimilarNearCommunityService
  attr_reader :communities

  def initialize(community_base, search_options = nil)
    return unless community_base
    @communities = []

    search_options ||= default_search_options
    search_options[:where][:location] = {near: {lat: community_base.lat, lon: community_base.lon}}
    search_options[:order] = {_geo_distance: {location: "#{community_base.lat},#{community_base.lon}", order: :asc, unit: :mi}}
    search_options[:limit] = 3
    search_options[:where][:care_type] = community_base.care_type
    search_options[:where][:location][:within] = '100mi'
    search_options[:where]["star_rating"] = (community_base.cached_data&.dig("star_rating") || 5)

    communities_result = Community.search("*", search_options).to_a
    return if communities_result.empty?
    communities_result.each{|community| @communities.push(community) if !@communities.include?(community)  && community_base != community }
  end

  private 

  def default_search_options
    {
      fields: ['name', 'description'],
      match: :word_start,
      where: {
        status: Community::STATE_ACTIVE,
      },
      includes: [:community_images]

    }
  end
end