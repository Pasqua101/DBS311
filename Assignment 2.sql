--Handling Players and Teams Tables

SET SERVEROUTPUT ON;

--Task 1 Create CRUD statements for Players and Teams

CREATE OR REPLACE PROCEDURE spPlayersInsert(
    l_playerID IN OUT players.playerid%TYPE,
    l_regNum IN players.regNumber%TYPE,
    l_lName IN players.lastname%TYPE,
    l_fName IN players.firstname%TYPE,
    active IN players.isactive%TYPE,
    exitCode IN OUT INT
) AS
BEGIN
    SELECT MAX(playerID) + 1
    INTO l_playerID
    FROM players;
    
    INSERT INTO players (playerID, regnumber, lastname, firstname, isactive)
    VALUES (l_playerID, l_regNum, l_lName, l_fName, active);
EXCEPTION
 WHEN OTHERS
    THEN 
        exitCode := -3;  
END spPlayersINSERT;

--executing it
DECLARE
    l_id players.playerid%type := 0;
    l_regNum players.regnumber%type := :l_regNum;
    l_lName players.lastname%type := :l_lName;
    l_fName players.firstname%type := :l_fName;
    l_active players.isActive%type := :l_active;  
    exitCode INT := 0;
BEGIN
    spPlayersInsert(l_id, l_regNum, l_lName, l_fName, l_active, exitCode);
    IF exitCode != 0
        THEN
            DBMS_OUTPUT.PUT_LINE('ERROR: ' || exitCode);
    ELSE
        DBMS_OUTPUT.PUT_LINE('Player created successfully! With an ID of ' || l_id);
        DBMS_OUTPUT.PUT_LINE('Exit with code: ' || exitCode);
    END IF;
END; 

CREATE OR REPLACE PROCEDURE spTeamsInsert(
    l_teamID  IN OUT teams.teamid%TYPE,
    l_teamname IN teams.teamname%TYPE,
    l_active IN teams.isactive%TYPE,
    l_colour IN teams.jerseycolour%TYPE,
    exitCode IN OUT INT
) AS
BEGIN

    SELECT MAX(teamID) + 1
    INTO l_teamID
    FROM teams;
    
    INSERT INTO teams (teamid, teamname, isactive, jerseycolour) 
    VALUES (l_teamID, l_teamname, l_active, l_colour);
EXCEPTION
WHEN OTHERS
    THEN
        exitCode := 3;
END spTeamsInsert;

--Executing it
DECLARE
    l_id teams.teamid%type := 0;
    l_teamname teams.teamname%type := :l_teamName;
    l_active teams.isActive%type := :l_active;  
    l_colour teams.jerseycolour%type := :l_colour;
    exitCode INT := 0;
BEGIN
    spTeamsInsert(l_id, l_teamName, l_active, l_colour, exitCode);
    IF exitCode != 0
        THEN
            DBMS_OUTPUT.PUT_LINE('ERROR: ' || exitCode);
    ELSE
        DBMS_OUTPUT.PUT_LINE('Player created successfully! With an ID of ' || l_id);
        DBMS_OUTPUT.PUT_LINE('Exit with code: ' || exitCode);
    END IF;
END; 

--Select procedure

CREATE OR REPLACE PROCEDURE spPlayersSelect(
    playerIDParam IN players.playerid%TYPE,
    row IN OUT players%ROWTYPE,
    exitCode IN OUT INT
) AS 
BEGIN

    SELECT *
    INTO row
    FROM players
    WHERE playerid = playerIDParam;
EXCEPTION
    WHEN NO_DATA_FOUND
        THEN
            exitCode := -1;
    WHEN OTHERS
        THEN
            exitCode := -3;
END spPlayersSelect;

--Executing it
DECLARE
    searchID players.playerid%TYPE := &playerID;
    playerInfo players%ROWTYPE;
    exitCode INT := 0;
