/*
* pratikchandra_thakur.sql
*
* Oracle Object-Relational Database Script for eSports Management System
* Created: 2025-06-16
* Author: Pratik Chandra Thakur
*
* Features:
*   - User-defined object types with inheritance
*   - Object tables
*   - Nested tables
*   - Integrity constraints
*   - Trigger for business rule enforcement
*   - Stored procedure and function
*/

-- Drop all existing objects to ensure script is re-runnable
-- Tables first (due to dependencies)
DROP TABLE matches PURGE;
DROP TABLE tournament_teams PURGE;
DROP TABLE team_players PURGE;
DROP TABLE tournaments PURGE;
DROP TABLE teams PURGE;
DROP TABLE players PURGE;

-- Then types (in reverse dependency order)
DROP TYPE match_t FORCE;
DROP TYPE tournament_t FORCE;
DROP TYPE team_t FORCE;
DROP TYPE amateur_player_t FORCE;
DROP TYPE professional_player_t FORCE;
DROP TYPE player_t FORCE;
DROP TYPE accolades_nt FORCE;
DROP TYPE accolade_t FORCE;
DROP TYPE game_titles_nt FORCE;
DROP TYPE game_title_t FORCE;

-- 1. Create User-Defined Types (UDTs) for nested tables
CREATE OR REPLACE TYPE game_title_t AS OBJECT (
    game_name VARCHAR2(100),
    genre VARCHAR2(50)
);
/

CREATE OR REPLACE TYPE game_titles_nt AS TABLE OF game_title_t;
/

CREATE OR REPLACE TYPE accolade_t AS OBJECT (
    accolade_name VARCHAR2(100),
    date_achieved DATE
);
/

CREATE OR REPLACE TYPE accolades_nt AS TABLE OF accolade_t;
/

-- 2. Create UDTs for inheritance structure
-- Parent Type
CREATE OR REPLACE TYPE player_t AS OBJECT (
    player_id NUMBER,
    gamer_tag VARCHAR2(50),
    name VARCHAR2(100),
    email VARCHAR2(100),
    date_of_birth DATE,
    nationality VARCHAR2(50),
    join_date DATE,
    
    -- Method declarations
    MEMBER FUNCTION get_age RETURN NUMBER,
    MEMBER PROCEDURE display_info
) NOT FINAL;
/

-- Define the player_t body with method implementations
CREATE OR REPLACE TYPE BODY player_t AS
    MEMBER FUNCTION get_age RETURN NUMBER IS
    BEGIN
        RETURN FLOOR(MONTHS_BETWEEN(SYSDATE, date_of_birth) / 12);
    END;
    
    MEMBER PROCEDURE display_info IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Player ID: ' || player_id);
        DBMS_OUTPUT.PUT_LINE('Gamer Tag: ' || gamer_tag);
        DBMS_OUTPUT.PUT_LINE('Name: ' || name);
        DBMS_OUTPUT.PUT_LINE('Nationality: ' || nationality);
    END;
END;
/

-- Professional Player Type (inheritance)
CREATE OR REPLACE TYPE professional_player_t UNDER player_t (
    contract_id VARCHAR2(50),
    salary NUMBER(12,2),
    contract_start_date DATE,
    contract_expiry_date DATE,
    
    -- Override method
    OVERRIDING MEMBER PROCEDURE display_info
);
/

CREATE OR REPLACE TYPE BODY professional_player_t AS
    OVERRIDING MEMBER PROCEDURE display_info IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('PROFESSIONAL PLAYER');
        DBMS_OUTPUT.PUT_LINE('Player ID: ' || player_id);
        DBMS_OUTPUT.PUT_LINE('Gamer Tag: ' || gamer_tag);
        DBMS_OUTPUT.PUT_LINE('Name: ' || name);
        DBMS_OUTPUT.PUT_LINE('Nationality: ' || nationality);
        DBMS_OUTPUT.PUT_LINE('Contract: ' || contract_id);
        DBMS_OUTPUT.PUT_LINE('Salary: $' || salary);
    END;
END;
/

-- Amateur Player Type (inheritance)
CREATE OR REPLACE TYPE amateur_player_t UNDER player_t (
    experience_level VARCHAR2(50),
    ranking NUMBER,
    
    -- Override method
    OVERRIDING MEMBER PROCEDURE display_info
);
/

