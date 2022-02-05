class Patch
  RANGE_INFORMATION_LINE = /^@@ .+\+(?<line_number>\d+),/
  MODIFIED_LINE = /^\+(?!\+|\+)/
  NOT_REMOVED_LINE = /^[^-]/

  attr_reader :body

  def self.from_file_body(source)
    lines = source.lines
    header = "@@ -0,0 +1,#{lines.count} @@\n"
    body = header + lines.map { |line| "+#{line}"}.join
    new(body)
  end

  def initialize(body)
    @body = body || ''
  end

  def changed_lines
    line_number = 0

    lines.each_with_index.inject([]) do |lines, (content, patch_position)|
      case content
      when RANGE_INFORMATION_LINE
        line_number = Regexp.last_match[:line_number].to_i
      when MODIFIED_LINE
        line = Line.new(
          content: content,
          number: line_number,
          patch_position: patch_position
        )
        lines << line
        line_number += 1
      when NOT_REMOVED_LINE
        line_number += 1
      end

      lines
    end
  end

  def position_for_line_number(line)
    changed_lines.find { |patch_line| patch_line.number == line }.patch_position
  end

  private

  def lines
    @body.lines
  end
end
