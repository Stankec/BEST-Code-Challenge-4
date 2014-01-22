# encoding: UTF-8
class MoviesController < ApplicationController
	require 'will_paginate/array'

  	def index
  		if !params[:page]; params[:page] = 1; end;
  		@movie = Movie.find(:all, :order => "released desc")
  		if params[:search]
  		  	@movie = Movie.search(params[:search])
    	end
  		@movie = @movie.paginate(:page => params[:page].to_i, :per_page => 10)
  	end # index
	
  	def show
  		@movie = Movie.find_by id: params[:id]
  		if @movie == nil
  			render404
  		end
  	end # show
	
  	def new
  		@movie = Movie.new
  	end # new

  	def fromRemote
  		@movie = Movie.new
  	end # newFromRemote
	
  	def edit
  		@movie = Movie.find_by id: params[:id]
  		if @movie == nil
  			flash[:notice] = "That movie does not exist"
  			redirect_to movies_path
  		end
  		if currentUser != nil && currentUser.isAdmin != true
  			render404
  		end
  	end # edit

  	def dummies
  		@movie = Movie.where(:isDummy => true)
  		@movie += Movie.where(:year => 0)
  		@movie += Movie.where(:runtime => 0)
  		if @movie == nil
  			flash[:notice] = "That movie does not exist"
  			redirect_to movies_path
  		end
  		if currentUser != nil && currentUser.isAdmin != true
  			render404
  		end
  		if !params[:page]; params[:page] = 1; end;
  		@movie = @movie.uniq.paginate(:page => params[:page].to_i, :per_page => 10)
  		render "index"
  	end

  	##################
  	### Rails CRUD ###
  	##################

  	def movie_params
        params.require(:movie).permit(	:title, :year, :released,
										:runtime, :plot, :awards,
										:poster, :isHidden, 
										:actor_list, :director_list, :writer_list,
										:genre_list, :language_list, :country_list 	)
    end
	
  	def create
  		@movie = nil

  		if params["remoteTitle"]
  			@movie = Movie.new
  			if !@movie.fetchMovieInfo(params["remoteTitle"], params["remoteYear"])
  				render "fromRemote"
  			end
  		else
  			@movie = Movie.new(movie_params)
  		end

  		if @movie.save
  			redirect_to movie_path(@movie)
  		else
  			displayErrors(@movie)
  			render "new"
  		end
  	end # create
	
  	def update
  		@movie = Movie.find_by id: params[:id]
  		if @movie.update_attributes(movie_params)
  			redirect_to movie_path(@movie)
  		else
  			displayErrors(@movie)
  			render "edit"
  		end
  	end # update
	
  	def destroy
  		@movie = Movie.find_by id: params[:id]
  		Edge.where("nodeA_id = ? OR nodeB_id = ?", @movie.id, @movie.id).find_each do |edge|
      		edge.destroy
      	end
      	Rating.where(:movie => @movie).find_each do |rating|
      		rating.destroy
      	end
  		if @movie.destroy
  			redirect_to movies_path
  		else
  			redirect_to :back
  		end
  	end # delete
end
