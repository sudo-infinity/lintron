class GithubWebhooksController < ApplicationController
  include GithubWebhook::Processor

  def pull_request(payload)
  end

  def webhook_secret(payload)
   ENV['GITHUB_WEBHOOK_SECRET']
 end
end
