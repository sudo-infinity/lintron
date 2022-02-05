class GithubWebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token, if: :json_request?
  include GithubWebhook::Processor

  LINT_ACTIONS = %w(opened synchronize)

  def pull_request(payload)
    if LINT_ACTIONS.include? payload['action']
      Thread.new do
        pr = PullRequest.from_payload(payload)
        violations = Linters.violations_for_pr(pr)
        Commenter.new(pr: pr, violations: violations).comment!
      end
    end

    head :no_content
  end

  def webhook_secret(_payload)
    ENV['GITHUB_WEBHOOK_SECRET']
  end

  protected

  def json_request?
    request.format.json?
  end
end
