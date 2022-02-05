require 'scss_lint'

module Linters
  class SCSSLint < Linters::Base
    def self.config_filename
      ::SCSSLint::Config::FILE_NAME
    end

    def initialize(linter_config = nil)
      @linter_config = linter_config
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
          linter: Linters::SCSSLint,
        )
      ]
    end

    def lint_to_violation(file, lint)
      Violation.new(
        file: file,
        line: lint.location.line,
        message: lint.description,
        linter: Linters::SCSSLint,
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
        # Tested with:
        #   rev-PartyTime
        #   u-utilityName
        #   ComponentName
        #   ComponentName--modifierName
        #   ComponentName-descendentName
        #   is-stateOfComponent
        validator: ->(name) { name =~ /^([a-z]+-)?([A-Za-z])+(--?[a-z][A-Za-z]+)?$/ }
      }
    }

    def add_suit
      ::SCSSLint::Linter::SelectorFormat::CONVENTIONS.merge!(SUIT)
    end
  end
end

Linters.register(:scss, Linters::SCSSLint)
