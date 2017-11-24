class Quest < ApplicationRecord

  belongs_to :user
  validates :user_id, presence:true
  validates :questtype, presence:true

  def Quest.generate_new(user, client)
    @last_following ||= client.friend_ids({count: 1}).first
    @last_follower ||= client.follower_ids({count: 1}).first
    @last_tweet ||= client.user_timeline({user_id: user.twid, count: 1}).first
    @last_retweet ||= client.retweeted_by_me({count: 1}).first

    #生成して情報格納
    quest = user.quests.build
    quest.last_following = @last_following
    quest.last_follower = @last_follower
    quest.last_tweet = @last_tweet
    quest.last_retweet = @last_retweet
    quest.randomgenerate
    quest.save
    return quest
  end

  def randomgenerate
    questtypes = Array[
      "follow_user_start_with_x",
      "follow_n_user_contain_x",
      "follow_n_user",
      "retweet_tweet_start_with_x",
      "retweet_n_tweet",
      "tweet_n_tweet",
      "tweet_start_with_x",
      "followed_by_n_user"
    ]
    self.questtype = questtypes.sample
    @random = Random.new
    case self.questtype
    when "follow_user_start_with_x" then
      self.target = ('あ'..'ん').to_a.shuffle.first
    when "follow_n_user_contain_x" then
      self.target = ('あ'..'ん').to_a.shuffle.first
      self.value = @random.rand(1..3)
    when "follow_n_user" then
      self.value = @random.rand(1..5)
    when "retweet_tweet_start_with_x" then
      self.target = ('あ'..'ん').to_a.shuffle.first
    when "retweet_n_tweet" then
      self.value = @random.rand(3..10)
    when "tweet_n_tweet" then
      self.value = @random.rand(3..10)
    when "tweet_start_with_x" then
      self.target = ('あ'..'ん').to_a.shuffle.first
    when "followed_by_n_user" then
      self.value = @random.rand(1..5)
    end
    self.last_follower = @last_follower
    self.last_following = @last_following
  end

  def to_s
    case self.questtype
    when "follow_user_start_with_x" then
      return "「" + self.target + "」 から始まるユーザをフォローしよう！"
    when "follow_n_user_contain_x" then
      return "「" + self.target + "」 を含むユーザを" + self.value.to_s + "人フォローしよう！"
    when "follow_n_user" then
      return self.value.to_s + "人フォローしよう！"
    when "retweet_tweet_start_with_x" then
      return "「" + self.target + "」 から始まるツイートをリツイートしよう！"
    when "retweet_n_tweet" then
      return self.value.to_s + "個のツイートをリツイートしよう！"
    when "tweet_n_tweet" then
      return self.value.to_s + "ツイートしよう！"
    when "tweet_start_with_x" then
      return "「" + self.target + "」 から始まるツイートをしよう！"
    when "followed_by_n_user" then
      return self.value.to_s + "人にフォローされよう！"
    end
  end

  def get_progress(client)
    case self.questtype
    when "follow_user_start_with_x" then
      client.friend_ids({count: 50}).each do |friend|
        break if friend == self.last_following
        return 1 if client.user(friend).name.start_with?(self.target)
      end
      return 0
    when "follow_n_user_contain_x" then
      count = 0
      client.friend_ids({count: 50}).each do |friend|
        break if friend == self.last_following
        count += 1 if client.user(friend).name.include?(self.target)
      end
      return count / self.value
    when "follow_n_user" then
      count = 0
      client.friend_ids({count: 50}).each do |friend|
        break if friend == self.last_following
        count += 1
      end
      return count / self.value
    when "retweet_tweet_start_with_x" then
      return 0
    when "retweet_n_tweet" then
      return 0
    when "tweet_n_tweet" then
      client.user_timeline(current_user.twid, ({count: 100})).each do |tweetid|
        break if tweetid == self.last_tweet
        count += 1
      end
      return 0
    when "tweet_start_with_x" then
      return 0
    when "followed_by_n_user" then
      count = 0
      client.follower_ids.each do |follower|
        break if follower == self.last_following
        count += 1
      end
      return count / self.value
    end
  end
end
