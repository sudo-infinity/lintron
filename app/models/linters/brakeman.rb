module Linters
  class Brakeman < Linters::Base
    def self.config_filename
      'brakeman.yml'
    end

    def options_from_file
      YAML.load_file(Rails.root.join 'brakeman.yml') || {}
    end

    def options
      ::Brakeman.default_options.merge(options_from_file).merge app_path: ''
    end

    def run(file)
      scanner = Linters::Brakeman::Scanner.new(file, options)
      scanner.process
      warnings = scanner.tracker.run_checks.warnings
      warnings.map do |warning|
        Violation.new file: file, line: warning.line, message: warning.message, linter: Linters::Brakeman
      end
    end
  end
end
