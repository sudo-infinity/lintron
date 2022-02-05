module Linters
  class Credo < Linters::Base
    LINT_LINE_PATTERN = /(?<type>\[.\]) (?<priority>.) (?<file_path>[^:]+):(?<line_number>[0-9]+)(:(?<column_number>[0-9]+))? (?<message>.+)/

    def run(file)
      lint_string = IO.popen(cmd(file), 'r+') do |f|
        f.puts file.blob
        f.close_write
        f.read
      end

      begin
        return lints(file, lint_string)
      rescue JSON::ParserError
        [
          Violation.new(
            file: file,
            line: (file.patch.changed_lines.first.number rescue 1),
            message: 'Unexpected error in Credo',
            linter: Linters::Credo,
          ),
        ]
      end
    end

    def cmd(file)
      <<-CMD.squish
        mix credo --format=oneline --read-from-stdin #{file.path}
        2>&1
      CMD
    end

    def lints(file, lint_string)
      lint_string.lines.each_with_object([]) do |line, list|
        match_data = LINT_LINE_PATTERN.match(line)
        next if match_data.blank?
        list << Violation.new(
          file: file,
          line: match_data[:line_number].to_i,
          message: match_data[:message],
          linter: Linters::Credo,
        )
      end
    end

    def self.config_filename
      '.credo.exs'
    end
  end
end

Linters.register(:ex, Linters::Credo)
Linters.register(:exs, Linters::Credo)
