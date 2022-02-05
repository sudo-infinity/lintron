class Violation
  attr_accessor :file, :line, :message

  def initialize(file:, line:, message:)
    @file = file
    @line = line
    @message = message
  end

  def inspect
    "#<Violation:#{ (object_id * 2).to_s(16) } @line=#{ line } @file=GithubFile(#{ file.path }) @message='#{ message }'>"
  end
end
