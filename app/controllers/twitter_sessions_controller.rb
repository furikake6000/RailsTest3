class TwitterSessionsController < ApplicationController

  require 'twitter'

  rescue_from OAuth::Unauthorized, with: :failure

  def create
    auth = request.env['omniauth.auth']
    saveuser(auth)
    redirect_to root_path

  end

  def destroy
    forgetuser
    redirect_to root_path
  end

  def failure
    render './public/401.html'
  end

end
