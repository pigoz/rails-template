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

################################################################################
## Gems
################################################################################
gem 'haml'
gem 'nifty-generators'
gem 'haml-rails', :group => [ :development ]
gem 'compass', '>= 0.10.6'
gem 'mongoid',  '2.0.0.rc.8'
gem 'bson_ext', '~> 1.2'

gem 'passenger'

# authentication and authorization
gem 'devise'
gem 'cancan'

# rspec, factory girl, webrat, autotest for testing
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
# use database cleaner with mongoid
<<-RUBY
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
## Authentication and authorization setup
################################################################################
generate "devise:install"
inject_into_file 'config/environments/development.rb',
       :after => 'config.action_dispatch.best_standards_support = :builtin' do
<<-RUBY

  # 
  config.action_mailer.default_url_options = { :host => 'localhost:3000' }
RUBY
end
generate "mongoid:devise User"
generate "cancan:ability"

################################################################################
## Templating stuff
################################################################################
generate 'nifty:layout --haml'
remove_file 'app/views/layouts/application.html.erb' # use nifty layout instead
generate 'nifty:config'

# initialize compass stuff
sass_dir = "app/stylesheets"
css_dir = "public/stylesheets/compiled"
compass_cmd = "compass init rails . --css-dir=#{css_dir} --sass-dir=#{sass_dir}"
compass_cmd << " --using blueprint/semantic"
run compass_cmd

# custom layout for compass
remove_file 'app/views/layouts/application.html.haml' 
file 'app/views/layouts/application.html.haml', read('application.html.haml')

# make an application partial css
file 'app/stylesheets/partials/_application.scss', <<-CSS
#container {
  @include showgrid;
}
CSS
append_file 'app/stylesheets/screen.scss', <<-CODE

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
generate 'controller home index'

################################################################################
## Create routes
################################################################################
inject_into_file 'config/routes.rb', :after => 'routes.draw do' do
  read('routes.rb')
end

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
