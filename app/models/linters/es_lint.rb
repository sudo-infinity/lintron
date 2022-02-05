module Linters
  class ESLint < Linters::Base
    def run(file)
      lint_string = IO.popen('node_modules/eslint/bin/eslint.js -f json --stdin', 'r+') do |f|
        f.puts file.blob
        f.close_write
        f.read
      end

      lints = JSON.parse(lint_string).first['messages']
      lints.map do |lint|
        Violation.new(file: file, line: lint['line'], message: lint['message'])
      end
    end
  end
end

Linters.register(:es6, Linters::ESLint)
