class AddGithubCacheToPullRequests < ActiveRecord::Migration
  def up
    add_column :pull_requests, :github_cache, :json

    PullRequest.transaction do
      PullRequest.find_each do |pr|
        pr.save!
      end
    end
  end

  def down
    remove_column :pull_requests, :github_cache
  end
end
