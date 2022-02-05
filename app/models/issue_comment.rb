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

  def existing_comment
    @_existing_comment ||=
      IssueComment.list_from_pr(@pr).find { |comment| similar_bodies(comment.body, @body) }
  end

  # Determines if two issues are "similar" enough that we don't need to re-post
  # Right now we just do this by stripping out checkboxes and comparing what is
  # left.
  def similar_bodies(left, right)
    pattern = /\[(\s|x|X)?\]/
    left.gsub(pattern, '') == right.gsub(pattern, '')
  end

  def comment!
    return existing_comment if existing_comment.present?
    Github.issues.comments.create @pr.org, @pr.repo, @pr.pr_number, body: @body
  end
end
