module ApplicationHelper
  def pickAWord
    path = Dir.glob('./app/assets/dict/*')
    File.open(path.sample, mode = "rt") do |f|
      return f.readlines.sample.chomp
    end
  end

  def render_404(e = nil)
    render file: Rails.root.join('public/404.html'), status: 404
  end

  def tweetlink(string)
    linkstr = "https://twitter.com/intent/tweet?" + "text=" + string + "&hashtags=F国からのスパイ"
    return URI.escape(linkstr)
  end

  def excludelinks(string)
    cpstr = string.dup
    URI.extract(cpstr,['http','https']).uniq.each do |url|
      cpstr.slice!(url)
      #これだと同じURLが2回以上登場する場合うまくいかないが想定しない
    end
    return cpstr
  end

  def uploadmedia(client, media)
    print(media.tempfile)
    Twitter::REST::Request.new(client, :multipart_post, 'https://upload.twitter.com/1.1/media/upload.json', key: :media, file: media.tempfile).perform
  end
end
