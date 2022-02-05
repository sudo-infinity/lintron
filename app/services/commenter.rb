class Commenter
  include ApiCache
  attr_accessor :pr, :violations

  delegate :under_abuse_limit, to: :abuse_throttle

  def initialize(pr:, violations:)
    @pr = pr
    @violations = violations
  end

  def abuse_throttle
    @_abuse_throttle ||= AbuseThrottle.new
  end

  def comment!
    stale_comments.each do |cmt|
      under_abuse_limit do
        cmt.delete! pr
      end
    end

    new_comments.each do |cmt|
      under_abuse_limit do
        cmt.comment! pr
      end
    end
  end

  def new_comments
    (all_comments - existing_comments).uniq
  end

  def stale_comments
    existing_comments - all_comments
  end

  def all_comments
    violations.map { |v| v.to_comment }
  end

  def existing_comments
    cache_api_request :existing_comments do
      list_from_pr.select { |cmt| lint?(cmt) }.map { |cmt| Comment.from_gh(cmt, @pr) }
    end
  end

  def lint?(cmt)
    cmt.user.login == ENV['GITHUB_USERNAME']
  end

  def list_from_pr(page = 1)
    gh_results = fetch_comment_page(page)
    results = gh_results.to_a
    results.concat list_from_pr(page + 1) if gh_results.links.next
    results
  end

  def fetch_comment_page(page)
    Github.pull_requests.comments.list pr.org,
                                       pr.repo,
                                       number: pr.pr_number,
                                       page: page
  end
end
