# encoding: UTF-8
class Movie < ActiveRecord::Base
	require 'csv'
	require 'uri'
	require 'open-uri'
	require 'json'

	#####################
	### Relationships ###
	#####################
	has_many :ratings
	has_many :users, :through => :ratings

	###############
	### Tagging ###
	###############
	acts_as_taggable_on :genre, :director, :writer, :actor, :language, :country

	##############
	### Search ###
	##############
	def self.search(term)
		if term == nil
			return Movie.all
		end
	  result = []
		searchTerms = term.split(',').map(&:downcase)
	  searchTerms.each do |a|
	    title = '%' + a.to_s + '%'
	    result += Movie.where("LOWER(title) LIKE ?", title)
	  end
	  result += Movie.tagged_with(searchTerms, :any => true)
		return result.uniq
	end # search

	#####################
	### Recomendation ###
	#####################
	def recommended(movies, numRecommendation, user=nil)
		if movies == nil && user != nil
			movies = user.movies
		end
		allPotentialNodes = {}
		if movies == nil
			return []
		end
		puts "Entering watched movies loop"
		movies.each do |movie|
			potentialNodes = movie.likePropability(user, movies)
			potentialNodes = cull(potentialNodes)
			nodesToRemove = []
			puts "Entering potential nodes loop for " + movie.title
			puts "Potential nodes: " + potentialNodes.to_s
			while (potentialNodes.keys.count < numRecommendation) && (potentialNodes.keys.count < (Movie.all.count - movies.count))
				potentialNodeIDs = potentialNodes.keys
				nodesToRemove.each do |nodeID|
					potentialNodeIDs.delete(nodeID)
				end
				nodesToRemove = potentialNodes.keys
				if potentialNodeIDs.count == 0
					break
				end
				potentialNodeIDs.each do |nodeID|
					movie = Movie.where(:id => nodeID)
					if movie != nil && movie.any?
						movie = movie.first
					end
					potentialNodes.merge(movie.likePropability(user, movies))
				end
			end
			potentialNodes.keys.each do |key|
				if allPotentialNodes[key] == nil
					allPotentialNodes[key] = potentialNodes[key]
				else
					v0 = allPotentialNodes[key] * potentialNodes[key]
					v1 = (1 - allPotentialNodes[key]) * (1 - potentialNodes[key])
					allPotentialNodes[key] = mNorm(v0, v1)[0]
				end
			end
		end
		counter = 1
		result = []
		puts "Picking top " + numRecommendation.to_s
		allPotentialNodes.sort_by {|key, value| value}.each do |idProp|
			result << idProp[0]
			if counter >= numRecommendation
				break
			end
			counter += 1
		end
		return Movie.where("id IN (?)", result)
	end # recommended

	def likePropability(user, movies=[])
		potentialNodes = {}
		rating = nil
		if user != nil
			rating = Rating.where(:movie => self, :user => user)
			movies = user.movies
		end
		if rating != nil && rating.any?
			rating = rating.first.rating
		else
			rating = 5
		end
		l0 =  rating.to_f / 5.0
		l1 = 1 - l0
		#s0 = l0
		#s1 = l1
		Edge.where("nodeA_id = ? OR nodeB_id = ?", self.id, self.id).each do |edge|
			otherNode = edge.nodeA
			if otherNode == self
				otherNode = edge.nodeB
			end
			if movies.include?(otherNode) || potentialNodes.include?(otherNode)
				next
			end
			pr = edge.calcPropability(l0, l1)
			potentialNodes[otherNode.id] = pr[0]
		end

		return potentialNodes
	end # likePropability

	def cull(hash)
		return hash.delete_if {|key, value| value < 0.1}
	end # cull

	###################
	### Data import ###
	###################
	def fetchMovieInfo(title, year)
		# check input
		if title == nil
			return false
		end
		if title != nil && !(title.is_a? String)
			title = title.to_s
		end
		if year != nil && !(year.is_a? String)
			year = year.to_s
		end

		# do query
		queryURL = "http://www.omdbapi.com/?t=" + title
		if year != nil && year.length != 0
			queryURL += "&y=" + year
		end
		jsonObject = JSON.parse(open(URI.escape(queryURL)).read)
		if jsonObject == nil
			return false
		end

		# check integrity
		if jsonObject["Response"] != "True" || jsonObject["Type"] != "movie"
			return false
		end

		# Populate
		self.title 		= jsonObject["Title"]
		self.year 		= jsonObject["Year"].to_i
		self.released 	= Date.strptime(jsonObject["Released"], "%d %B %Y")
		self.runtime 	= jsonObject["Runtime"].to_i
		self.plot 		= jsonObject["Plot"]
		self.awards 	= jsonObject["Awards"]
	    self.poster   	= jsonObject["Poster"]
	    self.imdbID   	= jsonObject["imdbID"]
	    # Sterilze
	    while jsonObject["Actors"].gsub!(/\([^()]*\)/,""); end;
	    while jsonObject["Director"].gsub!(/\([^()]*\)/,""); end;
	    while jsonObject["Writer"].gsub!(/\([^()]*\)/,""); end;
	    while jsonObject["Genre"].gsub!(/\([^()]*\)/,""); end;
	    while jsonObject["Language"].gsub!(/\([^()]*\)/,""); end;
	    while jsonObject["Country"].gsub!(/\([^()]*\)/,""); end;
	    # Taglist
	    self.actor_list 	= jsonObject["Actors"]
	    self.director_list 	= jsonObject["Director"]
	    self.writer_list 	= jsonObject["Writer"]
	    self.genre_list 	= jsonObject["Genre"]
	    self.language_list 	= jsonObject["Language"]
	    self.country_list 	= jsonObject["Country"]

	    return true
	end # fetchMovieInfo

	def self.importFromCSVWithIntegritiFix(moviesPath, prefsPath)
		self.importMoviesFromCSV(moviesPath)
		newPrefs = self.checkImportIntegrity(moviesPath, prefsPath)
		if newPrefs != nil
			self.trainNetworkWithCSV(newPrefs)
		else
			self.trainNetworkWithCSV(prefsPath)
		end
	end # importFromCSVWithIntegritiFix

	def self.trainNetworkWithCSV(path)
		puts "######################"
		puts "### Adding Ratings ###"
		puts "######################"

		CSV.foreach(path, :encoding => 'MacRoman') do |row|
			user = row[0]
			node = row[1].to_i
			weight = row[2].to_i

			if User.where(:nameFirst => "user" + user.to_s).any?
				user = User.where(:nameFirst => "user" + user).first
			else
				givenID = user
				puts "Creating new user: user" + user
				user = User.new
				user.nameFirst = "user" + givenID
				user.nameLast = ""
				user.loginUsername = user.nameFirst
				user.password = user.nameFirst
				user.contactEmail = user.nameFirst + "@users.com"
				user.isAdmin = false
				user.save
			end

			if Rating.where("user_id = ? AND movie_id = ?", user.id, node).any?
				puts "Skipping node " + node.to_s + " for " + user.nameFirst
				next
			else
				movie = Movie.where(:id => node)
				if movie.any?
					movie = movie.first
				else
					puts "Skipping node " + node.to_s + " for " + user.nameFirst + " (Node doesn't exist)"
					next
				end
				rating = Rating.new
				rating.movie = movie
				rating.user = user
				rating.rating = weight
				rating.save
				puts "User \""+user.nameFirst+"\" rated the movie \""+movie.title+"\" with a "+weight.to_s+" raiting" 


				user.movies.each do |watchedMovie|
					if watchedMovie == movie
						puts "Avoid recursion!"
						next
					end
					if Edge.where("(nodeA_id = ? AND nodeB_id = ?) OR (nodeA_id = ? AND nodeB_id = ?)", watchedMovie.id, movie.id, movie.id, watchedMovie.id).any?
						puts "Edge already exists!"
						next
					end
					edge = Edge.new
					edge.nodeA = watchedMovie
					edge.nodeB = movie
					edge.save
				end
			end
		end

		puts "##############################"
		puts "### Calculating Statistics ###"
		puts "##############################"

		Edge.all.find_each do |edge|
			edge.calcTanimoto
		end


		puts " === DONE ==="
	end # trainNetworkWithCSV

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
			if jsonObject["Released"]	== nil; jsonObject["Released"]		=  ""; end;		
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
			movie.title 	= title
			if Movie.where(:title => title).any?
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

	def self.checkImportIntegrity(path, path2)
		if path == nil; return; end;
		errors = {}
		correct = {}
		fix = {}

		puts "####################"
		puts "### Checking CSV ###"
		puts "####################"

		CSV.foreach(path, :encoding => 'MacRoman') do |row|
			title = row[row.length-1]
			if row.length > 2
				for pos in 1..(row.length-2) do
					title += " " + row[pos]
				end
			end
			title = title.strip
			puts "Testing: " + title
			if errors[title] == nil
				errors[title] = []
			end
			errors[title] << row[0].to_i
			fix[row[0].to_i] = nil
		end

		puts "#########################"
		puts "### Checking Database ###"
		puts "#########################"

		Movie.all.each do |m|
			puts "Checking: " + m.title
			correct[m.title] = m.id.to_i
		end

		puts "######################"
		puts "### Finding Errors ###"
		puts "######################"

		numErrors = 0

		errors.keys.each do |key|
			if errors[key].length != 1
				ids = ""
				errors[key].each do |a|
					if ids.length != 0
						ids += ", "
					end
					ids += a.to_s
				end
				numErrors += 1
				puts numErrors.to_s + ": " + key + " -> " + ids
			end
		end

		puts "########################"
		puts "### Findinf Solution ###"
		puts "########################"

		if numErrors == 0
			puts "    No errors found! Huray! You are done."
			return nil
		end

		correct.keys.each do |key|
			if errors[key] == nil
				puts "Skipping " + key.to_s
				next
			end
			if errors[key].length == 1 && errors[key][0] == correct[key]
				next
			end

			errors[key].each do |a|
				fix[a] = correct[key]
			end
		end

		numErrors = 0
		fix.keys.each do |key|
			if fix[key] != nil
				numErrors += 1
				puts numErrors.to_s + ": " + key.to_s + " -> " + fix[key].to_s
			end
		end

		if path2 == nil; return nil; end;

		puts "###################"
		puts "### Fixing File ###"
		puts "###################"

		outputFile = path2[0..-5] + "_fix.csv"
		output = ""

		puts "    Building new file...."
		CSV.foreach(path2, :encoding => 'MacRoman') do |row|
			nodeB = row[1].to_i
			if fix[nodeB] != nil
				nodeB = fix[nodeB]
			end
			output += row[0] + "," + nodeB.to_s + "," + row[2] + "\n"
		end

		puts "    Writing file...."
		File.write(outputFile, output)

		puts "    DONE!"

		return outputFile
	end # checkImportIntegrity


	#############
	### Maths ###
	#############
	def mNorm(a0, a1)
		if a0 + a1 == 1
			return [a0, a1]
		end
		if (a0 + a1).abs < 0.001
			return [a0, a1]
		end
		k = 1 / (a0 + a1)
		a0 = a0 * k
		a1 = a1 * k
		return [a0, a1]
	end # mNor
end
