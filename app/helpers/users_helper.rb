module UsersHelper
  def render_users_home
    @client = client_new

    @user_tw_account = @client.user(current_user.twid.to_i)
    @user = current_user

    User.transaction do
      @user.lock!

      @user.update_tw_account(@user_tw_account)

      @user.refresh_wordcaches(@client)
      @user.words_reset(@client)

      @detected_word = []
      @user.words.select{ |w| w.detected && !w.noticed_detection }.each do |word|
        word.noticed_detection = true
        word.save!
        detector = User.find(word.detectorid)
        next if detector.nil?
        word.detectoraccount = @client.user(detector.twid.to_i)
        @detected_word.push(word)
      end
    end

    #Words取得
    @words = @user.words.all
    words_p = @words.partition{|w| w.alive?}
    @todayswords = words_p[0]
    @deadwords = words_p[1]

    #@tweets = @client.home_timeline(count: 20)

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
    friends = []
    client.friend_ids.each_slice(1000) do |allfriends|
      friends.concat(User.where("twid IN (?)", allfriends.map(&:to_s)))
    end
    friends.push(current_user)
    friends.sort_by!{|a| a.get_score(nil) * -1 }
  end

end
