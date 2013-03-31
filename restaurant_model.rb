require 'singleton'
require 'sqlite3'

class RestaurantDatabase < SQLite3::Database 
	include Singleton

	def initialize 
		super("restaurant_database5.DB")
		self.results_as_hash = true
		self.type_translation = true
	end

	def self.execute(*args)
		self.instance.execute(*args)		
	end
end

class Chef 

	def self.find(id)
		chef_row = RestaurantDatabase.execute(<<-SQL, id)
			SELECT * 
			  FROM chef
			 WHERE chef.id = ?
		SQL

		chef_row.empty? ? nil : Chef.new(chef_row.first)

	end

	attr_accessor :first_name, :last_name, :mentor, :id

	def initialize(row)
		@id, @first_name, @last_name, @mentor = row['id'], row['first_name'], row['last_name'], row['mentor']
	end

	def proteges 
		chefs = RestaurantDatabase.execute(<<-SQL, id)
			SELECT protege.*
			  FROM chef parent
			  JOIN chef protege
			  	ON parent.id = protege.mentor
			 WHERE parent.id = ?
		SQL

		chefs.map { |chef| Chef.new(chef)}		
	end

	def num_proteges 
		num = RestaurantDatabase.execute(<<-SQL, id)
			SELECT COUNT(*) as number
			  FROM chef parent
			  JOIN chef protege
			  	ON parent.id = protege.mentor
			 WHERE parent.id = ?

		SQL

		num.first['number']	
	end

	def co_workers(id)
		chefs = RestaurantDatabase.execute(<<-SQL, id)
			SELECT self_map.*
	  		  FROM chef_tenure self
	  		  JOIN chef_tenure co_work
	  			ON self.restaurant_id = co_work.restaurant_id
	  		  JOIN chef self_map
	  		    ON co_work.chef_id = self_map.id
			 WHERE self.chef_id = ?
	  		   AND self.start_date < co_work.end_date AND self.end_date > co_work.start_date
	  		   AND self.chef_id != co_work.chef_id
		SQL

		chefs.map { |chef|  Chef.new(chef)}
	end 

end

class Restaurant

	def self.find(id)
	row = RestaurantDatabase.execute(<<-SQL, id)
		SELECT * 
		  FROM restaurant
		 WHERE restaurant.id = ?
	SQL
	
	row.empty? ? nil : Restaurant.new(row.first)
	end

	def self.by_neighborhood(neighborhood) ## take a neighborhood
	restaurants = RestaurantDatabase.execute(<<-SQL, neighborhood)
		SELECT * 
		  FROM restaurant
		 WHERE neighborhood	= ?
	SQL

	restaurants.map { |restaurant| Restaurant.new(restaurant) }
	end


	attr_accessor :name, :neighborhood, :cuisine, :id

	def initialize(row)
		@id, @name, @neighborhood, @cuisine = row['id'], row['name'], row['neighborhood'], row['cuisine']
	end_date

	def reviews
		RestaurantReview.reviews_for_restaurant(id)
	end

	def average_review_score
		RestaurantReview.average_review_score_restaurant(id)
	end


end 

class RestaurantReview
	def initialize(row)
		@id, @text_review, @score, @critic_id = row['id'], row['text_review'], row['score'], row['critic_id']
		@date_of_review, @restaurant_id = row['date_of_review'], row['restaurant_id']
	end

	def self.reviews_for_restaurant(restaurant_id)
	reviews = RestaurantDatabase.execute(<<-SQL, restaurant_id)
		SELECT * 
		  FROM restaurant_review
		 WHERE restaurant_id = ?
	SQL

	reviews.map { |review| RestaurantReview.new(review) }
	end 

	def self.average_review_score_restaurant(restaurant_id)
		score = RestaurantDatabase.execute(<<-SQL, restaurant_id)
			SELECT AVG(score) as average 
			  FROM restaurant_review
			 WHERE restaurant_id = ?
		SQL

		score.first["average"]
	end 

	def self.reviews_for_critics(critic_id)
		reviews = RestaurantDatabase.execute(<<-SQL, critic_id)
			SELECT restaurant_review.*
			  FROM critic
			  JOIN restaurant_review
			  	ON critic.id = restaurant_review.critic_id
			 WHERE critic.id = ?
		SQL

		reviews.map { |review| RestaurantReview.new(review) }
	end 

	def self.average_review_score_critic(critic_id)
		score = RestaurantDatabase.execute(<<-SQL, critic_id)
			SELECT avg(score) as average
			  FROM critic
			  JOIN restaurant_review
			  	ON critic.id = restaurant_review.critic_id
			 WHERE critic.id = ?
		SQL

		score.first["average"]
	end 

	def self.reviews_for_chef (chef_id)
		reviews = RestaurantDatabase.execute(<<-SQL, chef_id)
			SELECT restaurant_review.*
			  FROM chef 
			  JOIN chef_tenure
			  	ON chef.id = chef_tenure.chef_id
			  JOIN restaurant_review
			  	ON restaurant_review.restaurant_id = chef_tenure.restaurant_id
			 WHERE chef.id = ?
			   AND chef_tenure.head_chef = 1
			   AND restaurant_review.date_of_review 
			   BETWEEN chef_tenure.start_date 
			   AND chef_tenure.end_date
		SQL

		reviews.map { |review| RestaurantReview.new(review)}
	end 

	def self.unreviewed_restaurants  
		reviews = RestaurantDatabase.execute(<<-SQL)
			SELECT restaurant.id 
			FROM restaurant 
			WHERE restaurant.id NOT IN (SELECT restaurant.id 
									  FROM restaurant
									  JOIN restaurant_review
									  	ON restaurant.id = restaurant_review.restaurant_id
									 GROUP BY restaurant_id
									 HAVING COUNT(*) > 0)
		SQL
		reviews.map { |review| Restaurant.new(review)}
	end 
	
	def self.top_restaurants(n=3)
		restaurants = RestaurantDatabase.execute(<<-SQL,n)
			SELECT restaurant.* 
			  FROM restaurant_review 
			  JOIN restaurant
			    ON restaurant_id = restaurant.id
			  GROUP BY restaurant_id
			  ORDER BY AVG(score) DESC LIMIT ?  
		SQL

		restaurants.each { |restaurant| Restaurant.new(restaurant) }
	end

	def self.highly_reviewed_restaurants(min=1)
		restaurants = RestaurantDatabase.execute(<<-SQL,min)
			SELECT restaurant.* 
			  FROM restaurant_review 
			  JOIN restaurant
			    ON restaurant_id = restaurant.id
			  GROUP BY restaurant_id
			  HAVING COUNT(*) >= ?   
		SQL

		restaurants.each { |restaurant| Restaurant.new(restaurant) }
	end

end 

class Critic 
	attr_accessor :id, :screen_name

	def initialize(row)
		@id, @screen_name = row['id'], row['screen_name']
	end

	def self.reviews 
		RestaurantReview.reviews_for_critics(id)
	end 

	def self.average_review_score
		RestaurantReview.average_review_score_critic(id)
	end

	def unreviewed_restaurants(id)
		restaurants = RestaurantDatabase.execute(<<-SQL, id)
			SELECT restaurant.* 
			  FROM restaurant
			 WHERE restaurant.id NOT IN (SELECT restaurant_id
			 							   FROM restaurant_review
			 							  WHERE critic_id = ?)	
		SQL
		restaurants.map{ |restaurant| Restaurant.new(restaurant)}
	end

end 

