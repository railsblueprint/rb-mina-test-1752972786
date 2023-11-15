class ChangePasswordCommand < BaseCommand
  attribute :user, Types::Nominal(User)
  attribute :currrent_password, Types::String
  attribute :password, Types::String
  attribute :password_confirmation, Types::String

  validates_presence_of :user, :password, :password_confirmation, :currrent_password
  validate :current_password_valid?

  def process
    user.update(password: password, password_confirmation: password_confirmation)
  end

  def current_password_valid?
    user.valid_password?(current_password)
  end
end
