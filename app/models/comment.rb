class Comment
  attr_accessor :position, :path, :message

  def initialize(position:, path:, message:)
    @position = position
    @path = path
    @message = message
  end

  def self.from_violation(violation)
    new(position: violation.patch_position, path: violation.file.path, message: violation.message)
  end

  def self.from_gh(gh)
    new(position: gh.position, path: gh.path, message: gh.body)
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
    Github.pull_requests.comments.create \
      pr.org,
      pr.repo,
      pr.pr_number,
      {
        body: message,
        commit_id: pr.to_gh.head.sha,
        path: path,
        position: position
      }
  end
end
