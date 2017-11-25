class StaticPagesController < ApplicationController
  def home
    if logged_in?
      @client = client_new
      @tweets = @client.home_timeline
      @followings = @client.friend_ids
      render 'twitter_sessions/create'
      return
    end
  end

  def about
  end

  def sandbox

  end
end
