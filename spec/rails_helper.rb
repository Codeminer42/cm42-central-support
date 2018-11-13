# frozen_string_literal: true
ENV['RAILS_ENV'] ||= 'test'

require 'rails/all'

require 'factory_girl'
require 'factory_girl_rails'
require 'rspec/rails'
require 'shoulda/matchers'

# Add additional requires below this line. Rails is not loaded until this point!
require 'vcr'
require 'webmock'

VCR.configure do |config|
  config.cassette_library_dir = 'fixtures/vcr_cassettes'
  config.hook_into :webmock # or :fakeweb
  config.ignore_localhost = true
  config.configure_rspec_metadata!
end


system({"RAILS_ENV" => "test"}, "cd spec/support/rails_app ; bin/rails db:reset")

require 'support/rails_app/config/environment'

require 'support/database_cleaner'
require 'support/factory_girl'
require 'support/factories'
require 'spec_helper'
