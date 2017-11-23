class TwitterSessionsController < ApplicationController

  require 'twitter'

  def create
    auth = request.env['omniauth.auth']

    session[:token] = auth.credentials.token
    session[:secret] = auth.credentials.secret
    user = log_in(auth[:uid])

    redirect_to root_path

  end

  def destroy
    reset_session
    redirect_to root_path
  end

  private

end
