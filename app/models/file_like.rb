class FileLike
  def extname
    File.extname(path).gsub(/^\./, '') # without leading .
  end

  def basename(ext = nil)
    File.basename path, ext
  end
end