CREATE OR REPLACE TYPE BODY amateur_player_t AS
    OVERRIDING MEMBER PROCEDURE display_info IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('AMATEUR PLAYER');
        DBMS_OUTPUT.PUT_LINE('Player ID: ' || player_id);
        DBMS_OUTPUT.PUT_LINE('Gamer Tag: ' || gamer_tag);
        DBMS_OUTPUT.PUT_LINE('Name: ' || name);
        DBMS_OUTPUT.PUT_LINE('Nationality: ' || nationality);
        DBMS_OUTPUT.PUT_LINE('Experience Level: ' || experience_level);
        DBMS_OUTPUT.PUT_LINE('Ranking: ' || ranking);
    END;
END;
/

-- Team Type
CREATE OR REPLACE TYPE team_t AS OBJECT (
    team_id NUMBER,
    team_name VARCHAR2(100),
    founded_date DATE,
    region VARCHAR2(50),
    ranking NUMBER,
    website VARCHAR2(200)
);
/

-- Tournament Type
CREATE OR REPLACE TYPE tournament_t AS OBJECT (
    tournament_id NUMBER,
    tournament_name VARCHAR2(100),
    start_date DATE,
    end_date DATE,
    prize_pool NUMBER(15,2),
    location VARCHAR2(100),
    status VARCHAR2(20)
);
/

-- Match Type
CREATE OR REPLACE TYPE match_t AS OBJECT (
    match_id NUMBER,
    tournament_id NUMBER,
    team1_id NUMBER,
    team2_id NUMBER,
    match_date DATE,
    status VARCHAR2(20),
    score VARCHAR2(20),
    stream_link VARCHAR2(200)
);
/

-- 3. Create Tables with Proper Constraints

-- Players table (substitutable - can store both professional and amateur players)
CREATE TABLE players OF player_t (
    player_id PRIMARY KEY,
    gamer_tag NOT NULL UNIQUE,
    email UNIQUE,
    CHECK (email LIKE '%@%.%'),
    CHECK (date_of_birth < SYSDATE)
);

-- Teams table with nested table
CREATE TABLE teams OF team_t (
    team_id PRIMARY KEY,
    team_name NOT NULL UNIQUE,
    CHECK (ranking > 0)
) OBJECT IDENTIFIER IS PRIMARY KEY;

-- Add nested table for team accolades
ALTER TABLE teams ADD (
    accolades accolades_nt,
    preferred_games game_titles_nt
) NESTED TABLE accolades STORE AS team_accolades_tab
  NESTED TABLE preferred_games STORE AS team_games_tab;

-- Tournaments table
CREATE TABLE tournaments OF tournament_t (
    tournament_id PRIMARY KEY,
    tournament_name NOT NULL,
    CHECK (start_date <= end_date),
    CHECK (prize_pool > 0),
    CHECK (status IN ('Scheduled', 'Ongoing', 'Completed', 'Cancelled'))
);

-- Team-Player relationship (many-to-many)
CREATE TABLE team_players (
    team_id NUMBER,
    player_id NUMBER,
    join_date DATE DEFAULT SYSDATE,
    role VARCHAR2(50),
    is_captain NUMBER(1) DEFAULT 0,
    PRIMARY KEY (team_id, player_id),
    FOREIGN KEY (team_id) REFERENCES teams(team_id),
    FOREIGN KEY (player_id) REFERENCES players(player_id),
    CHECK (is_captain IN (0, 1))
);

-- Tournament-Team relationship (many-to-many)
CREATE TABLE tournament_teams (
    tournament_id NUMBER,
    team_id NUMBER,
    registration_date DATE DEFAULT SYSDATE,
    seed_number NUMBER,
    final_position NUMBER,
    PRIMARY KEY (tournament_id, team_id),
    FOREIGN KEY (tournament_id) REFERENCES tournaments(tournament_id),
    FOREIGN KEY (team_id) REFERENCES teams(team_id),
    CHECK (seed_number > 0),
    CHECK (final_position > 0)
);

