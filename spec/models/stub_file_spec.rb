require 'rails_helper'

describe StubFile do
  describe '#as_json' do
    it 'includes path, blob, patch' do
      path = 'test.rb'
      body = 'class lol_ruby; end'
      file = StubFile.new(
        path: path,
        blob: body,
        patch: Patch.from_file_body(body),
      )

      expect do
        expect(file.as_json.keys).to eq [:path, :blob, :patch]
      end.to_not raise_error
    end
  end
end
