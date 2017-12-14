module UsersHelper
  def render_users_home
    @client = client_new

    @user = current_user
    @user_tw_account = @client.user(current_user.twid.to_i)

    #鍵垢判定
    if @user.is_secret != @user_tw_account.protected?
      @user.is_secret = @user_tw_account.protected?
      @user.save
    end

    @user.refresh_wordcaches(@client)
    @user.words_reset(@client)

    #Words取得
    @words = @user.words.all
    words_p = @words.partition{|w| w.alive?}
    @todayswords = words_p[0]
    @deadwords = words_p[1]

    @tweets = @client.home_timeline(count: 20)

    @friends = get_friends(@client)

    render 'users/home'
  end

  def get_twpic_uri(useracc)
    useracc.profile_image_url.to_s.sub(/http/, "https").sub(/(.*)_normal/){$1}
  end

  def get_twpic_uri_small(useracc)
    useracc.profile_image_url.to_s.sub(/http/, "https")
  end

  def get_friends(client)
    @friends = []
    @client.friend_ids.each_slice(1000) do |allfriends|
      @friends.concat(User.where("twid IN (?)", allfriends.map(&:to_s)))
    end
    @friends.push(current_user)
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


end
