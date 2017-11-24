class AddLasttweetToQuest < ActiveRecord::Migration[5.1]
  def change
    add_column :quests, :last_tweet, :string
    add_column :quests, :last_retweet, :string
  end
end