-- Matches table
CREATE TABLE matches OF match_t (
    match_id PRIMARY KEY,
    FOREIGN KEY (tournament_id) REFERENCES tournaments(tournament_id),
    FOREIGN KEY (team1_id) REFERENCES teams(team_id),
    FOREIGN KEY (team2_id) REFERENCES teams(team_id),
    CHECK (team1_id != team2_id),
    CHECK (status IN ('Scheduled', 'Live', 'Completed', 'Postponed', 'Cancelled'))
);

-- 4. Create Trigger for Business Rule Enforcement
-- Trigger to enforce minimum salary for professional players
CREATE OR REPLACE TRIGGER check_professional_salary
BEFORE INSERT OR UPDATE ON players
FOR EACH ROW
WHEN (NEW.object_id = 'PROFESSIONAL_PLAYER_T')
DECLARE
    min_salary CONSTANT NUMBER(12,2) := 25000.00; -- Minimum salary threshold
BEGIN
    IF TREAT(:NEW AS professional_player_t).salary < min_salary THEN
        RAISE_APPLICATION_ERROR(-20001, 'Professional player salary cannot be less than $' || min_salary);
    END IF;
END;
/

-- 5. Stored Function and Procedure

-- Function to get contract status of a professional player
CREATE OR REPLACE FUNCTION get_contract_status(p_player_id NUMBER) 
RETURN VARCHAR2 IS
    v_player professional_player_t;
    v_status VARCHAR2(20);
    v_days_remaining NUMBER;
BEGIN
    -- Attempt to retrieve the player as a professional player
    SELECT TREAT(VALUE(p) AS professional_player_t) INTO v_player
    FROM players p
    WHERE p.player_id = p_player_id 
    AND VALUE(p) IS OF (professional_player_t);
    
    -- Calculate days remaining in contract
    v_days_remaining := v_player.contract_expiry_date - SYSDATE;
    
    -- Determine status based on expiration date
    IF v_days_remaining < 0 THEN
        v_status := 'Expired';
    ELSIF v_days_remaining < 90 THEN
        v_status := 'Expires Soon';
    ELSE
        v_status := 'Active';
    END IF;
    
    RETURN v_status;
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'Not a Professional Player';
    WHEN OTHERS THEN
        RETURN 'Error: ' || SQLERRM;
END;
/

-- Procedure to register a team for a tournament with validation
CREATE OR REPLACE PROCEDURE register_team_for_tournament(
    p_team_id IN NUMBER,
    p_tournament_id IN NUMBER,
    p_seed_number IN NUMBER DEFAULT NULL
) IS
    v_team_exists NUMBER;
    v_tournament_exists NUMBER;
    v_tournament_status VARCHAR2(20);
    v_already_registered NUMBER;
    v_team_count NUMBER;
    v_max_teams CONSTANT NUMBER := 32; -- Maximum teams per tournament
    v_seed NUMBER := p_seed_number;
    v_highest_seed NUMBER;
BEGIN
    -- Check if team exists
    SELECT COUNT(*) INTO v_team_exists FROM teams WHERE team_id = p_team_id;
    IF v_team_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Team ID ' || p_team_id || ' does not exist.');
    END IF;
    
    -- Check if tournament exists and get status
    BEGIN
        SELECT status INTO v_tournament_status 
        FROM tournaments 
        WHERE tournament_id = p_tournament_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20003, 'Tournament ID ' || p_tournament_id || ' does not exist.');
    END;
    
    -- Check if tournament is open for registration
    IF v_tournament_status != 'Scheduled' THEN
        RAISE_APPLICATION_ERROR(-20004, 'Tournament is not open for registration. Status: ' || v_tournament_status);
    END IF;
    
    -- Check if team is already registered
    SELECT COUNT(*) INTO v_already_registered 
    FROM tournament_teams 
    WHERE tournament_id = p_tournament_id AND team_id = p_team_id;
    
    IF v_already_registered > 0 THEN
        RAISE_APPLICATION_ERROR(-20005, 'Team is already registered for this tournament.');
    END IF;
    
    -- Check if tournament is full
    SELECT COUNT(*) INTO v_team_count 
    FROM tournament_teams 
    WHERE tournament_id = p_tournament_id;
    
    IF v_team_count >= v_max_teams THEN
        RAISE_APPLICATION_ERROR(-20006, 'Tournament has reached maximum capacity of ' || v_max_teams || ' teams.');
    END IF;
    
    -- Determine seed number if not provided
    IF v_seed IS NULL THEN
        SELECT NVL(MAX(seed_number), 0) + 1 INTO v_highest_seed
        FROM tournament_teams
        WHERE tournament_id = p_tournament_id;
        v_seed := v_highest_seed;
    ELSE
        -- Check if seed is already taken
        SELECT COUNT(*) INTO v_already_registered
        FROM tournament_teams
        WHERE tournament_id = p_tournament_id AND seed_number = v_seed;
        
        IF v_already_registered > 0 THEN
            RAISE_APPLICATION_ERROR(-20007, 'Seed number ' || v_seed || ' is already assigned to another team.');
        END IF;
    END IF;
    
    -- Register the team
    INSERT INTO tournament_teams (tournament_id, team_id, registration_date, seed_number)
    VALUES (p_tournament_id, p_team_id, SYSDATE, v_seed);
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Team ID ' || p_team_id || ' successfully registered for Tournament ID ' || 
        p_tournament_id || ' with seed number ' || v_seed);
    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/

