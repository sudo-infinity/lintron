Rails.application.routes.draw do
  resource :github_webhooks, only: :create, defaults: { format: :json }
  get '/relint/:org/:repo/:pr_number', to: 'relints#relint'
  devise_for :user, :controllers => { :omniauth_callbacks => "omniauth_callbacks" }

  resources :local_lints

  root to: 'hooks#index'

  authenticated :user do
    resources :hooks
  end
  resources :pull_requests
end
