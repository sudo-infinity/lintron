require 'rails_helper'

describe Linters::ESLint do
  it 'can lint without error' do
    source = <<-JS
class bad_es6_code {
  Render() {
return "This is some pretty poorly formatted code to be completely honest. We kind of made it this bad on purpose"
  }
}
    JS

    file = StubFile.new(
      path: 'test.js',
      blob: source,
    )

    lints = Linters::ESLint.new.run(file)

    expect(lints).to_not be_empty
  end
end
