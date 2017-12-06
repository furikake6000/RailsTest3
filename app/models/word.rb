class Word < ApplicationRecord
  include ApplicationHelper

  belongs_to :user
  validates :user_id, presence: true
  validates :name, presence: true

  def initialize(attributes = {})
    super
    self.name = pickAWord
  end
end
