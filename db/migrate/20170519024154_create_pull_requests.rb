class CreatePullRequests < ActiveRecord::Migration
  def change
    create_table :pull_requests do |t|
      t.string :org
      t.string :repo
      t.integer :pr_number
    end
  end
end
