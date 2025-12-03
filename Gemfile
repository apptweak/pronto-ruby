# frozen_string_literal: true

source "https://rubygems.org"

gem "pronto"
gem "pronto-brakeman", require: false
gem "pronto-rubocop", require: false
# gem 'pronto-bundler_audit', require: false # Temporarily disabled, incompatible with current pronto
gem "pronto-eslint_npm", require: false
gem "pronto-rails_best_practices", require: false
gem "pronto-rails_schema", require: false
# gem 'pronto-poper', require: false
# gem 'pronto-yamllint', require: false # Temporarily disabled, seems to throw an error
gem "pronto-erb_lint", require: false
gem "pronto-fasterer", require: false
gem "pronto-flay", require: false
gem "pronto-reek", require: false
gem "pronto-scss", require: false
gem "pronto-stylelint", require: false

gem "rubocop-capybara", require: false
gem "rubocop-factory_bot", require: false
gem "rubocop-i18n", require: false
gem "rubocop-minitest", require: false
gem "rubocop-performance", require: false
gem "rubocop-rails", require: false
gem "rubocop-rake", require: false
gem "rubocop-rspec", require: false
gem "rubocop-sequel", require: false
gem "rubocop-thread_safety", require: false
gem "rubocop-yard", require: false

gem "rugged", "< 1.7.1" # Rugged v1.7.1 introduces an issue with pronto, see https://github.com/prontolabs/pronto/issues/447 for updates

group :test do
  gem "climate_control"
  gem "pry"
  gem "rb-readline"
  gem "rspec"
  gem "webmock"
end
