class SeedProjectReposFromPullRequests < ActiveRecord::Migration
  def up
    PullRequest
      .select('org, repo')
      .group('org, repo')
      .each do |rec|
        ProjectRepo
          .create(
            org_name: rec.org,
            repo_name: rec.repo,
          )
    end
  end
end
