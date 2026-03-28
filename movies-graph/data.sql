-- =============================================================================
-- movies-graph/data.sql — Movie Graph relationships (Apache AGE)
-- =============================================================================
-- Creates all edges (relationships) between Person and Movie vertices that
-- were loaded in schema.sql.  Uses MATCH to find existing vertices by unique
-- property (name or title) and CREATE to add the edge.
--
-- Edge types:
--   ACTED_IN  — Person acted in a Movie  (property: roles — list of strings)
--   DIRECTED  — Person directed a Movie
--   PRODUCED  — Person produced a Movie
--   WROTE     — Person wrote a Movie
--   REVIEWED  — Person reviewed a Movie  (properties: summary, rating)
--   FOLLOWS   — Person follows a Person
--
-- Adapted from the Neo4j Movies dataset.  All data is factual and is not
-- subject to copyright.
--
-- Requirements: schema.sql must be loaded first (vertices must exist).
-- =============================================================================

-- Per-session setup required by AGE
LOAD 'age';
SET search_path = ag_catalog, "$user", public;

-- ---------------------------------------------------------------------------
-- ACTED_IN relationships (~172 edges)
-- ---------------------------------------------------------------------------

-- The Matrix
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Keanu Reeves'}), (m:Movie {title: 'The Matrix'})
  CREATE (p)-[:ACTED_IN {roles: ['Neo']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Carrie-Anne Moss'}), (m:Movie {title: 'The Matrix'})
  CREATE (p)-[:ACTED_IN {roles: ['Trinity']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Laurence Fishburne'}), (m:Movie {title: 'The Matrix'})
  CREATE (p)-[:ACTED_IN {roles: ['Morpheus']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Hugo Weaving'}), (m:Movie {title: 'The Matrix'})
  CREATE (p)-[:ACTED_IN {roles: ['Agent Smith']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Emil Eifrem'}), (m:Movie {title: 'The Matrix'})
  CREATE (p)-[:ACTED_IN {roles: ['Emil']}]->(m)
$$) AS (e agtype);

-- The Matrix Reloaded
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Keanu Reeves'}), (m:Movie {title: 'The Matrix Reloaded'})
  CREATE (p)-[:ACTED_IN {roles: ['Neo']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Carrie-Anne Moss'}), (m:Movie {title: 'The Matrix Reloaded'})
  CREATE (p)-[:ACTED_IN {roles: ['Trinity']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Laurence Fishburne'}), (m:Movie {title: 'The Matrix Reloaded'})
  CREATE (p)-[:ACTED_IN {roles: ['Morpheus']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Hugo Weaving'}), (m:Movie {title: 'The Matrix Reloaded'})
  CREATE (p)-[:ACTED_IN {roles: ['Agent Smith']}]->(m)
$$) AS (e agtype);

-- The Matrix Revolutions
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Keanu Reeves'}), (m:Movie {title: 'The Matrix Revolutions'})
  CREATE (p)-[:ACTED_IN {roles: ['Neo']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Carrie-Anne Moss'}), (m:Movie {title: 'The Matrix Revolutions'})
  CREATE (p)-[:ACTED_IN {roles: ['Trinity']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Laurence Fishburne'}), (m:Movie {title: 'The Matrix Revolutions'})
  CREATE (p)-[:ACTED_IN {roles: ['Morpheus']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Hugo Weaving'}), (m:Movie {title: 'The Matrix Revolutions'})
  CREATE (p)-[:ACTED_IN {roles: ['Agent Smith']}]->(m)
$$) AS (e agtype);

-- The Devil's Advocate
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Keanu Reeves'}), (m:Movie {title: 'The Devil\'s Advocate'})
  CREATE (p)-[:ACTED_IN {roles: ['Kevin Lomax']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Charlize Theron'}), (m:Movie {title: 'The Devil\'s Advocate'})
  CREATE (p)-[:ACTED_IN {roles: ['Mary Ann Lomax']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Al Pacino'}), (m:Movie {title: 'The Devil\'s Advocate'})
  CREATE (p)-[:ACTED_IN {roles: ['John Milton']}]->(m)
$$) AS (e agtype);

-- A Few Good Men
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Tom Cruise'}), (m:Movie {title: 'A Few Good Men'})
  CREATE (p)-[:ACTED_IN {roles: ['Lt. Daniel Kaffee']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Jack Nicholson'}), (m:Movie {title: 'A Few Good Men'})
  CREATE (p)-[:ACTED_IN {roles: ['Col. Nathan R. Jessup']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Demi Moore'}), (m:Movie {title: 'A Few Good Men'})
  CREATE (p)-[:ACTED_IN {roles: ['Lt. Cdr. JoAnne Galloway']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Kevin Bacon'}), (m:Movie {title: 'A Few Good Men'})
  CREATE (p)-[:ACTED_IN {roles: ['Capt. Jack Ross']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Kiefer Sutherland'}), (m:Movie {title: 'A Few Good Men'})
  CREATE (p)-[:ACTED_IN {roles: ['Lt. Jonathan Kendrick']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Noah Wyle'}), (m:Movie {title: 'A Few Good Men'})
  CREATE (p)-[:ACTED_IN {roles: ['Cpl. Jeffrey Barnes']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Cuba Gooding Jr.'}), (m:Movie {title: 'A Few Good Men'})
  CREATE (p)-[:ACTED_IN {roles: ['Cpl. Carl Hammaker']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Kevin Pollak'}), (m:Movie {title: 'A Few Good Men'})
  CREATE (p)-[:ACTED_IN {roles: ['Lt. Sam Weinberg']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'J.T. Walsh'}), (m:Movie {title: 'A Few Good Men'})
  CREATE (p)-[:ACTED_IN {roles: ['Lt. Col. Matthew Andrew Markinson']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'James Marshall'}), (m:Movie {title: 'A Few Good Men'})
  CREATE (p)-[:ACTED_IN {roles: ['Pfc. Louden Downey']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Christopher Guest'}), (m:Movie {title: 'A Few Good Men'})
  CREATE (p)-[:ACTED_IN {roles: ['Dr. Stone']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Aaron Sorkin'}), (m:Movie {title: 'A Few Good Men'})
  CREATE (p)-[:ACTED_IN {roles: ['Man in Bar']}]->(m)
$$) AS (e agtype);

-- Top Gun
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Tom Cruise'}), (m:Movie {title: 'Top Gun'})
  CREATE (p)-[:ACTED_IN {roles: ['Maverick']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Kelly McGillis'}), (m:Movie {title: 'Top Gun'})
  CREATE (p)-[:ACTED_IN {roles: ['Charlie']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Val Kilmer'}), (m:Movie {title: 'Top Gun'})
  CREATE (p)-[:ACTED_IN {roles: ['Iceman']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Anthony Edwards'}), (m:Movie {title: 'Top Gun'})
  CREATE (p)-[:ACTED_IN {roles: ['Goose']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Tom Skerritt'}), (m:Movie {title: 'Top Gun'})
  CREATE (p)-[:ACTED_IN {roles: ['Viper']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Meg Ryan'}), (m:Movie {title: 'Top Gun'})
  CREATE (p)-[:ACTED_IN {roles: ['Carole']}]->(m)
$$) AS (e agtype);

-- Jerry Maguire
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Tom Cruise'}), (m:Movie {title: 'Jerry Maguire'})
  CREATE (p)-[:ACTED_IN {roles: ['Jerry Maguire']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Cuba Gooding Jr.'}), (m:Movie {title: 'Jerry Maguire'})
  CREATE (p)-[:ACTED_IN {roles: ['Rod Tidwell']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Renee Zellweger'}), (m:Movie {title: 'Jerry Maguire'})
  CREATE (p)-[:ACTED_IN {roles: ['Dorothy Boyd']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Kelly Preston'}), (m:Movie {title: 'Jerry Maguire'})
  CREATE (p)-[:ACTED_IN {roles: ['Avery Bishop']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Jerry O\'Connell'}), (m:Movie {title: 'Jerry Maguire'})
  CREATE (p)-[:ACTED_IN {roles: ['Frank Cushman']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Jay Mohr'}), (m:Movie {title: 'Jerry Maguire'})
  CREATE (p)-[:ACTED_IN {roles: ['Bob Sugar']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Bonnie Hunt'}), (m:Movie {title: 'Jerry Maguire'})
  CREATE (p)-[:ACTED_IN {roles: ['Laurel Boyd']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Regina King'}), (m:Movie {title: 'Jerry Maguire'})
  CREATE (p)-[:ACTED_IN {roles: ['Marcee Tidwell']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Jonathan Lipnicki'}), (m:Movie {title: 'Jerry Maguire'})
  CREATE (p)-[:ACTED_IN {roles: ['Ray Boyd']}]->(m)
$$) AS (e agtype);

-- Stand By Me
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Wil Wheaton'}), (m:Movie {title: 'Stand By Me'})
  CREATE (p)-[:ACTED_IN {roles: ['Gordie Lachance']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'River Phoenix'}), (m:Movie {title: 'Stand By Me'})
  CREATE (p)-[:ACTED_IN {roles: ['Chris Chambers']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Jerry O\'Connell'}), (m:Movie {title: 'Stand By Me'})
  CREATE (p)-[:ACTED_IN {roles: ['Vern Tessio']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Corey Feldman'}), (m:Movie {title: 'Stand By Me'})
  CREATE (p)-[:ACTED_IN {roles: ['Teddy Duchamp']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'John Cusack'}), (m:Movie {title: 'Stand By Me'})
  CREATE (p)-[:ACTED_IN {roles: ['Denny Lachance']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Kiefer Sutherland'}), (m:Movie {title: 'Stand By Me'})
  CREATE (p)-[:ACTED_IN {roles: ['Ace Merrill']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Marshall Bell'}), (m:Movie {title: 'Stand By Me'})
  CREATE (p)-[:ACTED_IN {roles: ['Mr. Lachance']}]->(m)
$$) AS (e agtype);

-- As Good as It Gets
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Jack Nicholson'}), (m:Movie {title: 'As Good as It Gets'})
  CREATE (p)-[:ACTED_IN {roles: ['Melvin Udall']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Helen Hunt'}), (m:Movie {title: 'As Good as It Gets'})
  CREATE (p)-[:ACTED_IN {roles: ['Carol Connelly']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Greg Kinnear'}), (m:Movie {title: 'As Good as It Gets'})
  CREATE (p)-[:ACTED_IN {roles: ['Simon Bishop']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Cuba Gooding Jr.'}), (m:Movie {title: 'As Good as It Gets'})
  CREATE (p)-[:ACTED_IN {roles: ['Frank Sachs']}]->(m)
$$) AS (e agtype);

-- What Dreams May Come
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Robin Williams'}), (m:Movie {title: 'What Dreams May Come'})
  CREATE (p)-[:ACTED_IN {roles: ['Chris Nielsen']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Cuba Gooding Jr.'}), (m:Movie {title: 'What Dreams May Come'})
  CREATE (p)-[:ACTED_IN {roles: ['Albert Lewis']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Annabella Sciorra'}), (m:Movie {title: 'What Dreams May Come'})
  CREATE (p)-[:ACTED_IN {roles: ['Annie Collins-Nielsen']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Max von Sydow'}), (m:Movie {title: 'What Dreams May Come'})
  CREATE (p)-[:ACTED_IN {roles: ['The Tracker']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Werner Herzog'}), (m:Movie {title: 'What Dreams May Come'})
  CREATE (p)-[:ACTED_IN {roles: ['The Face']}]->(m)
$$) AS (e agtype);

-- Snow Falling on Cedars
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Ethan Hawke'}), (m:Movie {title: 'Snow Falling on Cedars'})
  CREATE (p)-[:ACTED_IN {roles: ['Ishmael Chambers']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Rick Yune'}), (m:Movie {title: 'Snow Falling on Cedars'})
  CREATE (p)-[:ACTED_IN {roles: ['Kazuo Miyamoto']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Max von Sydow'}), (m:Movie {title: 'Snow Falling on Cedars'})
  CREATE (p)-[:ACTED_IN {roles: ['Nels Gudmundsson']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'James Cromwell'}), (m:Movie {title: 'Snow Falling on Cedars'})
  CREATE (p)-[:ACTED_IN {roles: ['Judge Fielding']}]->(m)
$$) AS (e agtype);

-- You've Got Mail
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Tom Hanks'}), (m:Movie {title: 'You\'ve Got Mail'})
  CREATE (p)-[:ACTED_IN {roles: ['Joe Fox']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Meg Ryan'}), (m:Movie {title: 'You\'ve Got Mail'})
  CREATE (p)-[:ACTED_IN {roles: ['Kathleen Kelly']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Greg Kinnear'}), (m:Movie {title: 'You\'ve Got Mail'})
  CREATE (p)-[:ACTED_IN {roles: ['Frank Navasky']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Parker Posey'}), (m:Movie {title: 'You\'ve Got Mail'})
  CREATE (p)-[:ACTED_IN {roles: ['Patricia Eden']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Dave Chappelle'}), (m:Movie {title: 'You\'ve Got Mail'})
  CREATE (p)-[:ACTED_IN {roles: ['Kevin Jackson']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Steve Zahn'}), (m:Movie {title: 'You\'ve Got Mail'})
  CREATE (p)-[:ACTED_IN {roles: ['George Pappas']}]->(m)
$$) AS (e agtype);

-- Sleepless in Seattle
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Tom Hanks'}), (m:Movie {title: 'Sleepless in Seattle'})
  CREATE (p)-[:ACTED_IN {roles: ['Sam Baldwin']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Meg Ryan'}), (m:Movie {title: 'Sleepless in Seattle'})
  CREATE (p)-[:ACTED_IN {roles: ['Annie Reed']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Rita Wilson'}), (m:Movie {title: 'Sleepless in Seattle'})
  CREATE (p)-[:ACTED_IN {roles: ['Suzy']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Bill Pullman'}), (m:Movie {title: 'Sleepless in Seattle'})
  CREATE (p)-[:ACTED_IN {roles: ['Walter']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Victor Garber'}), (m:Movie {title: 'Sleepless in Seattle'})
  CREATE (p)-[:ACTED_IN {roles: ['Greg']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Rosie O\'Donnell'}), (m:Movie {title: 'Sleepless in Seattle'})
  CREATE (p)-[:ACTED_IN {roles: ['Becky']}]->(m)
$$) AS (e agtype);

-- Joe Versus the Volcano
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Tom Hanks'}), (m:Movie {title: 'Joe Versus the Volcano'})
  CREATE (p)-[:ACTED_IN {roles: ['Joe Banks']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Meg Ryan'}), (m:Movie {title: 'Joe Versus the Volcano'})
  CREATE (p)-[:ACTED_IN {roles: ['DeDe', 'Angelica Graynamore', 'Patricia Graynamore']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Nathan Lane'}), (m:Movie {title: 'Joe Versus the Volcano'})
  CREATE (p)-[:ACTED_IN {roles: ['Baw']}]->(m)
$$) AS (e agtype);

-- When Harry Met Sally
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Billy Crystal'}), (m:Movie {title: 'When Harry Met Sally'})
  CREATE (p)-[:ACTED_IN {roles: ['Harry Burns']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Meg Ryan'}), (m:Movie {title: 'When Harry Met Sally'})
  CREATE (p)-[:ACTED_IN {roles: ['Sally Albright']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Carrie Fisher'}), (m:Movie {title: 'When Harry Met Sally'})
  CREATE (p)-[:ACTED_IN {roles: ['Marie']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Bruno Kirby'}), (m:Movie {title: 'When Harry Met Sally'})
  CREATE (p)-[:ACTED_IN {roles: ['Jess']}]->(m)
$$) AS (e agtype);

-- That Thing You Do
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Tom Hanks'}), (m:Movie {title: 'That Thing You Do'})
  CREATE (p)-[:ACTED_IN {roles: ['Mr. White']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Liv Tyler'}), (m:Movie {title: 'That Thing You Do'})
  CREATE (p)-[:ACTED_IN {roles: ['Faye Dolan']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Charlize Theron'}), (m:Movie {title: 'That Thing You Do'})
  CREATE (p)-[:ACTED_IN {roles: ['Tina']}]->(m)
$$) AS (e agtype);

-- The Replacements
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Keanu Reeves'}), (m:Movie {title: 'The Replacements'})
  CREATE (p)-[:ACTED_IN {roles: ['Shane Falco']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Brooke Langton'}), (m:Movie {title: 'The Replacements'})
  CREATE (p)-[:ACTED_IN {roles: ['Annabelle Farrell']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Gene Hackman'}), (m:Movie {title: 'The Replacements'})
  CREATE (p)-[:ACTED_IN {roles: ['Jimmy McGinty']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Orlando Jones'}), (m:Movie {title: 'The Replacements'})
  CREATE (p)-[:ACTED_IN {roles: ['Clifford Franklin']}]->(m)
$$) AS (e agtype);

-- RescueDawn
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Marshall Bell'}), (m:Movie {title: 'RescueDawn'})
  CREATE (p)-[:ACTED_IN {roles: ['Admiral']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Christian Bale'}), (m:Movie {title: 'RescueDawn'})
  CREATE (p)-[:ACTED_IN {roles: ['Dieter Dengler']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Zach Grenier'}), (m:Movie {title: 'RescueDawn'})
  CREATE (p)-[:ACTED_IN {roles: ['Squad Leader']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Steve Zahn'}), (m:Movie {title: 'RescueDawn'})
  CREATE (p)-[:ACTED_IN {roles: ['Duane']}]->(m)
$$) AS (e agtype);

-- The Birdcage
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Robin Williams'}), (m:Movie {title: 'The Birdcage'})
  CREATE (p)-[:ACTED_IN {roles: ['Armand Goldman']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Nathan Lane'}), (m:Movie {title: 'The Birdcage'})
  CREATE (p)-[:ACTED_IN {roles: ['Albert Goldman']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Gene Hackman'}), (m:Movie {title: 'The Birdcage'})
  CREATE (p)-[:ACTED_IN {roles: ['Sen. Kevin Keeley']}]->(m)
$$) AS (e agtype);

-- Unforgiven
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Richard Harris'}), (m:Movie {title: 'Unforgiven'})
  CREATE (p)-[:ACTED_IN {roles: ['English Bob']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Clint Eastwood'}), (m:Movie {title: 'Unforgiven'})
  CREATE (p)-[:ACTED_IN {roles: ['Bill Munny']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Gene Hackman'}), (m:Movie {title: 'Unforgiven'})
  CREATE (p)-[:ACTED_IN {roles: ['Little Bill Daggett']}]->(m)
$$) AS (e agtype);

-- Johnny Mnemonic
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Keanu Reeves'}), (m:Movie {title: 'Johnny Mnemonic'})
  CREATE (p)-[:ACTED_IN {roles: ['Johnny Mnemonic']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Takeshi Kitano'}), (m:Movie {title: 'Johnny Mnemonic'})
  CREATE (p)-[:ACTED_IN {roles: ['Takahashi']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Dina Meyer'}), (m:Movie {title: 'Johnny Mnemonic'})
  CREATE (p)-[:ACTED_IN {roles: ['Jane']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Ice-T'}), (m:Movie {title: 'Johnny Mnemonic'})
  CREATE (p)-[:ACTED_IN {roles: ['J-Bone']}]->(m)
$$) AS (e agtype);

-- Cloud Atlas
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Tom Hanks'}), (m:Movie {title: 'Cloud Atlas'})
  CREATE (p)-[:ACTED_IN {roles: ['Zachry', 'Dr. Henry Goose', 'Isaac Sachs', 'Dermot Hoggins']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Hugo Weaving'}), (m:Movie {title: 'Cloud Atlas'})
  CREATE (p)-[:ACTED_IN {roles: ['Bill Smoke', 'Haskell Moore', 'Tadeusz Kesselring', 'Nurse Noakes', 'Boardman Mephi', 'Old Georgie']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Halle Berry'}), (m:Movie {title: 'Cloud Atlas'})
  CREATE (p)-[:ACTED_IN {roles: ['Luisa Rey', 'Jocasta Ayrs', 'Ovid', 'Meronym']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Jim Broadbent'}), (m:Movie {title: 'Cloud Atlas'})
  CREATE (p)-[:ACTED_IN {roles: ['Vyvyan Ayrs', 'Captain Molyneux', 'Timothy Cavendish']}]->(m)
$$) AS (e agtype);

-- The Da Vinci Code
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Tom Hanks'}), (m:Movie {title: 'The Da Vinci Code'})
  CREATE (p)-[:ACTED_IN {roles: ['Dr. Robert Langdon']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Ian McKellen'}), (m:Movie {title: 'The Da Vinci Code'})
  CREATE (p)-[:ACTED_IN {roles: ['Sir Leight Teabing']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Audrey Tautou'}), (m:Movie {title: 'The Da Vinci Code'})
  CREATE (p)-[:ACTED_IN {roles: ['Sophie Neveu']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Paul Bettany'}), (m:Movie {title: 'The Da Vinci Code'})
  CREATE (p)-[:ACTED_IN {roles: ['Silas']}]->(m)
$$) AS (e agtype);

-- V for Vendetta
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Hugo Weaving'}), (m:Movie {title: 'V for Vendetta'})
  CREATE (p)-[:ACTED_IN {roles: ['V']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Natalie Portman'}), (m:Movie {title: 'V for Vendetta'})
  CREATE (p)-[:ACTED_IN {roles: ['Evey Hammond']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Stephen Rea'}), (m:Movie {title: 'V for Vendetta'})
  CREATE (p)-[:ACTED_IN {roles: ['Eric Finch']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'John Hurt'}), (m:Movie {title: 'V for Vendetta'})
  CREATE (p)-[:ACTED_IN {roles: ['High Chancellor Adam Sutler']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Ben Miles'}), (m:Movie {title: 'V for Vendetta'})
  CREATE (p)-[:ACTED_IN {roles: ['Dascomb']}]->(m)
$$) AS (e agtype);

-- Speed Racer
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Emile Hirsch'}), (m:Movie {title: 'Speed Racer'})
  CREATE (p)-[:ACTED_IN {roles: ['Speed Racer']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'John Goodman'}), (m:Movie {title: 'Speed Racer'})
  CREATE (p)-[:ACTED_IN {roles: ['Pops']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Susan Sarandon'}), (m:Movie {title: 'Speed Racer'})
  CREATE (p)-[:ACTED_IN {roles: ['Mom']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Matthew Fox'}), (m:Movie {title: 'Speed Racer'})
  CREATE (p)-[:ACTED_IN {roles: ['Racer X']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Christina Ricci'}), (m:Movie {title: 'Speed Racer'})
  CREATE (p)-[:ACTED_IN {roles: ['Trixie']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Rain'}), (m:Movie {title: 'Speed Racer'})
  CREATE (p)-[:ACTED_IN {roles: ['Taejo Togokahn']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Ben Miles'}), (m:Movie {title: 'Speed Racer'})
  CREATE (p)-[:ACTED_IN {roles: ['Cass Jones']}]->(m)
$$) AS (e agtype);

-- Ninja Assassin
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Rain'}), (m:Movie {title: 'Ninja Assassin'})
  CREATE (p)-[:ACTED_IN {roles: ['Raizo']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Naomie Harris'}), (m:Movie {title: 'Ninja Assassin'})
  CREATE (p)-[:ACTED_IN {roles: ['Mika Coretti']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Rick Yune'}), (m:Movie {title: 'Ninja Assassin'})
  CREATE (p)-[:ACTED_IN {roles: ['Takeshi']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Ben Miles'}), (m:Movie {title: 'Ninja Assassin'})
  CREATE (p)-[:ACTED_IN {roles: ['Ryan Maslow']}]->(m)
$$) AS (e agtype);

-- The Green Mile
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Tom Hanks'}), (m:Movie {title: 'The Green Mile'})
  CREATE (p)-[:ACTED_IN {roles: ['Paul Edgecomb']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Michael Clarke Duncan'}), (m:Movie {title: 'The Green Mile'})
  CREATE (p)-[:ACTED_IN {roles: ['John Coffey']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'David Morse'}), (m:Movie {title: 'The Green Mile'})
  CREATE (p)-[:ACTED_IN {roles: ['Brutus "Brutal" Howell']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Bonnie Hunt'}), (m:Movie {title: 'The Green Mile'})
  CREATE (p)-[:ACTED_IN {roles: ['Jan Edgecomb']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'James Cromwell'}), (m:Movie {title: 'The Green Mile'})
  CREATE (p)-[:ACTED_IN {roles: ['Warden Hal Moores']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Sam Rockwell'}), (m:Movie {title: 'The Green Mile'})
  CREATE (p)-[:ACTED_IN {roles: ['"Wild Bill" Wharton']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Gary Sinise'}), (m:Movie {title: 'The Green Mile'})
  CREATE (p)-[:ACTED_IN {roles: ['Burt Hammersmith']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Patricia Clarkson'}), (m:Movie {title: 'The Green Mile'})
  CREATE (p)-[:ACTED_IN {roles: ['Melinda Moores']}]->(m)
$$) AS (e agtype);

-- Frost/Nixon
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Frank Langella'}), (m:Movie {title: 'Frost/Nixon'})
  CREATE (p)-[:ACTED_IN {roles: ['Richard Nixon']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Michael Sheen'}), (m:Movie {title: 'Frost/Nixon'})
  CREATE (p)-[:ACTED_IN {roles: ['David Frost']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Kevin Bacon'}), (m:Movie {title: 'Frost/Nixon'})
  CREATE (p)-[:ACTED_IN {roles: ['Jack Brennan']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Oliver Platt'}), (m:Movie {title: 'Frost/Nixon'})
  CREATE (p)-[:ACTED_IN {roles: ['Bob Zelnick']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Sam Rockwell'}), (m:Movie {title: 'Frost/Nixon'})
  CREATE (p)-[:ACTED_IN {roles: ['James Reston, Jr.']}]->(m)
$$) AS (e agtype);

-- Hoffa
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Jack Nicholson'}), (m:Movie {title: 'Hoffa'})
  CREATE (p)-[:ACTED_IN {roles: ['Hoffa']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Danny DeVito'}), (m:Movie {title: 'Hoffa'})
  CREATE (p)-[:ACTED_IN {roles: ['Robert "Bobby" Ciaro']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'J.T. Walsh'}), (m:Movie {title: 'Hoffa'})
  CREATE (p)-[:ACTED_IN {roles: ['Frank Fitzsimmons']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'John C. Reilly'}), (m:Movie {title: 'Hoffa'})
  CREATE (p)-[:ACTED_IN {roles: ['Peter "Pete" Connelly']}]->(m)
$$) AS (e agtype);

-- Apollo 13
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Tom Hanks'}), (m:Movie {title: 'Apollo 13'})
  CREATE (p)-[:ACTED_IN {roles: ['Jim Lovell']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Kevin Bacon'}), (m:Movie {title: 'Apollo 13'})
  CREATE (p)-[:ACTED_IN {roles: ['Jack Swigert']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Ed Harris'}), (m:Movie {title: 'Apollo 13'})
  CREATE (p)-[:ACTED_IN {roles: ['Gene Kranz']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Bill Paxton'}), (m:Movie {title: 'Apollo 13'})
  CREATE (p)-[:ACTED_IN {roles: ['Fred Haise']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Gary Sinise'}), (m:Movie {title: 'Apollo 13'})
  CREATE (p)-[:ACTED_IN {roles: ['Ken Mattingly']}]->(m)
$$) AS (e agtype);

-- Twister
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Bill Paxton'}), (m:Movie {title: 'Twister'})
  CREATE (p)-[:ACTED_IN {roles: ['Bill Harding']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Helen Hunt'}), (m:Movie {title: 'Twister'})
  CREATE (p)-[:ACTED_IN {roles: ['Dr. Jo Harding']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Zach Grenier'}), (m:Movie {title: 'Twister'})
  CREATE (p)-[:ACTED_IN {roles: ['Eddie']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Philip Seymour Hoffman'}), (m:Movie {title: 'Twister'})
  CREATE (p)-[:ACTED_IN {roles: ['Dustin "Dusty" Davis']}]->(m)
$$) AS (e agtype);

-- Cast Away
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Tom Hanks'}), (m:Movie {title: 'Cast Away'})
  CREATE (p)-[:ACTED_IN {roles: ['Chuck Noland']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Helen Hunt'}), (m:Movie {title: 'Cast Away'})
  CREATE (p)-[:ACTED_IN {roles: ['Kelly Frears']}]->(m)
$$) AS (e agtype);

-- One Flew Over the Cuckoo's Nest
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Jack Nicholson'}), (m:Movie {title: 'One Flew Over the Cuckoo\'s Nest'})
  CREATE (p)-[:ACTED_IN {roles: ['Randle McMurphy']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Danny DeVito'}), (m:Movie {title: 'One Flew Over the Cuckoo\'s Nest'})
  CREATE (p)-[:ACTED_IN {roles: ['Martini']}]->(m)
$$) AS (e agtype);

-- Something's Gotta Give
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Jack Nicholson'}), (m:Movie {title: 'Something\'s Gotta Give'})
  CREATE (p)-[:ACTED_IN {roles: ['Harry Sanborn']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Diane Keaton'}), (m:Movie {title: 'Something\'s Gotta Give'})
  CREATE (p)-[:ACTED_IN {roles: ['Erica Barry']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Keanu Reeves'}), (m:Movie {title: 'Something\'s Gotta Give'})
  CREATE (p)-[:ACTED_IN {roles: ['Julian Mercer']}]->(m)
$$) AS (e agtype);

-- Bicentennial Man
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Robin Williams'}), (m:Movie {title: 'Bicentennial Man'})
  CREATE (p)-[:ACTED_IN {roles: ['Andrew Marin']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Oliver Platt'}), (m:Movie {title: 'Bicentennial Man'})
  CREATE (p)-[:ACTED_IN {roles: ['Rupert Burns']}]->(m)
$$) AS (e agtype);

-- Charlie Wilson's War
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Tom Hanks'}), (m:Movie {title: 'Charlie Wilson\'s War'})
  CREATE (p)-[:ACTED_IN {roles: ['Rep. Charlie Wilson']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Julia Roberts'}), (m:Movie {title: 'Charlie Wilson\'s War'})
  CREATE (p)-[:ACTED_IN {roles: ['Joanne Herring']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Philip Seymour Hoffman'}), (m:Movie {title: 'Charlie Wilson\'s War'})
  CREATE (p)-[:ACTED_IN {roles: ['Gust Avrakotos']}]->(m)
$$) AS (e agtype);

-- The Polar Express
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Tom Hanks'}), (m:Movie {title: 'The Polar Express'})
  CREATE (p)-[:ACTED_IN {roles: ['Hero Boy', 'Father', 'Conductor', 'Hobo', 'Scrooge', 'Santa Claus']}]->(m)
$$) AS (e agtype);

-- A League of Their Own
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Tom Hanks'}), (m:Movie {title: 'A League of Their Own'})
  CREATE (p)-[:ACTED_IN {roles: ['Jimmy Dugan']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Geena Davis'}), (m:Movie {title: 'A League of Their Own'})
  CREATE (p)-[:ACTED_IN {roles: ['Dottie Hinson']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Lori Petty'}), (m:Movie {title: 'A League of Their Own'})
  CREATE (p)-[:ACTED_IN {roles: ['Kit Keller']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Rosie O\'Donnell'}), (m:Movie {title: 'A League of Their Own'})
  CREATE (p)-[:ACTED_IN {roles: ['Doris Murphy']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Madonna'}), (m:Movie {title: 'A League of Their Own'})
  CREATE (p)-[:ACTED_IN {roles: ['"All the Way" Mae Mordabito']}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Bill Paxton'}), (m:Movie {title: 'A League of Their Own'})
  CREATE (p)-[:ACTED_IN {roles: ['Bob Hinson']}]->(m)
$$) AS (e agtype);

-- ---------------------------------------------------------------------------
-- DIRECTED relationships (~44 edges)
-- ---------------------------------------------------------------------------

-- The Matrix trilogy
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Lilly Wachowski'}), (m:Movie {title: 'The Matrix'})
  CREATE (p)-[:DIRECTED]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Lana Wachowski'}), (m:Movie {title: 'The Matrix'})
  CREATE (p)-[:DIRECTED]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Lilly Wachowski'}), (m:Movie {title: 'The Matrix Reloaded'})
  CREATE (p)-[:DIRECTED]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Lana Wachowski'}), (m:Movie {title: 'The Matrix Reloaded'})
  CREATE (p)-[:DIRECTED]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Lilly Wachowski'}), (m:Movie {title: 'The Matrix Revolutions'})
  CREATE (p)-[:DIRECTED]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Lana Wachowski'}), (m:Movie {title: 'The Matrix Revolutions'})
  CREATE (p)-[:DIRECTED]->(m)
$$) AS (e agtype);

-- The Devil's Advocate
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Taylor Hackford'}), (m:Movie {title: 'The Devil\'s Advocate'})
  CREATE (p)-[:DIRECTED]->(m)
$$) AS (e agtype);

-- A Few Good Men
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Rob Reiner'}), (m:Movie {title: 'A Few Good Men'})
  CREATE (p)-[:DIRECTED]->(m)
$$) AS (e agtype);

-- Top Gun
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Tony Scott'}), (m:Movie {title: 'Top Gun'})
  CREATE (p)-[:DIRECTED]->(m)
$$) AS (e agtype);

-- Jerry Maguire
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Cameron Crowe'}), (m:Movie {title: 'Jerry Maguire'})
  CREATE (p)-[:DIRECTED]->(m)
$$) AS (e agtype);

-- Stand By Me
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Rob Reiner'}), (m:Movie {title: 'Stand By Me'})
  CREATE (p)-[:DIRECTED]->(m)
$$) AS (e agtype);

-- As Good as It Gets
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'James L. Brooks'}), (m:Movie {title: 'As Good as It Gets'})
  CREATE (p)-[:DIRECTED]->(m)
$$) AS (e agtype);

-- What Dreams May Come
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Vincent Ward'}), (m:Movie {title: 'What Dreams May Come'})
  CREATE (p)-[:DIRECTED]->(m)
$$) AS (e agtype);

-- Snow Falling on Cedars
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Scott Hicks'}), (m:Movie {title: 'Snow Falling on Cedars'})
  CREATE (p)-[:DIRECTED]->(m)
$$) AS (e agtype);

-- You've Got Mail
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Nora Ephron'}), (m:Movie {title: 'You\'ve Got Mail'})
  CREATE (p)-[:DIRECTED]->(m)
$$) AS (e agtype);

-- Sleepless in Seattle
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Nora Ephron'}), (m:Movie {title: 'Sleepless in Seattle'})
  CREATE (p)-[:DIRECTED]->(m)
$$) AS (e agtype);

-- Joe Versus the Volcano
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'John Patrick Stanley'}), (m:Movie {title: 'Joe Versus the Volcano'})
  CREATE (p)-[:DIRECTED]->(m)
$$) AS (e agtype);

-- When Harry Met Sally
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Rob Reiner'}), (m:Movie {title: 'When Harry Met Sally'})
  CREATE (p)-[:DIRECTED]->(m)
$$) AS (e agtype);

-- That Thing You Do
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Tom Hanks'}), (m:Movie {title: 'That Thing You Do'})
  CREATE (p)-[:DIRECTED]->(m)
$$) AS (e agtype);

-- The Replacements
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Howard Deutch'}), (m:Movie {title: 'The Replacements'})
  CREATE (p)-[:DIRECTED]->(m)
$$) AS (e agtype);

-- RescueDawn
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Werner Herzog'}), (m:Movie {title: 'RescueDawn'})
  CREATE (p)-[:DIRECTED]->(m)
$$) AS (e agtype);

-- The Birdcage
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Mike Nichols'}), (m:Movie {title: 'The Birdcage'})
  CREATE (p)-[:DIRECTED]->(m)
$$) AS (e agtype);

-- Unforgiven
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Clint Eastwood'}), (m:Movie {title: 'Unforgiven'})
  CREATE (p)-[:DIRECTED]->(m)
$$) AS (e agtype);

-- Johnny Mnemonic
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Robert Longo'}), (m:Movie {title: 'Johnny Mnemonic'})
  CREATE (p)-[:DIRECTED]->(m)
$$) AS (e agtype);

-- Cloud Atlas
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Tom Tykwer'}), (m:Movie {title: 'Cloud Atlas'})
  CREATE (p)-[:DIRECTED]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Lilly Wachowski'}), (m:Movie {title: 'Cloud Atlas'})
  CREATE (p)-[:DIRECTED]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Lana Wachowski'}), (m:Movie {title: 'Cloud Atlas'})
  CREATE (p)-[:DIRECTED]->(m)
$$) AS (e agtype);

-- The Da Vinci Code
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Ron Howard'}), (m:Movie {title: 'The Da Vinci Code'})
  CREATE (p)-[:DIRECTED]->(m)
$$) AS (e agtype);

-- V for Vendetta
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'James Marshall'}), (m:Movie {title: 'V for Vendetta'})
  CREATE (p)-[:DIRECTED]->(m)
$$) AS (e agtype);

-- Speed Racer
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Lilly Wachowski'}), (m:Movie {title: 'Speed Racer'})
  CREATE (p)-[:DIRECTED]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Lana Wachowski'}), (m:Movie {title: 'Speed Racer'})
  CREATE (p)-[:DIRECTED]->(m)
$$) AS (e agtype);

-- Ninja Assassin
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'James Marshall'}), (m:Movie {title: 'Ninja Assassin'})
  CREATE (p)-[:DIRECTED]->(m)
$$) AS (e agtype);

-- The Green Mile
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Frank Darabont'}), (m:Movie {title: 'The Green Mile'})
  CREATE (p)-[:DIRECTED]->(m)
$$) AS (e agtype);

-- Frost/Nixon
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Ron Howard'}), (m:Movie {title: 'Frost/Nixon'})
  CREATE (p)-[:DIRECTED]->(m)
$$) AS (e agtype);

-- Hoffa
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Danny DeVito'}), (m:Movie {title: 'Hoffa'})
  CREATE (p)-[:DIRECTED]->(m)
$$) AS (e agtype);

-- Apollo 13
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Ron Howard'}), (m:Movie {title: 'Apollo 13'})
  CREATE (p)-[:DIRECTED]->(m)
$$) AS (e agtype);

-- Twister
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Jan de Bont'}), (m:Movie {title: 'Twister'})
  CREATE (p)-[:DIRECTED]->(m)
$$) AS (e agtype);

-- Cast Away
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Robert Zemeckis'}), (m:Movie {title: 'Cast Away'})
  CREATE (p)-[:DIRECTED]->(m)
$$) AS (e agtype);

-- One Flew Over the Cuckoo's Nest
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Milos Forman'}), (m:Movie {title: 'One Flew Over the Cuckoo\'s Nest'})
  CREATE (p)-[:DIRECTED]->(m)
$$) AS (e agtype);

-- Something's Gotta Give
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Nancy Meyers'}), (m:Movie {title: 'Something\'s Gotta Give'})
  CREATE (p)-[:DIRECTED]->(m)
$$) AS (e agtype);

-- Bicentennial Man
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Chris Columbus'}), (m:Movie {title: 'Bicentennial Man'})
  CREATE (p)-[:DIRECTED]->(m)
$$) AS (e agtype);

-- Charlie Wilson's War
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Mike Nichols'}), (m:Movie {title: 'Charlie Wilson\'s War'})
  CREATE (p)-[:DIRECTED]->(m)
$$) AS (e agtype);

-- The Polar Express
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Robert Zemeckis'}), (m:Movie {title: 'The Polar Express'})
  CREATE (p)-[:DIRECTED]->(m)
$$) AS (e agtype);

-- A League of Their Own
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Penny Marshall'}), (m:Movie {title: 'A League of Their Own'})
  CREATE (p)-[:DIRECTED]->(m)
$$) AS (e agtype);

-- ---------------------------------------------------------------------------
-- PRODUCED relationships (~15 edges)
-- ---------------------------------------------------------------------------

-- The Matrix trilogy
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Joel Silver'}), (m:Movie {title: 'The Matrix'})
  CREATE (p)-[:PRODUCED]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Joel Silver'}), (m:Movie {title: 'The Matrix Reloaded'})
  CREATE (p)-[:PRODUCED]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Joel Silver'}), (m:Movie {title: 'The Matrix Revolutions'})
  CREATE (p)-[:PRODUCED]->(m)
$$) AS (e agtype);

-- Jerry Maguire
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Cameron Crowe'}), (m:Movie {title: 'Jerry Maguire'})
  CREATE (p)-[:PRODUCED]->(m)
$$) AS (e agtype);

-- When Harry Met Sally
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Rob Reiner'}), (m:Movie {title: 'When Harry Met Sally'})
  CREATE (p)-[:PRODUCED]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Nora Ephron'}), (m:Movie {title: 'When Harry Met Sally'})
  CREATE (p)-[:PRODUCED]->(m)
$$) AS (e agtype);

-- V for Vendetta
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Lilly Wachowski'}), (m:Movie {title: 'V for Vendetta'})
  CREATE (p)-[:PRODUCED]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Lana Wachowski'}), (m:Movie {title: 'V for Vendetta'})
  CREATE (p)-[:PRODUCED]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Joel Silver'}), (m:Movie {title: 'V for Vendetta'})
  CREATE (p)-[:PRODUCED]->(m)
$$) AS (e agtype);

-- Speed Racer
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Joel Silver'}), (m:Movie {title: 'Speed Racer'})
  CREATE (p)-[:PRODUCED]->(m)
$$) AS (e agtype);

-- Ninja Assassin
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Lilly Wachowski'}), (m:Movie {title: 'Ninja Assassin'})
  CREATE (p)-[:PRODUCED]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Lana Wachowski'}), (m:Movie {title: 'Ninja Assassin'})
  CREATE (p)-[:PRODUCED]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Joel Silver'}), (m:Movie {title: 'Ninja Assassin'})
  CREATE (p)-[:PRODUCED]->(m)
$$) AS (e agtype);

-- Something's Gotta Give
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Nancy Meyers'}), (m:Movie {title: 'Something\'s Gotta Give'})
  CREATE (p)-[:PRODUCED]->(m)
$$) AS (e agtype);

-- Cloud Atlas
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Stefan Arndt'}), (m:Movie {title: 'Cloud Atlas'})
  CREATE (p)-[:PRODUCED]->(m)
$$) AS (e agtype);

-- ---------------------------------------------------------------------------
-- WROTE relationships (~10 edges)
-- ---------------------------------------------------------------------------

-- A Few Good Men
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Aaron Sorkin'}), (m:Movie {title: 'A Few Good Men'})
  CREATE (p)-[:WROTE]->(m)
$$) AS (e agtype);

-- Top Gun
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Jim Cash'}), (m:Movie {title: 'Top Gun'})
  CREATE (p)-[:WROTE]->(m)
$$) AS (e agtype);

-- Jerry Maguire
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Cameron Crowe'}), (m:Movie {title: 'Jerry Maguire'})
  CREATE (p)-[:WROTE]->(m)
$$) AS (e agtype);

-- When Harry Met Sally
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Nora Ephron'}), (m:Movie {title: 'When Harry Met Sally'})
  CREATE (p)-[:WROTE]->(m)
$$) AS (e agtype);

-- V for Vendetta
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Lilly Wachowski'}), (m:Movie {title: 'V for Vendetta'})
  CREATE (p)-[:WROTE]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Lana Wachowski'}), (m:Movie {title: 'V for Vendetta'})
  CREATE (p)-[:WROTE]->(m)
$$) AS (e agtype);

-- Speed Racer
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Lilly Wachowski'}), (m:Movie {title: 'Speed Racer'})
  CREATE (p)-[:WROTE]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Lana Wachowski'}), (m:Movie {title: 'Speed Racer'})
  CREATE (p)-[:WROTE]->(m)
$$) AS (e agtype);

-- Cloud Atlas
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'David Mitchell'}), (m:Movie {title: 'Cloud Atlas'})
  CREATE (p)-[:WROTE]->(m)
$$) AS (e agtype);

-- Something's Gotta Give
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Nancy Meyers'}), (m:Movie {title: 'Something\'s Gotta Give'})
  CREATE (p)-[:WROTE]->(m)
$$) AS (e agtype);

-- ---------------------------------------------------------------------------
-- REVIEWED relationships (9 edges)
-- ---------------------------------------------------------------------------

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Jessica Thompson'}), (m:Movie {title: 'Cloud Atlas'})
  CREATE (p)-[:REVIEWED {summary: 'An amazing journey', rating: 95}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Jessica Thompson'}), (m:Movie {title: 'The Replacements'})
  CREATE (p)-[:REVIEWED {summary: 'Silly, but fun', rating: 65}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'James Thompson'}), (m:Movie {title: 'The Replacements'})
  CREATE (p)-[:REVIEWED {summary: 'The coolest football movie ever', rating: 100}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Angela Scope'}), (m:Movie {title: 'The Replacements'})
  CREATE (p)-[:REVIEWED {summary: 'Pretty funny at times', rating: 62}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Jessica Thompson'}), (m:Movie {title: 'Unforgiven'})
  CREATE (p)-[:REVIEWED {summary: 'Dark, but compelling', rating: 85}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Jessica Thompson'}), (m:Movie {title: 'The Birdcage'})
  CREATE (p)-[:REVIEWED {summary: 'Slapstick redeemed only by the Robin Williams and Gene Hackman\'s stellar performances', rating: 45}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Jessica Thompson'}), (m:Movie {title: 'The Da Vinci Code'})
  CREATE (p)-[:REVIEWED {summary: 'A solid romp', rating: 68}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'James Thompson'}), (m:Movie {title: 'The Da Vinci Code'})
  CREATE (p)-[:REVIEWED {summary: 'Fun, but a little far fetched', rating: 65}]->(m)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Jessica Thompson'}), (m:Movie {title: 'Jerry Maguire'})
  CREATE (p)-[:REVIEWED {summary: 'You had me at Jerry', rating: 92}]->(m)
$$) AS (e agtype);

-- ---------------------------------------------------------------------------
-- FOLLOWS relationships (3 edges)
-- ---------------------------------------------------------------------------

SELECT * FROM cypher('movies', $$
  MATCH (p1:Person {name: 'James Thompson'}), (p2:Person {name: 'Jessica Thompson'})
  CREATE (p1)-[:FOLLOWS]->(p2)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p1:Person {name: 'Angela Scope'}), (p2:Person {name: 'Jessica Thompson'})
  CREATE (p1)-[:FOLLOWS]->(p2)
$$) AS (e agtype);

SELECT * FROM cypher('movies', $$
  MATCH (p1:Person {name: 'Paul Blythe'}), (p2:Person {name: 'Angela Scope'})
  CREATE (p1)-[:FOLLOWS]->(p2)
$$) AS (e agtype);
