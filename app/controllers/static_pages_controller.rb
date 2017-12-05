class StaticPagesController < ApplicationController
  def home
    rescue_from OAuth::Unauthorized, with: :handle_401

    if logged_in?
      render_users_show
      return
    end
  end

  def about
  end

  def sandbox

  end
end
