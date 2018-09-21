if Rails.env.production? && ENV['HEROKU_APP_NAME'] == 'kwapi'
  require 'ddtrace'

  Datadog.configure do |c|
    c.use :rails, service_name: ENV['HEROKU_APP_NAME']
  end
end
