class RatingsController < ApplicationController
  	def new
  		if params[:forMovie] == nil || currentUser == nil
  			return
  		end
  		movie = Movie.find_by id: params[:forMovie]
  		if movie == nil
  			return
  		end
  		@rating = Rating.new
  		@rating.user = currentUser
  		@rating.movie = movie
  		@rating.rating = 1
  	end # new

  	##################
  	### Rails CRUD ###
  	##################

  	def rating_params
        params.require(:rating).permit(	:user_id, :movie_id, :rating )
    end
	
  	def create
  		@rating = Rating.new(rating_params)
  		@rating.user = currentUser

      	@rating.user.movies.find_each do |movie|
      		if Edge.where("(nodeA_id = ? AND nodeB_id = ?) OR (nodeA_id = ? AND nodeB_id = ?)", movie.id, @rating.movie.id, @rating.movie.id, movie.id).any?
      			next
      		end
      		puts "Connecting: \"" + @rating.movie.title + "\" with \"" + movie.title + "\""
      		edge = Edge.new
      		edge.nodeA = movie
      		edge.nodeB = @rating.movie
      		edge.relevanceFactor = 0.0
      		edge.save
      		edge.calcTanimoto
      	end

  		if @rating.save
  			redirect_to movie_path(@rating.movie)
  		else
  			displayErrors(@rating)
  			render "movies/show/"+@rating.movie.id
  		end
  	end # create
	
  	def update
  		@rating = Rating.find_by id: params[:id]
  		@rating.user = currentUser
  		if @rating.update_attributes(rating_params)
  			redirect_to movie_path(@rating.movie)
  		else
  			displayErrors(@rating)
  			render "movies/show/"+@rating.movie.id
  		end
  	end # update
	
  	def destroy
  		@rating = Rating.find_by id: params[:id]
  		if @rating.destroy
  			redirect_to movie_path(@rating.movie)
  		else
  			displayErrors(@rating)
  			render "movies/show/"+@rating.movie.id
  		end
  	end # delete
end
