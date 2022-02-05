class AddLintsToPullRequests < ActiveRecord::Migration
  def change
    add_column :pull_requests, :lints, :json
  end
end
