source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.5.1'

#== CORE RAILS =============================
gem 'rails', '~> 5.2.0'
gem 'puma', '~> 3.11'
gem 'bootsnap', '>= 1.1.0', require: false
gem 'rack-cors', '~> 1.0'

#== DATA ACCESS ============================
gem 'pg', '>= 0.18', '< 2.0'
gem 'searchkick', '~> 3.1'
gem 'paper_trail', '~> 9.0'

#== UTILITIES ==============================
gem 'fast_jsonapi', '~> 1.2'
gem 'jwt'
gem 'bcrypt', '~> 3.1.7'   # provides has_secure_password

#== APIS ===================================
gem 'geocoder', '~> 1.4.0'
gem "aws-sdk-s3", require: false

#== DEVELOPMENT & TESTING ==================
group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem "factory_bot_rails", "~> 4.0"
  gem "mocha"
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'

  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'

  gem 'annotate', '~> 2.7.0'
end
