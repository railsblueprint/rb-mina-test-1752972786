class UserIdentity < ApplicationRecord
  belongs_to :user

  validates :provider, presence: true
  validates :uid, presence: true
  validates :provider, uniqueness: { scope: :user_id }
  validates :uid, uniqueness: { scope: :provider }

  def oauth_expires?
    oauth_expires_at.present? && oauth_expires_at < Time.current
  end
end
