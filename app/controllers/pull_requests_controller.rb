class PullRequestsController < ApplicationController
  def index
    @prs =
      PullRequest
        .after(begin_date)
        .before(end_date)
        .send(merged_scope)
        .for_repo_or_all(params[:repo])
        .report_order
  end

  def begin_date
    return 2.week.ago.beginning_of_day if params[:start_date].blank?
    if params[:start_date].downcase.strip == 'prior business day'
      return 1.business_day.ago.beginning_of_day
    end
    return Chronic.parse(params[:start_date]).beginning_of_day
  end

  def end_date
    return 1.day.from_now.end_of_day if params[:start_date].blank? && params[:end_date].blank?
    return begin_date.end_of_day if params[:start_date].present? && params[:end_date].blank?
    if params[:end_date].downcase.strip == 'prior business day'
      return 1.business_day.ago.end_of_day
    end
    return Chronic.parse(params[:end_date]).end_of_day
  end

  def merged_scope
    return :itself unless params.key?(:merged)
    return :merged if params[:merged] == "true" || params[:merged].nil?
    :unmerged
  end
end
