module Linters
  class LinterConfig
    attr_accessor :pattern, :linter_class
    def initialize(pattern:, linter_class:)
      @pattern = pattern
      @linter_class = linter_class
    end

    def matches?(extension)
      case normalize_extension(extension)
      when normalize_extension(pattern)
        true
      else
        false
      end
    end

    def normalize_extension(ext)
      if ext.respond_to? :to_sym then ext.to_sym else ext end
    end
  end

  @@_registered_linters = []

  def self.register(pattern, linter_class)
    @@_registered_linters << LinterConfig.new(pattern: pattern, linter_class: linter_class)
  end

  def self.linters_for(extension)
    @@_registered_linters
      .select { |linter_config| linter_config.matches?(extension) }
      .map { |linter_config| linter_config.linter_class }
  end

  def self.all_violations(file)
    linter_classes = linters_for(file.extname)
    linter_classes.flat_map { |c| c.new.run(file) }
  end

  def self.violations_for_changes(file)
    all_violations(file).select { |v| file.patch.changed_lines.map(&:number).include?(v.line) }
  end
end

require 'linters/base'
require 'linters/rubo_cop'
Linters::RuboCop
