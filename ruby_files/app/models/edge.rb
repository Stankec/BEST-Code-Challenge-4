class Edge < ActiveRecord::Base
	belongs_to :nodeA, :class_name => "Movie"
	belongs_to :nodeB, :class_name => "Movie"

	def tanimotoCorrelation(ratingA, ratingB)
		mul = ratingA * ratingB
		return mul * ( (ratingA * ratingA) + (ratingB*ratingB) - mul)
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

	def self.calcTanimoto(movie, user)
		v0 = 1
		v1 = 1

		rating = Rating.where("movie_id = ? AND user_id = ?", movie.id, user.id)
		if rating.any?
			rating = rating.first
		end
		ratings = Rating.where("movie_id != ? AND movie_id = ?", movie.id, user.id)

		mx = nil
		ratings.find_each do |r|
			tc = tanimotoCorrelation(r.rating, rating.rating)
			v0 = v0 * tc
			mx = mNorm(v0, 1 - v0)
			v0 = mx[0]
		end
		v1 = mx[1]

		self.relevanceFactor = 1 - ( 1 / ratings.count )
		self.matrix00 = v0
		self.matrix01 = 1 - v0
		#self.matrix10 = v1
		#self.matrix11 = 1 - v1
		self.save
	end # calcTanimoto

	def self.calcPropability(a0, a1)
		return mMul(a0, a1, self.matrix00, self.matrix01, self.matrix01, self.matrix00)
	end # calculatePropability
end
