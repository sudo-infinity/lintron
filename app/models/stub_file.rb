require_relative './file_like'

# A simple object we can use in place of a GithubFile as a test mock or for
# debugging
class StubFile < FileLike
  attr_accessor :path, :blob

  def self.from_json(json)
    json = json.symbolize_keys
    StubFile.new(
      path: json[:path],
      blob: json[:blob],
      patch: Patch.new(json[:patch]),
    )
  end

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

  def as_json(_opts = {})
    {
      path: @path,
      blob: @blob,
      patch: patch.body,
    }
  end
end
