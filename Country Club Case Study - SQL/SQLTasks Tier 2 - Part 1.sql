In [1]:
/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 1 of the case study, which means that there'll be more guidance for you about how to 
setup your local SQLite connection in PART 2 of the case study. 

The questions in the case study are exactly the same as with Tier 2. 

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:

URL: https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */

SELECT name
FROM Facilities
WHERE membercost > 0;

/* Q2: How many facilities do not charge a fee to members? */

SELECT COUNT(name)
FROM Facilities
WHERE membercost = 0; 

/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT facid, name, membercost,monthlymaintenance
FROM Facilities
WHERE membercost > 0 AND membercost < (.2 * monthlymaintenance)


/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */

SELECT *
FROM Facilities
WHERE facid IN 1,5


/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */

SELECT 
  name, monthlymaintenance, 
  CASE WHEN monthlymaintenance > 100 THEN 'Expensive' WHEN monthlymaintenance <= 100 THEN 'Cheap' END AS pricecategory 
FROM country_club.Facilities;
 

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */

SELECT firstname,surname, joindate
FROM Members
ORDER BY joindate DESC;

/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT DISTINCT (
CONCAT( m.firstName, ' ', m.surname )
) AS membername, f.name
FROM country_club.Members AS m
LEFT JOIN country_club.Bookings AS b ON m.memid = b.memid
LEFT JOIN country_club.Facilities AS f ON f.facid = b.facid
WHERE f.name
IN (
'Tennis Court 1', 'Tennis Court 2'
)
ORDER BY membername
LIMIT 0 , 30

/*Q8: Produce a list of bookings on the day of 2012-09-14 which
#will cost the member (or guest) more than $30. Remember that guests have
#different costs to members (the listed costs are per half-hour 'slot'), and
#the guest user's ID is always 0. Include in your output the name of the
#facility, the name of the member formatted as a single column, and the cost.
#Order by descending cost, and do not use any subqueries. */

SELECT 
  DISTINCT (CONCAT(m.firstName, ' ', m.surname)) AS membername, f.name, 
  CASE WHEN (b.memid = 0 AND (b.slots * f.guestcost > 30)) THEN (b.slots * f.guestcost) ELSE b.slots * f.membercost END AS Cost 
FROM 
  country_club.Bookings AS b 
  LEFT JOIN country_club.Members AS m ON m.memid = b.memid 
  LEFT JOIN country_club.Facilities AS f ON f.facid = b.facid 
WHERE 
  (b.starttime >= '2012-09-14 00:00:00' AND b.starttime <= '2012-09-14 23:59:59') 
  AND CASE WHEN b.memid = 0 THEN (f.guestcost * b.slots) ELSE (f.membercost * b.slots) END > 30 
ORDER BY Cost DESC;


/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT sub3.membername,
       sub3.facilityname,
       sub3.cost
FROM   (SELECT sub2.membername AS membername,
               f.NAME          AS facilityname,
               CASE
                 WHEN sub2.type = 'Member'
                      AND ( sub2.slotnumber * f.membercost > 30 ) THEN
                 sub2.slotnumber * f.membercost
                 WHEN sub2.type = 'Guest'
                      AND ( sub2.slotnumber * f.guestcost > 30 ) THEN
                 sub2.slotnumber * f.guestcost
               END             AS Cost
        FROM   (SELECT DISTINCT ( Concat(m.firstname, ' ', m.surname) ) AS
                                membername,
                                sub1.memid                              AS
                                memberId,
                                sub1.facid                              AS
                                facilityId,
                                sub1.slots                              AS
                                slotNumber,
                                sub1.usertype                           AS Type
                FROM   (SELECT memid,
                               facid,
                               slots,
                               CASE
                                 WHEN memid = 0 THEN 'Guest'
                                 WHEN memid <> 0 THEN 'Member'
                               END AS UserType
                        FROM   country_club.bookings
                        WHERE  starttime >= '2012-09-14 00:00:00'
                               AND starttime <= '2012-09-14 23:59:59') AS sub1
                       LEFT JOIN country_club.members m
                              ON m.memid = sub1.memid) AS sub2
               LEFT JOIN country_club.facilities f
                      ON f.facid = sub2.facilityid) AS sub3
WHERE  sub3.cost > 30
ORDER  BY sub3.cost DESC; 