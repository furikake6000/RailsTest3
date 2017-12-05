class StaticPagesController < ApplicationController
  def home
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
