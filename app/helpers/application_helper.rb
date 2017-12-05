module ApplicationHelper
  def pickAWord
    path = Dir.glob('./app/assets/dict/*')
    File.open(path.sample, mode = "rt") do |f|
      return f.readlines.sample.chomp
    end
  end
end
