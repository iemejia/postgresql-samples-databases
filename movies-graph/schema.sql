-- =============================================================================
-- movies-graph/schema.sql — Movie Graph (Apache AGE)
-- =============================================================================
-- Creates the Apache AGE extension, a graph named "movies", and all vertices
-- (Person and Movie nodes).  Relationships are loaded separately via data.sql.
--
-- Adapted from the Neo4j Movies dataset.  All data is factual (movie titles,
-- actor names, release years) and is not subject to copyright.
--
-- Requirements: PostgreSQL with the Apache AGE extension installed.
-- =============================================================================

-- Install the AGE extension (idempotent)
CREATE EXTENSION IF NOT EXISTS age;

-- Per-session setup required by AGE
LOAD 'age';
SET search_path = ag_catalog, "$user", public;

-- Create the graph
SELECT create_graph('movies');

-- ---------------------------------------------------------------------------
-- Movie nodes (38 movies)
-- ---------------------------------------------------------------------------
SELECT * FROM cypher('movies', $$
CREATE (:Movie {title: 'The Matrix', released: 1999, tagline: 'Welcome to the Real World'})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Movie {title: 'The Matrix Reloaded', released: 2003, tagline: 'Free your mind'})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Movie {title: 'The Matrix Revolutions', released: 2003, tagline: 'Everything that has a beginning has an end'})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Movie {title: 'The Devil\'s Advocate', released: 1997, tagline: 'Evil has its winning ways'})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Movie {title: 'A Few Good Men', released: 1992, tagline: 'In the heart of the nation\'s capital, in a courthouse of the U.S. government, one man will stop at nothing to keep his honor, and one will stop at nothing to find the truth.'})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Movie {title: 'Top Gun', released: 1986, tagline: 'I feel the need, the need for speed.'})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Movie {title: 'Jerry Maguire', released: 2000, tagline: 'The rest of his life begins now.'})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Movie {title: 'Stand By Me', released: 1986, tagline: 'For some, it\'s the last real taste of innocence, and the first real taste of life. But for everyone, it\'s the time that memories are made of.'})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Movie {title: 'As Good as It Gets', released: 1997, tagline: 'A comedy from the heart that goes for the throat.'})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Movie {title: 'What Dreams May Come', released: 1998, tagline: 'After life there is more. The end is just the beginning.'})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Movie {title: 'Snow Falling on Cedars', released: 1999, tagline: 'First loves last. Forever.'})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Movie {title: 'You\'ve Got Mail', released: 1998, tagline: 'At odds in life... in love on-line.'})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Movie {title: 'Sleepless in Seattle', released: 1993, tagline: 'What if someone you never met, someone you never saw, someone you never knew was the only someone for you?'})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Movie {title: 'Joe Versus the Volcano', released: 1990, tagline: 'A story of love, lava and burning desire.'})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Movie {title: 'When Harry Met Sally', released: 1998, tagline: 'Can two friends sleep together and still love each other in the morning?'})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Movie {title: 'That Thing You Do', released: 1996, tagline: 'In every life there comes a time when that thing you dream becomes that thing you do'})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Movie {title: 'The Replacements', released: 2000, tagline: 'Pain heals, Chicks dig scars... Glory lasts forever'})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Movie {title: 'RescueDawn', released: 2006, tagline: 'Based on the extraordinary true story of one man\'s fight for freedom'})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Movie {title: 'The Birdcage', released: 1996, tagline: 'Come as you are'})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Movie {title: 'Unforgiven', released: 1992, tagline: 'It\'s a hell of a thing, killing a man'})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Movie {title: 'Johnny Mnemonic', released: 1995, tagline: 'The hottest data on earth. In the coolest head in town'})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Movie {title: 'Cloud Atlas', released: 2012, tagline: 'Everything is connected'})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Movie {title: 'The Da Vinci Code', released: 2006, tagline: 'Break The Codes'})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Movie {title: 'V for Vendetta', released: 2006, tagline: 'Freedom! Forever!'})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Movie {title: 'Speed Racer', released: 2008, tagline: 'Speed has no limits'})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Movie {title: 'Ninja Assassin', released: 2009, tagline: 'Prepare to enter a secret world of assassins'})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Movie {title: 'The Green Mile', released: 1999, tagline: 'Walk a mile you\'ll never forget.'})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Movie {title: 'Frost/Nixon', released: 2008, tagline: '400 million people were waiting for the truth.'})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Movie {title: 'Hoffa', released: 1992, tagline: 'He didn\'t want law. He wanted justice.'})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Movie {title: 'Apollo 13', released: 1995, tagline: 'Houston, we have a problem.'})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Movie {title: 'Twister', released: 1996, tagline: 'Don\'t Breathe. Don\'t Look Back.'})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Movie {title: 'Cast Away', released: 2000, tagline: 'At the edge of the world, his journey begins.'})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Movie {title: 'One Flew Over the Cuckoo\'s Nest', released: 1975, tagline: 'If he\'s crazy, what does that make you?'})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Movie {title: 'Something\'s Gotta Give', released: 2003})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Movie {title: 'Bicentennial Man', released: 1999, tagline: 'One robot\'s 200 year journey to become an ordinary man.'})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Movie {title: 'Charlie Wilson\'s War', released: 2007, tagline: 'A stiff drink. A little mascara. A lot of nerve. Who said they couldn\'t bring down the Soviet empire.'})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Movie {title: 'The Polar Express', released: 2004, tagline: 'This Holiday Season... Believe'})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Movie {title: 'A League of Their Own', released: 1992, tagline: 'Once in a lifetime you get a chance to do something different.'})
$$) AS (v agtype);

