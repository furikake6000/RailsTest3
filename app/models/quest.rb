class Quest < ApplicationRecord

  belongs_to :user
  validates :user_id, presence:true
  validates :type, presence:true

  def generate_new(user, client)
    @@random = Random.new

    @last_following ||= client.friend_ids({count: 1}).first.to_s
    @last_follower ||= client.follower_ids({count: 1}).first.to_s
    @last_tweet ||= client.user_timeline({user_id: user.twid, count: 1}).first.id.to_s
    @last_retweet ||= client.retweeted_by_me({count: 1}).first.id.to_s

    #生成して情報格納
    questtypes = Array[
      "FollowUserStartsWithX",
      "FollowNUsersContainX",
      "FollowNUsers",
      "RetweetStartsWithX",
      "RetweetNTimes",
      "TweetNTimes",
      "TweetStartsWithX",
      "FollowedByNUsers"
    ]
    quest = user.quests.build(
      type: questtypes.sample,
      last_following: @last_following,
      last_follower: @last_follower,
      last_tweet: @last_tweet,
      last_retweet: @last_retweet
    )
    save
    return quest
  end
end

class FollowUserStartsWithX < Quest
  validates :target, presence: true

  def initialize(attributes = {})
    super
    self.target =('あ'..'ん').to_a.shuffle.first
  end

  def to_s
    "「" + target + "」 から始まるユーザをフォローしよう！"
  end

  def get_progress(user, client, cache)
    return @progress if !@progress.nil?
    cache[:friend] ||= client.friend_ids({count: 20})
    cache[:friend].each do |friend|
      break if friend.to_s == last_following
      return @progress = 1.0 if client.user(friend).name.start_with?(target)
    end
    return @progress = 0.0
  end
end
class FollowNUsersContainX < Quest
  validates :target, presence: true
  validates :value, presence: true

  def initialize(attributes = {})
    super
    self.target =('あ'..'ん').to_a.shuffle.first
    self.value =@@random.rand(1..3)
  end

  def to_s
    "「" + target + "」 を含むユーザを" + value.to_s + "人フォローしよう"
  end

  def get_progress(user, client, cache)
    return @progress if !@progress.nil?
    cache[:friend] ||= client.friend_ids({count: 20})
    cache[:friend].each do |friend|
      break if friend.to_s == last_following
      count += 1.0 if client.user(friend).name.include?(target)
    end
    return @progress = count / value
  end
end
class FollowNUsers < Quest
  validates :value, presence: true

  def initialize(attributes = {})
    super
    self.value =@@random.rand(1..3)
  end

  def to_s
    value.to_s + "人フォローしよう！"
  end

  def get_progress(user, client, cache)
    return @progress if !@progress.nil?
    cache[:friend] ||= client.friend_ids({count: 20})
    cache[:friend].each do |friend|
      break if friend.to_s == last_following
      count += 1.0
    end
    return @progress = count/value
  end
end
class RetweetStartsWithX < Quest
  validates :target, presence: true

  def initialize(attributes = {})
    super
    self.target =('あ'..'ん').to_a.shuffle.first
  end

  def to_s
    "「" + target + "」 から始まるツイートをリツイートしよう！"
  end

  def get_progress(user, client, cache)
    return @progress if @progress.nil?
    cache[:retweet] ||= client.retweeted_by_me({count: 30, since_id: last_retweet})
    cache[:retweet].each do |tweet|
      return @progress = 1.0 if tweet.text.start_with?(target)
    end
    return @progress = 0.0
  end
end
class RetweetNTimes < Quest
  validates :value, presence: true

  def initialize(attributes = {})
    super
    self.value =@@random.rand(3..10)
  end

  def to_s
    return value.to_s + "個のツイートをリツイートしよう！"
  end

  def get_progress(user, client, cache)
    return @progress if @progress.nil?
    cache[:retweet] ||= client.retweeted_by_me({count: 30, since_id: last_retweet})
    return @progress = cache[:retweet].size.to_f / value
  end
end
class TweetNTimes < Quest
  validates :value, presence: true

  def initialize(attributes = {})
    super
    self.value =@@random.rand(3..10)
  end

  def to_s
    value.to_s + "ツイートしよう！"
  end

  def get_progress(user, client, cache)
    cache[:tweet] ||= client.user_timeline({user_id: user.twid, count: 30, since_id: last_tweet})
    return cache[:tweet].size.to_f / value
  end
end
class TweetStartsWithX < Quest
  validates :target, presence: true

  def initialize(attributes = {})
    super
    self.target =('あ'..'ん').to_a.shuffle.first
  end

  def to_s
    "「" + target + "」 から始まるツイートをしよう！"
  end

  def get_progress(user, client, cache)
    cache[:tweet] ||= client.user_timeline({user_id: user.twid, count: 30, since_id: last_tweet})
    cache[:tweet].each do |tweet|
      return 1.0 if tweet.text.start_with?(target)
    end
    return 0.0
  end
end
class FollowedByNUsers < Quest
  validates :value, presence: true

  def initialize(attributes = {})
    super
    self.value =@@random.rand(1..5)
  end

  def to_s
    value.to_s + "人にフォローされよう！"
  end

  def get_progress(user, client, cache)
    count = 0.0
    cache[:follower] ||= client.follower_ids({count: 20})
    cache[:follower].each do |follower|
      break if follower.to_s == last_following
      count += 1.0
    end
    return count / value
  end
end
