class HookEnabler
  HOOK_URL = 'https://lintron.herokuapp.com/github_webhooks'

  attr_accessor :repo, :org, :user

  def initialize(repo, org, user)
    @repo = repo
    @org = org
    @user = user
  end

  def run
    maybe_enable_hook_for(repo, org)
  end

  def maybe_enable_hook_for(repo, org)
    return if has_hook_already?(repo, org)

    enable_hook_for(repo, org)
  end

  def enable_hook_for(repo, org)
    github.repos.hooks.create(
      org,
      repo,
      {
        name: 'web',
        config: {
          url: HookEnabler::HOOK_URL,
          secret: ENV['GITHUB_WEBHOOK_SECRET'],
          content_type: 'json',
        },
        events: ['*'],
        active: true,
      },
    )
  end

  def has_hook_already?(repo, org)
    current_hooks_for(repo, org).any? { |hook| hook.config.url == HookEnabler::HOOK_URL }
  end

  def current_hooks_for(repo, org)
    github.repos.hooks.list(org, repo)
  end

  def github
    @_github ||= github = Github.new do |c|
      c.basic_auth = "#{user.username}:#{user.secret}"
    end
  end
end
