class UsersController < ApplicationController
  def show
    @client = client_new
    @user_tw_account = @client.user(params[:id].to_s)
    @user = User.find_by(twid: @user_tw_account.id)
  end

  def senddm
    if params[:ajax_tag] == 'senddm'
      @client = client_new
      @client.create_direct_message(current_user.twid.to_i, "ぼたんがおされたよん")
    end
  end
end
