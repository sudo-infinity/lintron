module Linters
  # A linter that detects whether any tests have been edited or added (bc each
  # PR should have tests)
  class SpecsRequired < Linters::Base
    def self.config_filename
      '.linty_rc'
    end

    def self.run(pr)
      return [] if any_tests(pr)

      stats = PrStats.new(pr.org, pr.repo, Time.zone.now.beginning_of_week, Time.zone.now)
      prs_with_tests = stats.prs_with_tests + (pr.persisted? ? 0 : 1)
      total_prs = stats.total_prs + (pr.persisted? ? 0 : 1)

      [
        PrViolation.new(
          pr: pr,
          linter: Linters::SpecsRequired,
          message: "No tests added or edited in this PR. Pull Requests should have tests. #{prs_with_tests} of #{total_prs} this week have tests.",
        )
      ]
    end

    def self.any_tests(pr)
      eligible_files = pr
        .files
        .reject { |f| f.patch.changed_lines.empty? }

      eligible_files.empty? || eligible_files.any? { |f| test?(f) }
    end

    def self.test?(file)
      file.path.include?('test') ||
      file.path.include?('spec')
    end
  end
end

Linters.register_pr_linter(Linters::SpecsRequired)
