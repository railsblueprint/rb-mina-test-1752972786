require_relative "boot"

require "rails/all"
require 'good_job/engine'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Railsblueprint
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0
    config.active_job.queue_adapter = :good_job
    config.exceptions_app = self.routes

    # config.assets.cache = false
    config.assets.cache_store = :null_store

    config.i18n.fallbacks = true

    # this is for removing assets/stylesheets
    config.hotwire_livereload.force_reload_paths =  %w[
            app/javascript
            app/assets/javascripts
          ].map { |p| Rails.root.join(p) }

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
Rails.backtrace_cleaner.remove_silencers!
