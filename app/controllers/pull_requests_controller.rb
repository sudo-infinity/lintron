class PullRequestsController < ApplicationController
  def index
    @prs =
      PullRequest
      .after(Time.zone.now.beginning_of_week)
      .order("org ASC, repo ASC, github_cache->>'created_at' DESC")
  end
end
