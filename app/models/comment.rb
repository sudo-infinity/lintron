class Comment
  include ApiCache
  attr_accessor :pr, :position, :path, :message
  SHA_PATTERN = %r{/[a-f0-9]{32,}/}

  def initialize(pr:, position:, path:, message:, id: nil)
    @pr = pr
    @position = position
    @path = path
    @message = message
    @id = id
  end

  def self.from_gh(gh, pr)
    new(pr: pr, position: gh.position, path: gh.path, message: gh.body, id: gh.id)
  end

  def ==(other)
    position == other.position && path == other.path && same_message?(other)
  end

  def eql?(other)
    self == other
  end

  def same_message?(other)
    # Is exact same message, or only a sha changed (happens when we link to
    # blobs in the lint message)
    message_without_shas == other.message_without_shas
  end

  def message_without_shas
    message.gsub(SHA_PATTERN, '')
  end

  def hash
    Digest::SHA1.hexdigest("#{ path }#{ position }#{ message_without_shas }").hex
  end

  def comment!
    cmt = cache_api_request :to_gh do
      begin
        Github.pull_requests.comments.create \
          pr.org,
          pr.repo,
          pr.pr_number,
          body: message,
          commit_id: pr.to_gh.head.sha,
          path: path,
          position: position
        rescue Github::Error::UnprocessableEntity => e
          # Try to post a PR comment instead, because this mostly happens if the
          # patch has no lines in github (which means no line comments can post)
          IssueComment.from_line_comment(pr, self).comment!
        end
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

  def json_for_review
    {
      path: path,
      position: position,
      body: message,
    }
  end
end
