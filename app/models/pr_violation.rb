class PrViolation < Violation
  attr_accessor :pr, :message

  def initialize(pr:, message:)
    @pr = pr
    @message = message
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
