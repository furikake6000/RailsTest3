class User < ApplicationRecord

  def User.find_or_create_from_auth(auth)
    twid = auth[:uid]
    return User.find_or_create_by(twid: twid)
  end

end
