require 'brakeman/scanner'

module Linters
  class Brakeman < Linters::Base
    class Scanner < ::Brakeman::Scanner
      def initialize(file, options, processor = nil)
        @options = options
        @app_tree = ::Linters::Brakeman::AppTree.from_options(file)

        if !@app_tree.root || !@app_tree.exists?('app')
          fail ::Brakeman::NoApplication,
               'Please supply the path to a Rails application.'
        end

        @processor = processor || ::Brakeman::Processor.new(@app_tree, options)
      end
    end
  end
end
