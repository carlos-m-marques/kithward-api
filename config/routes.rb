Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  scope 'v1', defaults: {format: 'json'} do
    resources :communities do
      get 'dictionary', on: :collection
      post 'import', on: :collection

      resources :listings
      resources :images, controller: 'community_images'
    end

    resources :listings do
      resources :images, controller: 'listing_images'
    end

    resources :accounts do
      get 'exception', on: :collection
    end

    resources :leads

    resources :geo_places

    scope 'auth' do
      match 'login', to: 'auth#login', via: [:post]
      match 'token', to: 'auth#token', via: [:post]
      match 'request_verification', to: 'auth#request_verification', via: [:post]
    end

  end

  get 'sitemap.xml', :to => 'sitemap#sitemap', :defaults => {:format => 'xml'}
end
