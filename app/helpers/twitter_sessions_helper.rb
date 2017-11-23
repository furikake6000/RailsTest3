module TwitterSessionsHelper

  def client_new
    #Twitter APIのセットアップ
    Twitter::REST::Client.new do |config|
      config.consumer_key = Rails.application.secrets.twitter_api_key
      config.consumer_secret = Rails.application.secrets.twitter_api_secret
      config.access_token = session[:token]
      config.access_token_secret = session[:secret]
    end
  end

  def logged_in?
    !session[:twid].nil?
  end

  def log_in(twid)
    user = User.find_by(twid: twid)
    user = create_user(twid) if user.nil?
    session[:twid] = twid
    return user
  end

  def current_user
    return User.find_by(twid: session[:twid])
  end

  private
    def create_user(twid)
      user = User.new
      user.twid = twid
      user.save
      @client ||= client_new
      #初期に5件のQuestを生成
      5.times do
        Quest.generate_new(user, @client)
      end
    end
end
