class RemoveDetectorFromWords < ActiveRecord::Migration[5.1]
  def change
    add_column :words, :detectorid, :integer
  end
end
