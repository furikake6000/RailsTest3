class Report < ApplicationRecord
  belongs_to :user
  belongs_to :word
  belongs_to :reported, class_name: 'User', :foreign_key => 'reported_id'
end
