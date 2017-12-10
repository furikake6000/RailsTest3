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
  end

  def report
    if params[:ajax_tag] == 'report'
      @user = User.find(params[:reported_id])
      render_404 if @user.nil?
      @word = @user.words.find_by(name: params[:word])
      if !(@word.nil?)
        if @word.detected
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
