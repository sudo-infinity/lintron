Rails.application.routes.draw do
  resource :github_webhooks, only: :create, defaults: { format: :json }
end
