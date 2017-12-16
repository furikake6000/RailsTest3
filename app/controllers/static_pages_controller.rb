class StaticPagesController < ApplicationController
  def home
    if logged_in?
      render_users_home
      return
    end
  end

  def ranking
    @client = client_new
  end

  def about
  end

  def info
  end

  def sandbox
  end

  def postimage
    @client = client_new
    file = params[:uppic]
    @result = uploadmedia(@client, file)
    print(@result)

    @client.update("ぬわ", {media_ids: @result[:media_id_string]})
  end

  def admin
    #管理者でなければ弾かれる
    unless logged_in? && current_user.admin
      redirect_to root_path and return
    end
    @users = User.paginate(page: params[:page])
  end
end
