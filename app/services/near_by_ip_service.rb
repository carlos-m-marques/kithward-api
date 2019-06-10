class NearByIpService
  attr_reader :communities

  def initialize(ip, search_options = nil)
    @communities = []
    ipdata = IpdataService.new(ip)
    return unless ipdata.latitude && ipdata.longitude

    limit = 10
    @communities_size_limit = 2

    search_options ||= default_search_options
    search_options[:where][:location] = {near: {lat: ipdata.latitude, lon: ipdata.longitude}}
    search_options[:order] = {_geo_distance: {location: "#{ipdata.latitude},#{ipdata.longitude}", order: :asc, unit: :mi}}
    search_options[:limit] = limit

    order_params.each do |order_params|
      break if @communities.size >= @communities_size_limit
      search_options[:where][:location][:within] = order_params[:distance]
      search_options[:where]["cached_data.star_rating"] = order_params[:star_rating]
      search_options[:offset] = 0
      while true
        communities_result = Community.search("*", search_options).to_a
        break if communities_result.empty?
        communities_result.each{|community| @communities.push(community) if can_be_pushed(community) }
        break if communities_result.size < limit || @communities.size >= @communities_size_limit
        search_options[:offset] += limit
      end

    end
  end

  private 

  def can_be_pushed(community)
    return false if @communities.include?(community) || @communities.size >= @communities_size_limit
    related_community = @communities.any?{ |added_community| added_community.is_related?(community) }
    return !related_community
  end

  def order_params
    [
      {star_rating: 5 , distance: '50mi'},
      {star_rating: 4 , distance: '50mi'},
      {star_rating: 3 , distance: '50mi'},
      {star_rating: 5 , distance: '200mi'},
      {star_rating: 4 , distance: '200mi'},
      {star_rating: 3 , distance: '200mi'},
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