-- 6. Insert Sample Data

-- Insert Players (both professional and amateur)
INSERT INTO players VALUES (
    professional_player_t(
        101, 'ZywOo', 'Mathieu Herbaut', 'zywoo@team.com', 
        TO_DATE('2000-11-09', 'YYYY-MM-DD'), 'France', TO_DATE('2019-03-15', 'YYYY-MM-DD'),
        'CTR-VIT-001', 550000.00, TO_DATE('2023-01-01', 'YYYY-MM-DD'), TO_DATE('2026-12-31', 'YYYY-MM-DD')
    )
);

INSERT INTO players VALUES (
    professional_player_t(
        102, 's1mple', 'Oleksandr Kostyliev', 's1mple@team.com', 
        TO_DATE('1997-10-02', 'YYYY-MM-DD'), 'Ukraine', TO_DATE('2016-08-04', 'YYYY-MM-DD'),
        'CTR-NAV-002', 620000.00, TO_DATE('2022-06-01', 'YYYY-MM-DD'), TO_DATE('2025-06-01', 'YYYY-MM-DD')
    )
);

INSERT INTO players VALUES (
    professional_player_t(
        103, 'NiKo', 'Nikola Kovač', 'niko@team.com', 
        TO_DATE('1997-02-16', 'YYYY-MM-DD'), 'Bosnia', TO_DATE('2017-02-09', 'YYYY-MM-DD'),
        'CTR-G2-003', 580000.00, TO_DATE('2021-11-01', 'YYYY-MM-DD'), TO_DATE('2024-07-15', 'YYYY-MM-DD')
    )
);

INSERT INTO players VALUES (
    professional_player_t(
        104, 'device', 'Nicolai Reedtz', 'device@team.com', 
        TO_DATE('1995-09-08', 'YYYY-MM-DD'), 'Denmark', TO_DATE('2015-01-19', 'YYYY-MM-DD'),
        'CTR-AST-004', 540000.00, TO_DATE('2022-10-01', 'YYYY-MM-DD'), TO_DATE('2025-09-30', 'YYYY-MM-DD')
    )
);

INSERT INTO players VALUES (
    professional_player_t(
        105, 'Faker', 'Lee Sang-hyeok', 'faker@team.com', 
        TO_DATE('1996-05-07', 'YYYY-MM-DD'), 'South Korea', TO_DATE('2013-02-15', 'YYYY-MM-DD'),
        'CTR-SKT-005', 700000.00, TO_DATE('2022-01-15', 'YYYY-MM-DD'), TO_DATE('2027-01-14', 'YYYY-MM-DD')
    )
);

INSERT INTO players VALUES (
    professional_player_t(
        106, 'Perkz', 'Luka Perkovic', 'perkz@team.com', 
        TO_DATE('1998-09-30', 'YYYY-MM-DD'), 'Croatia', TO_DATE('2015-11-20', 'YYYY-MM-DD'),
        'CTR-G2L-006', 490000.00, TO_DATE('2022-04-15', 'YYYY-MM-DD'), TO_DATE('2025-04-14', 'YYYY-MM-DD')
    )
);

