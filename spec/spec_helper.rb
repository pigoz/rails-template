# This file is copied to spec/ when you run 'rails generate rspec:install
require 'spork'

Spork.prefork do
  ENV["RAILS_ENV"] ||= 'test'

  ## hack to make mongoid work with spork
  require "rails/mongoid"
  Spork.trap_class_method(Rails::Mongoid, :load_models)

  ## hack to make devise work with spork
  require "rails/application"
  Spork.trap_method(Rails::Application, :reload_routes!)

  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

  RSpec.configure do |config|
    # == Mock Framework
    #
    # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
    #
    # config.mock_with :mocha
    # config.mock_with :flexmock
    config.mock_with :rr
    # config.mock_with :rspec

    # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
    # -- we use factory girl instead of fixtures
    # config.fixture_path = "#{::Rails.root}/spec/fixtures"

    # If you're not using ActiveRecord, or you'd prefer not to run each of your
    # examples within a transaction, remove the following line or assign false
    # instead of true.
    config.use_transactional_fixtures = true
  end
end

Spork.each_run do
  require 'factory_girl'
  Dir.glob(File.dirname(__FILE__) + "/factories/**/*.rb").each do |factory|
    require factory
  end
end
