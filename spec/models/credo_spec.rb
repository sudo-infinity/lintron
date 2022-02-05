require 'rails_helper'

describe Linters::Credo do
  it 'can lint without error' do
    source = <<-ELIXIR
    defmodule Hi do

      def function_without_docs() do
        Enum.map([], fn(x) -> x end)
        |> Enum.map(fn(x) -> x end)
      end
    end
    ELIXIR

    file = StubFile.new(
      path: 'test.ex',
      blob: source,
    )

    lints = Linters::Credo.new.run(file)

    expect(lints).to_not be_empty
  end
end