-- ---------------------------------------------------------------------------
-- Person nodes (133 people)
-- ---------------------------------------------------------------------------
SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Keanu Reeves', born: 1964})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Carrie-Anne Moss', born: 1967})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Laurence Fishburne', born: 1961})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Hugo Weaving', born: 1960})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Lilly Wachowski', born: 1967})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Lana Wachowski', born: 1965})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Joel Silver', born: 1952})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Emil Eifrem', born: 1978})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Charlize Theron', born: 1975})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Al Pacino', born: 1940})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Taylor Hackford', born: 1944})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Tom Cruise', born: 1962})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Jack Nicholson', born: 1937})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Demi Moore', born: 1962})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Kevin Bacon', born: 1958})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Kiefer Sutherland', born: 1966})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Noah Wyle', born: 1971})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Cuba Gooding Jr.', born: 1968})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Kevin Pollak', born: 1957})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'J.T. Walsh', born: 1943})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'James Marshall', born: 1967})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Christopher Guest', born: 1948})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Rob Reiner', born: 1947})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Aaron Sorkin', born: 1961})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Kelly McGillis', born: 1957})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Val Kilmer', born: 1959})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Anthony Edwards', born: 1962})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Tom Skerritt', born: 1933})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Meg Ryan', born: 1961})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Tony Scott', born: 1944})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Jim Cash', born: 1941})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Renee Zellweger', born: 1969})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Kelly Preston', born: 1962})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Jerry O\'Connell', born: 1974})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Jay Mohr', born: 1970})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Bonnie Hunt', born: 1961})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Regina King', born: 1971})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Jonathan Lipnicki', born: 1996})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Cameron Crowe', born: 1957})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'River Phoenix', born: 1970})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Corey Feldman', born: 1971})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Wil Wheaton', born: 1972})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'John Cusack', born: 1966})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Marshall Bell', born: 1942})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Helen Hunt', born: 1963})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Greg Kinnear', born: 1963})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'James L. Brooks', born: 1940})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Annabella Sciorra', born: 1960})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Max von Sydow', born: 1929})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Werner Herzog', born: 1942})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Robin Williams', born: 1951})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Vincent Ward', born: 1956})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Ethan Hawke', born: 1970})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Rick Yune', born: 1971})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'James Cromwell', born: 1940})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Scott Hicks', born: 1953})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Tom Hanks', born: 1956})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Parker Posey', born: 1968})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Dave Chappelle', born: 1973})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Steve Zahn', born: 1967})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Nora Ephron', born: 1941})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Rita Wilson', born: 1956})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Bill Pullman', born: 1953})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Victor Garber', born: 1949})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Rosie O\'Donnell', born: 1962})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'John Patrick Stanley', born: 1950})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Nathan Lane', born: 1956})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Billy Crystal', born: 1948})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Carrie Fisher', born: 1956})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Bruno Kirby', born: 1949})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Liv Tyler', born: 1977})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Brooke Langton', born: 1970})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Gene Hackman', born: 1930})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Orlando Jones', born: 1968})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Howard Deutch', born: 1950})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Christian Bale', born: 1974})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Zach Grenier', born: 1954})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Mike Nichols', born: 1931})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Richard Harris', born: 1930})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Clint Eastwood', born: 1930})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Takeshi Kitano', born: 1947})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Dina Meyer', born: 1968})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Ice-T', born: 1958})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Robert Longo', born: 1953})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Halle Berry', born: 1966})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Jim Broadbent', born: 1949})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Tom Tykwer', born: 1965})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'David Mitchell', born: 1969})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Stefan Arndt', born: 1961})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Ian McKellen', born: 1939})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Audrey Tautou', born: 1976})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Paul Bettany', born: 1971})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Ron Howard', born: 1954})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Natalie Portman', born: 1981})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Stephen Rea', born: 1946})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'John Hurt', born: 1940})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Ben Miles', born: 1967})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Emile Hirsch', born: 1985})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'John Goodman', born: 1960})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Susan Sarandon', born: 1946})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Matthew Fox', born: 1966})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Christina Ricci', born: 1980})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Rain', born: 1982})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Naomie Harris'})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Michael Clarke Duncan', born: 1957})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'David Morse', born: 1953})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Sam Rockwell', born: 1968})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Gary Sinise', born: 1955})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Patricia Clarkson', born: 1959})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Frank Darabont', born: 1959})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Frank Langella', born: 1938})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Michael Sheen', born: 1969})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Oliver Platt', born: 1960})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Danny DeVito', born: 1944})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'John C. Reilly', born: 1965})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Ed Harris', born: 1950})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Bill Paxton', born: 1955})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Philip Seymour Hoffman', born: 1967})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Jan de Bont', born: 1943})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Robert Zemeckis', born: 1951})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Milos Forman', born: 1932})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Diane Keaton', born: 1946})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Nancy Meyers', born: 1949})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Chris Columbus', born: 1958})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Julia Roberts', born: 1967})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Madonna', born: 1954})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Geena Davis', born: 1956})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Lori Petty', born: 1963})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Penny Marshall', born: 1943})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Paul Blythe'})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Angela Scope'})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'Jessica Thompson'})
$$) AS (v agtype);

SELECT * FROM cypher('movies', $$
CREATE (:Person {name: 'James Thompson'})
$$) AS (v agtype);
