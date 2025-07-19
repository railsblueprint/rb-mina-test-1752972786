set :nginx_server_name, "rb-deployment-test.example.com"
set :rails_env, "production"
set :deploy_to, -> { "/home/#{fetch(:user)}/rb_deployment_test/production" }
set :hostname, "example.com"
