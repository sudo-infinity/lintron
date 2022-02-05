class GithubFile
  include ApiCache
  attr_accessor :org, :repo, :to_gh

  def initialize(org:, repo:, to_gh:)
    @org = org
    @repo = repo
    @to_gh = to_gh
  end

  def self.from_pr_and_file(pr, file)
    GithubFile.new(
      org: pr.org,
      repo: pr.repo,
      to_gh: file
    )
  end

  def blob
    cache_api_request :blob do
      Base64.decode64(Github.git_data.blobs.get(org, repo, to_gh.sha).content)
    end
  end

  def extname
    File.extname(to_gh.filename)
  end
end
