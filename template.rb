say <<-eos

===============================================================================
 using rails-template =)
===============================================================================
eos

################################################################################
## helper methods
################################################################################
def read(file)
  File.new( File.expand_path(File.join('~/dev/rails-template/', file)) ).read
end

def stage(file)
  remove_file(file)
  file(file, read(file))
end

def newline
  "\n"
end

################################################################################
## Gems
################################################################################
gem 'haml'
gem 'nifty-generators'
gem 'haml-rails', :group => [ :development ]
gem 'compass', '>= 0.10.6'
gem 'mongoid',  '2.0.0.rc.8'
gem 'bson_ext', '~> 1.2'
gem 'simple_form'

gem 'passenger'

# authentication and authorization
gem 'devise'
gem 'cancan'

# rspec, factory girl, webrat, autotest for testing
gem 'capybara'
gem 'cucumber'
gem 'cucumber-rails'
gem 'database_cleaner', :group => [ :development, :test ]
gem 'rspec', :group => [ :development, :test ]
gem 'rspec-rails', :group => [ :development, :test ]
gem 'shoulda-matchers', :group => [ :development, :test ]
gem 'metric_fu', :group => [ :development, :test ]

run 'bundle install'

################################################################################
## Setup Mongo
################################################################################
generate 'mongoid:config'

################################################################################
## Unit testing with Rspec
################################################################################
generate 'rspec:install'
inject_into_file 'spec/spec_helper.rb', :after => 'config.mock_with :rspec' do
newline + newline + <<-RUBY
  # use database cleaner with mongoid
  require 'database_cleaner'

  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.orm = "mongoid"
  end

  config.before(:each) do
    DatabaseCleaner.clean
  end
RUBY
end
run "echo '--format documentation' >> .rspec"

################################################################################
## Integration/Acceptance testing with Cucumber + Capybara
################################################################################
generate 'cucumber:install --capybara --rspec --skip-database'
stage 'features/support/database_cleaner.rb'

################################################################################
## Authentication and authorization setup
################################################################################
generate "devise:install"
inject_into_file 'config/environments/development.rb',
       :after => 'config.action_dispatch.best_standards_support = :builtin' do
newline + newline + <<-RUBY
  config.action_mailer.default_url_options = { :host => 'localhost:3000' }
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.delivery_method = :sendmail
RUBY
end
generate "mongoid:devise User"
generate "cancan:ability"

################################################################################
## Templating stuff
################################################################################
generate 'nifty:config'
generate 'nifty:layout --haml'
remove_file 'app/views/layouts/application.html.erb'
remove_file 'app/views/layouts/application.html.haml'
remove_file 'public/stylesheets/application.css'
remove_file 'public/stylesheets/sass/application.sass'
generate 'simple_form:install'

inject_into_file 'app/controllers/application_controller.rb', :before => /^end$/ do
newline + <<-RUBY
  helper_method :app_name
  private
  def app_name
    @app_name ||= Rails.application.class.to_s.split("::").first
  end
RUBY
end

# initialize compass stuff
sass_dir = "app/stylesheets"
css_dir = "public/stylesheets/compiled"
compass_cmd = "compass init rails . --css-dir=#{css_dir} --sass-dir=#{sass_dir}"
compass_cmd << " --using blueprint/semantic"
run compass_cmd

# custom layout for compass
stage 'app/views/layouts/application.html.haml'

# make an application partial css
stage 'app/stylesheets/partials/_application.scss'
stage 'app/stylesheets/partials/_form.scss'
append_file 'app/stylesheets/screen.scss', newline + <<-CODE
// Add the application styles.
@import "partials/application";
CODE

################################################################################
## Cleanup rails default files
################################################################################
remove_file 'public/index.html'
remove_file 'public/images/rails.png'

################################################################################
## Controllers
################################################################################
generate 'controller home index --skip-routes'
# drop in out view
stage 'app/views/home/index.html.haml'

################################################################################
## Create routes
################################################################################
inject_into_file 'config/routes.rb', :after => 'routes.draw do' do
  newline + read('routes.rb')
end

################################################################################
## Customize devise
################################################################################
stage 'app/models/user.rb'

inject_into_file 'config/initializers/devise.rb',
       :after => '  # config.authentication_keys = [ :email ]' do
newline + <<-RUBY
  config.authentication_keys = [ :username ]
RUBY
end

gsub_file 'config/locales/devise.en.yml',
          "invalid: 'Invalid email or password.'" do
  "invalid: 'Invalid username or password.'"
end

stage 'app/views/devise/registrations/new.html.haml'
stage 'app/views/devise/sessions/new.html.haml'
stage 'app/views/devise/mailer/confirmation_instructions.html.haml'

################################################################################
## metric_fu
################################################################################
append_file 'Rakefile', <<-RUBY

require 'metric_fu'
MetricFu::Configuration.run do |config|
  config.rcov[:test_files] = ['spec/**/*_spec.rb']
  config.rcov[:rcov_opts] << "-Ispec" # Needed to find spec_helper
end
RUBY

################################################################################
## Git commit
################################################################################
git :init
git :add => "."
git :commit => "-a -m 'created initial application'"

say <<-eos
===============================================================================
 Your new Rails application is ready to go.

 Don't forget to scroll up for important messages from installed generators.
===============================================================================
eos
