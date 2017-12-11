class User < ApplicationRecord
  validates :twid, presence: true

  default_scope -> { order(score: :desc) }

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
      todayswords.push(word) if (worddate == Time.zone.today && (self.cached_at.nil? || self.cached_at < Time.zone.now.ago(300)))
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
        tweets = client.user_timeline({user_id: user.twid, include_rts: false, page:i})
        print(i)
        tweets.each do |tweet|
          tweetdate = tweet.created_at.dup.localtime("+09:00").to_date
          if tweetdate == Time.zone.today
            todayswords.each do |w|
              count += tweet.full_text.scan(/(?=#{w.name})/).count
            end
          elsif tweetdate == Time.zone.yesterday
            throw :finish if yesterdaystweets.nil?
            yesterdayswords.each do |w|
              count += tweet.full_text.scan(/(?=#{w.name})/).count
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
    end
  end

  def get_score(client)
    returnscore = self.score
    self.words.each do |word|
      returnscore += word.get_score(self, client)
    end
    return returnscore
  end

end
