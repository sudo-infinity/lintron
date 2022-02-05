class GithubWebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token, if: :json_request?
  include GithubWebhook::Processor

  LINT_ACTIONS = %w(opened synchronize)

  def github_pull_request(payload)
    if LINT_ACTIONS.include? payload['action']
      Thread.new do
        begin
          pr = PullRequest.from_payload(payload)
          pr.lint_and_comment!
          RelintLink.new(pr: pr, request: request).comment!
        rescue => e
          Rails.logger.error e
        end
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
