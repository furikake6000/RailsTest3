class Word < ApplicationRecord
  include ApplicationHelper

  belongs_to :user
  belongs_to :detector ,class_name: 'User', foreign_key:'detector_id'
  validates :user_id, presence: true
  validates :name, presence: true

  def initialize(attributes = {})
    super
    self.name = pickAWord
  end

  def to_s
    return self.name
  end
end
