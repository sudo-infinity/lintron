# frozen_string_literal: true

# A config file for a particular linter, e.g. .eslintrc or .rubocop.yml
# Can be created from a full filepath or a content blob
# access #path or #content when using in linters
class LinterConfigFile
  def initialize(path: nil, content: nil)
    raise ArgumentError, 'path or content must be provided' unless path || content
    @path = path
    @content = content
  end

  def self.from_path(file_path)
    LinterConfigFile.new(path: file_path)
  end

  def self.from_content(content)
    LinterConfigFile.new(content: content)
  end

  def content
    @content ||= File.read(@path)
  end

  def path
    @path ||= create_temp_file(@content)
  end

  def create_temp_file(content)
    Tempfile.open('linter_config') do |file|
      # keep a reference so the file does not get GC'd until this instance is gone
      @tempfile = file
      file.write(content)
      file.path
    end
  end
end
