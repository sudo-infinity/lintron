class HooksController < ApplicationController
  def index; end

  def create
    hook_enabler = HookEnabler.new(params[:repo], params[:org], current_user)

    begin
      hook_enabler.run
    rescue Github::Error => e
      flash[:error] = e.message
    end

    redirect_to :back
  end
end
