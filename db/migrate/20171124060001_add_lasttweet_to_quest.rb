class AddLasttweetToQuest < ActiveRecord::Migration[5.1]
  def change
    add_column :quests, :last_tweet, :integer
    add_column :quests, :last_retweet, :integer
  end
end
