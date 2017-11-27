class StaticPagesController < ApplicationController
  def home
    if logged_in?
      @client ||= client_new
      @quests = current_user.quests.all
      @progresses = {}
      @quests.each do |q|
        @progresses[q.id] = get_progress(q, current_user, @client)
      end
      render 'users/show'
      return
    end
  end

  def about
  end

  def sandbox

  end
end
