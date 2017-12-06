class Word < ApplicationRecord
  belongs_to :user
  validates :user_id, presence: true
  validates :name, presence: true

end
