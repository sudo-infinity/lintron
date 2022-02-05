gem 'activesupport', '>= 4.2.1'
gem 'git_diff_parser', '~> 2.3.0'
gem 'httparty', '~> 0.14.0'
gem 'colorize', '~> 0.8.1'
gem 'ruby-terminfo', '~> 0.1.1'
gem 'filewatcher', '~> 0.5.3'

require_relative 'lintron/api'
require_relative 'lintron/cli'
require_relative 'lintron/terminal_reporter'

# Module for the local lintron gem
module Lintron
end
