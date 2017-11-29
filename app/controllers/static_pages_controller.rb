class StaticPagesController < ApplicationController
  def home
    if logged_in?
      render 'users/show'
      return
    end
  end

  def about
  end

  def sandbox

  end
end
