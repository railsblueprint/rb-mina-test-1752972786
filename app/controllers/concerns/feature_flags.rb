module FeatureFlags
  extend ActiveSupport::Concern

  included do
    helper_method :feature_enabled_for_current_user?
  end

  def feature_enabled_for_current_user?(feature_name)
    Flipper.enabled?(feature_name, current_user)
  end

  def require_feature!(feature_name) # rubocop:disable Naming/PredicateMethod
    unless feature_enabled_for_current_user?(feature_name)
      redirect_to root_path, alert: t("errors.feature_not_enabled")
      return false
    end
    true
  end

  def feature_enabled_for_percentage?(feature_name, percentage=nil)
    if percentage
      Flipper.enabled?(feature_name, current_user, percentage_of_actors: percentage)
    else
      Flipper.enabled?(feature_name, current_user)
    end
  end

  def feature_enabled_for_group?(feature_name, group_name)
    Flipper.enabled?(feature_name, current_user) &&
      Flipper.group(group_name).match?(current_user, {})
  end
end
