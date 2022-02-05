Rails.application.routes.draw do
  resource :github_webhooks, only: :create, defaults: { format: :json }
  get '/relint/:org/:repo/:pr_number', to: 'relints#relint'
end
