class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  layout :resolve_layout

  before_action do
    @repos = ProjectRepo.all
  end

  private

  def authenticate_user_from_token!
    user_email = params[:user_email].presence
    user       = user_email && User.find_by_email(user_email)
    token = UserToken.find_by(user: user, token: params[:user_token])

    # Notice how we use Devise.secure_compare to compare the token
    # in the database with the token given in the params, mitigating
    # timing attacks.
    if user && token && Devise.secure_compare(token.token, params[:user_token])
      sign_in user, store: false
    end
  end

  def resolve_layout
    if user_signed_in?
      'application_logged_in'
    else
      'application'
    end
  end
end
