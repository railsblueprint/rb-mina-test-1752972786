class User < ApplicationRecord
  rolify

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :lockable, :trackable
  # :timeoutable

  has_many :posts, dependent: :nullify

  def full_name
    [first_name, last_name].filter_map(&:presence).join(" ").presence || email
  end

  def short_name
    [first_name&.first, last_name].filter_map(&:presence).join(". ").presence || email
  end

  def initials
    @_initials ||= full_name.gsub(/[^\p{L} ]/, "").split
                            .tap { |a| break a.size > 1 ? a[0][0] + a[1][0] : a[0][0..1] }
  end

  def avatar_color
    (full_name.gsub(/[^a-zA-Z]/, "").to_i(36) % 8) + 1
  end

  alias rolify_has_role? has_role?

  # rubocop:disable Naming/PredicateName
  def has_role?(role, resource=nil)
    rolify_has_role?(role, resource) || rolify_has_role?(:superadmin)
  end
  # rubocop:enable Naming/PredicateName

  begin
    Role.all.map do |record|
      define_method("#{record.name}?".to_sym) do
        rolify_has_role?(record.name)
      end
    end
  rescue ActiveRecord::StatementInvalid
    Rails.logger.warn "Warning: Roles table missing, not role check methods created"
  end

  def to_liquid
    attributes.with_indifferent_access
              .slice(:id, :email, :unconfirmed_email, :first_name, :last_name, :job, :company)
              .merge({
                "self_url"  => url_for([:profile,
                                        { id: id }.merge(Rails.application.config.action_mailer.default_url_options)]),
                "self_path" => url_for([:profile, { id: id, only_path: true }])
              })
  end
end
