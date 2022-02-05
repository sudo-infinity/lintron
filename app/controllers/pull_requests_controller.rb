class PullRequestsController < ApplicationController
  def index
    scope = PullRequest

    begin_date = 2.week.ago.beginning_of_day
    end_date = 1.day.from_now.end_of_day
    if params[:start_date].present?
      if params[:date] == 'prior business day'
        begin_date = 1.business_day.ago.beginning_of_day
      else
        begin_date = Chronic.parse(params[:start_date]).beginning_of_day
      end
      end_date = begin_date.end_of_day
    end

    if params[:end_date].present?
      if params[:date] == 'prior business day'
        end_date = 1.business_day.ago.end_of_day
      else
        end_date = Chronic.parse(params[:end_date]).end_of_day
      end
    end

    scope = scope.after(begin_date).before(end_date)

    if params.key?(:merged)
      case params[:merged]
      when "true", nil
        scope = scope.merged
      when "false"
        scope = scope.unmerged
      end
    end

    if params[:repo].present?
      scope = scope.for_repo(params[:repo])
    end

    @prs =
      scope
      .order("org ASC, repo ASC, github_cache->>'created_at' DESC")
  end
end
