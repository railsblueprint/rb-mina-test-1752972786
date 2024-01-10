require "blueprint_config"

BlueprintConfig.env_backend_options = {whitelist_keys: [:port]}

BlueprintConfig.after_initialize = proc do
  BlueprintConfig.instance.refine do |backends|
    if backends[:env]
      backends.insert_after :env, :db, BlueprintConfig::Backend::ActiveRecord.new(nest: true)
    else
      backends.push :db, BlueprintConfig::Backend::ActiveRecord.new(nest: true)
    end
  end
end

unless defined?(Rails)
  BlueprintConfig.root ||= "#{File.dirname(__FILE__)}/.."
  BlueprintConfig.env ||= ENV["RAILS_ENV"] || "development"

  BlueprintConfig.define_shortcut
  BlueprintConfig.init
end