BEGIN 
    spPlayersSelect(searchID, playerInfo, exitCode); --takes in a playerID to search by and a variable that holds the rowtype of the players table. Stores the returned values in the playerInfo variable and outputs it
    IF exitCode != 0
        THEN
            DBMS_OUTPUT.PUT_LINE('ERROR: ' || exitCode || ' Please refer to the User Guide');
    ELSE
            DBMS_OUTPUT.PUT_LINE('Player ID: ' || playerInfo.playerID);
            DBMS_OUTPUT.PUT_LINE('First Name: ' || playerInfo.firstname);
            DBMS_OUTPUT.PUT_LINE('Last Name: ' || playerInfo.lastname);
            DBMS_OUTPUT.PUT_LINE('Reg Number: ' || playerInfo.regNumber);
            DBMS_OUTPUT.PUT_LINE('Is Active: ' || playerInfo.isActive);    
            DBMS_OUTPUT.PUT_LINE('Exited procedure with : ' || exitCode);
    END IF;
END;

CREATE OR REPLACE PROCEDURE spTeamsSelect(
    teamIDParam IN teams.teamid%TYPE,
    row IN OUT teams%ROWTYPE,
    exitCode IN OUT INT
) AS
BEGIN
    SELECT *
    INTO row
    FROM teams
    WHERE teamid = teamIDParam;

EXCEPTION
    WHEN NO_DATA_FOUND
        THEN
            exitCode := -1;
    WHEN OTHERS
        THEN
            exitCode := -3;

END spTeamsSelect;

--Execute it
DECLARE
    searchForTeamID teams.teamid%TYPE :=&teamID;
    teamInfo teams%ROWTYPE;
    exitCode INT := 0;
BEGIN
    spTeamsSelect(searchForTeamID, teamInfo, exitCode);
    IF exitCode != 0 
        THEN
            DBMS_OUTPUT.PUT_LINE('ERROR: ' || exitCode || ' Please refer to the User Guide');
    ELSE
        DBMS_OUTPUT.PUT_LINE('TeamID: ' || teamInfo.teamid);
        DBMS_OUTPUT.PUT_LINE('Team name: ' || teamInfo.teamname);
        DBMS_OUTPUT.PUT_LINE('Is Active: ' || teamInfo.isactive);
        DBMS_OUTPUT.PUT_LINE('Jersey Colour: ' || teamInfo.jerseycolour); 
    END IF;
END;
--Delete procedure
CREATE OR REPLACE PROCEDURE spPlayersDelete(
    l_playerID IN players.playerID%TYPE,
    exitCode IN OUT INT
) AS
BEGIN
    DELETE 
    FROM players
    WHERE playerid =  l_playerID;
    
    IF sql%rowcount = 0 
        THEN 
            exitCode := -1;
    ELSE IF sql%ROWCOUNT > 1
        THEN
            exitCode := -4;
    ELSE 
        exitCode:= 0;
    END IF;
    END IF;

END spPlayersDelete;
--Execute it
DECLARE
    deletePlayer players.playerid%type := &deletePlayer;
    exitCode INT := 0;
BEGIN
    spPlayersDelete(deletePlayer, exitCode);
    
    IF exitCode != 0
        THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || exitCode);
    ELSE
        DBMS_OUPUT.PUT_LINE('Player deleted successfully');
        DBMS_OUTPUT.PUT_LINE('Exited procedure with : ' || exitCode);
END;

CREATE OR REPLACE PROCEDURE spTeamsDelete(
    l_teamid IN teams.teamid%type,
    exitCode IN OUT INT
) AS
BEGIN
    DELETE 
    FROM teams
    WHERE teamid = l_teamid;

    IF sql%rowcount = 0 
        THEN 
            exitCode := -1;
    ELSE 
        exitCode := 0;
    END IF;

END spTeamsDelete;

--Execute it
DECLARE
    deleteTeam teams.teamid%type :=  &deleteTeam;
    exitCode INT := 0;
BEGIN
    spTeamsDelete(deleteTeam, exitCode);
    IF exitCode != 0
        THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || exitCode);
    ELSE
        DBMS_OUTPUT.PUT_LINE('Team deleted successfully');
    END IF;
END;

--Update procedure

CREATE OR REPLACE PROCEDURE spPlayersUpdate(
    l_playerID IN players.playerid%type,
    newRegNum IN players.regnumber%type,
    newLName IN players.lastname%type,
    newFName IN players.firstname%type,
    newIsActive IN players.isActive%type,
    exitCode IN OUT INT
) AS
BEGIN
    UPDATE players
    SET regnumber = newRegNum,
        lastname = newLName,
        firstname = newFName,
        isActive = newIsActive
    WHERE playerid = l_playerID;

