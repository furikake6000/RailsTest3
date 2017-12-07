module UsersHelper
  def render_users_show
    @client = client_new
    @user = current_user
    @user_tw_account = @client.user(current_user.twid.to_i)
    #@quests = @user.quests.all
    #quest_reset
    words_reset
    @words = @user.words.all
    @cache = {}
    @ranking = User.limit(10)
    render 'users/show'
  end

  private
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

    def words_reset
      #履歴削除
      if @user.word_updated_at.nil? || @user.word_updated_at < Time.zone.now.beginning_of_day
        @user.words.destroy_all
        5.times do
          word = @user.words.create
        end
        @user.word_updated_at = Time.zone.now
        @user.save
      end
    end
end
