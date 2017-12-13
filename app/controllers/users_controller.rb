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
    @words = @user.words.all
    @tweets = @client.user_timeline(params[:id].to_s)
  end

  def report
    if params[:ajax_tag] == 'report'
      @user = User.find(params[:reported_id])
      @client = client_new
      @user_tw_account = @client.user(@user.twid.to_i)
      render_404 if @user.nil?
      @wordstr = params[:word]
      @word = @user.words.find_by(name: @wordstr)
      if !(@word.nil?)
        if !(@word.report_available?)
          #通報期限切れ
          @result = "reportnotavailable"
        elsif @word.detected
          @result = "alreadyreported"
        else
          @word.detect_by(current_user)
          @result = "success"
        end
      else
        current_user.score -= 50
        current_user.save
        @result = "fail"
      end
    else
      render_404
    end
  end
end
