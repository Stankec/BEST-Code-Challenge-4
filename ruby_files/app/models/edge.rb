class Edge < ActiveRecord::Base
	require 'thread'
	require 'thwait'

	belongs_to :nodeA, :class_name => "Movie"
	belongs_to :nodeB, :class_name => "Movie"

	def tanimotoCorrelation(ratingA, ratingB)
		mul = ratingA.to_f * ratingB.to_f
		return mul / ( (ratingA * ratingA).to_f + (ratingB*ratingB).to_f - mul)
	end # tanimotoCorrelation

	def mMul(a0, a1, b00, b01, b10, b11)
		c0 = a0 * b00 + a1 * b10
		c1 = a0 * b01 + a1 * b11
		mx = mNorm(c0, c1)
		c0 = mx[0] * self.relevanceFactor
		c1 = mx[1] * self.relevanceFactor
		return [c0, c1]
	end # mMul

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

	def calcTanimoto()
		v0 = 1.0
		v1 = 1.0

		tuples = {}
		User.all.each do |user|
			ratings = user.ratings.where("movie_id = ? OR movie_id = ?", self.nodeA.id, self.nodeB.id)
			if ratings == nil || ratings.count != 2
				next
			end
			tuples[user.id] = ratings
		end

		mx = nil
		tuples.keys.each do |key|
			tc = tanimotoCorrelation(tuples[key].first.rating, tuples[key].second.rating)
			v0 = v0 * tc
			mx = mNorm(v0, 1 - v0)
			v0 = mx[0]
		end
		if mx == nil
			return
		end
			v1 = mx[1]

		self.relevanceFactor = 1.0 - ( 1.0 / tuples.keys.count ).to_f
		self.matrix00 = v0.to_f
		self.matrix01 = 1.0 - v0
		#self.matrix10 = v1
		#self.matrix11 = 1 - v1
		self.save
	end # calcTanimoto

	def self.threadedTanimoto(numThreads)
		threads = []
		blockLen = (Edge.all.count/numThreads)+1
		lowestID = Edge.all.order(:id).first.id

		for i in 1..numThreads
			puts "Creating thread " + i.to_s + " starting@: " + lowestID.to_s + " ending@: " + (lowestID+blockLen).to_s
			threads << Thread.new {
				Edge.where("id >= ? AND id <= ?", lowestID, lowestID+blockLen).each do |edge|
					puts "=================" + Thread.current.object_id.to_s + " calculating edge: " + edge.id.to_s
					edge.calcTanimoto
				end
				return true
			}
			lowestID += blockLen
		end

		puts "Waiting for threads..."
		ThreadsWait.all_waits(*threads)
		puts " === DONE ==="
	end # threadedTanimoto

	def calcRelevance()
		tuples = {}
		User.all.each do |user|
			ratings = user.ratings.where("movie_id = ? OR movie_id = ?", self.nodeA.id, self.nodeB.id)
			if ratings == nil || ratings.count != 2
				next
			end
			tuples[user.id] = ratings
		end

		self.relevanceFactor = 1.0 - ( 1.0 / tuples.keys.count ).to_f
		self.save
	end # calcRelevance

	def calcPropability(a0, a1)
		if self.matrix00 == nil || self.matrix01 == nil
			puts " ### ERROR: edge has propability matrix NIL ### "
			return [0.0, 0.0] 
		end
		return mMul(a0, a1, self.matrix00, self.matrix01, self.matrix01, self.matrix00)
	end # calculatePropability
end
