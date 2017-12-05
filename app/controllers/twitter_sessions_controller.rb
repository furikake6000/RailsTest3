class TwitterSessionsController < ApplicationController

  require 'twitter'

  rescue_from OAuth::Unauthorized, with: :handle_401

  def create
    auth = request.env['omniauth.auth']
    saveuser(auth)
    redirect_to root_path

  end

  def destroy
    forgetuser
    redirect_to root_path
  end

  def handle_401(exception = nil)
    render './public/401.html'
  end

end
