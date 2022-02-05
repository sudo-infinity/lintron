# frozen_string_literal: true

require 'rails_helper'
require 'lintron/cli'

describe Lintron::CLI do
  describe '#origin_info' do
    let(:cli) do
      Lintron::CLI.new
    end

    before do
      allow_any_instance_of(OptionParser).to receive(:parse!)
    end

    it 'should return nil if no git origin' do
      allow(cli).to receive(:git_origin).and_return('')
      expect(cli.origin_info).to be nil
    end

    it 'should work with github ssh origin' do
      allow(cli).to receive(:git_origin).and_return('git@github.com:prehnRA/lintron.git')
      expect(cli.origin_info[:repo]).to eq 'lintron'
      expect(cli.origin_info[:org]).to eq 'prehnRA'
    end

    it 'should work with github readonly origin' do
      allow(cli).to receive(:git_origin).and_return('git://github.com/prehnRA/lintron.git')
      expect(cli.origin_info[:repo]).to eq 'lintron'
      expect(cli.origin_info[:org]).to eq 'prehnRA'
    end

    it 'should work with github https origin' do
      allow(cli).to receive(:git_origin).and_return('https://github.com/prehnRA/lintron.git')
      expect(cli.origin_info[:repo]).to eq 'lintron'
      expect(cli.origin_info[:org]).to eq 'prehnRA'
    end
  end
end
