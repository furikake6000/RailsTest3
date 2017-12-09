class UsersController < ApplicationController
  def show
    @client = client_new
    @user_tw_account = @client.user(params[:id].to_s)
    @user = User.find_by(twid: @user_tw_account.id)
    render_404 if @user.nil?
    @words = @user.words.all
  end

  def senddm
    if params[:ajax_tag] == 'senddm'
      @client = client_new
      @client.create_direct_message(current_user.twid.to_i, "ぼたんがおされたよん")
    end
  end

  def report
    if params[:ajax_tag] == 'report'
      @user = User.find(params[:reported_id])
      @word = @user.words.find_by(name: params[:word])
      if !(@word.nil?)
        @succeed = true
      else
        @succeed = false
      end
    else
      render_404
    end
  end
end
