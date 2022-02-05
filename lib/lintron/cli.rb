require 'optparse'
require 'rubygems'
require 'active_support/all'
require 'filewatcher'
require_relative '../../app/models/local_pr_alike'

# ./linters require some extra deps
require 'brakeman'
require_relative '../../app/models/linters/base'
require_relative '../../app/models/linters/js_linter'
require_relative '../../app/models/linters'

module Lintron
  # Handles setting up flags for CLI runs based on defaults, linty_rc, and
  # command line arguments
  class CLI
    def initialize
      @options = {}
      OptionParser.new do |opts|
        opts.banner = 'Usage: linty [options]'

        opts.on('--watch', 'Watch for changes') do |v|
          @options[:watch] = v
        end
      end.parse!
    end

    def go
      if config[:watch]
        go_watch
      else
        go_once
      end
    end

    def go_watch
      system('clear')
      go_once

      watcher.watch do |filename|
        system('clear')
        puts "Re-linting because of #{filename}\n\n"
        go_once
      end
    end

    def watcher
      FileWatcher.new(['*', '**/*'], exclude: config[:watch_exclude])
    end

    def go_once
      violations = Lintron::API.new(config[:base_url]).violations(pr)
      puts Lintron::TerminalReporter.new.format_violations(violations)
    end

    def pr
      pr = LocalPrAlike.from_branch(org_name, repo_name, base_branch)
      pr.linter_configs = relevant_linter_configs(pr.files)
      pr
    end

    def base_branch
      config[:base_branch]
    end

    def config
      defaults
        .merge(validated_config_from_file)
        .merge(@options)
        .merge(
          {
            base_branch: ARGV[0],
          }.compact,
        )
    end

    def defaults
      {
        base_branch: 'origin/develop',
        watch_exclude: [
          '**/*.log',
          'tmp/**/*',
        ],
      }
    end

    def validated_config_from_file
      config = config_from_file

      unless config.key?(:base_url)
        raise('.linty_rc missing required key: base_url')
      end

      config
    end

    def config_from_file
      file_path = File.join(repo_path, '.linty_rc')

      raise('.linty_rc is missing.') unless File.exist?(file_path)

      begin
        JSON.parse(File.read(file_path)).symbolize_keys
      rescue JSON::ParserError
        raise('Malformed .linty_rc')
      end
    end

    def repo_name
      info = origin_info
      info ? info[:repo] : Pathname(repo_path).basename
    end

    def org_name
      info = origin_info
      info ? info[:org] : 'local'
    end

    def repo_path
      `git rev-parse --show-toplevel`.strip
    end

    def origin_info
      origin = `git config --get remote.origin.url`
      return nil unless origin && origin.split('/').length > 1
      path_parts = origin.split('/')
      {
        org: path_parts[-2],
        repo: path_parts[-1],
      }
    end

    # a hash of file_name => LinterConfigFile
    # for all linter configs pertaining to this PRs list of changed source files (StubFiles)
    def relevant_linter_configs(files)
      extensions = files.map(&:extname).uniq
      extensions.reduce({}) do |linter_configs, extension|
        linter_configs.merge(linter_configs_for(extension))
      end
    end

    def linter_configs_for(extension)
      Linters.linter_configs_for(extension).reduce({}) do |linter_configs, config_filename|
        full_path = File.join(repo_path, config_filename)
        if File.exist?(full_path)
          linter_configs.merge(config_filename => LinterConfigFile.from_path(full_path))
        else
          linter_configs
        end
      end
    end
  end
end
