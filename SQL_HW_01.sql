-- SQL Homework

use sakila;

-- 1a. Display the first and last names of all actors from the table actor.
select 
    first_name, last_name
from
    actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT 
    CONCAT(first_name, ' ', last_name) AS 'Actor Name'
FROM
    actor;


-- --2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
--    What is one query would you use to obtain this information?
select 
    actor_id, first_name, last_name
from
    actor
	Where first_name = "Joe";


-- --2b. Find all actors whose last name contain the letters GEN:
select 
    actor_id, first_name, last_name
from
    actor
	Where last_name like "%GEN%";


-- --2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
select 
    first_name, last_name
from
    actor
	Where last_name like "%LI%"
    order by last_name, first_name;


-- --2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
Select * from country
	where country in (
    "Afghanistan", 
    "Bangladesh",
    "China"
);

-- --3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, 
-- --    so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, 
-- --    as the difference between it and VARCHAR are significant).
alter table actor
add description BLOB;


-- --3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
alter table actor
drop description;

-- --4a. List the last names of actors, as well as how many actors have that last name.
select last_name, count(last_name)
from
    actor
    group by last_name;

-- --4b. List last names of actors and the number of actors who have that last name, but only for names that are 
-- --    shared by at least two actors
select last_name, count(last_name)
from
    actor
    group by last_name
    Having count(last_name) >= 2;

-- --4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. 
-- --    Write a query to fix the record.
update actor 
set 
    first_name = 'HARPO'
where
    first_name = 'GROUCHO'
	and last_name = 'WILLIAMS';

-- --4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! 
-- --    In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
update actor 
set 
    first_name = 'GROUCHO'
where
    first_name = 'HARPO';

-- --5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
-- --Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html
Create table address (
	address_id smallint(5) Auto_increment,
    address1 Varchar(50) not null,
    address2 Varchar(50),
    district varchar(20) not null,
    city_id varchar(5),
    postal_code varchar(10),
    phone varchar(20) not null,
    location geometry not null,
    last_update timestamp,
    primary key (address_id)
    );

-- --6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
select 
    first_name,
    last_name,
    address,
    address2,
    district,
    city_id,
    postal_code
		from address addr
        join staff staff
        on (staff.address_id = addr.address_id);

-- --6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment
select first_name, last_name, sum(amount)
	from payment pmt
    join staff staff
    on (staff.staff_id = pmt.staff_id)
    where payment_date between "2005-08-01" and "2005-08-31"
    group by first_name, last_name;
    
-- --6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
select title, count(actor_id)
	from film film
    join film_actor actor
    on (film.film_id = actor.film_id)
    group by title;

-- --6d. How many copies of the film Hunchback Impossible exist in the inventory system?
select title, count(inventory_id)
	from film film
    join inventory inv
    on (film.film_id = inv.film_id)
    where title = "Hunchback Impossible"
    group by title;
    
-- --6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. 
-- --    List the customers alphabetically by last name:
select first_name "First Name",
	   last_name "Last Name",
       sum(amount) "Total Paid"
	from customer cust
    join payment pmt
    on (cust.customer_id = pmt.customer_id)
    group by first_name, last_name
    order by last_name;

-- --7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence,
-- --    films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles
-- --    of movies starting with the letters K and Q whose language is English.

select title
	from film flm
    join language lang
    on (flm.language_id = lang.language_id)
	Where title like "K%" 
		or title like "Q%"
		and flm.language_id in (
		select lang.language_id 
		where lang.name in ("English"))
	order by title;
    
-- --7b. Use subqueries to display all actors who appear in the film Alone Trip.

select act.actor_id, act.first_name, act.last_name
	from actor act
    join film_actor flma
    on (act.actor_id = flma.actor_id)
    Where flma.actor_id in (
		Select flma.actor_id
		from film_actor flma
        join film flm
        on (flm.film_id = flma.film_id)
		where flm.film_id in (
			select film_id
			from film flm
			where flm.title = "Alone Trip"))
	Group by act.actor_id, act.first_name, act.last_name;


-- --7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all 
-- --    Canadian customers. Use joins to retrieve this information.
select cst.first_name, cst.last_name, cst.email
	from customer cst
	inner join address addr
		on (cst.address_id = addr.address_id)
	inner join city cty
		on (addr.city_id = cty.city_id)
	inner join country cnt
		on (cty.country_id = cnt.country_id)
	where cnt.country = "Canada";

-- --7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion.
-- --    Identify all movies categorized as family films.
select title
	from film flm
    inner join film_category flmc
		on (flm.film_id = flmc.film_id)
	inner join category cat
		on (flmc.category_id = cat.category_id)
	where cat.name = "Family";

-- --7e. Display the most frequently rented movies in descending order.
select flm.title, count(rnt.rental_id) "Rental Count"
	from film flm
    inner join inventory inv
		on (flm.film_id = inv.film_id)
    inner join rental rnt
		on (rnt.inventory_id = inv.inventory_id)
	group by title
    order by count(rnt.rental_id) desc
    limit 10;

-- --7f. Write a query to display how much business, in dollars, each store brought in.
select str.store_id, sum(pmt.amount) Sales
	from store str
    inner join staff stf
		on (str.store_id = stf.store_id)
	inner join payment pmt
		on (stf.staff_id = pmt.staff_id)
	Group by str.store_id;

-- --7g. Write a query to display for each store its store ID, city, and country.
select str.store_id, cty.city, cnt.country
	from store str
    inner join address adr
		on (str.address_id = adr.address_id)
	inner join city cty
		on (cty.city_id = adr.city_id)
	inner join country cnt
		on (cnt.country_id = cty.country_id)
	Group by str.store_id, cty.city_id, cnt.country;

-- --7h. List the top five genres in gross revenue in descending order. 
-- --    (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
select cat.name "Category", sum(pmt.amount) "Sales"
	from category cat
    inner join film_category fcat
		on (fcat.category_id = cat.category_id)
	inner join inventory inv
		on (inv.film_id = fcat.film_id)
	inner join rental rnt
		on (rnt.inventory_id = inv.inventory_id)
	inner join payment pmt
		on (pmt.rental_id = rnt.rental_id)
	group by cat.name
    order by sum(pmt.amount) desc
    limit 5;

-- --8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- --    Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute 
-- --    another query to create a view.
create view sales_report as
select cat.name "Category", sum(pmt.amount) "Sales"
	from category cat
    inner join film_category fcat
		on (fcat.category_id = cat.category_id)
	inner join inventory inv
		on (inv.film_id = fcat.film_id)
	inner join rental rnt
		on (rnt.inventory_id = inv.inventory_id)
	inner join payment pmt
		on (pmt.rental_id = rnt.rental_id)
	group by cat.name
    order by sum(pmt.amount) desc
    limit 5;

-- --8b. How would you display the view that you created in 8a?
select * from sales_report;

-- --8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
drop view sales_report;