INSERT INTO players VALUES (
    professional_player_t(
        107, 'Caps', 'Rasmus Winther', 'caps@team.com', 
        TO_DATE('1999-11-17', 'YYYY-MM-DD'), 'Denmark', TO_DATE('2017-01-05', 'YYYY-MM-DD'),
        'CTR-G2L-007', 510000.00, TO_DATE('2023-01-10', 'YYYY-MM-DD'), TO_DATE('2026-01-09', 'YYYY-MM-DD')
    )
);

INSERT INTO players VALUES (
    professional_player_t(
        108, 'Rekkles', 'Martin Larsson', 'rekkles@team.com', 
        TO_DATE('1996-09-20', 'YYYY-MM-DD'), 'Sweden', TO_DATE('2014-05-12', 'YYYY-MM-DD'),
        'CTR-FNC-008', 520000.00, TO_DATE('2022-12-01', 'YYYY-MM-DD'), TO_DATE('2024-06-01', 'YYYY-MM-DD')
    )
);

INSERT INTO players VALUES (
    professional_player_t(
        109, 'Bjergsen', 'Søren Bjerg', 'bjergsen@team.com', 
        TO_DATE('1996-02-21', 'YYYY-MM-DD'), 'Denmark', TO_DATE('2013-11-24', 'YYYY-MM-DD'),
        'CTR-TSM-009', 590000.00, TO_DATE('2023-03-01', 'YYYY-MM-DD'), TO_DATE('2026-03-01', 'YYYY-MM-DD')
    )
);

INSERT INTO players VALUES (
    professional_player_t(
        110, 'Doublelift', 'Yiliang Peng', 'doublelift@team.com', 
        TO_DATE('1993-07-19', 'YYYY-MM-DD'), 'USA', TO_DATE('2011-03-08', 'YYYY-MM-DD'),
        'CTR-TL-010', 560000.00, TO_DATE('2022-08-15', 'YYYY-MM-DD'), TO_DATE('2024-02-15', 'YYYY-MM-DD')
    )
);

-- Amateur Players
INSERT INTO players VALUES (
    amateur_player_t(
        201, 'RisingTide', 'James Wilson', 'rising@amateur.com', 
        TO_DATE('2002-06-12', 'YYYY-MM-DD'), 'UK', TO_DATE('2023-01-05', 'YYYY-MM-DD'),
        'Intermediate', 157
    )
);

INSERT INTO players VALUES (
    amateur_player_t(
        202, 'NovaStar', 'Emma Roberts', 'nova@amateur.com', 
        TO_DATE('2003-03-27', 'YYYY-MM-DD'), 'Canada', TO_DATE('2023-02-10', 'YYYY-MM-DD'),
        'Advanced', 89
    )
);

INSERT INTO players VALUES (
    amateur_player_t(
        203, 'ShadowFist', 'Michael Chen', 'shadow@amateur.com', 
        TO_DATE('2001-11-14', 'YYYY-MM-DD'), 'USA', TO_DATE('2022-09-30', 'YYYY-MM-DD'),
        'Semi-Pro', 42
    )
);

INSERT INTO players VALUES (
    amateur_player_t(
        204, 'FireStorm', 'Olivia Brown', 'fire@amateur.com', 
        TO_DATE('2002-08-05', 'YYYY-MM-DD'), 'Australia', TO_DATE('2023-04-15', 'YYYY-MM-DD'),
        'Beginner', 342
    )
);

INSERT INTO players VALUES (
    amateur_player_t(
        205, 'QuickSilver', 'Daniel Martinez', 'quick@amateur.com', 
        TO_DATE('2004-05-22', 'YYYY-MM-DD'), 'Spain', TO_DATE('2023-06-01', 'YYYY-MM-DD'),
        'Intermediate', 178
    )
);

-- Insert Teams with nested tables
INSERT INTO teams VALUES (
    team_t(1001, 'Team Vitality', TO_DATE('2013-08-10', 'YYYY-MM-DD'), 'Europe', 4, 'www.teamvitality.gg'),
    accolades_nt(
        accolade_t('ESL Pro League Season 16', TO_DATE('2022-10-02', 'YYYY-MM-DD')),
        accolade_t('BLAST Premier Spring Finals', TO_DATE('2023-06-18', 'YYYY-MM-DD'))
    ),
    game_titles_nt(
        game_title_t('Counter-Strike 2', 'FPS'),
        game_title_t('League of Legends', 'MOBA')
    )
);

