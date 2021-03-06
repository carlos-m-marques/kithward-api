source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.5.1'

gem 'scriptster'
gem 'ruby-progressbar'

#== CORE RAILS =============================
gem 'rails', '~> 5.2.2'
gem 'puma', '~> 3.4'
gem 'bootsnap', '>= 1.1.0', require: false
gem 'rack-cors', '~> 1.0'

#== DATA ACCESS ============================
gem 'pg', '>= 0.18', '< 2.0'
gem 'searchkick', '~> 4.1'
gem 'paper_trail', '~> 9.0'
gem 'paper_trail-hashdiff', git: 'https://github.com/dudufangor/paper_trail-hashdiff.git'
gem 'kaminari', '1.1.1'

#== UTILITIES ==============================
gem 'oj', '~> 3.9', '>= 3.9.1'
gem 'blueprinter', '0.9.0'
gem 'jwt'
gem 'hashdiff', '~> 1.0'
gem 'bcrypt', '~> 3.1.7'   # provides has_secure_password
gem 'acts_as_paranoid', '~> 0.6.0'
gem 'ffaker'
gem 'country-select'
gem 'cancancan', '~> 3.0', '>= 3.0.1'
gem 'devise'
gem 'activeadmin_addons'
gem 'activeadmin', '~> 2.2'
gem 'sidekiq', '~> 5.2', '>= 5.2.7'
gem 'aasm', '~> 5.0', '>= 5.0.5'
gem 'ransack', '2.1.1'
gem 'json-schema-generator', '~> 0.0.9'
gem 'foreman', '~> 0.85.0'
gem 'sidekiq-failures', '~> 1.0'
gem 'moesif_rack'

#== APIS ===================================
gem 'geocoder', '~> 1.5.0'
gem 'aws-sdk-s3', '~> 1.0.0', require: false
gem 'sentry-raven', '2.7.4'
gem 'intercom', '~> 3.7.0'
gem 'prismic.io', '~> 1.6.0'
gem 'newrelic_rpm'
gem 'sendgrid-ruby'
gem 'faraday'

group :assets do
  gem 'coffee-rails'
end

#== DEVELOPMENT & TESTING ==================
group :development, :test, :staging do
  gem 'awesome_print'
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'pry'
  gem 'factory_bot_rails', '~> 4.0'
  gem 'mocha'
  gem 'dotenv-rails'
  gem 'pry-rescue'
  gem 'pry-stack_explorer'
  gem 'rouge'
  gem 'axlsx', '2.1.0.pre'
  gem 'axlsx_rails'
  gem 'business_time'
end

group :test do
  gem 'spring'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring-watcher-listen', '~> 2.0.0'
end
