class TwitterSessionsController < ApplicationController

  require 'twitter'

  def create
    auth = request.env['omniauth.auth']
    saveuser(auth)
    redirect_to root_path

  end

  def destroy
    reset_session
    redirect_to root_path
  end

end
