require 'rails_helper'

describe Linters do
  it 'can lint a PR' do
    pr = FixturePR.new('can_lint')
    violations = nil
    expect { violations = Linters.violations_for_pr(pr) }.to_not raise_error
    expect(violations).to_not be_empty
  end
end
