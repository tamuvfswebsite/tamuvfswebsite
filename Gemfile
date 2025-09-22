source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.4.5"
#ruby "2.7.2"

gem 'concurrent-ruby', '1.3.5'

gem 'rails', '~> 8.0.2.1', '>= 8.0.2.1'

# Use postgresql as the database for Active Record

gem 'pg', '~> 1.1'

# Use Puma as the app server

gem 'puma', '~> 6.0'


# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails"


# Use SCSS for stylesheets
#gem 'sass-rails', '>= 6'

# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
#gem 'webpacker'
#gem 'webpacker', '~> 5.0'

# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
#gem 'turbolinks', '~> 5'


# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# Use Redis adapter to run Action Cable in production
# gem "redis", "~> 4.0"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

#gem 'record_tag_helper'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]

# Reduces boot times through caching; required in config/boot.rb
#gem "bootsnap", '>=1.4.4', require: false
gem 'bootsnap', require: false
gem 'rexml'

# Use Sass to process CSS
gem "sassc-rails"

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[mri mingw x64_mingw]
#  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw ]
  gem 'rspec-rails'

end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"
  gem 'simplecov', require: false
  gem "webdrivers"
end

gem 'yaml_db'

gem 'brakeman'
gem 'rubocop'
gem 'rubocop-performance'
gem 'rubocop-rails'
gem 'rubocop-rspec'

gem 'devise', '~>4.9'
#gem 'omniauth'
#gem 'omniauth', '~>2.0'
#gem 'omniauth-google-oauth2', '>= 1.0.0'
#gem 'omniauth-rails_csrf_protection'
gem "omniauth", "~> 2.1"
gem "omniauth-rails_csrf_protection", "~> 1.0"
gem "omniauth-google-oauth2", "~> 1.1"
gem 'record_tag_helper', '~> 1.0'