INSERT INTO teams VALUES (
    team_t(1002, 'Natus Vincere', TO_DATE('2009-12-17', 'YYYY-MM-DD'), 'CIS', 3, 'www.navi.gg'),
    accolades_nt(
        accolade_t('PGL Major Stockholm', TO_DATE('2021-11-07', 'YYYY-MM-DD')),
        accolade_t('BLAST Premier World Final', TO_DATE('2021-12-19', 'YYYY-MM-DD'))
    ),
    game_titles_nt(
        game_title_t('Counter-Strike 2', 'FPS'),
        game_title_t('Dota 2', 'MOBA')
    )
);

INSERT INTO teams VALUES (
    team_t(1003, 'G2 Esports', TO_DATE('2014-02-24', 'YYYY-MM-DD'), 'Europe', 2, 'www.g2esports.com'),
    accolades_nt(
        accolade_t('LEC Spring Split', TO_DATE('2023-04-16', 'YYYY-MM-DD')),
        accolade_t('BLAST Premier Fall Final', TO_DATE('2022-11-27', 'YYYY-MM-DD'))
    ),
    game_titles_nt(
        game_title_t('League of Legends', 'MOBA'),
        game_title_t('Counter-Strike 2', 'FPS'),
        game_title_t('Valorant', 'FPS')
    )
);

INSERT INTO teams VALUES (
    team_t(1004, 'Astralis', TO_DATE('2016-01-18', 'YYYY-MM-DD'), 'Denmark', 8, 'www.astralis.gg'),
    accolades_nt(
        accolade_t('ESL Pro League Season 12', TO_DATE('2020-10-04', 'YYYY-MM-DD')),
        accolade_t('ELEAGUE Major Atlanta', TO_DATE('2017-01-29', 'YYYY-MM-DD')),
        accolade_t('IEM Katowice Major', TO_DATE('2019-03-03', 'YYYY-MM-DD'))
    ),
    game_titles_nt(
        game_title_t('Counter-Strike 2', 'FPS'),
        game_title_t('League of Legends', 'MOBA')
    )
);

INSERT INTO teams VALUES (
    team_t(1005, 'T1', TO_DATE('2012-12-13', 'YYYY-MM-DD'), 'South Korea', 1, 'www.t1.gg'),
    accolades_nt(
        accolade_t('LoL World Championship', TO_DATE('2022-11-05', 'YYYY-MM-DD')),
        accolade_t('LCK Summer Split', TO_DATE('2023-08-20', 'YYYY-MM-DD'))
    ),
    game_titles_nt(
        game_title_t('League of Legends', 'MOBA'),
        game_title_t('Valorant', 'FPS'),
        game_title_t('Dota 2', 'MOBA')
    )
);

INSERT INTO teams VALUES (
    team_t(1006, 'Fnatic', TO_DATE('2004-07-23', 'YYYY-MM-DD'), 'Europe', 5, 'www.fnatic.com'),
    accolades_nt(
        accolade_t('LEC Spring Split', TO_DATE('2021-04-11', 'YYYY-MM-DD')),
        accolade_t('LoL World Championship Season 1', TO_DATE('2011-06-20', 'YYYY-MM-DD'))
    ),
    game_titles_nt(
        game_title_t('League of Legends', 'MOBA'),
        game_title_t('Counter-Strike 2', 'FPS')
    )
);

-- Insert Tournaments
INSERT INTO tournaments VALUES (tournament_t(2001, 'ESL Pro League Season 20', 
    TO_DATE('2025-09-01', 'YYYY-MM-DD'), TO_DATE('2025-10-15', 'YYYY-MM-DD'), 
    850000.00, 'Malta', 'Scheduled'));

INSERT INTO tournaments VALUES (tournament_t(2002, 'IEM Katowice 2026', 
    TO_DATE('2026-02-01', 'YYYY-MM-DD'), TO_DATE('2026-02-14', 'YYYY-MM-DD'), 
    1000000.00, 'Katowice, Poland', 'Scheduled'));

