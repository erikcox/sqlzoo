 -- SQLZOO: The JOIN operation
-- https://sqlzoo.net/wiki/The_JOIN_operation

-- 1. The first example shows the goal scored by a player with the last name 'Bender'. The * says to list all the columns in the table - a shorter way of saying matchid, teamid, player, gtime
-- Modify it to show the matchid and player name for all goals scored by Germany. To identify German players, check for: teamid = 'GER'

SELECT matchid, player
FROM goal
WHERE teamid = 'GER';

-- 2. From the previous query you can see that Lars Bender's scored a goal in game 1012. Now we want to know what teams were playing in that match.
-- Notice in the that the column matchid in the goal table corresponds to the id column in the game table. We can look up information about game 1012 by finding that row in the game table.
--Show id, stadium, team1, team2 for just game 1012

SELECT id, stadium, team1, team2
FROM game
WHERE id = 1012;

-- 3. You can combine the two steps into a single query with a JOIN.
-- SELECT *
--   FROM game JOIN goal ON (id=matchid)
-- The FROM clause says to merge data from the goal table with that from the game table. The ON says how to figure out which rows in game go with which rows in goal - the matchid from goal must match id from game. (If we wanted to be more clear/specific we could say
-- ON (game.id=goal.matchid)
-- The code below shows the player (from the goal) and stadium name (from the game table) for every goal scored.
-- Modify it to show the player, teamid, stadium and mdate for every German goal.

SELECT go.player, go.teamid, gme.stadium, gme.mdate
FROM game gme
JOIN goal go ON (gme.id = go.matchid)
WHERE go.teamid = 'GER';

-- 4. Use the same JOIN as in the previous question.
--Show the team1, team2 and player for every goal scored by a player called Mario player LIKE 'Mario%'

SELECT gme.team1, gme.team2, go.player
FROM game gme
JOIN goal go ON gme.id = go.matchid
WHERE go.player LIKE 'Mario%';

-- 5. The table eteam gives details of every national team including the coach. You can JOIN goal to eteam using the phrase goal JOIN eteam on teamid=id
-- Show player, teamid, coach, gtime for all goals scored in the first 10 minutes gtime<=10

SELECT go.player, go.teamid, et.coach, go.gtime
FROM goal  go
JOIN eteam et ON go.teamid =  et.id
WHERE go.gtime<=10;

-- 6. To JOIN game with eteam you could use either
-- game JOIN eteam ON (team1=eteam.id) or game JOIN eteam ON (team2=eteam.id)
-- Notice that because id is a column name in both game and eteam you must specify eteam.id instead of just id
-- List the dates of the matches and the name of the team in which 'Fernando Santos' was the team1 coach.

SELECT gme.mdate, et.teamname
FROM game gme
JOIN eteam et ON et.id = gme.team1
WHERE et.coach =  'Fernando Santos'
AND et.id = gme.team1;

-- 7. List the player for every goal scored in a game where the stadium was 'National Stadium, Warsaw'

SELECT go.player
FROM goal go
JOIN game gme ON gme.id = go.matchid
WHERE gme.stadium = 'National Stadium, Warsaw';

-- 8. The example query shows all goals scored in the Germany-Greece quarterfinal.
-- Instead show the name of all players who scored a goal against Germany.

SELECT DISTINCT go.player
FROM game gme JOIN goal go ON gme.id = go.matchid
WHERE (gme.team1='GER' OR gme.team2='GER')
AND go.teamid <> 'GER';

-- 9. Show teamname and the total number of goals scored.
-- COUNT and GROUP BY

SELECT et.teamname, COUNT(go.teamid) AS num_goals
FROM eteam et JOIN goal go ON et.id=go.teamid
GROUP BY et.teamname
ORDER BY et.teamname;
 
-- 10. Show the stadium and the number of goals scored in each stadium.

SELECT gme.stadium, COUNT(go.matchid) AS goal_count
FROM game gme
JOIN goal go ON gme.id = go.matchid
GROUP BY gme.stadium
ORDER BY gme.stadium;

-- 11. For every match involving 'POL', show the matchid, date and the number of goals scored.

SELECT go.matchid, gme.mdate,COUNT(gme.id) AS goals_scored
FROM game gme 
JOIN goal go ON go.matchid = gme.id 
WHERE (gme.team1 = 'POL' OR gme.team2 = 'POL')
GROUP BY gme.id;

-- 12. For every match where 'GER' scored, show matchid, match date and the number of goals scored by 'GER'

SELECT go.matchid, gme.mdate,  COUNT(go.matchid) AS goals_scored
FROM goal go
JOIN game gme ON go.matchid = gme.id
GROUP BY go.matchid, go.teamid
HAVING go.teamid = 'GER';

-- 13. List every match with the goals scored by each team as shown. This will use "CASE WHEN" which has not been explained in any previous exercises.
-- Notice in the query given every goal is listed. If it was a team1 goal then a 1 appears in score1, otherwise there is a 0. You could SUM this column to get a count of the goals scored by team1. Sort your result by mdate, matchid, team1 and team2.
-- NOTE: Must use LEFT JOIN instead of just JOIN to account for 0-0 matches.

SELECT mdate,
  team1,
  SUM(CASE WHEN teamid=team1 THEN 1 ELSE 0 END) score1,
  team2,
  SUM(CASE WHEN teamid=team2 THEN 1 ELSE 0 END) score2
FROM game LEFT JOIN goal ON goal.matchid = game.id
GROUP BY game.id
ORDER BY mdate, matchid, team1, team2;