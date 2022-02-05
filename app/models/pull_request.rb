class PullRequest < ActiveRecord::Base
  scope :after, ->(date) { where("(github_cache->>'created_at')::timestamp >= ?", date) }
  scope :before, ->(date) { where("(github_cache->>'created_at')::timestamp < ?", date) }
  scope :for_repo, (lambda do |repo_slug|
    org_name, repo_name = repo_slug.split('/')
    self.for(org_name, repo_name)
  end)
  scope :for, ->(org, repo) { where(org: org, repo: repo) }
  scope :merged, -> { where("(github_cache->>'merged')::boolean") }
  scope :unmerged, -> { where("not (github_cache->>'merged')::boolean") }

  include ApiCache

  PR_URL_PATTERN = %r{http(s)?://github.com/(?<org>[^/]+)/(?<repo>[^/]+)/pull/(?<pr_number>[0-9]+)}

  before_validation do
    self.github_cache = to_gh.to_h
  end

  def initialize(org:, repo:, pr_number:)
    super(
      org: org,
      repo: repo,
      pr_number: pr_number,
    )
  end

  def github_cache
    Hashie::Mash.new attributes['github_cache']
  end

  def self.from_url(url)
    match_data = PR_URL_PATTERN.match(url)
    self.find_or_initialize_by(org: match_data[:org], repo: match_data[:repo], pr_number: match_data[:pr_number].to_i)
  end

  def self.from_payload(payload)
    repo = payload['pull_request']['head']['repo']
    repo_name = repo['name']
    org = repo['owner']['login']
    pr_number = payload['number']
    PullRequest.find_or_initialize_by(org: org, repo: repo_name, pr_number: pr_number)
  end

  def to_gh
    cache_api_request :to_gh do
      Github.pull_requests.get org, repo, pr_number
    end
  end

  def files
    cache_api_request :files do
      page = 1
      files_tmp = []
      loop do
        files = fetch_file_page(page)
        files_tmp.concat(files)
        break if files.length == 0
        page += 1
      end
      files_tmp.map do |f|
        GithubFile.from_pr_and_file(self, f)
      end
    end
  end

  def changed_files
    files.select do |file|
      status = file.to_gh[:status]
      %w{modified added}.include?(status)
    end
  end

  def fetch_file_page(page)
    Github.pull_requests.files org, repo, pr_number, page: page
  end

  def commits
    cache_api_request :commits do
      Github.pull_requests.commits(@org, @repo, @pr_number)
    end
  end

  def latest_commit
    # Yes, you have to do this in this way, because `#last` is not defined on
    # the structure which comes back from the API gem
    commits[commits.length - 1]
  end

  def lint_and_comment!
    Status.process_with_status(self) do
      violations = Linters.violations_for_pr(self)
      self.lints = violations.as_json
      self.save!
      Commenter.new(pr: self, violations: violations).comment!
    end
  end

  def expected_url_from_path(path)
    "https://github.com/#{@org}/#{@repo}/blob/#{latest_commit.sha}/#{path}"
  end

  def key
    "#{@org}/#{@repo}/#{@pr_number}"
  end

  def tests?
    lints.none? { |lint| lint['linter'] == 'Linters::SpecsRequired' }
  end
end
