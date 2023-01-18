
CREATE OR REPLACE PROCEDURE spRostersInsert(
    playerId rosters.playerId%type,
    teamId rosters.teamid%type,
    active rosters.isActive%type,
    jerseyNum rosters.jerseynumber%type,
    roasterId OUT rosters.rosterId%type,
    errCode OUT number)
AS
BEGIN
    SELECT max(rosterID) + 1
    INTO roasterId
    FROM rosters;
 
    INSERT INTO rosters (rosterId, playerId, teamId, isActive, jerseynumber)
    VALUES (roasterId , playerId, teamId, active, jerseyNum);
    EXCEPTION
 WHEN OTHERS
 THEN errCode := -3;
END spRostersInsert;

-- UPDATE
CREATE OR REPLACE PROCEDURE spRostersUpdate(
     idNo rosters.rosterId%type,
     pId rosters.playerId%type,
     tId rosters.teamid%type,
     active rosters.isActive%type,
     jNum rosters.jerseynumber%type,
     errCode OUT number)
AS
BEGIN
     UPDATE rosters
     SET playerId = pID,
     teamId = tId,
     isActive = active,
     jerseynumber = jNum
     WHERE rosterID = idNo;
EXCEPTION
     WHEN NO_DATA_FOUND
     THEN errCode := -1;
     WHEN TOO_MANY_ROWS
     THEN errCode := -2;
     WHEN OTHERS
     THEN errCode := -3;
END spRostersUpdate;
-- DELETE
CREATE OR REPLACE PROCEDURE spRostersDelete(
     idNo numeric,
     errCode OUT number) AS
BEGIN
     DELETE FROM rosters
     WHERE rosterID = idNo;
EXCEPTION
     WHEN NO_DATA_FOUND
     THEN errCode := -1;
     WHEN TOO_MANY_ROWS
     THEN errCode := -2;
     WHEN OTHERS
     THEN errCode := -3;
END spRostersDelete;
-- SELECT
CREATE OR REPLACE PROCEDURE spRostersSelect(
     idNo IN numeric,
     r OUT rosters%rowtype,
     errCode OUT number) AS
BEGIN
     SELECT *
     INTO r
     FROM rosters
     WHERE rosterID = idNo;
EXCEPTION
     WHEN NO_DATA_FOUND
     THEN errCode := -1;
     WHEN TOO_MANY_ROWS
     THEN errCode := -2;
     WHEN OTHERS
     THEN errCode := -3;
END spRostersSelect;
