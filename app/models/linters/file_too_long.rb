module Linters
  # A linter that detects whether specs are updated when the corresponding
  # application code changes
  class FileTooLong < Linters::Base
    def self.violation_for(file)
      Violation.new(
        file: file,
        line: file.first_line_of_patch,
        message: <<-message.squish
          Skipping this file because it is too long.
        message
      )
    end
  end
end
