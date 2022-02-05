class RelintLink
  def initialize(pr:, request:)
    @pr = pr
    @request = request
  end

  def url
    "http://#{@request.host}/relint/#{@pr.org}/#{@pr.repo}/#{@pr.pr_number}"
  end

  def comment!
    IssueComment.new(pr: @pr, body: "To relint, [click here](#{url}).").comment!
  end
end
