class QuestsController < ApplicationController
  def new
  end

  def show
    if current_user.nil?
      redirect_to root_path
    end
    @client = client_new
    @quests = current_user.quests.all
    @progresses = {}
    @cache = {}
    @quests.each do |q|
      #@progresses[q.id] = q.get_progress(current_user, @client, @cache)
      @progresses[q.id] = q.get_progress(current_user, @client, @cache)
    end
  end

  def destroy
    targetquest = current_user.quests.find_by(id: params[:id])
    if !targetquest.nil?
      targetquest.destroy
      @client = client_new
      Quest.generate_new(current_user, @client)
    end
  end
end
