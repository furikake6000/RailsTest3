class Quest < ApplicationRecord
  belongs_to :user
  validates :user_id, presence:true
  validates :type, presence:true

  def Quest.generate_new(user)
    @client ||= client_new
    @last_following ||= @client.friend_ids.first
    @last_follower ||= @client.follower_ids.first

    #生成して情報格納
    quest = user.quests.build
    quest.randomgenerate
    return quest
  end

  private
    def randomgenerate
      types = Array[
        "follow_user_start_with_x",
        "follow_n_user_contain_x",
        "follow_n_user",
        "retweet_tweet_start_with_x",
        "retweet_n_tweet",
        "tweet_n_tweet",
        "tweet_start_with_x",
        "followed_by_n_user"
      ]
      self.type = types.sample
      self.last_follower = @last_follower
      self.last_following = @last_following
    end
end
