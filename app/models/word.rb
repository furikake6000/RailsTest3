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
    #clientがnilだったらキャッシュを探す
    if client.nil?
      return 0 if self.cached_at.nil?
      return self.countcache
    end
    #5分以内だったらキャッシュを返す
    return self.countcache if !(self.cached_at.nil?) && self.cached_at > Time.zone.now.ago(300)
    count = 0
    catch :finish do
      1.upto(50) do |i|
        tweets = client.user_timeline({user_id: user.twid, include_rts: false, page:i})
        tweets.each do |tweet|
          throw :finish if tweet.created_at < user.word_updated_at.beginning_of_day
          count += tweet.full_text.scan(/(?=#{self.name})/).count
        end
      end
    end
    self.countcache = count
    self.cached_at = Time.zone.now
    self.save
    return self.countcache
  end

  def get_score(user, client)
    return -100 if detected
    return count_including_tweets(user, client) * 50
  end

  def detect_by(user)
    self.detected = true
    self.detectorid = user.id
    self.save
    user.score += 100
    user.save
  end
end
