class User < ApplicationRecord
  validates :twid, presence: true

  has_many :quests

  def User.find_or_create_from_auth(auth)
    twid = auth[:uid]
    return User.find_or_create_by(twid: twid)
  end

end
