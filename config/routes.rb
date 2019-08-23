require 'sidekiq/web'

Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  mount Sidekiq::Web => '/sidekiq'

  ActiveAdmin.routes(self)

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

    namespace :admin do
      resources :communities do
        patch 'flag', on: :member
        get 'super_classes', on: :collection

        get 'permissions', on: :collection
        get 'permissions', on: :member, action: 'resource_permissions'

        resources :community_images do
          get 'file', on: :member

          get 'permissions', on: :collection
          get 'permissions', on: :member, action: 'resource_permissions'
        end
        resources :unit_layouts do
          patch 'flag', on: :member
          get 'super_classes', on: :collection

          get 'permissions', on: :collection
          get 'permissions', on: :member, action: 'resource_permissions'

          resources :unit_layout_images do
            get 'file', on: :member

            get 'permissions', on: :collection
            get 'permissions', on: :member, action: 'resource_permissions'
          end
        end
        resources :buildings do
          patch 'flag', on: :member
          get 'super_classes', on: :collection

          get 'permissions', on: :collection
          get 'permissions', on: :member, action: 'resource_permissions'
        end
        resources :units do
          patch 'flag', on: :member
          get 'super_classes', on: :collection

          get 'permissions', on: :collection
          get 'permissions', on: :member, action: 'resource_permissions'
        end
      end

      resources :pois do
        get 'permissions', on: :collection
        get 'permissions', on: :member, action: 'resource_permissions'
      end
      resources :poi_categories do
        get 'permissions', on: :collection
        get 'permissions', on: :member, action: 'resource_permissions'
      end

      resources :pm_systems do
        get 'super_classes', on: :collection

        get 'permissions', on: :collection
        get 'permissions', on: :member, action: 'resource_permissions'
      end
      resources :owners do
        get 'super_classes', on: :collection

        get 'permissions', on: :collection
        get 'permissions', on: :member, action: 'resource_permissions'
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
