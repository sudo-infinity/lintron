# frozen_string_literal: true

require 'rails_helper'
require 'lintron/api'

describe Lintron::ViolationLine do
  describe '#file_and_line' do
    let(:with_line_info) do
      Lintron::ViolationLine.new(message: 'you broke a rule', path: 'user.rb', line: 123)
    end
    let(:no_line_info) do
      Lintron::ViolationLine.new(message: 'you broke a rule')
    end

    it 'should format line and path' do
      base = 'user.rb:123    '
      expect(with_line_info.file_and_line).to eq base

      width = 30
      expanded = base + ' ' * (width - base.length)
      expect(with_line_info.file_and_line(width)).to eq expanded
    end

    it 'should work without line and path' do
      expect(no_line_info.file_and_line).to eq ''
      expect(no_line_info.file_and_line(30)).to eq(' ' * 30)
    end
  end
end
