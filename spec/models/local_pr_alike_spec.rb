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
      methods = %w[org repo files changed_files persisted? expected_url_from_path]
      methods.each do |method|
        expect(LocalPrAlike.method_defined?(method.to_sym)).to be true
      end
    end
  end
end
