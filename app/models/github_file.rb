class GithubFile
  include ApiCache
  attr_accessor :org, :repo, :to_gh

  def initialize(org:, repo:, to_gh:)
    @org = org
    @repo = repo
    @to_gh = to_gh
  end

  def path
    to_gh.filename
  end

  def patch
    Patch.new(to_gh.patch)
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
      Base64
      .decode64(Github.git_data.blobs.get(org, repo, to_gh.sha).content)
      .encode('UTF-8', :invalid => :replace, :undef => :replace, :replace => '')
    end
  end

  def extname
    File.extname(to_gh.filename).gsub(/^\./, '') # without leading .
  end

  def basename(ext = nil)
    File.basename to_gh.filename, ext
  end
end
