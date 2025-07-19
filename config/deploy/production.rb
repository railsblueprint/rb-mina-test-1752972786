set :nginx_server_name, "rb-test-final.example.com"
set :rails_env, "production"
set :deploy_to, -> { "/home/#{fetch(:user)}/rb_test_final/production" }
set :hostname, "example.com"
