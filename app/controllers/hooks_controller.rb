class HooksController < ApplicationController
  def index
  end

  def create
    hook_enabler = HookEnabler.new(params[:repo], params[:org], current_user)

    begin
      hook_enabler.run
      flash[:success] = "Got it! Now open a Pull Request to see Lintron work."
    rescue Github::Error::NotFound => e
      flash[:alert] = "Repo not found."
    rescue Github::Error => e
      flash[:alert] = e.message
    end

    redirect_to :back
  end
end
