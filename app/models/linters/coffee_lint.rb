module Linters
  class CoffeeLint < Linters::JSLinter
    CONFIG_PATH = Rails.root.join('coffeelint.json')

    def linter_name
      'CoffeeLint'
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
        when 'Line exceeds maximum allowed length'
          file.blob.lines[lint.line - 1].length < 81
        else
          false
        end
      end
      super(filtered_lints, file)
    end
  end
end

Linters.register(:coffee, Linters::CoffeeLint)
Linters.register(:cjsx, Linters::CoffeeLint)
