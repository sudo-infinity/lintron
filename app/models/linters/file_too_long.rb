module Linters
  # A linter that detects whether specs are updated when the corresponding
  # application code changes
  class FileTooLong < Linters::Base
    def self.config_filename
      '.linty_rc'
    end

    def self.violation_for(pr, file)
      PrViolation.new(
        pr: pr,
        linter: Linters::FileTooLong,
        message: <<-message.squish
          #{file.path}: Skipping this file because it is too long.
        message
      )
    end
  end
end
