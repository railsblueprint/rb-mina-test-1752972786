set :nginx_server_name, "blueprint-final-test.staging.railsblueprint.com"
set :rails_env, "staging"
set :deploy_to, -> { "/home/#{fetch(:user)}/blueprint_final_test/staging" }
set :hostname, "chill"
