require 'rails_helper'

describe Violation do
  describe '#as_json' do
    it 'has path, line, message, and linter' do
      violation = Violation.new(
        file: OpenStruct.new(path: 'test.rb'),
        line: 1,
        message: 'This line is very bad.',
      )

      expect do
        expect(violation.as_json.keys).to eq %i[path line message linter]
      end.to_not raise_error
    end
  end
end
