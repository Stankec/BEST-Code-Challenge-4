BCC4::Application.routes.draw do
	# Movies
  	get "movies/index"
  	get "movies/show"
  	get "movies/new"
  	get "movies/edit"
  	get "movies/recommended"
  	get "movies/fromRemote"
	# Pages
	get "pages/index"
	get "pages/show"
	get "pages/edit"
	get "pages/new"
	get "pages/settings"
	get "pages/main"
	# Users
	get "users/index"
	get "users/show"
	get "users/edit"
	get "users/new"
	get "users/watchedMovies"
	# Sessions
	get "login" => "sessions#new", :as => "login"
  	get "logout" => "sessions#destroy", :as => "logout"
  	# Root
  	root :to => "pages#main"

  	# Resources
  	resources :sessions
  	resources :users
  	resources :pages
  	resources :movies
end
