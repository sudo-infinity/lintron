class Linters::RuboCop < Linters::Base
  def run(file)
    return [] if ignored_file?(file)
    config = RuboCop::ConfigStore.new
    config.options_config = @linter_config.path if @linter_config
    runner = RuboCop::Runner.new({}, config)
    processed_source = processed_source_for(file)
    offenses, _ = runner.send(:inspect_file, processed_source)
    offenses.map { |o| Violation.new(file: file, line: o.location.line, message: o.message, linter: Linters::RuboCop) }
  end

  def ignored_file?(file)
    case file.path
    when *['db/schema.rb', %r{^db/migrate}]
      true
    else
      false
    end
  end

  def processed_source_for(file)
    RuboCop::ProcessedSource.new(file.blob, 2.3, file.path)
  end

  def self.config_filename
    '.rubocop.yml'
  end
end

Linters.register(:rb, Linters::RuboCop)
Linters.register(:rake, Linters::RuboCop)
