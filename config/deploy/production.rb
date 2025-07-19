set :nginx_server_name, "blueprint-final-test.example.com"
set :rails_env, "production"
set :deploy_to, "/home/#{fetch(:user)}/blueprint_final_test/production"
set :hostname, "example.com"
