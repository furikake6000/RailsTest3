class TwitterSessionsController < ApplicationController

  require 'twitter'

  def create
    auth = request.env['omniauth.auth']

    session[:token] = auth.credentials.token
    session[:secret] = auth.credentials.secret

    client = client_new
    @tweets = client.home_timeline(include_entities: false)

  end

  def destroy
    reset_session
    redirect_to root_path
  end

  private
    def client_new
      #Twitter APIのセットアップ
      Twitter::REST::Client.new do |config|
        config.consumer_key = Rails.application.secrets.twitter_api_key
        config.consumer_secret = Rails.application.secrets.twitter_api_secret
        config.access_token = session[:token]
        config.access_token_secret = session[:secret]
      end
    end
end
