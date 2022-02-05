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

  def self.all_violations(pr, file)
    linter_classes = linters_for(file.extname)
    linter_classes.flat_map do |c|
      linter = c.new(pr.get_config_file(c.config_filename))
      linter.run_and_filter(file)
    end
  end

  def self.violations_for_changes(pr, file)
    if file.patch.changed_lines.length > 1000 || file.blob.length > 100_000
      [Linters::FileTooLong.violation_for(pr, file)]
    else
      all_violations(pr, file).select do |v|
        file.patch.changed_lines.map(&:number).include?(v.line)
      end
    end
  end

  def self.violations_for_pr(pr)
    pr.changed_files
      .flat_map { |f| violations_for_changes(pr, f) }
      .concat(pr_level_violations(pr))
  end

  def self.linter_rbs
    Dir[File.join(File.dirname(__FILE__), 'linters', '**', '*.rb')]
  end

  def self.load_all
    linter_rbs.map { |linter| load linter }
  end

  def self.register_pr_linter(linter_class)
    @_registered_pr_linters << linter_class
  end

  def self.pr_level_violations(pr)
    @_registered_pr_linters.flat_map { |linter| linter.run(pr) }
  end

  def self.linter_configs_for(extension)
    linter_classes = linters_for(extension)
    linter_classes.map(&:config_filename).select(&:itself)
  end

  @_registered_linters = []
  @_registered_pr_linters = []
  load_all
end

Linters::FileTooLong
