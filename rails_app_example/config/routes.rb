Myapp::Application.routes.draw do
  root "jobs#index"

  resources :jobs, only: [:index] do
    post :crashing, on: :collection
    post :single, on: :collection
    post :multiple, on: :collection
  end
end
