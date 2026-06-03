Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :recipes do
        collection do
          get :search
        end
      end

      resources :tags, only: [:index]

      resources :shopping_lists do
        resources :items, controller: "shopping_items" do
          collection do
            delete :checked
          end
        end
      end
    end
  end

  get "health", to: proc { [200, {}, ["ok"]] }
end
