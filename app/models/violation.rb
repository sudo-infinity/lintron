class Violation
  attr_accessor :file, :line, :message, :linter

  def initialize(file:, line:, message:, linter: nil)
    @file = file
    @line = line
    @message = message
    @linter = linter
  end

  def position
    file.patch.position_for_line_number(line)
  end

  def to_comment(pr)
    Comment.new(
      pr: pr,
      position: position,
      path: file.path,
      message: message
    )
  end

  def to_s
    inspect
  end

  def to_str
    inspect
  end

  def inspect
    "#<Violation:#{ (object_id * 2).to_s(16) } @line=#{ line } @file=GithubFile(#{ file.path }) @message='#{ message }'>"
  end

  def as_json(_opts = {})
    {
      path: file.try(:path),
      line: line,
      message: message,
      linter: linter.to_s,
    }
  end
end
