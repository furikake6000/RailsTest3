class UsersController < ApplicationController
  def show
    @client = client_new
    @user = User.find(params[:id])
    @user_tw_account = @client.user(@user.twid.to_i)
  end

  def senddm
    if params[:ajax_tag] == 'senddm'
      @client = client_new
      @client.create_direct_message(current_user.twid.to_i, "ぼたんがおされたよん")
    end
  end
end
