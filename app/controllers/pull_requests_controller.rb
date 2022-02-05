class PullRequestsController < ApplicationController
  def index
    scope = PullRequest

    if params.key?(:week_of)
      scope =
        scope
        .after(Chronic.parse(params[:week_of]).beginning_of_week)
        .before(Chronic.parse(params[:week_of]).end_of_week)
    elsif params[:date].present?
      scope =
        scope
        .after(Chronic.parse(params[:date]).beginning_of_day)
        .before(Chronic.parse(params[:date]).beginning_of_day + 1.day)
    else
      scope =
        scope.
        after(2.weeks.ago)
    end

    if params.key?(:merged)
      case params[:merged]
      when "true", nil
        scope = scope.merged
      when "false"
        scope = scope.unmerged
      end
    end

    @prs =
      scope
      .order("org ASC, repo ASC, github_cache->>'created_at' DESC")
  end
end
