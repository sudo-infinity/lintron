require 'rubygems'
require 'httparty'
require 'byebug'

module Lintron
  # Makes requests to the lintron local lint API
  class API
    def initialize(base_url)
      @base_url = base_url
    end

    def violations(pr)
      response = post_lint_request(pr)
      violations =
        JSON
        .parse(response.body)
        .map { |json| Lintron::ViolationLine.new(json) }

      violations.sort_by(&:file_and_line)
    rescue JSON::ParserError
      puts 'Error occurred while parsing response from Lintron'.colorize(:red)
      puts 'Raw response body: '
      puts response.body
    end

    def post_lint_request(pr)
      HTTParty.post(URI.join(@base_url, 'local_lints'), request_params(pr))
    end

    def request_params(pr)
      {
        body: pr.to_json,
        headers: {
          'Content-Type' => 'application/json',
          'Accept' => 'application/json',
        },
      }
    end
  end

  # Represents one line of the lint results. Exists so that
  # (1) We can use dot syntax to access members instead of []
  # (2) I can define file_and_line which is used for display and sorting
  class ViolationLine < OpenStruct
    def file_and_line(padTo = 0)
      return ' ' * padTo unless path && line

      file_and_line = "#{path}:#{format '%03i', line}    "

      if padTo > file_and_line.length
        file_and_line += ' ' * (padTo - file_and_line.length)
      end

      file_and_line
    end
  end
end
