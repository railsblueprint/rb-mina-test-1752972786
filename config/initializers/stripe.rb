Rails.application.config.stripe.secret_key = AppConfig.stripe&.secret_key
Rails.application.config.stripe.publishable_key = AppConfig.stripe&.publishable_key
Rails.application.config.stripe.signing_secrets = AppConfig.stripe&.signing_secrets
Rails.application.config.stripe.auto_mount = false