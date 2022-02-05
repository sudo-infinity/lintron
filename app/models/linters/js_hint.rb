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

    def filter_messages(lints)
      filtered_lints = lints.reject do |lint|
        case lint.message
        when /'(require|global|module)' is not defined\./
          true
        else
          false
        end
      end
      super(filtered_lints)
    end
  end
end

Linters.register(:js, Linters::JSHint)
