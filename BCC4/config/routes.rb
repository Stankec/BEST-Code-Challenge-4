BCC4::Application.routes.draw do
	# Pages
	get "pages/index"
	get "pages/show"
	get "pages/edit"
	get "pages/new"
	get "pages/settings"
	# Users
	get "users/index"
	get "users/show"
	get "users/edit"
	get "users/new"
	# Sessions
	get "login" => "sessions#new", :as => "login"
  	get "logout" => "sessions#destroy", :as => "logout"
  	# Root
  	root :to => "pages#index"
end
