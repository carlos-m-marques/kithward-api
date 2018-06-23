Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  scope 'api/v1', defaults: {format: 'json'} do
    resources :facilities

    resources :keywords

    resources :accounts

    resource :session
  end
end
