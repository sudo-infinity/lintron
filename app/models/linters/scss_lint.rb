require 'scss_lint'

module Linters
  class SCSSLint < Linters::Base
    def initialize
      add_suit
    end

    def run(file)
      engine = ::SCSSLint::Engine.new code: file.blob
      linters = ::SCSSLint::LinterRegistry.linters.map(&:new)
      lints = linters.flat_map do |linter|
        run_linter(linter, file.path, engine, config)
      end

      lints.compact.map { |l| lint_to_violation(file, l) }
    rescue Sass::SyntaxError => e
      [
        Violation.new(
          file: file,
          line: e.sass_line,
          message: e.message,
        )
      ]
    end

    def lint_to_violation(file, lint)
      Violation.new(
        file: file,
        line: lint.location.line,
        message: lint.description,
        linter: Linters::SCSSList,
      )
    end

    def run_linter(linter, path, engine, config)
      return unless config.linter_enabled?(linter)
      return if config.excluded_file_for_linter?(path, linter)
      linter.run(engine, config.linter_options(linter))
    end

    def config
      @_config ||= ::SCSSLint::Config.load(::SCSSLint::Config::FILE_NAME)
    end

    SUIT = {
      'SUIT' => {
        explanation: 'should follow SUIT conventions',
        validator: ->(name) { name =~ /^(([A-Z]|(u\-[a-z0-9]))[A-Za-z0-9]*)([\-]{,2}[a-z0-9][A-Za-z0-9]*)+$/ }
      }
    }

    def add_suit
      ::SCSSLint::Linter::SelectorFormat::CONVENTIONS.merge!(SUIT)
    end
  end
end

Linters.register(:scss, Linters::SCSSLint)
