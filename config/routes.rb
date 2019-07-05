Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  scope 'v1', defaults: {format: 'json'} do
    resources :communities do
      get 'dictionary', on: :collection
      post 'import', on: :collection
      get 'near_by_ip', on: :collection
      get 'similar_near', on: :member

      get 'by_area', on: :collection

      resources :listings
      resources :images, controller: 'community_images'
      resources :pois, controller: 'community_pois'
    end

    resources :listings do
      resources :images, controller: 'listing_images'
    end

    resources :accounts do
      get 'exception', on: :collection
    end

    resources :leads

    resources :geo_places
    resources :pois do
      collection do
        resources :categories, controller: 'poi_categories'
      end
    end

    scope 'auth' do
      match 'login', to: 'auth#login', via: [:post]
      match 'token', to: 'auth#token', via: [:post]
      match 'request_verification', to: 'auth#request_verification', via: [:post]
    end

  end

  namespace :admin do
    if Rails.env.staging?
      get :clone_db
    end
  end


  get 'sitemap.xml', :to => 'sitemap#sitemap', :defaults => {:format => 'xml'}
end
