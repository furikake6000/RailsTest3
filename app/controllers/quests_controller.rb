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
  end

  def destroy
    targetquest = current_user.quests.find_by(id: params[:id])
    if !targetquest.nil?
      #進捗の確認
      @client ||= client_new
      @cache ||= {}
      if params[:phase] == "questclear" && targetquest.get_progress_debug(current_user, @client, @cache) >= 1.0
        #クエストクリアしてたらスコアの加算
        current_user.score += targetquest.get_score
      end
      targetquest.destroy
      Quest.generate_new(current_user, @client)
    end
  end
end
