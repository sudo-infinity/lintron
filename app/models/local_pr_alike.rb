require 'git_diff_parser'
require_relative './stub_file'
require_relative './patch'
require_relative './linter_config_file'

# An object that is similar enough to PullRequest to be linted. It can be
# constructed from the CLI tool (compares local working tree to base_branch) or
# from the JSON payload that the CLI tool sends to the API
class LocalPrAlike
  attr_accessor :files, :repo, :org, :linter_configs

  def self.from_json(params)
    LocalPrAlike.new.tap do |pr|
      pr.org = params[:org]
      pr.repo = params[:repo]
      pr.files = params[:files].map do |file_json|
        StubFile.from_json(file_json)
      end
      pr.linter_configs = (params[:linter_configs] || {}).reduce({}) do |acc, (filename, content)|
        acc.merge(filename => LinterConfigFile.from_content(content))
      end
    end
  end

  def self.from_branch(org, repo, base_branch, repo_path)
    LocalPrAlike.new.tap do |pr|
      pr.org = org
      pr.repo = repo
      pr.files = pr.stubs_for_existing(base_branch) + pr.stubs_for_new
      pr.load_linter_configs(repo_path)
    end
  end

  def persisted?
    false
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

  # return a LinterConfigFile if the repo has one matching this filename, or nil
  def get_config_file(filename)
    linter_configs[filename]
  end

  # a hash of file_name => LinterConfigFile
  # for all linter configs pertaining to this PRs list of changed source files (StubFiles)
  def load_linter_configs(repo_path)
    extensions = files.map(&:extname).uniq
    @linter_configs = extensions.reduce({}) do |linter_configs, extension|
      linter_configs.merge(linter_configs_for(extension, repo_path))
    end
  end

  def linter_configs_for(extension, repo_path)
    Linters.linter_configs_for(extension).reduce({}) do |linter_configs, config_filename|
      full_path = File.join(repo_path, config_filename)
      if File.exist?(full_path)
        linter_configs.merge(config_filename => LinterConfigFile.from_path(full_path))
      else
        linter_configs
      end
    end
  end

  def linter_configs_content
    linter_configs.reduce({}) do |acc, (config_name, config_file)|
      acc.merge(config_name => config_file.content)
    end
  end

  def files_as_json(_opts = {})
    @files.map(&:as_json)
  end

  def to_json(_opts = {})
    {
      org: org,
      repo: repo,
      linter_configs: linter_configs_content,
      files: files_as_json.select do |file_json|
        begin
          JSON.dump(file_json)
          file_json
        rescue JSON::GeneratorError
          puts "Ignoring #{file_json[:path]}, possible binary"
          nil
        end
      end,
    }.to_json
  end
end
