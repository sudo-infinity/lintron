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
  end
end

Linters.register(:coffee, Linters::CoffeeLint)
Linters.register(:cjsx, Linters::CoffeeLint)
