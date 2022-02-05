# frozen_string_literal: true

# Sample stub files for testing PRs
class SampleStubFile
  def self.all
    %w[index.js user.rb pull_request.rb linters.rb].map do |filename|
      body = "body of #{filename}"
      StubFile.new(
        path: filename,
        blob: body,
        patch: Patch.from_file_body(body),
      )
    end
  end
end
