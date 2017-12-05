class StaticPagesController < ApplicationController
  def home
    if logged_in?
      render_users_show
      return
    else
      @dict = pickAWord
    end
  end

  def about
  end

  def sandbox

  end
end
