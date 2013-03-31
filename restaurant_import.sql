CREATE TABLE chef (
	id INTEGER PRIMARY KEY,
	first_name VARCHAR(255) NOT NULL,
	last_name VARCHAR(255)  NOT NULL,
	mentor VARCHAR(255)
);

CREATE TABLE restaurant (
	id INTEGER PRIMARY KEY,
	name VARCHAR(255) NOT NULL,
	neighborhood VARCHAR(255) NOT NULL,
	cuisine VARCHAR(50) NOT NULL
);

CREATE TABLE chef_tenure (
	id INTEGER PRIMARY KEY,
	chef_id INTEGER,
	start_date TEXT(20),
	end_date TEXT(20),
	head_chef INTEGER,
	restaurant_id INTEGER,

	FOREIGN KEY(chef_id) REFERENCES chef(id),
	FOREIGN KEY(restaurant_id) REFERENCES restaurant(id)
);

CREATE TABLE critic (
	id INTEGER PRIMARY KEY,
	screen_name VARCHAR(50)
);

CREATE TABLE restaurant_review (
	text_review TEXT(255) NOT NULL,
	score INTEGER NOT NULL,
	date_of_review NOT NULL,
	restaurant_id NOT NULL,
	critic_id NOT NULL,

	FOREIGN KEY(restaurant_id) REFERENCES restaurant(id),
	FOREIGN	KEY(critic_id) REFERENCES critic(id)
);

INSERT INTO chef ('first_name', 'last_name', 'mentor')
	 VALUES	('fname1', "lname1", NULL),
	 		('fname2', 'lname2', 1),
	 		('fname3', 'lname3', 1),
	 		('fname4', 'lname4', 2),
	 		('fname5', 'lname5', 2),
	 		('fname6', 'lname6', 3);

INSERT INTO restaurant ('name', 'neighborhood', 'cuisine')
	 VALUES	('restaurant1', 'neighborhood1', 'thai'),
	 		('restaurant2', 'neighborhood2', 'chinese'),
	 		('restaurant3', 'neighborhood3', 'seafood'),
	 		('restaurant4', 'neighborhood4', 'breakfast'),
	 		('restaurant5', 'neighborhood5', 'mexican'),
	 		('restaurant6', 'neighborhood6', 'indian'),
	 		('restaurant7', 'neighborhood1', 'chinese');

INSERT INTO chef_tenure ('chef_id', 'start_date', 'end_date', 'head_chef', 'restaurant_id')
	 VALUES	(1, '2012-01-01', '2013-01-01', 0, 3),
	 		(2, '2013-02-01', '2013-05-01', 1, 3),
	 		(3, '2012-06-01', '2013-08-01', 1, 3);

INSERT INTO critic ('screen_name')
	 VALUES	('SN1'),
	 		('SN2'),
	 		('SN3');
	 			
INSERT INTO restaurant_review ('text_review', 'score', 'date_of_review', 'restaurant_id', 'critic_id')
	 VALUES	('nice', 15, '2013-03-15', 1 , 1),
	 		('disgusting', 5, '2013-06-15', 2, 2),
	 		('savory', 18,'2013-03-01', 3, 3),
	 		('ok', 10,'2012-10-01', 3, 1);

