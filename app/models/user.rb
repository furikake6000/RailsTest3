class User < ApplicationRecord
  validates :twid, presence: true

  default_scope -> { order(current_score_cache: :desc) }

  has_many :quests, dependent: :destroy
  has_many :words, dependent: :destroy

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
      yesterdayswords.push(word) if (worddate == Time.zone.yesterday && word.cached_at.localtime("+09:00").to_date == Time.zone.yesterday)
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
      1.upto(50) do |i|
        tweets = client.user_timeline({user_id: self.twid, include_rts: false, page:i})
        print(i)
        tweets.each do |tweet|
          tweetdate = tweet.created_at.dup.localtime("+09:00").to_date
          if tweetdate == Time.zone.today
            throw :finish if todayswords.empty?
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
    end

    yesterdayswords.each do |w|
      w.save
    end
    todayswords.each do |w|
      w.save
    end
  end

  def words_reset(client)
    #1日以上前の単語を削除する(日付変わった瞬間に削除されない)
    self.words.each do |word|
      if word.created_at.localtime("+09:00") < Time.zone.now.yesterday.localtime("+09:00").beginning_of_day
        #削除される時にスコア加算
        self.score += word.get_score(self, client)
        word.destroy
      end
    end
    #日付変わったら5個単語を生成
    if self.word_updated_at.nil? || self.word_updated_at.localtime("+09:00") < Time.zone.now.localtime("+09:00").beginning_of_day
      self.words.destroy_all
      self.word_updated_at = Time.now
      self.save
      5.times do
        word = self.words.create
      end
    end
  end

  def get_score(client)
    self.current_score_cache = self.score
    self.words.each do |word|
      self.current_score_cache += word.get_score(self, client)
    end
    self.save
    return self.current_score_cache
  end

end
