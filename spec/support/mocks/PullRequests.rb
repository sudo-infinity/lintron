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

class PRMissingRBSpec < MockPR
  def files
    Array(
      StubFile.new(
        path: 'app/models/post.rb',
        blob: 'STUB FOR TESTING',
      )
    )
  end
end

class PRMissingESSpec < MockPR
  def files
    Array(
      StubFile.new(
        path: 'app/assets/javascripts/components/post.es6',
        blob: 'STUB FOR TESTING',
      )
    )
  end
end

class PRWithAllSpecs < MockPR
  def files
    filenames = %w{
      app/assets/javascripts/components/post.es6
      spec/javascripts/components/post_spec.es6
      app/models/post.rb
      spec/models/post_spec.rb
    }
    filenames.map { |f| StubFile.new(path: f, blob: '') }
  end
end
