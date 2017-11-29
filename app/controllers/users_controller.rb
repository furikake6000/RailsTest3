class UsersController < ApplicationController
  def show
    @client = client_new
    @user = current_user
    @user_tw_account = @client.user(current_user.twid.to_i)
  end

  def senddm
    if params[:ajax_tag] == 'senddm'
      @client = client_new
      @client.create_direct_message(current_user.twid.to_i, "ぼたんがおされたよん")
    end
  end
end
