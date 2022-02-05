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

    new_comments[0..50].each do |cmt|
      under_abuse_limit do
        cmt.comment! pr
      end
    end

    bail_out! if new_comments.length > 50
  end

  def bail_out!
    IssueComment pr: pr, body: (
      <<-MARKDOWN
        ![Am I the only one?](http://www.quickmeme.com/img/f5/f5d74310c80a6085a3152eb5b050d53d4861368d99a2e5654d4ca736f3f566b8.jpg)

        Bailing out due to excessive lints.
      MARKDOWN
    ).comment!
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
