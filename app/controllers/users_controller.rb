class UsersController < ApplicationController
  def show
    #ログインしていないと見られない
    redirect_to root_path if !logged_in?
    @client = client_new
    @user_tw_account = @client.user(params[:id].to_s)
    @user = User.find_by(twid: @user_tw_account.id)

    #自分自身を選択していたらルートにリダイレクト
    redirect_to root_path if @user == current_user
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
          current_user.report.create(reported: @user, word: @word, word_str: params[:word], succeed: true)
          @result = "success"
        end
      else
        current_user.score -= 50
        current_user.save
        current_user.report.create(reported: @user, word: nil, word_str: params[:word], succeed: false)
        @result = "fail"
      end
    else
      render_404
    end
  end
end
