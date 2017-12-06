class AddDetectorToWord < ActiveRecord::Migration[5.1]
  def change
    add_reference :words, :detector, foreign_key: true
  end
end
