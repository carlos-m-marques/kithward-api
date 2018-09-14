Raygun.setup do |config|
  config.api_key = "iZxAzPCCR57j64S4k7nM4Q=="
  config.filter_parameters = Rails.application.config.filter_parameters

  # The default is Rails.env.production?
  # config.enable_reporting = !Rails.env.development? && !Rails.env.test?
end
