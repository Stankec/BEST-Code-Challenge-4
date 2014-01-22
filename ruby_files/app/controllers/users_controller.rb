# encoding: utf-8
class UsersController < ApplicationController
  	def index
      	@user = User.all
  	end # index
	
  	def show
      	@user = User.find_by id: params[:id]
  	end # show
	
  	def new
      	@user = User.new
  	end # new
	
  	def edit
      	@user = User.find_by id: params[:id]
  	end # edit

    def watchedMovies
        @user = User.find_by id: params[:user]
        if !params[:page]; params[:page] = 1; end;
        @movie = @user.movies.paginate(:page => params[:page].to_i, :per_page => 10)
        return
    end # watchedMovies

    def closeAccount
        @user = User.find_by id: params[:id]
    end # closeAccount
	
  	##################
  	### Rails CRUD ###
  	##################

    def user_params
        params.require(:user).permit(	:nameFirst, :nameLast, :nameNickname, 
        								              :loginUsername, :password, :password_confirmation, 
        								              :contactEmail, :useNickname	)
    end
	
  	def create
  		@user = User.new(user_params)
  		if @user.save
  			redirect_to users_path()
  		else
  			displayErrors(@user)
  			render "new"
  		end
  	end # create
	
  	def update
  		@user = User.find_by id: params[:id]
  		if @user.update_attributes(user_params)
  			redirect_to users_path()
  		else
  			displayErrors(@user)
  			render "edit"
  		end
  	end # update
	
  	def destroy
  		@user = User.find_by id: params[:id]
  		if @user.destroy
  			redirect_to users_path
  		else
  			redirect_to :back
  		end
  	end # delete
end
