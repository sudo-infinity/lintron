require 'rails_helper'

describe LocalPrAlike do
  describe '#stubs_for_existing' do
    let :diff do
      <<-DIFF
diff --git a/.gitignore b/.gitignore
index dcf9ed7..8afc9c4 100644
--- a/.gitignore
+++ b/.gitignore
@@ -5,6 +5,9 @@
 #   git config --global core.excludesfile '~/.gitignore_global'
 .ruby-version
 .env
+.byebug_history
+.rspec
+
 node_modules
 build
 # Ignore bundler config.
      DIFF
    end

    let :pr do
      LocalPrAlike.new.tap do |pr|
        allow(pr).to receive(:raw_diff) { diff }
      end
    end

    it 'makes stub files from diff' do
      expect(pr.stubs_for_existing('origin/master').length).to eq 1
    end

    it 'implements required methods' do
      methods = %i[org repo files changed_files persisted? expected_url_from_path]
      methods.each do |method|
        expect(LocalPrAlike.method_defined?(method)).to be true
      end
    end
  end

  describe '#load_linter_configs' do
    let(:pr) do
      LocalPrAlike.new.tap do |pr|
        allow(pr).to receive(:files) { SampleStubFile.all }
      end
    end

    it 'loads linter config files when found' do
      allow(File).to receive(:exist?).and_return(true)
      pr.load_linter_configs('/tmp')
      expect(pr.get_config_file('.eslintrc').path).to eq('/tmp/.eslintrc')
      expect(pr.get_config_file('.rubocop.yml').path).to eq('/tmp/.rubocop.yml')
    end

    it 'returns nil when linter configs are not found' do
      allow(File).to receive(:exist?).and_return(false)
      pr.load_linter_configs('/tmp')
      expect(pr.get_config_file('.eslintrc')).to be(nil)
      expect(pr.get_config_file('.rubocop.yml')).to be(nil)
    end

    it 'returns nil for configs associated with no linters' do
      allow(File).to receive(:exist?).and_return(true)
      pr.load_linter_configs('/tmp')
      expect(pr.get_config_file('.no_such_linter')).to be(nil)
    end
  end
end
