module UsersHelper
  def render_users_home
    @client = client_new
    @user = current_user
    @user_tw_account = @client.user(current_user.twid.to_i)
    words_reset
    @words = @user.words.all
    @cache = {}
    render 'users/home'
  end

  def get_twpic_uri(useracc)
    useracc.profile_image_url.to_s.sub(/http/, "https").sub(/(.*)_normal/){$1}
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
      #1日以上前の単語を削除する(日付変わった瞬間に削除されない)
      @user.words.each do |word|
        if word.created_at.localtime("+09:00") < Time.now.localtime("+09:00").beginning_of_day.yesterday
          #削除される時にスコア加算
          @user.score += word.get_score(@user, @client)
          word.destroy
        end
      end
      #日付変わったら5個単語を生成
      if @user.word_updated_at.nil? || @user.word_updated_at.localtime("+09:00") < Time.now.localtime("+09:00").beginning_of_day
        @user.words.destroy_all
        @user.word_updated_at = Time.now
        @user.save
        5.times do
          word = @user.words.create
        end
      end
    end
end
