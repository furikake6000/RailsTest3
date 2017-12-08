class StaticPagesController < ApplicationController
  def home
    if logged_in?
      render_users_home
      return
    end
  end

  def about
  end

  def sandbox

  end
end
