say <<-eos

===============================================================================
 using rails-template =)
===============================================================================
eos

################################################################################
## helper methods
################################################################################
def origin(file)
  File.expand_path(File.join('~/dev/rails-template/', file))
end

def read(file)
  File.new(origin(file)).read
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

# templating gems
gem 'haml'
gem 'compass'
gem 'haml-rails', :group => [ :development ] # haml generators

# orm
gem 'mongoid',  '~> 2.0'
gem 'bson_ext', '~> 1.3'

# awesome
gem 'inherited_resources'
gem 'simple_form'

# authentication and authorization
gem 'devise'
gem 'cancan'

# rspec, factory girl, webrat, autotest for testing
gem 'capybara', :group => [ :development, :test ]
gem 'database_cleaner', :group => [ :development, :test ]
gem 'rspec', :group => [ :development, :test ]
gem 'rspec-rails', :group => [ :development, :test ]
gem 'metric_fu', :group => [ :development, :test ]

run 'bundle install'

## Add a few helper methodos
stage 'app/helpers/application_helper.rb'

################################################################################
## Setup Mongo
################################################################################
generate 'mongoid:config'
stage 'config/initializers/inherited_resources_mongoid.rb'

################################################################################
## Unit testing with Rspec
################################################################################
generate 'rspec:install'
inject_into_file 'spec/spec_helper.rb', :after => 'config.mock_with :rspec' do
  newline + newline + read('share/database_cleaner_rspec_config.rb')
end
run "echo '--format documentation' >> .rspec"

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
## Cleanup rails default files
################################################################################
remove_file 'public/index.html'
remove_file 'public/images/rails.png'
remove_file 'app/views/layouts/application.html.erb'

################################################################################
## Templating stuff
################################################################################
generate 'simple_form:install'
stage 'config/initializers/sass.rb'
stage 'app/views/layouts/application.html.haml'
stage 'app/assets/stylesheets/application.scss'
stage 'app/assets/stylesheets/form.scss'

################################################################################
## Generate Home controller and view
################################################################################
generate 'controller home index --skip-routes'
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
          "invalid: 'Invalid username or password.'" end

stage 'app/views/devise/registrations/new.html.haml'
stage 'app/views/devise/sessions/new.html.haml'
stage 'app/views/devise/mailer/confirmation_instructions.html.haml'

################################################################################
## metric_fu
################################################################################
stage 'lib/tasks/metric_fu.rb'

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
