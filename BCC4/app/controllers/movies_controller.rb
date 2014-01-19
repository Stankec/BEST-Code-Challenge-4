# encoding: UTF-8
class MoviesController < ApplicationController
	require 'uri'
	require 'open-uri'
	require 'json'

  	def index
  	end # index
	
  	def show
  	end # index
	
  	def new
  		@movie = Movie.new
  	end # index

  	def fromRemote
  		@movie = Movie.new
  	end # newFromRemote
	
  	def edit
  	end # index

  	##################
  	### Rails CRUD ###
  	##################

  	def movie_params
        params.require(:movie).permit(	:title, :year, :released,
										:runtime, :plot, :awards,
										:poster, :isHidden	)
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
