class UsersMovies < ActiveRecord::Migration
  	def change
  		create_table :movies_users do |t|
  			t.belongs_to :user
  	    	t.belongs_to :movie
  	  	end
  	end
end
