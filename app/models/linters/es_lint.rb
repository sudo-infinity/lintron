module Linters
  class ESLint < Linters::Base
    def run(file)
      lint_string = IO.popen(cmd(file), 'r+') do |f|
        f.puts file.blob
        f.close_write
        f.read
      end

      begin
        lints = JSON.parse(lint_string).first['messages']
        lints.map do |lint|
          Violation.new(file: file, line: lint['line'], message: lint['message'], linter: Linters::ESLint)
        end
      rescue JSON::ParserError
        [
          Violation.new(
            file: file,
            line: (file.patch.changed_lines.first.number rescue 1),
            message: 'Unexpected error in ESLint',
            linter: Linters::ESLint,
          ),
        ]
      end
    end

    def cmd(file)
      <<-CMD.squish
        node_modules/eslint/bin/eslint.js
        -f json
        --stdin
        --stdin-filename #{file.path}
        2>&1
      CMD
    end
  end
end

Linters.register(:es6, Linters::ESLint)
Linters.register(:js, Linters::ESLint)
