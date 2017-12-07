class Word < ApplicationRecord
  include ApplicationHelper

  belongs_to :user
  #belongs_to :detector ,class_name: 'User', foreign_key:'detector_id'
  validates :user_id, presence: true
  validates :name, presence: true

  def initialize(attributes = {})
    super
    self.name = pickAWord
  end

  def to_s
    return self.name
  end

  def count_including_tweets(user, client, cache)
    count = 0
    cache ||= client.user_timeline({user_id: user.twid, count: 30, since_id: last_tweet})
    cache.each do |tweet|
      count += tweet.text.scan(/(?=#{self.name})/).count
    end
    return count
  end
end