EXCEPTION
    WHEN NO_DATA_FOUND
        THEN
            exitCode := -1;
    WHEN OTHERS
        THEN
            exitCode:= -3;

END spPlayersUpdate;

--Executing it
DECLARE
    l_playerID players.playerID%TYPE := :l_playerID;
    l_regNum players.regnumber%TYPE := :l_regNum;
    lName players.lastname%TYPE := :lName;
    fName players.firstname%TYPE := :fName;
    active players.isactive%TYPE := :active;
    exitCode INT := 0;
BEGIN
    spPlayersUpdate(l_playerID, l_regNum, lname, fname, active, exitCode);
    IF exitCode != 0
        THEN
            DBMS_OUTPUT.PUT_LINE('ERROR: ' || exitCode);
    ELSE
        DBMS_OUTPUT.PUT_LINE('Updated player!');
    END IF;
END;


CREATE OR REPLACE PROCEDURE spTeamsUpdate(
    l_teamID IN teams.teamid%TYPE,
    l_name IN teams.teamname%TYPE,
    l_active IN teams.isactive%TYPE,
    l_colour IN teams.jerseycolour%TYPE,
    exitCode IN OUT INT
) AS
BEGIN

    UPDATE teams
    SET teamname = l_name,
    isactive = l_active,
    jerseycolour = l_colour
    WHERE teamid = l_teamID;
EXCEPTION
    WHEN NO_DATA_FOUND
        THEN 
            exitCode:= -1;
    WHEN OTHERS
        THEN
            exitCode := -3;
END spTeamsUpdate;

--Execute it
DECLARE

    l_teamid teams.teamid%TYPE := :l_teamid;
    l_name teams.teamname%TYPE := :l_name;
    l_active teams.isactive%TYPE := :l_active;
    l_colour teams.jerseycolour%TYPE := :l_colour;
    exitCode INT := 0;
BEGIN

    spTeamsUpdate(l_teamid, l_name, l_active, l_colour, exitCode);
    IF exitCode != 0
        THEN
            DBMS_OUTPUT.PUT_LINE('ERROR: ' || exitCode);
    ELSE
        DBMS_OUTPUT.PUT_LINE('Team updated succesfully!');
    END IF;
END;


--Task 2, select ALL for 2 tables
CREATE OR REPLACE PROCEDURE spTeamsSelectAll
AS 
BEGIN
DECLARE
    l_teamID teams.teamid%TYPE;
    l_name teams.teamname%TYPE;
    l_active teams.isactive%TYPE;
    l_colour teams.jerseycolour%TYPE;
    CURSOR c1 IS
        SELECT *
        FROM teams;
BEGIN
    OPEN c1;
    LOOP
        FETCH c1 INTO l_teamID, l_name, l_active, l_colour;
        IF c1%FOUND
            THEN
                DBMS_OUTPUT.PUT_LINE('TeamID: ' || l_teamID);
                DBMS_OUTPUT.PUT_LINE('Team Name: ' || l_name);
                DBMS_OUTPUT.PUT_LINE('isActive: ' || l_active);
                DBMS_OUTPUT.PUT_LINE('Jersey Colour: ' || l_colour);
                DBMS_OUTPUT.PUT_LINE('');
                --MAY Change the output later
        ELSE
            EXIT;
        END IF;
    END LOOP;
    CLOSE c1;
EXCEPTION
    WHEN OTHERS
        THEN DBMS_OUTPUT.PUT_LINE('ERROR CODE: -3');
END;
END spTeamsSelectAll;
--Executing it

BEGIN
    spTeamsSelectAll;    
END;

CREATE OR REPLACE PROCEDURE spPlayersSelectAll
AS
BEGIN
DECLARE
    l_playerid players.playerid%TYPE;
    l_regnum players.regnumber%TYPE;
    l_lName players.lastname%TYPE;
    l_fName players.firstname%TYPE;
    l_active players.isactive%TYPE;
    CURSOR c1 IS
        SELECT * 
        FROM players;
        
