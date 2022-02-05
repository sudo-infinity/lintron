class UserToken < ActiveRecord::Base
  belongs_to :user

  before_validation :ensure_token

  validates :token, uniqueness: true, presence: true
  validates :user, presence: true

  protected

  def ensure_token
    while token.blank?
      self.token = SecureRandom.uuid
      conflicting_token = UserToken.find_by_token(self.token)
      self.token = nil if conflicting_token.present?
    end
  end
end
