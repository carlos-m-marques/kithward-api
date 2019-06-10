class IpdataService
  attr_reader :response
  def initialize(ip=nil)
    @ip = ip
    call
  end

  def body
    @body ||= begin 
      return unless @response && @response&.body
      JSON @response&.body
    end
  end

  def latitude
    body&.dig('latitude')
  end

  def longitude
    body&.dig('longitude')
  end

  private

  def call
    api_key = Rails.application.credentials.dig(:ipdata, :api_key)
    @response = Faraday.get("https://api.ipdata.co/#{@ip}?api-key=#{api_key}")
  end
end