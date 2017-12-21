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
      todayswords.push(word) if (worddate == Time.zone.today && (word.cached_at.nil? || word.cached_at < Time.zone.now.ago(1800)))
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
      w.save
    end
    todayswords.each do |w|
      w.save
    end

    self.get_todays_score(nil)
  end

  def words_reset(client)
    #2日以上前の単語を削除する
    self.words.each do |word|
      if word.created_at.localtime("+09:00").to_date < Time.zone.yesterday
        word.destroy
      end
    end
    #1時を過ぎたら
    if self.word_updated_at.nil? || self.word_updated_at.localtime("+09:00").to_date <= (Time.zone.now - 1.hour).to_date.yesterday
      #スコア加算
      self.score += self.get_old_score(nil)
      self.word_updated_at = Time.zone.now
      self.save
    end

    #もし今日の単語7個持っていなかったら
    todaywordcount = 0
    self.words.each do |word|
      if word.created_at.localtime("+09:00").to_date == Time.zone.today
        todaywordcount += 1
      end
    end
    (7 - todaywordcount).times do
      word = self.words.create
    end
  end

  def get_score(client)
    self.get_todays_score(nil) if self.todayscore.nil?
    self.current_score_cache = self.score + self.todayscore
    self.save
    return self.current_score_cache
  end

  def get_todays_score(client)
    self.todayscore = 0
    self.words.each do |word|
      self.todayscore += word.get_score(self, client) if word.alive?
    end
    self.reports.each do |rp|
      self.todayscore += rp.succeed ? 100 : -20 if rp.today?
    end
    self.save
    return self.todayscore
  end

  def get_yesterdays_score(client)
    yesterdayscore = 0
    self.words.each do |word|
      yesterdayscore += word.get_score(self, client) if word.yesterday?
    end
    self.reports.each do |rp|
      yesterdayscore += rp.succeed ? 100 : -20 if rp.yesterday?
    end
    return yesterdayscore
  end

  def get_old_score(client)
    oldscore = 0
    self.words.each do |word|
      oldscore += word.get_score(self, client) if !word.alive?
    end
    self.reports.each do |rp|
      oldscore += rp.succeed ? 100 : -20 if !rp.today?
    end
    return oldscore
  end
end
