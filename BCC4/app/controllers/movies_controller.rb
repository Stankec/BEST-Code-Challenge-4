# encoding: UTF-8
class MoviesController < ApplicationController
	require 'uri'
	require 'open-uri'
	require 'json'

  	def index
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
  		if @movie == nil && currentUser != nil && currentUser.isAdmin == true
  			render404
  		end
  	end # edit

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
  			queryURL = "http://www.omdbapi.com/?t=" + params["remoteTitle"]
  			if params["remoteYear"] && params["remoteYear"].length != 0
  				queryURL += "&y=" + params["remoteYear"]
  			end
  			jsonObject = JSON.parse(open(URI.escape(queryURL)).read)
  			if jsonObject == nil; render "fromRemote"; return; end;

  			@movie.title 	= jsonObject["Title"]
  			@movie.year 	= jsonObject["Year"].to_i
  			@movie.released = Date.strptime(jsonObject["Released"], "%d %B %Y")
  			@movie.runtime 	= jsonObject["Runtime"].to_i
  			@movie.plot 	= jsonObject["Plot"]
  			@movie.awards 	= jsonObject["Awards"]
        	@movie.poster   = jsonObject["Poster"]
        	@movie.imdbID   = jsonObject["imdbID"]
        	while jsonObject["Actors"].gsub!(/\([^()]*\)/,""); end;
        	while jsonObject["Director"].gsub!(/\([^()]*\)/,""); end;
        	while jsonObject["Writer"].gsub!(/\([^()]*\)/,""); end;
        	while jsonObject["Genre"].gsub!(/\([^()]*\)/,""); end;
        	while jsonObject["Language"].gsub!(/\([^()]*\)/,""); end;
        	while jsonObject["Country"].gsub!(/\([^()]*\)/,""); end;
        	@movie.actor_list 		= jsonObject["Actors"]
        	@movie.director_list 	= jsonObject["Director"]
        	@movie.writer_list 		= jsonObject["Writer"]
        	@movie.genre_list 		= jsonObject["Genre"]
        	@movie.language_list 	= jsonObject["Language"]
        	@movie.country_list 	= jsonObject["Country"]
  		else
  			@movie = Movie.new(movie_params)
  		end

  		if @movie.save
  			redirect_to movies_path()
  		else
  			displayErrors(@movie)
  			render "new"
  		end
  	end # create
	
  	def update
  		@movie = Movie.find_by id: params[:id]
  		if @movie.update_attributes(movie_params)
  			redirect_to movies_path()
  		else
  			displayErrors(@movie)
  			render "edit"
  		end
  	end # update
	
  	def destroy
  		@movie = Movie.find_by id: params[:id]
  		if @movie.destroy
  			redirect_to movies_path
  		else
  			redirect_to :back
  		end
  	end # delete
end
