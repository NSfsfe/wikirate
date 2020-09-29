# -*- encoding : utf-8 -*-
source "http://rubygems.org"

# decko_gem_path = ENV["WIKIRATE_DECKO_GEM_PATH"] || "./vendor/decko"
decko_gem_path = "./vendor/decko"

if ENV["RM_INFO"] && ARGV[0] == 'check'
  puts "Execution in RubyMine detected in Gemfile. Ignoring decko gem path"
  # This causes Rubymine and IntelliJ to handle these paths as normal sources rather
  # than gems or libraries.
  # That way the files are included as normal project sources in Find and Open.
else
  path decko_gem_path do
    gem "card", require: false
    gem "card-mod-defaults"
    gem "decko"
  end
end

gem "card-mod-bookmarks", path: "./vendor/card-mods/bookmarks"
gem "card-mod-csv_import", path: "./vendor/card-mods/csv_import"
# gem "card-mod-logger", path: "./vendor/card-mods/logger"
gem "card-mod-new_relic", path: "./vendor/card-mods/new_relic"
gem "card-mod-pdfjs", path: "./vendor/card-mods/pdfjs"
gem "card-mod-solid_cache", path: "./vendor/card-mods/solid_cache"

gem "mysql2", "> 0.4"

gem "bulk_insert"
gem "descriptive_statistics"
gem "savanna-outliers"
gem "statistics2"

gem "curb"
gem "daemons"
gem "delayed_job_active_record"
gem "delayed_job_web"

gem "company-mapping"
gem "link_thumbnailer"
gem "nokogumbo"
gem "open_uri_redirections"
gem "pdfkit"
gem "roo"
gem "wbench"
gem "wkhtmltopdf-binary", "0.12.5.4"

gem "rubocop", "0.88" # 0.89 introduced bugs. may get resolved in rubocop-decko update?
gem "rubocop-decko"

gem "fog-aws"
gem "rack-cors"

gem "bcrypt_pbkdf"
gem "ed25519"

gem "sprockets"

# seems like newrelic should be in :live, but that wasn't working.
# not sure why -efm
gem "newrelic_rpm"
# gem "ruby-prof"
gem "airbrussh", require: false

gem "ruby-jmeter"

group :live do
  gem "dalli"
  gem "therubyracer"
end

group :test do
  gem "rspec"
  gem "rspec-html-matchers"
  gem "rspec-rails"
  # gem 'wagn-rspec-formatter',  git: 'https://github.com/xithan/wagn-rspec-formatter.git'

  gem "simplecov", require: false
  gem "spork"

  gem "timecop"
  # gem 'codeclimate-test-reporter', require: nil

  # CUKES see features dir
  gem "capybara", "~> 2.18"
  # gem "chromedriver-helper"
  # gem "geckodriver-helper"
  gem "cucumber", "~> 3.1"
  # feature-driven-development suite (cucumber 4 not working)
  gem "cucumber-expressions" # , "5.0.7" # this breaks at 5.0.12
  gem "cucumber-rails", "~> 2.0", require: false
  gem "selenium-webdriver", "3.141.0"
  #gem 'capybara-webkit' # lets cucumber launch browser windows
  gem "launchy"

  gem "email_spec"
  # used by cucumber for db transactions
  gem "database_cleaner", "~> 1.5"

  gem "minitest"
end

group :development do
  gem 'html2haml'
  gem "rubocop-rspec"

  # gem "rails-dev-tweaks"
  # gem "sprockets" # just so above works

  gem "capistrano"
  gem "capistrano-bundler"
  gem "capistrano-git-with-submodules", '~> 2.0'
  gem "capistrano-maintenance", require: false
  gem "capistrano-passenger"
  gem "capistrano-rvm"
  gem "pivotal-tracker"

  gem "better_errors"
  gem "binding_of_caller"

  gem "spring"

  # gem "nospring"
  gem "spring-commands-rspec"
end

group :test, :development, :cypress do
  gem "cypress-on-rails"
  gem "pry"
  gem "pry-byebug"
  gem "pry-rails"
  gem "pry-rescue"
  gem "pry-stack_explorer", "~> 0.4.9"
  gem "puma"
end

Dir.glob("mod/**{,/*/**}/Gemfile").each do |gemfile|
  instance_eval(File.read(gemfile))
end
