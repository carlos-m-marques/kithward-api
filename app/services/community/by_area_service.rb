class Community::ByAreaService
  RESULT = Struct.new(:valid?, :error, :values)
  ALLOWED_AREAS = ["country", "state", "city", "region", "metro", "borough", "county", "township", "postal"]

  def self.search(type:, value:, params: {})
    return error("Missing 'type' and/or 'value'.") unless type.present? && value.present?
    return error("Wrong type value. The following are valid: #{ALLOWED_AREAS.join(' , ')}.") unless ALLOWED_AREAS.include?(type.to_s)
    search_options = {
      where: {
        "#{type}": value
      },
      load: false,
      limit: 100
    }
    search_options.merge!({limit: params[:limit]}) if params[:limit]
    RESULT.new(true, nil, Community.search('*', search_options).results)
  end

  def self.error(msg)
    RESULT.new(false, msg)
  end

end