class Linters::RuboCop < Linters::Base
  def run(file)
    runner = RuboCop::Runner.new({}, RuboCop::ConfigStore.new)
    processed_source = processed_source_for(file)
    offenses, _ = runner.send(:inspect_file, processed_source)
    offenses.map { |o| Violation.new(file: file, line: o.location.line, message: o.message) }
  end

  def processed_source_for(file)
    RuboCop::ProcessedSource.new(file.blob, file.path)
  end
end

Linters.register(:rb, Linters::RuboCop)
