module Linters
  class JSHint < Linters::JSLinter
    CONFIG_PATH = Rails.root.join('.jshintrc')

    def linter_name
      'JSXJSHint'
    end

    def config_contents
      File.open(CONFIG_PATH) { |f| f.read }
    end

    def linter_config
      JSON.parse(config_contents)
    end

    def filter_messages(lints, file)
      filtered_lints = lints.reject do |lint|
        case lint.message
        when /'(require|global|module|App|expect|Rev|React|_)' is not defined\./
          true
        when /Line must be at most/
          file.blob.lines[lint.line - 1].length < 81
        else
          false
        end
      end
      super(filtered_lints, file)
    end
  end
end

Linters.register(:js, Linters::JSHint)
Linters.register(:jsx, Linters::JSCheckStyle)
