class Status
  CONTEXT = 'Lintron'

  attr_accessor :pr, :state, :description, :target_url

  def self.process_with_status(pr, &block)
    Status.new(pr, :pending).send!
    begin
      yield block
      Status.new(pr, :success).send!
    rescue => e
      Status.new(pr, :error).send!
      raise e
    end
  end

  def initialize(pr, state, description: nil, target_url: nil)
    @pr = pr
    @state = state
    @description = description
    @target_url = target_url
  end

  def send!
    Github.repos.statuses.create pr.org, pr.repo, pr.to_gh.head.sha, body_params
  end

  def body_params
    body_params = {
      state: state,
      context: CONTEXT,
      description: description,
      target_url: target_url
    }

    body_params.delete_if { |_k, v| v.nil? }
  end
end
