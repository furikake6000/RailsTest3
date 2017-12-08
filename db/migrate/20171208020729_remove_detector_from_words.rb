class RemoveDetectorFromWords < ActiveRecord::Migration[5.1]
  def change
    remove_reference :words, :detector, foreign_key: true
    add_column :words, :detectorid, :integer
  end
end
