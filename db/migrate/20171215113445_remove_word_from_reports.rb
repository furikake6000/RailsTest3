class RemoveWordFromReports < ActiveRecord::Migration[5.1]
  def change
    remove_reference :reports, :word, foreign_key: true
  end
end
