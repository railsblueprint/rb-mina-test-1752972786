class Setting < ApplicationRecord
  self.inheritance_column = nil

  enum type: [:set, :string, :integer, :boolean, :json]

  if Rails.env.development?
    default_scope -> { where(deleted_at: nil) }

    scope :unsaved, -> { unscoped.where.not(deleted_at: nil).or(Setting.where(not_migrated: true)) }
  end

  # returns array of possible types with translation for use in selects in forms
  def self.type_enum
    types.map { |t| [type_text(t[0]), t[0].to_sym] }
  end

  def self.type_text type
    I18n.t(type, scope: [:activerecord, :attributes, :setting, :types])
  end

  def type_text
    self.class.type_text type
  end

  def parsed_json_value
    parsed = begin
      JSON.parse(value)
    rescue StandardError
      nil
    end
    parsed.is_a?(Hash) ? parsed.with_indifferent_access : parsed
  end

  # rubocop:disable Style/MissingRespondToMissing
  def self.method_missing method
    self[method]
  end
  # rubocop:enable Style/MissingRespondToMissing

  def self.[] name
    s = find_by(alias: name)
    return nil unless s
    return s.value.to_i if s.integer?
    return s.value.to_b if s.boolean?
    return s.parsed_json_value if s.json?

    s.value
  end

  def self.to_liquid
    all.filter_map { |s|
      { s.alias => s.value } unless s.set?
    }.reduce(&:merge)
  end
end
