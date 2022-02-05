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
    new_comments.each do |cmt|
      under_abuse_limit do
        cmt.comment! pr
      end
    end
  end

  def new_comments
    all_comments - existing_comments
  end

  def all_comments
    violations.map { |v| Comment.from_violation(v) }
  end

  def existing_comments
    cache_api_request :existing_comments do
      list_from_pr.map { |cmt| Comment.from_gh cmt }
    end
  end

  def list_from_pr
    Github.pull_requests.comments.list(pr.org, pr.repo, pr.pr_number)
  end
end
