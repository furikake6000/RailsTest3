class QuestsController < ApplicationController
  def new
  end

  def show
    @user = current_user
    @client = client_new
    @quests = @user.quests.all
  end

  def destroy
  end
end
