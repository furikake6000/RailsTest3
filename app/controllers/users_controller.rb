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
      @result = true
    else
      render_404
    end
  end
end
