# Adds a comment with a checklist to every PR so a reviewer can think hard about
# common sources of error
class PullRequestChecklist
  PULL_REQUEST_CHECKLIST_PATH = 'pull-request-checklist.md'

  def initialize(pr:)
    @pr = pr
  end

  def comment!
    IssueComment.new(pr: @pr, body: body).comment!
  end

  def body
    @_body ||= File.read(Rails.root.join(PULL_REQUEST_CHECKLIST_PATH))
  end
end
