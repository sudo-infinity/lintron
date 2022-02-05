class PullRequestsController < ApplicationController
  def index
    week_of = params[:week_of].present? ? Date.parse(params[:week_of]) : Time.zone.now

    @prs =
      PullRequest
      .after(week_of.beginning_of_week)
      .order("org ASC, repo ASC, github_cache->>'created_at' DESC")
  end
end
