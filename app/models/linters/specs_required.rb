module Linters
  # A linter that detects whether specs are updated when the corresponding
  # application code changes
  class SpecsRequired < Linters::Base
    def self.config
      HashWithIndifferentAccess.new(
        rb: {
          spec_file_ext: 'rb',
          app_path_pattern: %r{[^/]+/(?<path>[^\Z]+)\Z},
        },
        /\A(js|es6|jsx)\Z/ => {
          spec_file_ext: 'js',
          app_path_pattern: %r{app/assets/(?<path>[^\Z]+)\Z},
        },
      )
    end

    def self.config_for_extname(extname)
      config.find do |pattern, _config|
        pattern = Regexp.new("\\A#{pattern}\\Z") unless pattern.class < Regexp
        pattern.match(extname)
      end.try(:[], 1)
    end

    def self.run(pr)
      files_needing_specs(pr)
        .flat_map { |f| check_for_matching_spec(pr, f) }
        .compact
    end

    def self.files_needing_specs(pr)
      pr.files
        .select { |f| requires_spec?(f.extname) }
        .reject { |f| spec?(f.path) }
    end

    def self.spec?(filename)
      /\A(spec|test)/.match(filename)
    end

    def self.spec_for?(base, candidate)
      return false unless spec?(candidate.path)
      "#{base.basename('.*')}_spec" == candidate.basename('.*')
    end

    def self.requires_spec?(extname)
      config_for_extname(extname).present?
    end

    def self.check_for_matching_spec(pr, file)
      return if pr.files.any? { |candidate| spec_for?(file, candidate) }
      spec_missing_violation_for(pr, file)
    end

    def self.spec_missing_violation_for(pr, file)
      Violation.new(
        file: file,
        line: 1,
        message: <<-message.strip_heredoc
          Expected changes or additions to a test file called
          [#{expected_spec_filename(file)}](#{expected_spec_url(pr, file)})
        message
      )
    end

    def self.expected_spec_filename(file)
      filename_base = file.basename '.*'
      extname = file.extname
      if %w(es6 jsx js).include?(extname)
        file_extname = 'js'
      else
        file_extname = 'rb'
      end
      "#{filename_base}_spec.#{file_extname}"
    end

    def self.expected_spec_path(file)
      path_pattern = config_for_extname(file.extname)[:app_path_pattern]
      path_match = File.dirname(path_pattern.match(file.path)[:path])
      "spec/#{path_match}/#{expected_spec_filename(file)}"
    end

    def self.expected_spec_url(pr, file)
      sha = pr.latest_commit.sha
      "https://github.com/#{pr.org}/#{pr.repo}/blob/#{sha}/#{expected_spec_path(file)}"
    end
  end
end

Linters.register_pr_linter(Linters::SpecsRequired)
