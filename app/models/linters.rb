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

  def self.register(pattern, linter_class)
    @_registered_linters << LinterConfig.new(pattern: pattern, linter_class: linter_class)
  end

  def self.linters_for(extension)
    @_registered_linters
      .select { |linter_config| linter_config.matches?(extension) }
      .map(&:linter_class)
  end

  def self.all_violations(file)
    linter_classes = linters_for(file.extname)
    linter_classes.flat_map { |c| c.new.run_and_filter(file) }
  end

  def self.violations_for_changes(file)
    all_violations(file).select { |v| file.patch.changed_lines.map(&:number).include?(v.line) }
  end

  def self.violations_for_pr(pr)
    pr.files.flat_map { |f| violations_for_changes(f) }
  end

  def self.linter_rbs
    Dir[File.join(File.dirname(__FILE__), 'linters', '**', '*')]
  end

  def self.load_all
    linter_rbs.map { |linter| load linter }
  end

  @_registered_linters = []
  load_all
end
