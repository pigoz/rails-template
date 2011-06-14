rails-template
==============

The Rails 3 template I use. Here's a list of gems:

    mongoid (optional)
    haml (+ haml_rails for generators)
    compass
    devise
    cancan
    rspec-rails (+ database_cleaner if using mongoid)
    rr
    factory_girl
    metric_fu

Usage:

    cd dev
    git clone git@github.com:pigoz/rails-template.git
    rails new my_application -T -O -m rails-template/template.rb # for mongo_id
    rails new my_application -T -m rails-template/template.rb # for ar
