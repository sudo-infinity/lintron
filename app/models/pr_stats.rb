class PrStats
  def initialize(org, repo, after, before)
    @prs = PullRequest.for(org, repo).after(after).before(before)
  end

  def total_prs
    @prs.count
  end

  def prs_with_tests
    @prs.select { |pr| pr.tests? }.length
  end
end
