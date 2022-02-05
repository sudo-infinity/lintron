require 'rails_helper'

RSpec.describe LocalLintsController, type: :controller do
  let(:params) do
    body = 'class lol_bad_ruby; end'
    {
      files: [
        {
          path: 'test.rb',
          blob: body,
          patch: Patch.from_file_body(body),
        },
      ],
    }
  end

  describe '#create' do
    it 'can take a JSON of a lint request, and return violations' do
      post :create, params

      expect(response).to be_success
      expect do
        violations = JSON.parse(response.body)
        expect(violations).to_not be_empty
      end.to_not raise_error(JSON::ParserError)
    end
  end
end
