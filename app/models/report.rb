class Report < ApplicationRecord
  belongs_to :user
  belongs_to :reported, class_name: 'User', :foreign_key => 'reported_id'

  def today?
    return (self.created_at.localtime("+09:00") > Time.now.localtime("+09:00").beginning_of_day)
  end
end
