# A base mock Pull Request object suitable for testing without pinging github
class MockPR
  def org
    'prehnRA'
  end

  def repo
    'exemplar'
  end

  def latest_commit
    OpenStruct.new sha: 'deadbeefdeadbeefdeadbeefdeadbeefdeadbeef'
  end
end

class FixturePR < MockPR
  def initialize(directory)
    @directory = directory
  end

  def fixture_dir
    Rails.root.join('spec', 'fixtures', 'pull_requests', @directory)
  end

  def relative_path_of(full_path)
    Pathname.new(full_path).relative_path_from(fixture_dir).to_s
  end

  def files
    filenames = Dir["#{fixture_dir}/**/*"]
    @files ||= filenames.map do |filename|
      StubFile.new(path: relative_path_of(filename), blob: File.read(filename))
    end
  end
end

# A mock PR which is missing a required ruby spec
class PRMissingRBSpec < MockPR
  def files
    Array(
      StubFile.new(
        path: 'app/models/post.rb',
        blob: 'STUB FOR TESTING',
      ),
    )
  end
end

# A mock PR which is missing a required js spec
class PRMissingESSpec < MockPR
  def files
    Array(
      StubFile.new(
        path: 'app/assets/javascripts/components/post.es6',
        blob: 'STUB FOR TESTING',
      ),
    )
  end
end

# A mock PR filled out with ruby and js files with the corresponding specs
class PRWithAllSpecs < MockPR
  def files
    filenames = %w(
      app/assets/javascripts/components/post.es6
      spec/javascripts/components/post_spec.es6
      app/models/post.rb
      spec/models/post_spec.rb
    )
    filenames.map { |f| StubFile.new(path: f, blob: '') }
  end
end
