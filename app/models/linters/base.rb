class Linters::Base
  def run_and_filter(file)
    filter_messages(run(file))
  end

  def filter_messages(lints)
    lints
  end
end
