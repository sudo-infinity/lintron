require 'rails_helper'

describe PullRequest do
  describe '#expected_url_from_path' do
    it 'returns a github url with the correct parts' do
      pr = PullRequest.new(org: 'test-org', repo: 'test', pr_number: 123)
      mock_commit = OpenStruct.new sha: 'deadbeef'
      allow(pr).to receive(:latest_commit).and_return mock_commit

      expect do
        url = pr.expected_url_from_path('spec/models/post_spec.rb')
        expect(url).to include 'deadbeef' # sha
        expect(url).to include 'post_spec.rb' # filename
      end.to_not raise_error
    end
  end
end