INSERT INTO tournaments VALUES (tournament_t(2003, 'BLAST Premier World Final 2025', 
    TO_DATE('2025-12-10', 'YYYY-MM-DD'), TO_DATE('2025-12-18', 'YYYY-MM-DD'), 
    1250000.00, 'Copenhagen, Denmark', 'Scheduled'));

INSERT INTO tournaments VALUES (tournament_t(2004, 'LEC Summer Split 2025', 
    TO_DATE('2025-06-15', 'YYYY-MM-DD'), TO_DATE('2025-08-20', 'YYYY-MM-DD'), 
    500000.00, 'Berlin, Germany', 'Scheduled'));

INSERT INTO tournaments VALUES (tournament_t(2005, 'PGL Major Stockholm 2025', 
    TO_DATE('2025-11-01', 'YYYY-MM-DD'), TO_DATE('2025-11-14', 'YYYY-MM-DD'), 
    2000000.00, 'Stockholm, Sweden', 'Scheduled'));

-- Insert Team-Player relationships
INSERT INTO team_players VALUES (1001, 101, TO_DATE('2022-01-01', 'YYYY-MM-DD'), 'AWPer', 0);
INSERT INTO team_players VALUES (1002, 102, TO_DATE('2021-01-15', 'YYYY-MM-DD'), 'AWPer', 1);
INSERT INTO team_players VALUES (1003, 103, TO_DATE('2021-11-01', 'YYYY-MM-DD'), 'Rifler', 1);
INSERT INTO team_players VALUES (1004, 104, TO_DATE('2022-10-01', 'YYYY-MM-DD'), 'AWPer', 0);
INSERT INTO team_players VALUES (1005, 105, TO_DATE('2013-02-15', 'YYYY-MM-DD'), 'Mid Laner', 1);
INSERT INTO team_players VALUES (1003, 106, TO_DATE('2022-04-15', 'YYYY-MM-DD'), 'Mid Laner', 0);
INSERT INTO team_players VALUES (1003, 107, TO_DATE('2023-01-10', 'YYYY-MM-DD'), 'Mid Laner', 1);
INSERT INTO team_players VALUES (1006, 108, TO_DATE('2022-12-01', 'YYYY-MM-DD'), 'ADC', 0);
INSERT INTO team_players VALUES (1001, 109, TO_DATE('2023-03-01', 'YYYY-MM-DD'), 'Mid Laner', 1);
INSERT INTO team_players VALUES (1006, 110, TO_DATE('2022-08-15', 'YYYY-MM-DD'), 'ADC', 1);

-- Insert Tournament-Team registrations
INSERT INTO tournament_teams VALUES (2001, 1001, TO_DATE('2025-07-15', 'YYYY-MM-DD'), 1, NULL);
INSERT INTO tournament_teams VALUES (2001, 1002, TO_DATE('2025-07-16', 'YYYY-MM-DD'), 2, NULL);
INSERT INTO tournament_teams VALUES (2001, 1003, TO_DATE('2025-07-17', 'YYYY-MM-DD'), 3, NULL);
INSERT INTO tournament_teams VALUES (2001, 1004, TO_DATE('2025-07-18', 'YYYY-MM-DD'), 4, NULL);

INSERT INTO tournament_teams VALUES (2002, 1001, TO_DATE('2025-12-01', 'YYYY-MM-DD'), 1, NULL);
INSERT INTO tournament_teams VALUES (2002, 1002, TO_DATE('2025-12-02', 'YYYY-MM-DD'), 2, NULL);
INSERT INTO tournament_teams VALUES (2002, 1003, TO_DATE('2025-12-03', 'YYYY-MM-DD'), 3, NULL);
INSERT INTO tournament_teams VALUES (2002, 1005, TO_DATE('2025-12-04', 'YYYY-MM-DD'), 4, NULL);

