module FeatureFlagsHelper
  def feature_enabled?(feature_name, actor=current_user)
    Flipper.enabled?(feature_name, actor)
  end

  def with_feature(feature_name, actor=current_user, &)
    return unless feature_enabled?(feature_name, actor)

    capture(&)
  end

  def without_feature(feature_name, actor=current_user, &)
    return if feature_enabled?(feature_name, actor)

    capture(&)
  end

  def feature_percentage(feature_name)
    feature = Flipper.feature(feature_name)
    gate_values = feature.gate_values
    gate_values.percentage_of_actors || 0
  end

  def feature_groups(feature_name)
    feature = Flipper.feature(feature_name)
    gate_values = feature.gate_values
    Array(gate_values.groups)
  end
end
