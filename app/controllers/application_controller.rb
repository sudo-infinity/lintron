class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  layout :resolve_layout

  before_action do
    @repos = ProjectRepo.all
  end

  def resolve_layout
    if user_signed_in?
      'application_logged_in'
    else
      'application'
    end
  end
end
