require 'rubygems'
require 'colorize'
require 'terminfo'

module Lintron
  # Outputs lint results on the command line
  class TerminalReporter
    def format_violations(violations)
      row_header_width = violations.map { |v| v.file_and_line.length }.max
      return no_violations if violations.empty?
      last_file = violations.first.path
      buffer = ''

      violations.each do |violation|
        buffer += do_line(violation, last_file, row_header_width)
        last_file = violation.path
      end
      buffer += "\n\n"
      buffer
    end

    def no_violations
      'No violations found!'.colorize(:green)
    end

    def do_line(violation, last_file, row_header_width)
      rule = ''
      if last_file != violation.path
        colors.rewind
        rule += hr
      end

      file_and_line = violation.file_and_line(row_header_width)
      rule + wrap_pretty(
        "#{file_and_line}#{violation['message']}".colorize(colors.next),
        file_and_line.length,
      )
    end

    def hr
      '-' * TermInfo.screen_size[1] + "\n\n\n"
    end

    def colors
      @_colors ||= [:magenta, :cyan].cycle.each
    end

    def wrap_pretty(string, indent_level)
      width = TermInfo.screen_size[1] # Get the width of the term
      buffer = ''
      words = string.split(/\s/)

      current_word = 0
      line_length = 0
      last_line_word = 0
      while current_word < words.length
        line_length += words[current_word].length
        if line_length > width - 5 - indent_level &&
           current_word > last_line_word

          buffer += "\n"
          buffer += ' ' * indent_level
          line_length = indent_level
          last_line_word = current_word
        else
          buffer += words[current_word]
          buffer += ' '
          current_word += 1
        end
      end
      buffer + "\n"
    end
  end
end
