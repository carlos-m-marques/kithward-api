class NearByIpService < SearchCommunityByLatAndLonService

  def initialize(ip, search_options = nil)
    @communities = []
    ipdata = IpdataService.new(ip)

    return unless ipdata.latitude && ipdata.longitude

    find_communities(ipdata.latitude, ipdata.longitude, search_options)
  end

  private 

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
end