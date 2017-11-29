module UsersHelper
  def render_users_show
    @client = client_new
    @user = current_user
    @user_tw_account = @client.user(current_user.twid.to_i)
    render 'users/show'
  end
end
