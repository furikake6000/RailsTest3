class UsersController < ApplicationController
  def show
    #ログインしていないと見られない
    if !logged_in?
      redirect_to root_path
      return
    end
    @client = client_new
    @user_tw_account = @client.user(params[:id].to_s)
    @user = User.find_by(twid: @user_tw_account.id)

    #自分自身を選択していたらルートにリダイレクト
    if @user == current_user
      redirect_to root_path
      return
    end
    render_404 if @user.nil?

    User.transaction do
      @user.lock!
      @user.update_tw_account(@user_tw_account)
    end

    #Words取得
    @words = @user.words.all
    words_p = @words.partition{|w| w.alive?}
    @todayswords = words_p[0]
    @deadwords = words_p[1]

    @friends = get_friends(@client)

    @tweets = @client.user_timeline(params[:id].to_s)

  rescue Twitter::Error::Unauthorized
  #鍵垢orAPIエラー等だった場合ここにくる
    @unauthorized_occured = true
  end

  def report_history
    #ログインしていないと見られない
    if !logged_in?
      redirect_to root_path
      return
    end
    @client = client_new

    current_user.reports.all.uniq{ |rp| rp.reported_id }.each do |rp|
      if rp.reported.screen_name.nil? or rp.reported.screen_name.blank?
        User.transaction do
          rp.reported.lock!
          acc = @client.user(rp.reported.twid.to_i)
          rp.reported.update_tw_account(acc)
        end
      end
    end

    @rphists = current_user.reports.all.order("created_at DESC")
  end

  def report
    if params[:ajax_tag] == 'report'
      @user = User.find(params[:reported_id])
      render_404 if @user.nil?

      if params[:word].blank?
        @result = "blank"
        return
      end

      @client = client_new
      @wordstr = params[:word]
      @user_tw_account = @client.user(@user.twid.to_i)

      @word = @user.words.find_by(name: params[:word])

      if !(@word.nil?)
        if !(@word.report_available?)
          #通報期限切れ
          @result = "reportnotavailable"
        elsif @word.detected
          @result = "alreadyreported"
        else
          User.transaction do
            me = current_user
            @user.lock! # 摘発した相手のデータを更新するのでロックする
            me.lock!
            @word.detect_by(me)
            me.reports.create(reported: @user, word_str: params[:word], succeed: true)
            me.save!
          end
          @result = "success"
        end
      else
        User.transaction do
          me = current_user
          me.lock!
          me.reports.create(reported: @user, word_str: params[:word], succeed: false)
          me.save!
        end
        @result = "fail"
      end
    else
      render_404
    end
  end
end
