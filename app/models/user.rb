class User < ApplicationRecord
  validates :twid, presence: true

  default_scope -> { order(score: :desc) }

  has_many :quests, dependent: :destroy

  def User.find_or_create_from_auth(auth)
    twid = auth[:uid]
    return User.find_or_create_by(twid: twid)
  end

end
