require 'rails_helper'

describe PullRequest do
  let(:pr) do
    pr = PullRequest.new(org: 'test-org', repo: 'test', pr_number: 123)
    mock_commit = OpenStruct.new sha: 'deadbeef'
    allow(pr).to receive(:latest_commit).and_return mock_commit
    pr
  end

  describe '#expected_url_from_path' do
    it 'returns a github url with the correct parts' do
      expect do
        url = pr.expected_url_from_path('spec/models/post_spec.rb')
        expect(url).to include 'deadbeef' # sha
        expect(url).to include 'post_spec.rb' # filename
      end.to_not raise_error
    end
  end

  describe '#get_config_file' do
    let(:linter_config_file) { LinterConfigFile.from_content('configs in here') }

    it 'returns a linter config file if it exists' do
      allow(pr).to receive(:fetch_config_file).and_return(linter_config_file)
      expect(pr.get_config_file('.eslintrc')).to be(linter_config_file)
    end

    it 'returns nil on a NotFound error' do
      allow(Github.repos.contents).to receive(:get).and_throw(Github::Error::NotFound)
      expect do
        expect(pr.get_config_file('.eslintrc')).to be(nil)
      end.not_to raise_error
    end

    it 'does not try to fetch nil config file from github' do
      expect(Github.repos.contents).to_not receive(:get)
      expect do
        expect(pr.get_config_file(nil)).to be(nil)
      end.not_to raise_error
    end

    it 'only fetches once for repeated access to a config file' do
      allow(pr).to receive(:fetch_config_file).once.and_return(linter_config_file)
      expect(pr.get_config_file('.eslintrc')).to be(linter_config_file)
      expect(pr.get_config_file('.eslintrc')).to be(linter_config_file)
      expect(pr.get_config_file('.eslintrc')).to be(linter_config_file)
    end

    it 'only fetches once if the config is not found' do
      allow(pr).to receive(:fetch_config_file).once.and_return(nil)
      expect do
        expect(pr.get_config_file('.eslintrc')).to be(nil)
        expect(pr.get_config_file('.eslintrc')).to be(nil)
        expect(pr.get_config_file('.eslintrc')).to be(nil)
      end.not_to raise_error
    end
  end
end
