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
    !session[:token].nil?
  end
end
