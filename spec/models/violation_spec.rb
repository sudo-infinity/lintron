require 'rails_helper'

describe Violation do
  describe '#as_json' do
    it 'has path, line and message' do
      violation = Violation.new(
        file: OpenStruct.new(path: 'test.rb'),
        line: 1,
        message: 'This line is very bad.',
      )

      expect do
        expect(violation.as_json.keys).to eq [:path, :line, :message]
      end.to_not raise_error
    end
  end
end
