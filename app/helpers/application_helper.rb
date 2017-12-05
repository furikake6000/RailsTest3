module ApplicationHelper
  def pickAWord
    File.open("./app/assets/dict/dict1", mode = "rt"){|f|
      return f.readlines.sample
    }
  end
end
