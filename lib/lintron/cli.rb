require 'rubygems'
require 'active_support/all'
require_relative '../../app/models/local_pr_alike'

module Lintron
  # Handles setting up flags for CLI runs based on defaults, linty_rc, and
  # command line arguments
  class CLI
    def pr
      LocalPrAlike.from_branch(base_branch)
    end

    def base_branch
      config[:base_branch]
    end

    def config
      {
        base_branch: 'origin/develop',
      }.merge(
        config_from_file.symbolize_keys,
      ).merge(
        {
          base_branch: ARGV[0],
        }.compact,
      )
    end

    def config_from_file
      file_path = File.join(`git rev-parse --show-toplevel`.strip, '.linty_rc')

      if File.exist?(file_path)
        begin
          JSON.parse(File.read(file_path))
        rescue JSON::ParserError
          raise('Malformed .linty_rc')
        end
      else
        {}
      end
    end
  end
end
