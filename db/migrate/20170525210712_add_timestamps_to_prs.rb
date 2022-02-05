class AddTimestampsToPrs < ActiveRecord::Migration
  def change
    change_table :pull_requests do |t|
      t.timestamps
    end
  end
end
