module Linters
  class SpecsRequired < Linters::Base
    def config
      HashWithIndifferentAccess.new({
        rb: {
          spec_file_ext: 'rb',
          app_path_pattern: %r{[^/]+/(?<path>[^\Z]+)\Z},
        },
        /\A(js|es6|jsx)\Z/ => {
          spec_file_ext: 'js',
          app_path_pattern: %r{app/assets/(?<path>[^\Z]+)\Z},
        },
      })
    end

    def run(pr)
      filenames = pr.files.map(&:path)
      pr.files
        .select { |f| requires_spec?(f.extname) }
        .reject { |f| is_spec?(f.path) }
        .flat_map { |f| check_for_matching_spec(pr, f, filenames) }
        .compact
    end

    def is_spec?(filename)
      /\A(spec|test)/.match(filename)
    end

    def is_spec_for?(base, candidate)
      return false unless is_spec?(candidate)

       "#{base.basename('.*')}_spec" == candidate.basename('.*')
    end

    def requires_spec?(extname)
      config.keys.any? do |pattern|
        pattern = Regexp.new("\\A#{pattern}\\Z") unless pattern.class < Regexp
        pattern.match(extname)
      end
    end

    def check_for_matching_spec(pr, file, all_filenames)
      unless all_filenames.any? { |candidate| is_spec_for?(file, candidate) }
        spec_missing_violation_for(pr, file)
      end
    end

    def spec_missing_violation_for(pr, file)
      Violation.new(
        file: file,
        line: 1 ,
        message: <<-message.strip_heredoc
          Expected changes or additions to a test file called [#{expected_spec_filename(file)}](#{expected_spec_url(pr, file)})
        message
      )
    end

    def expected_spec_filename(file)
      filename_base = file.basename '.*'
      extname = file.extname
      if %{es6 jsx js}.include?(extname)
        file_extname = 'js'
      else
        file_extname = 'rb'
      end
      "#{filename_base}_spec.#{file_extname}"
    end

    def expected_spec_path(file)
      path_pattern = config[file.extname][:app_path_pattern]
      path_match = File.dirname(path_pattern.match(file.path)[:path])
      "spec/#{path_match}/#{expected_spec_filename(file)}"
    end

    def expected_spec_url(pr, file)
      sha = pr.latest_commit.sha
      "https://github.com/#{pr.org}/#{pr.repo}/blob/#{sha}/#{expected_spec_path(file)}"
    end
  end
end

Linters.register_pr_linter(Linters::SpecsRequired)
