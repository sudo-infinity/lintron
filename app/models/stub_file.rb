# A simple object we can use in place of a GithubFile as a test mock or for
# debugging
class StubFile < FileLike
  attr_accessor :path, :blob

  def initialize(path:, blob:, patch: nil)
    @path = path
    @blob = blob
    @patch = patch
  end

  def patch_from_blob
    lines = @blob.lines
    "@@ -0,0 +1,#{lines.length}\n" +
    lines.map { |l| "+#{l}" }.join('')
  end

  def patch
    @patch || Patch.new(patch_from_blob)
  end
end
