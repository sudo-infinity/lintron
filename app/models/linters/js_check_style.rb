module Linters
  class JSCheckStyle < Linters::JSLinter
    CONFIG_PATH = Rails.root.join('.jscsrc')

    def linter_name
      'JSXCheckStyle'
    end

    def config_contents
      File.open(CONFIG_PATH) { |f| f.read }
    end

    def linter_config
      JSON.parse(config_contents)
    end
  end
end

Linters.register(:js, Linters::JSCheckStyle)
