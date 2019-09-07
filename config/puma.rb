threads_count = ENV.fetch("RAILS_MIN_THREADS") { 1 }
max_threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }

if ENV.fetch("RAILS_ENV") { "development" } != 'development'
  workers ENV.fetch("WEB_CONCURRENCY") { 2 }

  preload_app!

  on_worker_boot do
    ActiveRecord::Base.establish_connection
  end
end


plugin :tmp_restart

threads threads_count, max_threads_count
port        ENV.fetch("PORT") { 3000 }
environment ENV.fetch("RAILS_ENV") { "development" }
