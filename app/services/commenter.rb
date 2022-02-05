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

    add_review

    bail_out! if new_comments.length > 50
  end

  def add_review
    body = (new_comments.select { |cmt| cmt.class == IssueComment }).map(&:body).join("\n---\n")
    if body.empty?
      body = "http://lintron.herokuapp.com/relint/#{@pr.org}/#{@pr.repo}/#{@pr.pr_number}"
    end

    Github.pull_requests.reviews.create pr.org, pr.repo, pr.pr_number,
      body: body,
      event: "COMMENT",
      comments: (new_comments.select { |cmt| cmt.class == Comment })[0..50].map(&:json_for_review)
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
    violations.map { |v| v.to_comment(pr) }
  end

  def existing_comments
    cache_api_request :existing_comments do
      line_comments = list_from_pr.select { |cmt| lint?(cmt) }.map { |cmt| Comment.from_gh(cmt, @pr) }
      issue_comments = list_from_issue.select { |cmt| lint?(cmt) }.map { |cmt| IssueComment.from_gh(pr: @pr, gh: cmt) }
      line_comments + issue_comments
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

  def list_from_issue(page = 1)
    gh_results = fetch_issue_comments_page(page)
    results = gh_results.to_a
    results.concat fetch_issue_comments_page(page + 1) if gh_results.links.next
    results
  end

  def fetch_issue_comments_page(page)
     Github
      .issues
      .comments
      .list(pr.org, pr.repo, number: pr.pr_number, page: page)
  end
end
