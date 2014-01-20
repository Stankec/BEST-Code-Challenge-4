# encoding: UTF-8
class Movie < ActiveRecord::Base
	require 'csv'
	require 'uri'
	require 'open-uri'
	require 'json'
	#####################
    ### Relationships ###
    #####################
	has_and_belongs_to_many :users

	###############
    ### Tagging ###
    ###############
	acts_as_taggable_on :genre, :director, :writer, :actor, :language, :country

	def self.importMoviesFromCSV(path)
		if path == nil; return; end;
		CSV.foreach(path, :encoding => 'MacRoman') do |row|
			title = row[row.length-1]
			if row.length > 2
				for pos in 1..(row.length-2) do
					title += " " + row[pos]
				end
			end
			title = title.strip
			puts title

			movie = Movie.new
  			queryURL = "http://www.omdbapi.com/?t=" + title
  			jsonObject = JSON.parse(open(URI.escape(queryURL)).read)
  			if jsonObject == nil; next; end;

  			# Check fetced
  			if jsonObject["Title"]		== nil; jsonObject["Title"]			=  ""; end;
  			if jsonObject["Year"]		== nil; jsonObject["Year"]			=  ""; end;
  			if jsonObject["Released"]	== nil; jsonObject["Released"]		=  "1 July 1901"; end;		
  			if jsonObject["Runtime"]	== nil; jsonObject["Runtime"]		=  ""; end;		
  			if jsonObject["Plot"]		== nil; jsonObject["Plot"]			=  ""; end;
  			if jsonObject["Awards"]		== nil; jsonObject["Awards"]		=  ""; end;	
        	if jsonObject["Poster"]		== nil; jsonObject["Poster"]		=  ""; end;	
        	if jsonObject["imdbID"]		== nil; jsonObject["imdbID"]		=  ""; end;	
        	if jsonObject["Actors"]		== nil; jsonObject["Actors"]		=  ""; end;	
        	if jsonObject["Director"]	== nil; jsonObject["Director"]		=  ""; end;		
        	if jsonObject["Writer"]		== nil; jsonObject["Writer"]		=  ""; end;	
        	if jsonObject["Genre"]		== nil; jsonObject["Genre"]			=  ""; end;
        	if jsonObject["Language"]	== nil; jsonObject["Language"]		=  ""; end;		
        	if jsonObject["Country"]	== nil; jsonObject["Country"]		=  ""; end;		

        	# Populate
  			movie.title 	= jsonObject["Title"]
  			if Movie.where(:title => jsonObject["Title"]).any?
  				next;
  			end

  			movie.year 		= jsonObject["Year"].to_i
  			begin
  				movie.released 	= Date.strptime(jsonObject["Released"], "%d %B %Y")
  			rescue
  				movie.released 	= Date.today
  			end
  			movie.runtime 	= jsonObject["Runtime"].to_i
  			movie.plot 		= jsonObject["Plot"]
  			movie.awards 	= jsonObject["Awards"]
        	movie.poster   	= jsonObject["Poster"]
        	movie.imdbID   	= jsonObject["imdbID"]
        	while jsonObject["Actors"].gsub!(/\([^()]*\)/,""); end;
        	while jsonObject["Director"].gsub!(/\([^()]*\)/,""); end;
        	while jsonObject["Writer"].gsub!(/\([^()]*\)/,""); end;
        	while jsonObject["Genre"].gsub!(/\([^()]*\)/,""); end;
        	while jsonObject["Language"].gsub!(/\([^()]*\)/,""); end;
        	while jsonObject["Country"].gsub!(/\([^()]*\)/,""); end;
        	movie.actor_list 		= jsonObject["Actors"]
        	movie.director_list 	= jsonObject["Director"]
        	movie.writer_list 		= jsonObject["Writer"]
        	movie.genre_list 		= jsonObject["Genre"]
        	movie.language_list 	= jsonObject["Language"]
        	movie.country_list 		= jsonObject["Country"]

        	# Check object
        	if movie.title 			== nil; movie.title 			= ""		; movie.isDummy = true	; end;	
  			if movie.year 			== nil; movie.year 				= 0			; movie.isDummy = true	; end;
  			if movie.released 		== nil; movie.released 			= Date.today; movie.isDummy = true	; end;		
  			if movie.runtime 		== nil; movie.runtime 			= 0			; movie.isDummy = true	; end;
  			if movie.plot 			== nil; movie.plot 				= ""		; movie.isDummy = true	; end;	
  			if movie.awards 		== nil; movie.awards 			= ""		; movie.isDummy = true	; end;	
        	if movie.poster   		== nil; movie.poster   			= ""		; movie.isDummy = true	; end;	
        	if movie.imdbID   		== nil; movie.imdbID   			= ""		; movie.isDummy = true	; end;	
        	if movie.actor_list 	== nil; movie.actor_list 		= ""		; movie.isDummy = true	; end;	
        	if movie.director_list 	== nil; movie.director_list		= ""		; movie.isDummy = true	; end;	
        	if movie.writer_list 	== nil; movie.writer_list 		= ""		; movie.isDummy = true	; end;	
        	if movie.genre_list 	== nil; movie.genre_list 		= ""		; movie.isDummy = true	; end;	
        	if movie.language_list 	== nil; movie.language_list		= ""		; movie.isDummy = true	; end;	
        	if movie.country_list 	== nil; movie.country_list 		= ""		; movie.isDummy = true	; end;	

        	movie.save
		end
	end # importMoviesFromCSV
end
