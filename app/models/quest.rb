class Quest < ApplicationRecord

  belongs_to :user
  validates :user_id, presence:true
  validates :type, presence:true

  def Quest.generate_new(user, client)
    @@random = Random.new

    begin
      @last_following ||= client.friend_ids({count: 1}).first.to_s
      @last_follower ||= client.follower_ids({count: 1}).first.to_s
      @last_tweet ||= client.user_timeline({user_id: user.twid, count: 1}).first.id.to_s
      @last_retweet ||= client.retweeted_by_me({count: 1}).first.id.to_s
    rescue Twitter::Error::TooManyRequests
      return nil
    end

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
    quest.save
    return quest
  end

  def get_progress_debug(user, client, cache)
    begin
      p = get_progress(user, client, cache)
      p ||= 0.0
      return p
    rescue Twitter::Error::TooManyRequests
      return -1.0
    end
  end

  def get_score
    return 100
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
    cache[:friend] ||= client.friend_ids({user_id: user.twid})
    cache[:friend].each_slice(10).each do |slice|
      slice.each do |friend|
        return 0.0 if friend.to_s == last_following
        return 1.0 if client.user(friend).name.start_with?(target)
      end
    end
    return 0.0
  end

  def get_score
    return 220
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
    count = 0.0
    cache[:friend] ||= client.friend_ids({user_id: user.twid})
    cache[:friend].each_slice(10).each do |slice|
      slice.each do |friend|
        print(friend.to_s + " == " + last_following + " : " + (friend.to_s == last_following).to_s)
        return count / value if friend.to_s == last_following
        count += 1.0 if client.user(friend).name.include?(target)
      end
    end
    return count / value
  end

  def get_score
    return 105 * value
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
    count = 0.0
    cache[:friend] ||= client.friend_ids({user_id: user.twid})
    cache[:friend].each_slice(10).each do |slice|
      slice.each do |friend|
        return count / value if friend.to_s == last_following
        count += 1.0
      end
    end
    return count/value
  end

  def get_score
    return 80 * value
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
    cache[:retweet] ||= client.retweeted_by_me({count: 30, since_id: last_retweet})
    cache[:retweet].each do |tweet|
      return 1.0 if tweet.text.start_with?(target)
    end
    return 0.0
  end

  def get_score
    return 55
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
    cache[:retweet] ||= client.retweeted_by_me({count: 30, since_id: last_retweet})
    return cache[:retweet].size.to_f / value
  end

  def get_score
    return 75 * value
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

  def get_score
    return 65 * value
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

  def get_score
    return 125
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
    cache[:follower] ||= client.follower_ids({user_id: user.twid})
    cache[:follower].each_slice(10).each do |slice|
      slice.each do |follower|
        return count / value if follower.to_s == last_follower
        count += 1.0
      end
    end
    return count / value
  end

  def get_score
    return 235 * value
  end
end
