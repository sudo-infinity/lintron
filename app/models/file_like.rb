# Base class for Github API files and mock files that perform basic operations
# on the blob and path
class FileLike
  def extname
    File.extname(path).gsub(/^\./, '') # without leading .
  end

  def basename(ext = nil)
    File.basename path, ext
  end

  def first_line_of_patch
    patch.changed_lines.first.try(:number)
  end
end
