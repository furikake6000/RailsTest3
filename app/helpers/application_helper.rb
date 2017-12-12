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
end
