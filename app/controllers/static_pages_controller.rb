class StaticPagesController < ApplicationController
  def home
    if logged_in?
      render_users_home
      return
    end
  end

  def ranking

  end

  def about
  end

  def info
  end
end
