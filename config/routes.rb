Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  scope 'v1', defaults: {format: 'json'} do
    resources :facilities

    resources :accounts

    scope 'auth' do
      match 'login', to: 'auth#login', via: [:post]
      match 'token', to: 'auth#token', via: [:post]
    end
  end
end
