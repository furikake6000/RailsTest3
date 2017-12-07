class User < ApplicationRecord
  validates :twid, presence: true

  default_scope -> { order(score: :desc) }

  has_many :quests, dependent: :destroy
  has_many :words, dependent: :destroy
  has_many :detected, class_name: 'Word'

  def User.find_or_create_from_auth(auth)
    twid = auth[:uid]
    return User.find_or_create_by(twid: twid)
  end

end
