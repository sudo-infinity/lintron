class PullRequest
  include ApiCache
  attr_accessor :org, :repo, :pr_number

  def initialize(org:, repo:, pr_number:)
    @org = org
    @repo = repo
    @pr_number = pr_number
  end

  def to_gh
    cache_api_request :to_gh do
      Github.pull_requests.get org, repo, pr_number
    end
  end

  def files
    cache_api_request :files do
      files_tmp ||= Github.pull_requests.files org, repo, pr_number
      files_tmp.map do |f|
        GithubFile.from_pr_and_file(self, f)
      end
    end
  end
end
