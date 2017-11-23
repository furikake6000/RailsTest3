module TwitterSessionsHelper

  def log_in(user)
    session[:user_id] = user.id
  end

  def current_user()
    #インスタンス変数current_userを参照、いなかったらセッションから取得
    @current_user ||= User.find_by(id: session[:user_id])
  end
end
