# Receives lints from the lintron CLI tool and replies with a JSON payload
# of the violations
class LocalLintsController < ApplicationController
  skip_before_action :verify_authenticity_token, if: :json_request?

  def create
    pr = LocalPrAlike.from_json(params)
    violations = Linters.violations_for_pr(pr)

    render json: violations
  end

  protected

  def json_request?
    request.format.json?
  end
end
