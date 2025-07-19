set :nginx_server_name, "rb-deployment-test-staging.example.com"
set :rails_env, "staging"
set :deploy_to, -> { "/home/#{fetch(:user)}/rb_deployment_test/staging" }
set :hostname, "example.com"
