class TwitterSessionsController < ApplicationController
  def create
    user = User.find_or_create_from_auth(request.env['omniauth.auth'])
    log_in(user)
    redirect_to root_path
  end

  def destroy
    reset_session
    redirect_to root_path
  end
end
