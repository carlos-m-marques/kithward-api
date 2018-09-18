Raven.configure do |config|
  config.dsn = 'https://164d6ce586e242a1bd6f210f7f9f1a7f:f60b9a76a9ef4aa3bc33ff0fbfa1ef48@sentry.io/1283182'

  config.environments = %w[ production ]
  
  config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
end
