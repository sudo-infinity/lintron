# frozen_string_literal: true

require 'rails_helper'

describe LinterConfigFile do
  describe '#initialize' do
    it 'requires a path or file content' do
      expect do
        LinterConfigFile.new
      end.to raise_error
    end

    it 'saves a tmp file once if needed' do
      config = LinterConfigFile.from_content('File Content')
      first_path = config.path
      expect(File.read(config.path)).to eq 'File Content'
      expect(config.path).to eq first_path
    end

    it 'reads and caches content from a local file' do
      path = Tempfile.open('temp') do |file|
        file.write('File Content')
        file.path
      end
      config = LinterConfigFile.from_path(path)
      content = config.content
      expect(content).to eq 'File Content'
      File.unlink(path)
      expect(config.content).to eq 'File Content'
    end
  end
end
