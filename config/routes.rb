Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  scope 'v1', defaults: {format: 'json'} do
    resources :communities do
      get 'dictionary', on: :collection

      resources :images, controller: 'community_images'
    end

    resources :accounts do
      get 'exception', on: :collection
    end

    resources :leads

    resources :geo_places

    scope 'auth' do
      match 'login', to: 'auth#login', via: [:post]
      match 'token', to: 'auth#token', via: [:post]
    end
  end
end
