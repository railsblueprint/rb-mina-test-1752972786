module RecaptchaValidator
  extend ActiveSupport::Concern

  class_methods do
    def validate_recaptcha **options
      define_method :recaptcha_action do
        options[:action]
      end
      options.delete(:action)

      validate :recaptcha, options
    end
  end

  # rubocop:disable Metrics/BlockLength
  included do
    attribute :recaptcha_v3_response, BaseCommand::Types::String
    attribute :recaptcha_v2_response, BaseCommand::Types::String

    memoize def recaptcha
      return if recaptcha_v3_response.present? && recaptcha_v3_response_valid?

      errors.delete(:recaptcha) if recaptcha_v2_response.present? && recaptcha_v2_response_valid?
    end

    def recaptcha_version
      return "v3" if recaptcha_v3_response.blank? && recaptcha_v2_response.blank?
      return "v3" if recaptcha_v3_response.present? && recaptcha_v3_response_valid?

      "v2"
    end

    memoize def recaptcha_v3_response_valid?
      verify_recaptcha action:         recaptcha_action,
                       skip_remote_ip: true,
                       minimum_score:  AppConfig.recaptcha&.v3&.minimum_score&.to_f || 0.99,
                       secret_key:     AppConfig.recaptcha.v3.secret_key,
                       response:       recaptcha_v3_response
    end

    memoize def recaptcha_v2_response_valid?
      verify_recaptcha secret_key: AppConfig.recaptcha.v2.secret_key,
                       response:   recaptcha_v2_response
    end

    memoize def recaptcha_v3_response_failed?
      recaptcha_v3_response.present? && !recaptcha_v3_response_valid?
    end

    def verify_recaptcha(options={})
      return true if Recaptcha.skip_env?(options[:env])

      recaptcha_response = options[:response]

      if Recaptcha.invalid_response?(recaptcha_response)
        errors.add(:recaptcha, :verification_failed)
        return false
      end

      return true if Recaptcha.verify_via_api_call(recaptcha_response, options)

      errors.add(:recaptcha, :verification_failed)
      false
    rescue Errno::EHOSTUNREACH, Timeout::Error
      errors.add(:recaptcha, :recaptcha_unreachable)
    end

    def recaptcha_configured?
      AppConfig.dig(:recaptcha, :v2, :secret_key).present? &&
      AppConfig.dig(:recaptcha, :v2, :site_key).present? &&
      AppConfig.dig(:recaptcha, :v3, :secret_key).present? &&
      AppConfig.dig(:recaptcha, :v3, :site_key).present?
    end
  end
  # rubocop:enable Metrics/BlockLength
end
