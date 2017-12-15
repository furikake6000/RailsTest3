class Word < ApplicationRecord
  include ApplicationHelper

  belongs_to :user
  validates :user_id, presence: true
  validates :name, presence: true

  def initialize(attributes = {})
    super
    self.name = pickAWord
  end

  def to_s
    return self.name
  end

  def count_including_tweets(user, client)
    #キャッシュを返す
    #キャッシュ取得はUser::refresh_wordcachesで行うように（仕様変更）
    return self.countcache
  end

  def get_score(user, client)
    return -100 if detected
    return self.countcache * 50
  end

  def detect_by(user)
    self.detected = true
    self.detectorid = user.id
    self.save
    user.score += 100
    user.save
  end

  def alive?
    return (self.created_at.localtime("+09:00") > Time.now.localtime("+09:00").beginning_of_day)
  end

  def report_available?
    return (self.created_at.localtime("+09:00") > (Time.now - 1.hour).localtime("+09:00").beginning_of_day)
  end
end
