require 'sidekiq/web'

Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  mount Sidekiq::Web => '/sidekiq'

  ActiveAdmin.routes(self)

  scope 'v1', defaults: {format: 'json'} do
    get 'permissions/:entity', to: 'permissions#permissions'
    get 'permissions/:entity/:entity_id', to: 'permissions#resource_permissions'

    resources :account_access_requests do
      post :approve, on: :member
      patch :reject, on: :member
    end

    resources :communities do
      get 'dictionary', on: :collection
      post 'import', on: :collection
      get 'near_by_ip', on: :collection
      get 'similar_near', on: :member
      get 'available', on: :collection

      post 'favorite', on: :member
      delete 'favorite', to: 'communities#unfavorite', on: :member

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
      get 'favorites', to: 'accounts#favorites', on: :collection
      get 'favorites', to: 'accounts#account_favorites', on: :member
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

    namespace :admin do
      resources :communities do
        patch 'flag', on: :member
        get 'super_classes', on: :collection
        get 'account_requests', on: :member

        resources :community_images do
          get 'file', on: :member
        end

        resources :unit_layouts do
          patch 'flag', on: :member
          get 'super_classes', on: :collection

          resources :unit_layout_images do
            get 'file', on: :member
          end
        end

        resources :buildings do
          patch 'flag', on: :member
          get 'super_classes', on: :collection
        end

        resources :units do
          patch 'flag', on: :member
          get 'super_classes', on: :collection
        end
      end

      resources :pois
      resources :poi_categories

      resources :pm_systems do
        get 'super_classes', on: :collection
      end

      resources :owners do
        get 'super_classes', on: :collection
      end
    end
  end

  namespace :admin do
    if Rails.env.staging?
      get :clone_db
    end
  end

  get 'sitemap.xml', :to => 'sitemap#sitemap', :defaults => {:format => 'xml'}
end
