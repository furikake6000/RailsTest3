module UsersHelper
  def render_users_show
    @client = client_new
    @user = current_user
    @user_tw_account = @client.user(current_user.twid.to_i)
    @quests = @user.quests.all
    quest_reset
    @cache = {}
    @ranking = User.limit(10)
    render 'users/show'
  end

  #時間切れクエストを削除、更新
  def quest_reset
    #履歴削除
    @quests.each do |quest|
      if quest.created_at.tomorrow < Time.zone.now
        quest.destroy
      end
    end

    #新規生成
    (4 - @quests.count).downto(0) do |n|
      Quest.generate_new(current_user, @client)
      #@quests更新
      @quests = @user.quests.all if n==0
    end
  end
end
