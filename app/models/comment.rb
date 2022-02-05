class Comment
  include ApiCache
  attr_accessor :position, :path, :message

  def initialize(position:, path:, message:, id: nil)
    @position = position
    @path = path
    @message = message
    @id = id
  end

  def self.from_violation(violation)
    new position: violation.position,
        path: violation.file.path,
        message: violation.message
  end

  def self.from_gh(gh, pr)
    new(position: gh.position, path: gh.path, message: gh.body, id: gh.id)
  end

  def ==(other)
    position == other.position && path == other.path && message == other.message
  end

  def eql?(other)
    self == other
  end

  def hash
    Digest::SHA1.hexdigest("#{ path }#{ position }#{ message }").hex
  end

  def comment!(pr)
    cmt = cache_api_request :to_gh do
      Github.pull_requests.comments.create \
        pr.org,
        pr.repo,
        pr.pr_number,
        body: message,
        commit_id: pr.to_gh.head.sha,
        path: path,
        position: position
    end
    @id = cmt.id
    cmt
  end

  def delete!(pr)
    Github.pull_requests.comments.delete \
      pr.org,
      pr.repo,
      @id
  end
end
