class SearchCommunityByLatAndLonService
  attr_reader :communities


  def find_communities(lat, lon, search_options = nil, exclude_community=nil, limit=2)
    @communities = []
    search_options ||= default_search_options
    
    search_options[:where][:location] = {near: {lat: lat, lon: lon}}
    search_options[:limit] = limit

    search_options[:order] = {_geo_distance: {location: "#{lat},#{lon}", order: :asc, unit: :mi}}

    order_params.each do |order_params|
      break if @communities.size > 1
      search_options[:where][:location][:within] = order_params[:distance]
      search_options[:where]["cached_data.star_rating"] = order_params[:star_rating]
      communities_result = Community.search("*", search_options).to_a
      next if communities_result.empty?
      communities_result.each{|community| @communities.push(community) if !@communities.include?(community)  && exclude_community != community }
    end
  end

  private 

  def order_params
    raise "Write your own order_params like ex:"
    [
      {star_rating: 5 , distance: '50mi'},
    ]
  end

  def default_search_options
    {
      fields: ['name', 'description'],
      match: :word_start,
      where: {
        status: Community::STATUS_ACTIVE,
      },
      includes: [:community_images]

    }
  end
end