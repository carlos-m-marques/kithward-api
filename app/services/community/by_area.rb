class Community::ByArea

  ALLOWED_AREAS = ["country", "state", "city", "region", "metro", "borough", "county", "township", "postal"]

  def self.search(type:, value:)
    return unless ALLOWED_AREAS.include?(type.to_s)
    search_options = {
      where: {
        "#{type}": value
      },
      load: false,
      limit: 100
    }
    search_options = yield(search_options) if block_given?
    Community.search('*', search_options)
  end

end