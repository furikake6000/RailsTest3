class Quest < ApplicationRecord
  belongs?to :user
  validates :user_id, presence:true
  validates :type, presence:true
end
