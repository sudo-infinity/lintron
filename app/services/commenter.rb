class Commenter
  include ApiCache
  attr_accessor :pr, :violations

  def initialize(pr:, violations:)
    @pr = pr
    @violations = violations
  end

  def comment!
    new_comments.each { |cmt| cmt.comment! pr }
  end

  def new_comments
    all_comments - existing_comments
  end

  def all_comments
    violations.map { |v| Comment.from_violation(v) }
  end

  def existing_comments
    cache_api_request :existing_comments do
      Github.pull_requests.comments.list(pr.org, pr.repo, pr.pr_number).map { |cmt| Comment.from_gh cmt }
    end
  end
end
