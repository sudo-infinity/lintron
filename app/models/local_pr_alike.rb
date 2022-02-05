require 'git_diff_parser'
require_relative './stub_file'
require_relative './patch'

# An object that is similar enough to PullRequest to be linted. It can be
# constructed from the CLI tool (compares local working tree to base_branch) or
# from the JSON payload that the CLI tool sends to the API
class LocalPrAlike
  attr_accessor :files

  def self.from_json(json)
    LocalPrAlike.new.tap do |pr|
      pr.files = json.map do |file_json|
        StubFile.from_json(file_json)
      end
    end
  end

  def self.from_branch(base_branch)
    LocalPrAlike.new.tap do |pr|
      pr.files = pr.stubs_for_existing(base_branch) + pr.stubs_for_new
    end
  end

  def stubs_for_existing(base_branch)
    patches = GitDiffParser.parse(raw_diff(base_branch))

    patches.map do |patch|
      StubFile.new(
        path: patch.file,
        blob: File.read(patch.file),
        patch: Patch.new(patch.body),
      )
    end
  end

  def raw_diff(base_branch)
    diff = `git diff --no-ext-diff #{base_branch} .`
    unless $CHILD_STATUS.success?
      raise(
        'git diff failed. You may need to set a default branch in .linty_rc.',
      )
    end
    diff
  end

  def stubs_for_new
    untracked_names = `git ls-files --others --exclude-standard`.split("\n")
    untracked_names.map do |name|
      body = File.read(name)
      StubFile.new(
        path: name,
        blob: body,
        patch: Patch.from_file_body(body),
      )
    end
  end

  def changed_files
    files
  end

  def expected_url_from_path(path)
    path
  end

  def as_json(_opts = {})
    @files.map(&:as_json)
  end
end
