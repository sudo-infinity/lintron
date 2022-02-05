class IssueComment
  def self.from_line_comment(pr, line_comment)
    new(pr: pr, body: "#{line_comment.path}: #{line_comment.message}")
  end

  # TODO: This pagination logic also happens in commenter.rb, maybe refactor
  def self.list_from_pr(pr, page = 1)
    gh_results = fetch_comment_page(pr, page)
    results = gh_results.to_a
    results.concat list_from_pr(pr, page + 1) if gh_results.links.next
    results
  end

  def self.fetch_comment_page(pr, page)
    Github.issues.comments.list pr.org,
                                pr.repo,
                                number: pr.pr_number,
                                page: page
  end

  def initialize(pr:, body:)
    @pr = pr
    @body = body
  end

  def already_commented?
    IssueComment.list_from_pr(@pr).any? { |comment| comment.body == @body }
  end

  def comment!(pr)
    return if already_commented?
    Github.issues.comments.create @pr.org, @pr.repo, @pr.pr_number, body: @body
  end
end
