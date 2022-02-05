class PrViolation < Violation
  attr_accessor :pr, :message, :linter

  def initialize(pr:, message:, linter: nil)
    @pr = pr
    @message = message
    @linter = linter
  end

  def to_comment(pr)
    IssueComment.new(
      pr: pr,
      body: message,
    )
  end

  def inspect
    "#<PrViolation:#{ (object_id * 2).to_s(16) } @pr=#{ pr } @message='#{ message }'>"
  end
end
