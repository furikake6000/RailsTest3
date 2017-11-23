class TwitterSessionsController < ApplicationController

  require 'twitter'

  def create
    auth = request.env['omniauth.auth']
    user = User.find_or_create_from_auth(auth)
    log_in(user)

    client = client_new(auth)
    #ためしにツイート
    client.update "認証成功したぽよ～～～"

    redirect_to root_path
  end

  def destroy
    reset_session
    redirect_to root_path
  end

  private
    def client_new(auth)
      #Twitter APIのセットアップ
      Twitter::REST::Client.new do |config|
        config.consumer_key = Rails.application.secrets.twitter_api_key
        config.consumer_secret = Rails.application.secrets.twitter_api_secret
        config.access_token = auth.credentials.token
        config.access_token_secret = auth.credentials.secret
      end
    end
end