BEGIN
    OPEN c1;
        LOOP 
            FETCH c1 INTO l_playerid, l_regnum, l_lName, l_fName, l_active;
            IF c1%FOUND
                THEN
                    DBMS_OUTPUT.PUT_LINE('Player ID: ' || l_playerid);
                    DBMS_OUTPUT.PUT_LINE('Reg Number: ' || l_regnum);
                    DBMS_OUTPUT.PUT_LINE('Last Name: ' || l_lName);
                    DBMS_OUTPUT.PUT_LINE('First Name: ' || l_fName);
                    DBMS_OUTPUT.PUT_LINE('Is Active: ' || l_active);
                    DBMS_OUTPUT.PUT_LINE('');
            ELSE
                EXIT;
            END IF;
        END LOOP;
    CLOSE c1;
    DBMS_OUTPUT.PUT_LINE('Exited with 0');
EXCEPTION
    WHEN OTHERS
        THEN
            DBMS_OUTPUT.PUT_LINE('Error Code: -3');
END;
END spPlayersSelectAll;

BEGIN
    spPlayersSelectAll;
END;


--Task 3
CREATE VIEW vwPlayerRosters AS
SELECT p.playerid AS playerID,
      p.isactive AS playerActive,
     firstname,
     lastname,
     rosterid,
     r.isactive AS rosterActive,
     t.teamid AS teamid,
     teamname,
     t.isactive As teamActive,
     jerseycolour
FROM players p
JOIN rosters r ON p.playerid = r.playerid
JOIN teams t ON r.teamid = t.teamid;

SELECT * FROM vwPlayerRosters;


--Task 4
CREATE OR REPLACE PROCEDURE spTeamRosterByID(
    findTeamID IN OUT teams.teamid%TYPE
) AS
BEGIN 
DECLARE
    l_fName players.firstname%TYPE; 
    l_lName players.lastname%TYPE;
    CURSOR c1 IS
    SELECT firstname,
            lastname
            
    FROM vwPlayerRosters
    WHERE teamid = findTeamID;
BEGIN
    OPEN c1;
        DBMS_OUTPUT.PUT_LINE(LPAD('FirstName', 10) ||' ' || LPAD('LastName', 15));
        LOOP
         FETCH c1 INTO l_fName, l_lName;
            IF c1%FOUND
                THEN
                    DBMS_OUTPUT.PUT_LINE(LPAD(l_fName, 10) || LPAD(l_lName, 15));    
            ELSE
                EXIT;
            END IF;
        END LOOP;   
    CLOSE c1;
END;
END spTeamRosterByID;

--Executing it
DECLARE
    l_teamID teams.teamid%TYPE := &l_teamID;
BEGIN
    spTeamRosterByID(l_teamID);
END;


--Task 5
CREATE OR REPLACE PROCEDURE spTeamRosterByName(
    p_teamName IN teams.teamname%TYPE
) AS
BEGIN
DECLARE
    l_teamName teams.teamname%TYPE;
    fName players.firstname%TYPE;
    lName players.lastname%TYPE;
    CURSOR getRoster IS
        SELECT  teamname, firstname, lastname
        FROM vwPlayerRosters 
        WHERE UPPER(teamname) LIKE '%' || TRIM(UPPER(p_teamName)) || '%'
        ORDER BY 
            teamname ASC,
            firstname ASC;      
BEGIN
    DBMS_OUTPUT.PUT_LINE(LPAD('TeamName', 10) ||' ' || RPAD('FirstName', 15) ||  RPAD('LastName', 14));
    OPEN getRoster;
        LOOP
            FETCH getRoster INTO l_teamName, fName, lName;
            IF getRoster%FOUND
                THEN
                    DBMS_OUTPUT.PUT_LINE(LPAD(l_teamName, 8) ||' ' || RPAD(fName, 13) ||  RPAD(lName, 14));
            ELSE
                EXIT;
            END IF;
        END LOOP;
    CLOSE getRoster;
END;
END spTeamRosterByName;


DECLARE
    teamName teams.teamname%TYPE := :teamName;
BEGIN
    spTeamRosterByName(teamName);
END;


--Task 11
--*find all matches that one team will be playing
--based on teamiD given
CREATE OR REPLACE PROCEDURE spGetMatchesForTeam(
    l_teamID IN OUT games.hometeam%TYPE
) AS
BEGIN
DECLARE
    matchTime games.gamedatetime%TYPE;
BEGIN

    SELECT hometeam, visitteam
    FROM games
    WHERE hometeam = l_teamID
    OR visitteam = l_teamID;

END spGetMatchesForTeam;