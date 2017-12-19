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
    catch :finish do
      client.user_timeline({user_id: self.twid, include_rts: false, exclude_replies: true}).each do |tweet|
        #ツイートが空だったら抜ける（mix3@ｻﾀﾃﾞｰﾅｲﾄﾌｨｰﾊﾞｰ様、ありがとうございます）
        throw :finish if tweet.nil?
        tweetdate = tweet.created_at.dup.localtime("+09:00").to_date
        if tweetdate == Time.zone.today
          #throw :finish if todayswords.empty? ←前日の単語カウントが0になるバグの原因
          todayswords.each do |w|
            w.countcache += tweet.full_text.scan(/(?=#{w.name})/).count
          end
        elsif tweetdate == Time.zone.yesterday
          throw :finish if yesterdayswords.empty?
          yesterdayswords.each do |w|
            w.countcache += tweet.full_text.scan(/(?=#{w.name})/).count
          end
        else
          throw :finish
        end
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
    #日付変わったら
    if self.word_updated_at.nil? || self.word_updated_at.localtime("+09:00").to_date <= Time.zone.yesterday
      #スコア加算
      self.score += self.get_yesterdays_score(nil)
      self.word_updated_at = Time.now
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
      self.todayscore += rp.succeed ? 100 : -50 if rp.today?
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
      yesterdayscore += rp.succeed ? 100 : -50 if rp.yesterday?
    end
    return yesterdayscore
  end
end
