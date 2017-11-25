class QuestsController < ApplicationController
  def new
  end

  def show
    @user = current_user
    @client = client_new
    @quests = @user.quests.all
    @progresses = {}
    @quests.each do |q|
      @progresses[q.id] = get_progress(q, @user, @client)
    end
  end

  def destroy
  end

  def get_progress(quest, user, client)
    begin
      case quest.questtype
      when "follow_user_start_with_x" then
        @friends ||= client.friend_ids({count: 20})
        @friends.each do |friend|
          break if friend.to_s == quest.last_following
          return 1.0 if client.user(friend).name.start_with?(quest.target)
        end
        return 0.0
      when "follow_n_user_contain_x" then
        count = 0.0
        @friends ||= client.friend_ids({count: 20})
        @friends.each do |friend|
          break if friend.to_s == quest.last_following
          count += 1.0 if client.user(friend).name.include?(quest.target)
        end
        return count / quest.value
      when "follow_n_user" then
        count = 0.0
        @friends ||= client.friend_ids({count: 20})
        @friends.each do |friend|
          break if friend.to_s == quest.last_following
          count += 1.0
        end
        return count / quest.value
      when "retweet_tweet_start_with_x" then
        @retweets ||= client.retweeted_by_me({count: 30, since_id: quest.last_retweet})
        @retweets.each do |tweet|
          return 1.0 if tweet.text.start_with?(self.target)
        end
        return 0.0
      when "retweet_n_tweet" then
        count = 0.0
        @retweets ||= client.retweeted_by_me({count: 30, since_id: quest.last_retweet})
        @retweets.each do |tweet|
          count += 1.0
        end
        return count / quest.value
      when "tweet_n_tweet" then
        count = 0.0
        @tweets ||= client.user_timeline({user_id: user.twid, count: 30, since_id: quest.last_tweet})
        @tweets.each do |tweet|
          count += 1.0
        end
        return count * 100 / quest.value
      when "tweet_start_with_x" then
        count = 0.0
        @tweets ||= client.user_timeline({user_id: user.twid, count: 30, since_id: quest.last_tweet})
        @tweets.each do |tweet|
          count += 1.0 if tweet.text.start_with?(quest.target)
        end
        return count / self.value
      when "followed_by_n_user" then
        count = 0.0
        @followers ||= client.follower_ids({count: 20})
        @followers.each do |follower|
          break if follower.to_s == quest.last_following
          count += 1.0
        end
        return count / quest.value
      end
    rescue Twitter::Error::TooManyRequests
      return "Twitter API上限に達しました。しばらくしてから再度お試しください。"
    end
  end
end
