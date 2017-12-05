module ApplicationHelper
  def pickAWord
    path = Dir.glob('./app/assets/dict/*')
    File.open(path.sample, mode = "rt"){|f|
      return f.readlines.sample
    }
  end
end
