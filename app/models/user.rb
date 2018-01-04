class User < ApplicationRecord
  validates :twid, presence: true

  default_scope -> { order(current_score_cache: :desc) }

  has_many :reports
  has_many :words, dependent: :destroy
  has_many :reported_reports, class_name: 'Report', :foreign_key => 'reported_id'

  def User.find_or_create_from_auth(auth)
    twid = auth[:uid]
    return User.find_or_create_by(twid: twid)
  end

  def refresh_wordcaches(client)
    #キャッシュを再取得してくれるのは今日と昨日のWordだけ
    todayswords = []
    yesterdayswords = []
    self.words.each do |word|
      worddate = word.created_at.dup.localtime("+09:00").to_date
      #今日の単語は、キャッシュ取得がまだ行われていないか5分以内に行われていなかったら取得待ち列に並べる
      todayswords.push(word) if (worddate == Time.zone.today && (word.cached_at.nil? || word.cached_at < Time.zone.now.ago(300)))
      #昨日の単語は、今日キャッシュ取得がまだ行われていなかったら取得待ち列に並べる
      yesterdayswords.push(word) if (worddate == Time.zone.yesterday && ( word.cached_at.nil? || word.cached_at.localtime("+09:00").to_date == Time.zone.yesterday))
    end

    yesterdayswords.each do |w|
      w.cached_at = Time.zone.now
      w.countcache = 0
    end
    todayswords.each do |w|
      w.cached_at = Time.zone.now
      w.countcache = 0
    end

    #さかのぼるツイートごとに単語検索する
    query_params = { :user_id => self.twid, :exclude_replies => true, :count => 200 }
    catch :finish do
      1.upto(50) do |i|
        tweets = client.user_timeline(query_params)
        #ツイートが空だったら抜ける（mix3@ｻﾀﾃﾞｰﾅｲﾄﾌｨｰﾊﾞｰ様、ありがとうございます）
        throw :finish if tweets.empty?
        tweets.each do |tweet|
          tweetdate = tweet.created_at.dup.localtime("+09:00").to_date
          if tweetdate == Time.zone.today
            #throw :finish if todayswords.empty? ←前日の単語カウントが0になるバグの原因
            todayswords.each do |w|
              w.countcache += tweet.full_text.scan(/(?=#{w.name})/).count if !tweet.retweeted?
            end
          elsif tweetdate == Time.zone.yesterday
            throw :finish if yesterdayswords.empty?
            yesterdayswords.each do |w|
              w.countcache += tweet.full_text.scan(/(?=#{w.name})/).count if !tweet.retweeted?
            end
          else
            throw :finish
          end
        end
        query_params[:max_id] = tweets.last.id
      end
    end

    yesterdayswords.each do |w|
      w.save!
    end
    todayswords.each do |w|
      w.save!
    end

    self.get_todays_score(nil)
  end

  def words_reset(client)
    #もし今日の単語7個持っていなかったら
    todaywordcount = 0
    self.words.each do |word|
      if word.alive?
        todaywordcount += 1
      end
    end
    (7 - todaywordcount).times do
      word = self.words.create
    end
  end

  #総スコアを計算する
  def get_score(client)
    #基準スコア（アップデート前のスコア）に単語スコアとレポートスコアを加算しキャッシュに保存
    self.current_score_cache = self.score + self.get_words_score(nil) + self.get_reports_score(nil)
    self.save!
    return self.current_score_cache
  end

  #一日ごとスコアを計算する
  def get_todays_score(client)
    self.todayscore = 0
    self.words.each do |word|
      self.todayscore += word.get_score(self, client) if word.alive?
    end
    self.reports.each do |rp|
      self.todayscore += rp.succeed ? 100 : -20 if rp.today?
    end
    self.save!
    return self.todayscore
  end

  #単語スコアを計算
  def get_words_score(client)
    wordscore = 0
    self.words.each do |word|
      wordscore += word.get_score(self, client)
    end
    return wordscore
  end
  #摘発スコアを計算
  def get_reports_score(client)
    reportscore = 0
    self.reports.each do |rp|
      reportscore += rp.succeed ? 100 : -20
    end
    return reportscore
  end

  #Twitterアカウントの情報を更新する
  def update_tw_account(user_tw_account)
    self.name = user_tw_account.name
    self.screen_name = user_tw_account.screen_name
    self.url = user_tw_account.url.to_s
    self.imgurl = ApplicationController.helpers.get_twpic_uri(user_tw_account)
    #鍵垢判定
    if self.is_secret != user_tw_account.protected?
      self.is_secret = user_tw_account.protected?
    end
    self.save!
  end
end
