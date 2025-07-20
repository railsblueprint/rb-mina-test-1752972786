# Fix for Mina encoding issues with non-latin characters
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

require 'active_support'
require 'active_support/core_ext/object/blank'
require_relative "app_config"
require 'dotenv/load'
require 'wannabe_bool'
require 'yaml'
require 'new_relic/cli/command'

overrides_filename = "#{File.dirname(__FILE__)}/deploy/#{ARGV[0]}.yml"
DEPLOY_SETTINGS = File.exist?(overrides_filename) ? YAML.load_file(overrides_filename) : {}

set :default_stage, :staging

require 'mina/rails'
require 'mina/multistage'
require 'mina/git'
require 'mina/rbenv'
require 'mina/data_migrate'
require 'mina/nginx'
require 'mina/puma_systemd'
require 'mina/rollbar'
require 'mina/secrets'
require 'mina/whenever'

set :application, "mina_test_786"
set :application_name, "mina_test_786"  # Required for mina-puma-nginx gem
set :repository, 'git@github.com:railsblueprint/rb-mina-test-1752972786.git'

# Fix for mina-puma-systemd gem which uses application_name for service name
set :puma_service_name, -> { "puma_#{fetch(:application)}_#{fetch(:rails_env)}" }

set :user, 'deploy'
set :domain, fetch(:hostname)
set :identity_file, DEPLOY_SETTINGS["ssh_key"]

set :branch, ENV["BRANCH"] || DEPLOY_SETTINGS["default_branch"] || "master"
set :version_scheme, :datetime

set :ruby_version, File.open(".ruby-version").read
set :bundler_version, `bundle -v`.split(" ").last

set :local_user, -> { `git config user.name`.chomp.presence || (ENV['USER'] ? Etc.getpwnam(ENV['USER'])&.gecos.presence : nil ) || ENV['USER'] || ENV['USERNAME'] ||  (ENV['GITLAB_USER_NAME'] ? "#{ENV['GITLAB_USER_NAME']} via gitlab": nil) || "unkown user" }

set :bundle_options, "--quiet"
set :bundle_path, "#{fetch(:shared_path)}/bundle"

set :rollbar_access_token, AppConfig.dig(fetch(:stage),:rollbar, :token)
set :rollbar_local_username, -> { fetch(:local_user) }

# set :force_migrate, true

# Optional settings:
#   set :user, 'foobar'          # Username in the server to SSH to.
#   set :port, '30000'           # SSH port number.
#   set :forward_agent, true     # SSH forward_agent.

# Puma configuration defaults
set :keep_releases, 5
set :puma_user, -> { fetch(:user) }
set :puma_group, -> { fetch(:user) }

# Shared dirs and files will be symlinked into the app-folder by the 'deploy:link_shared_paths' step.
# Some plugins already add folders to shared_dirs like `mina/rails` add `public/assets`, `vendor/bundle` and many more
# run `mina -d` to see all folders and files already included in `shared_dirs` and `shared_files`
set :shared_dirs, fetch(:shared_dirs, []).push('node_modules', 'public/assets', 'bundle') - ['vendor/bundle']
set :shared_files, fetch(:shared_files, []).push("config/credentials/#{fetch(:rails_env)}.key")
# set :secrets_files, ["config/master.key", "config/credentials/production.key", "puma.rb", "missing_file.txt"]

set :nginx_sites_enabled_path,   -> { "#{fetch(:nginx_path)}/conf.d" }

set :whenever_name , -> { "#{fetch(:application)}_#{fetch(:rails_env)}" }

# This task is the environment that is loaded for all remote run commands, such as
# `mina deploy` or `mina rake`.
task :remote_environment do
  # Set UTF-8 locale to prevent encoding issues
  command %{export LANG=en_US.UTF-8}
  command %{export LC_ALL=en_US.UTF-8}
  command %{export LC_CTYPE=en_US.UTF-8}
  
  # If you're using rbenv, use this to load the rbenv environment.
  # Be sure to commit your .ruby-version or .rbenv-version to your repository.
  invoke :'rbenv:load'

  # For those using RVM, use this to load an RVM version@gemset.
  # invoke :'rvm:use', 'ruby-2.5.3@default'
end


# Put any custom commands you need to run at setup
# All paths in `shared_dirs` and `shared_paths` will be created on their own.
task :setup do
  command %{rbenv install #{fetch(:ruby_version)} --skip-existing}
  # command %{rvm install ruby-2.5.3}
  command %{gem install bundler -v #{fetch(:bundler_version)}}
  invoke :'secrets:upload'
end

task :'yarn:install' do
  command 'yarn install'
end

task :'bundle:config' do
  command 'bundle config --local deployment true'
  command "bundle config --local without '#{fetch(:bundle_withouts)}'"
  command "bundle config --local path '#{fetch(:bundle_path)}'"
end

task :'deploy:log' do
  message = "Branch #{fetch(:branch)} (at `cat #{fetch(:current_path)}/.mina_git_revision`) deployed as release $version by #{fetch(:local_user)}"
  in_path(fetch(:deploy_to)) do
    command "echo \"#{message}\" >> revisions.log"
  end
end


desc "Initial deployment (puma, nginx, ssl). Run 'mina staging setup' first."
task :'deploy:initial' do
  deploy do
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:config'
    invoke :'bundle:install'
    invoke :'rails:db_create'
    invoke :'rails:db_data_migrate'
    invoke :'rails:db_seed'
    invoke :'yarn:install'
    invoke :'rails:assets_precompile'
    invoke :'puma:setup'
    invoke :'puma:start'
    invoke :'nginx:setup'
    invoke :'nginx:reload'
    invoke :'nginx:certbot'

    on :launch do
      invoke :'whenever:update'
      invoke :'deploy:log'
    end
  end
end

desc "Deploys the current version to the server."
task :deploy do
  run(:local) do
    invoke :'rollbar:starting'
  end
  
  deploy do
    # Put things that will set up an empty directory into a fully set-up
    # instance of your project.
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:config'
    invoke :'bundle:install'
    invoke :'rails:db_data_migrate'
    invoke :'yarn:install'
    invoke :'rails:assets_precompile'
    invoke :'deploy:cleanup'

    on :launch do
      invoke :'puma:restart'
      invoke :'whenever:update'
      invoke :'deploy:log'
    end

  end

  run(:local) do
    invoke :'rollbar:finished'
    invoke :'newrelic:deploy'
  end
  # you can use `run :local` to run tasks on local machine before of after the deploy scripts
  # run(:local){ say 'done' }
end

task :'newrelic:deploy' do
  revision = `git rev-parse #{fetch(:branch)}`
  NewRelic::Cli::Deployments.new(
    [
      "-e", fetch(:rails_env),
      "-u", fetch(:local_user),
      "-r", revision
    ]).run
end


desc "Deploys the current local branch to the server."
task :'deploy:current' do
  set :branch, `git branch --show-current`.chomp
  invoke :'git:ensure_pushed'
  invoke :deploy
end

desc 'Seeding remote database'
task 'deploy:seed': :remote_environment do
  comment "Seeding ..."
  in_path(fetch(:current_path)) do
    command "#{fetch(:rake)} db:seed what=#{ENV['what']}"
  end
end


def check_for_changes_script(options)
  diffs = options[:at].map do |path|
    %(diff -x builds -qrN "#{fetch(:current_path)}/#{path}" "./#{path}" 2>/dev/null)
  end.join(' && ')

  %(
    if #{diffs}
    then
      #{options[:skip]}
    else
      #{options[:changed]}
    fi
  )
end