INSERT INTO tournament_teams VALUES (2003, 1001, TO_DATE('2025-10-15', 'YYYY-MM-DD'), 1, NULL);
INSERT INTO tournament_teams VALUES (2003, 1002, TO_DATE('2025-10-16', 'YYYY-MM-DD'), 2, NULL);
INSERT INTO tournament_teams VALUES (2003, 1004, TO_DATE('2025-10-17', 'YYYY-MM-DD'), 3, NULL);
INSERT INTO tournament_teams VALUES (2003, 1006, TO_DATE('2025-10-18', 'YYYY-MM-DD'), 4, NULL);

INSERT INTO tournament_teams VALUES (2004, 1003, TO_DATE('2025-05-15', 'YYYY-MM-DD'), 1, NULL);
INSERT INTO tournament_teams VALUES (2004, 1005, TO_DATE('2025-05-16', 'YYYY-MM-DD'), 2, NULL);
INSERT INTO tournament_teams VALUES (2004, 1006, TO_DATE('2025-05-17', 'YYYY-MM-DD'), 3, NULL);

INSERT INTO tournament_teams VALUES (2005, 1001, TO_DATE('2025-09-15', 'YYYY-MM-DD'), 1, NULL);
INSERT INTO tournament_teams VALUES (2005, 1002, TO_DATE('2025-09-16', 'YYYY-MM-DD'), 2, NULL);
INSERT INTO tournament_teams VALUES (2005, 1003, TO_DATE('2025-09-17', 'YYYY-MM-DD'), 3, NULL);
INSERT INTO tournament_teams VALUES (2005, 1004, TO_DATE('2025-09-18', 'YYYY-MM-DD'), 4, NULL);

-- Insert Matches
INSERT INTO matches VALUES (match_t(3001, 2001, 1001, 1002, 
    TO_DATE('2025-09-03 14:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'Scheduled', NULL,
    'https://twitch.tv/esl_csgo'));

INSERT INTO matches VALUES (match_t(3002, 2001, 1003, 1004, 
    TO_DATE('2025-09-03 17:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'Scheduled', NULL,
    'https://twitch.tv/esl_csgo'));

INSERT INTO matches VALUES (match_t(3003, 2002, 1001, 1003, 
    TO_DATE('2026-02-02 12:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'Scheduled', NULL,
    'https://twitch.tv/esl_csgo'));

INSERT INTO matches VALUES (match_t(3004, 2002, 1002, 1005, 
    TO_DATE('2026-02-02 15:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'Scheduled', NULL,
    'https://twitch.tv/esl_csgo'));

INSERT INTO matches VALUES (match_t(3005, 2003, 1001, 1006, 
    TO_DATE('2025-12-11 18:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'Scheduled', NULL,
    'https://twitch.tv/blastpremier'));

INSERT INTO matches VALUES (match_t(3006, 2004, 1003, 1006, 
    TO_DATE('2025-06-16 14:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'Scheduled', NULL,
    'https://twitch.tv/lec'));

-- Show all created objects
COMMIT;

-- Test queries for verification
SELECT 'Total Players: ' || COUNT(*) FROM players;
SELECT 'Professional Players: ' || COUNT(*) FROM players p WHERE VALUE(p) IS OF (professional_player_t);
SELECT 'Amateur Players: ' || COUNT(*) FROM players p WHERE VALUE(p) IS OF (amateur_player_t);
SELECT 'Total Teams: ' || COUNT(*) FROM teams;
SELECT 'Total Tournaments: ' || COUNT(*) FROM tournaments;
SELECT 'Total Matches: ' || COUNT(*) FROM matches;

-- Test function
SELECT p.gamer_tag, get_contract_status(p.player_id) AS contract_status
FROM players p
WHERE VALUE(p) IS OF (professional_player_t);

-- Example of executing the procedure (commented out to avoid accidental execution)
-- EXEC register_team_for_tournament(1006, 2005, 5);

-- Display nested table data example
SELECT t.team_name, a.accolade_name, a.date_achieved
FROM teams t, TABLE(t.accolades) a
ORDER BY t.team_name, a.date_achieved;

-- Display player hierarchy with dynamic polymorphism
SELECT p.player_id, p.gamer_tag, 
    CASE
        WHEN VALUE(p) IS OF (professional_player_t) THEN 'Professional'
        WHEN VALUE(p) IS OF (amateur_player_t) THEN 'Amateur'
        ELSE 'Standard'
    END AS player_type
FROM players p
ORDER BY player_id;

