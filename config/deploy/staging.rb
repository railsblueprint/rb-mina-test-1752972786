set :nginx_server_name, "rb-test-final.staging.railsblueprint.com"
set :rails_env, "staging"
set :deploy_to, -> { "/home/#{fetch(:user)}/rb_test_final/staging" }
set :hostname, "chill"
