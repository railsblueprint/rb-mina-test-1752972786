class User < ApplicationRecord
  include Rails.application.routes.url_helpers

  rolify

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :lockable, :trackable, :omniauthable,
         omniauth_providers: [:google_oauth2, :github, :facebook, :twitter, :linkedin]
  # :timeoutable

  include PgSearch::Model
  pg_search_scope :search, against: [:id, :first_name, :last_name, :email]

  multisearchable against: [:id, :first_name, :last_name, :email]

  has_many :posts, dependent: :nullify
  has_many :user_identities, dependent: :destroy
  has_one_attached :avatar
  has_one_attached :avatar_source

  def full_name
    [first_name, last_name].filter_map(&:presence).join(" ").presence || email
  end

  def short_name
    [first_name&.first, last_name].filter_map(&:presence).join(". ").presence || email
  end

  memoize def initials
    full_name.gsub(/[^\p{L} ]/, "").split.tap { |a| break a.size > 1 ? a[0][0] + a[1][0] : a[0][0..1] }
  end

  def searchable_name
    full_name
  end

  def avatar_color
    (full_name.gsub(/[^a-zA-Z]/, "").to_i(36) % 8) + 1
  end

  alias rolify_has_role? has_role?

  # rubocop:disable Naming/PredicatePrefix
  def has_role?(role, resource=nil)
    roles.any? { |r| r.name.to_sym == role.to_sym && r.resource == resource } ||
      roles.any? { |r| r.name.to_sym == :superadmin }
  end
  # rubocop:enable Naming/PredicatePrefix
  Role::ROLES.each do |role|
    define_method(:"#{role}?") do
      has_role?(role)
    end
  end

  def to_liquid
    attributes.with_indifferent_access
              .slice(:id, :email, :unconfirmed_email, :first_name, :last_name, :job, :company)
              .merge({
                "self_url"  => url_for([:profile, { id: }]),
                "self_path" => url_for([:profile, { id:, only_path: true }])
              })
  end

  # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/MethodLength
  def self.from_omniauth(auth)
    # First, try to find by existing identity
    identity = UserIdentity.find_by(provider: auth.provider, uid: auth.uid)
    if identity
      update_social_profile_from_oauth(identity.user, auth)
      return identity.user
    end

    # If no identity found, try to find user by email
    user = User.find_by(email: auth.info.email) if auth.info.email.present?

    # If no user found, create a new one
    if user.nil?
      user = User.new(
        email:      auth.info.email,
        password:   Devise.friendly_token[0, 20],
        first_name: auth.info.first_name || auth.info.name&.split&.first,
        last_name:  auth.info.last_name || auth.info.name&.split&.last
      )
      user.skip_confirmation!
      user.save!
    end

    # Create or update the identity for this provider
    identity = user.user_identities.find_or_initialize_by(provider: auth.provider)
    identity.uid = auth.uid
    identity.oauth_token = auth.credentials.token
    identity.oauth_expires_at = Time.zone.at(auth.credentials.expires_at) if auth.credentials.expires_at
    identity.oauth_refresh_token = auth.credentials.refresh_token if auth.credentials.refresh_token
    identity.save!

    # Update social profile URLs
    update_social_profile_from_oauth(user, auth)

    user
  end
  # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/MethodLength

  # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/MethodLength
  def self.update_social_profile_from_oauth(user, auth)
    case auth.provider
    when "github"
      if user.github_profile.blank?
        # GitHub provides the profile URL in auth.info.urls['GitHub'] or we can construct it
        profile_url = auth.info.urls&.dig("GitHub") ||
                     (auth.info.nickname.present? ? "https://github.com/#{auth.info.nickname}" : nil)
        user.update_column(:github_profile, profile_url) if profile_url.present?
      end
    when "facebook"
      if user.facebook_profile.blank?
        # Facebook can provide URL in auth.info.urls or we use the link field
        profile_url = auth.info.urls&.dig("Facebook") ||
                     auth.extra&.raw_info&.link ||
                     (auth.uid.present? ? "https://facebook.com/#{auth.uid}" : nil)
        user.update_column(:facebook_profile, profile_url) if profile_url.present?
      end
    when "google_oauth2"
      # Google doesn't map directly to our social fields, but we could store Google+ URL if available
      # Google+ was shut down, so we skip this
    when "twitter"
      if user.twitter_profile.blank?
        # Twitter provides URL or we can construct it from nickname
        profile_url = auth.info.urls&.dig("Twitter") ||
                     (auth.info.nickname.present? ? "https://twitter.com/#{auth.info.nickname}" : nil)
        user.update_column(:twitter_profile, profile_url) if profile_url.present?
      end
    when "linkedin"
      if user.linkedin_profile.blank?
        profile_url = auth.info.urls&.dig("LinkedIn") || auth.info.urls&.dig("public_profile")
        user.update_column(:linkedin_profile, profile_url) if profile_url.present?
      end
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/MethodLength

  def self.new_with_session(params, session)
    super.tap do |user|
      data = session["devise.provider_data"]
      user.email = data["email"] if data && user.email.blank?
    end
  end

  def linked_providers
    user_identities.pluck(:provider)
  end

  def linked_to?(provider)
    user_identities.exists?(provider: provider.to_s)
  end
end
