class UsersController < ApplicationController
  def show
    #ログインしていないと見られない
    if !logged_in?
      redirect_to root_path
      return
    end
    @client = client_new
    @user_tw_account = @client.user(params[:id].to_s)
    @user = User.find_by(twid: @user_tw_account.id)

    #自分自身を選択していたらルートにリダイレクト
    if @user == current_user
      redirect_to root_path
      return
    end
    render_404 if @user.nil?

    #Words取得
    @words = @user.words.all
    words_p = @words.partition{|w| w.alive?}
    @todayswords = words_p[0]
    @deadwords = words_p[1]

    @friends = get_friends(@client)

    @tweets = @client.user_timeline(params[:id].to_s)

  rescue Twitter::Error::Unauthorized
  #鍵垢orAPIエラー等だった場合ここにくる
    @unauthorized_occured = true
  end

  def report_history
      #ログインしていないと見られない
      if !logged_in?
        redirect_to root_path
        return
      end
      @client = client_new
  end

  def report
    if params[:ajax_tag] == 'report'
      @user = User.find(params[:reported_id])
      @client = client_new
      @user_tw_account = @client.user(@user.twid.to_i)
      render_404 if @user.nil?
      @word = @user.words.find_by(name: params[:word])
      if !(@word.nil?)
        if !(@word.report_available?)
          #通報期限切れ
          @result = "reportnotavailable"
        elsif @word.detected
          @result = "alreadyreported"
        else
          @word.detect_by(current_user)
          current_user.reports.create(reported: @user, word_str: params[:word], succeed: true)
          current_user.save
          @result = "success"
        end
      else
        current_user.score -= 50
        current_user.reports.create(reported: @user, word_str: params[:word], succeed: false)
        current_user.save
        @result = "fail"
      end
    else
      render_404
    end
  end
end
