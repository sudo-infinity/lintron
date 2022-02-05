require 'scss_lint'

module Linters
  class SCSSLint < Linters::Base
    def run(file)
      engine = ::SCSSLint::Engine.new code: file.blob
      linters = ::SCSSLint::LinterRegistry.linters.map(&:new)
      lints = linters.flat_map do |linter|
        run_linter(linter, file.path, engine, config)
      end

      lints.compact.map { |l| lint_to_violation(file, l) }
    end

    def lint_to_violation(file, lint)
      Violation.new(
        file: file,
        line: lint.location.line,
        message: lint.description
      )
    end

    def run_linter(linter, path, engine, config)
      return unless config.linter_enabled?(linter)
      return if config.excluded_file_for_linter?(path, linter)
      linter.run(engine, config.linter_options(linter))
    end

    def config
      ::SCSSLint::Config.load(::SCSSLint::Config::FILE_NAME)
    end
  end
end

Linters.register(:scss, Linters::SCSSLint)
