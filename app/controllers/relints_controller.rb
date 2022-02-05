class RelintsController < ApplicationController
  def relint
    pr = PullRequest.new(**pr_params)

    Thread.new do
      pr.lint_and_comment!
      RelintLink.new(pr: pr, request: request).comment!
    end

    redirect_to pr.to_gh['html_url']
  end

  def pr_params
    params.permit(:org, :repo, :pr_number).symbolize_keys
  end
end
