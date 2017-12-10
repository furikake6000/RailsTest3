class User < ApplicationRecord
  validates :twid, presence: true

  default_scope -> { order(score: :desc) }

  has_many :quests, dependent: :destroy
  has_many :words, dependent: :destroy

  def User.find_or_create_from_auth(auth)
    twid = auth[:uid]
    return User.find_or_create_by(twid: twid)
  end

  def get_score(client)
    returnscore = self.score
    self.words.each do |word|
      returnscore += word.get_score(self, client)
    end
    return returnscore
  end

end
