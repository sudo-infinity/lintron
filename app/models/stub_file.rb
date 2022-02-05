# A simple object we can use in place of a GithubFile as a test mock or for
# debugging
class StubFile < FileLike
  attr_accessor :path, :blob

  def initialize(path:, blob:)
    @path = path
    @blob = blob
  end
end
