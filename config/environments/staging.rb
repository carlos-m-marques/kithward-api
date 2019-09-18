# Just use the production settings
require File.expand_path('../production.rb', __FILE__)

Rails.application.configure do
  # Here override any defaults
  config.log_level = :debug
  config.active_job.queue_adapter = :sidekiq
  Dotenv::Railtie.load
  config.serve_static_files = true
  config.active_record.verbose_query_logs = true
end
