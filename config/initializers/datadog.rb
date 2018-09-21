if Rails.env.production?
  Datadog.configure do |c|
    c.use :rails, service_name: 'kwapi'
  end
end
