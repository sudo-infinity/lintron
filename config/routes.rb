Rails.application.routes.draw do
  resource :github_webhooks, only: :create, defaults: { format: :json }
  get '/relint/:org/:repo/:pr_number', to: 'relints#relint'
  devise_for :user, :controllers => { :omniauth_callbacks => "omniauth_callbacks" }

  devise_scope :user do
    root to: 'hooks#index'
    resources :hooks
  end
end
