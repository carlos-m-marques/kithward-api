source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.5.1'

#== CORE RAILS =============================
gem 'rails', '~> 5.2.2'
gem 'puma', '~> 3.11'
gem 'bootsnap', '>= 1.1.0', require: false
gem 'rack-cors', '~> 1.0'

#== DATA ACCESS ============================
gem 'pg', '>= 0.18', '< 2.0'
gem 'searchkick', '~> 3.1'
gem 'paper_trail', '~> 9.0'
gem 'paper_trail-hashdiff'
gem 'kaminari', '1.1.1'

#== UTILITIES ==============================
gem 'oj', '~> 3.6'
gem 'blueprinter', '0.9.0'
gem 'jwt'
gem 'hashdiff'
gem 'bcrypt', '~> 3.1.7'   # provides has_secure_password
gem 'acts_as_paranoid', '~> 0.6.0'
gem 'ffaker'
gem 'country-select'
gem 'cancancan', '~> 3.0', '>= 3.0.1'
gem 'devise'
gem 'activeadmin_addons'
gem 'activeadmin', git: 'https://github.com/activeadmin/activeadmin.git', branch: 'fix_renamed_resources_and_optional_belongs_to'
gem 'sidekiq', '~> 5.2', '>= 5.2.7'

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
group :development, :test do
  gem 'awesome_print'
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'pry'
  gem 'factory_bot_rails', '~> 4.0'
  gem 'mocha'
  gem 'dotenv-rails'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'

  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end
