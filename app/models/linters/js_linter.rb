# An abstract linter that invokes a linter function written in JS using ExecJS
module Linters
  class JSLinter < Linters::Base
    def self.env
      File.open(shim_js, &:read)
    end

    def self.linters_source
      @_linters_source ||= File.open(linter_js, &:read)
    end

    def self.context
      @_context ||= ExecJS.compile(env + linters_source)
    end

    def self.shim_js
      Rails.root.join('src', 'envshim.js')
    end

    def self.linter_js
      Rails.root.join('build', 'linters.js')
    end

    def fn_call_src(fn, *arguments)
      "#{ fn }(#{ arguments.map(&:to_json).join(',') })"
    end

    def call(fn, *arguments)
      ::Linters::JSLinter.context.eval(fn_call_src(fn, *arguments))
    end

    def call_linter(name, *arguments)
      call("Linters.#{ name }", *arguments)
    end

    def run(file)
      begin
        lints = call_linter(linter_name, file.blob, linter_config)
      rescue ExecJS::ProgramError => e
        lints = [
          {
            'line' => 1,
            'message' => e.to_s,
          },
        ]
      end

      lints.map do |lint|
        Violation.new file: file, line: lint['line'], message: lint['message'], linter: self.class
      end
    end

    # define linter_name
    # define linter_config
  end
end
