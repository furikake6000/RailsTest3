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

  def count_including_tweets(user, client)
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
    return count
  end
end
