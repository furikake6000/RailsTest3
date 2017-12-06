module TwitterSessionsHelper

  def client_new
    #Twitter APIのセットアップ
    Twitter::REST::Client.new do |config|
      config.consumer_key = Rails.application.secrets.twitter_api_key
      config.consumer_secret = Rails.application.secrets.twitter_api_secret
      config.access_token = cookies.permanent.signed[:token]
      config.access_token_secret = cookies.permanent.signed[:secret]
    end
  end

  def saveuser(auth)
    cookies.permanent.signed[:twid] = auth[:uid]
    cookies.permanent.signed[:token] = auth.credentials.token
    cookies.permanent.signed[:secret] = auth.credentials.secret
    user = User.find_by(twid: cookies.permanent.signed[:twid])
    user ||= create_user(cookies.permanent.signed[:twid])
    return user
  end

  def logged_in?
    !(current_user.nil?)
  end

  def current_user
    return nil if cookies.permanent.signed[:twid].nil?
    return @current_user ||= User.find_by(twid: cookies.permanent.signed[:twid])
  end

  def handle_401(exception = nil)
    render './public/401.html'
  end

  def forgetuser
    cookies.delete(:twid)
    cookies.delete(:token)
    cookies.delete(:secret)
  end

  private
    def create_user(twid)
      user = User.new
      user.twid = twid
      user.save
      @client ||= client_new
      #初期に5件のQuestを生成
      5.times do
        #q = Quest.generate_new(user, @client)
      end
    end
end
