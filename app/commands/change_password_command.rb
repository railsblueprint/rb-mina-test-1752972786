class ChangePasswordCommand < BaseCommand
  attribute :user, Types::Nominal(User)
  attribute :current_password, Types::String
  attribute :password, Types::String
  attribute :password_confirmation, Types::String

  validates_presence_of :user, :password, :password_confirmation, :current_password
  validate :current_password_valid

  def process
    user.update(password:, password_confirmation:)
  end

  def current_password_valid
    return if user.nil?
    return if user&.valid_password?(current_password)

    errors.add(:current_password, :invalid)
  end
end
