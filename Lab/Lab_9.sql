-- 1. Create the Team table
CREATE TABLE team (
    tname VARCHAR(25) NOT NULL,
    tid INT NOT NULL PRIMARY KEY,
    coach VARCHAR(25),
    home_city VARCHAR(25)
);

-- 2. Create the Player table
CREATE TABLE player (
    pname VARCHAR(25) NOT NULL,
    pid INT NOT NULL PRIMARY KEY,
    age INT,
    role VARCHAR(15), -- Batsman, Bowler, All-Rounder, Wicketkeeper
    salary DECIMAL(10,2),
    tid INT NOT NULL,
    captain_id INT,
    FOREIGN KEY (tid) REFERENCES team(tid),
    FOREIGN KEY (captain_id) REFERENCES player(pid)
);

-- 3. Create the Tournament table
CREATE TABLE tournament (
    tour_id INT NOT NULL PRIMARY KEY,
    tour_name VARCHAR(30),
    year INT
);

-- 4. Create the Match table
CREATE TABLE match (
    mid INT NOT NULL PRIMARY KEY,
    mdate DATE,
    venue VARCHAR(30),
    team1_id INT,
    team2_id INT,
    winner_id INT,
    tour_id INT,
    FOREIGN KEY (team1_id) REFERENCES team(tid),
    FOREIGN KEY (team2_id) REFERENCES team(tid),
    FOREIGN KEY (winner_id) REFERENCES team(tid),
    FOREIGN KEY (tour_id) REFERENCES tournament(tour_id)
);

-- 5. Create the Player_Match_Performance table
CREATE TABLE performance (
    pid INT NOT NULL,
    mid INT NOT NULL,
    runs INT DEFAULT 0,
    wickets INT DEFAULT 0,
    catches INT DEFAULT 0,
    PRIMARY KEY (pid, mid),
    FOREIGN KEY (pid) REFERENCES player(pid),
    FOREIGN KEY (mid) REFERENCES match(mid)
);

-- Disable constraints to allow insertion in any order
EXEC sp_MSforeachtable "ALTER TABLE ? NOCHECK CONSTRAINT ALL";

-- Insert data into Team table
INSERT INTO team VALUES
('Lahore Lions', 1, 'Mickey Arthur', 'Lahore'),
('Karachi Kings', 2, 'Wasim Akram', 'Karachi'),
('Islamabad United', 3, 'Dean Jones', 'Islamabad'),
('Peshawar Zalmi', 4, 'Darren Sammy', 'Peshawar');

-- Insert data into Player table
INSERT INTO player VALUES
('Babar Azam', 101, 29, 'Batsman', 90000, 1, NULL),
('Shaheen Afridi', 102, 27, 'Bowler', 85000, 1, 101),
('Rizwan', 103, 31, 'Wicketkeeper', 88000, 2, NULL),
('Amir', 104, 32, 'Bowler', 70000, 2, 103),
('Shadab Khan', 105, 26, 'All-Rounder', 80000, 3, NULL),
('Hasan Ali', 106, 30, 'Bowler', 75000, 3, 105),
('Wahab Riaz', 107, 35, 'Bowler', 72000, 4, NULL),
('Tom Kohler', 108, 28, 'Batsman', 65000, 4, 107);

-- Insert data into Tournament table
INSERT INTO tournament VALUES
(1, 'PSL', 2024),
(2, 'Champions Cup', 2025);

-- Insert data into Match table
INSERT INTO match VALUES
(201, '2024-02-01', 'Lahore', 1, 2, 1, 1),
(202, '2024-02-05', 'Karachi', 2, 3, 3, 1),
(203, '2024-02-10', 'Islamabad', 3, 4, 4, 1),
(204, '2025-03-01', 'Peshawar', 1, 3, 3, 2),
(205, '2025-03-05', 'Lahore', 2, 4, 2, 2);

-- Insert data into Performance table
INSERT INTO performance VALUES
(101, 201, 75, 0, 1),
(102, 201, 10, 3, 0),
(103, 201, 50, 0, 2),
(104, 202, 5, 2, 0),
(105, 202, 40, 1, 1),
(106, 203, 15, 4, 0),
(107, 203, 20, 2, 1),
(108, 204, 60, 0, 0),
(101, 204, 55, 0, 1),
(105, 205, 35, 2, 0);

-- Enable constraints again
EXEC sp_MSforeachtable "ALTER TABLE ? CHECK CONSTRAINT ALL";


-- 1
/*
go
CREATE TRIGGER trg_TeamConsistency
ON player
AFTER INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM inserted i
        JOIN player p ON i.captain_id = p.pid
        WHERE i.tid != p.tid AND i.captain_id IS NOT NULL
    )
    BEGIN
        RAISERROR ('The captain must belong to the same team as the player.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
go

insert into player values('sajjad', 109, 20, 'Batsman', 85000, 2, 101)
*/


--2
/*
go 
CREATE TRIGGER trg_CaptainIntegrity
ON player
AFTER UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM inserted i
        JOIN deleted d ON i.pid = d.pid
        WHERE i.tid != d.tid 
        AND i.pid IN (SELECT captain_id FROM player WHERE captain_id IS NOT NULL)
    )
    BEGIN
        RAISERROR ('Cannot change team for a player who is a captain of others.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
go

update player
set tid=2
where pid=101
*/


--3
go 
CREATE TRIGGER trg_CaptainReassignment
ON player
INSTEAD OF DELETE
AS
BEGIN
    -- Step 1: Reassign subordinates to NULL
    UPDATE player
    SET captain_id = NULL
    WHERE captain_id IN (SELECT pid FROM deleted);

    -- Step 2: Perform the actual deletion
    DELETE FROM player
    WHERE pid IN (SELECT pid FROM deleted);
END;



--4
CREATE TRIGGER trg_MatchValidation
ON match
AFTER INSERT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted WHERE team1_id = team2_id)
    BEGIN
        RAISERROR ('A team cannot play against itself.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;



--5 
CREATE TRIGGER trg_WinnerValidation
ON match
AFTER UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM inserted 
        WHERE winner_id != team1_id AND winner_id != team2_id
    )
    BEGIN
        RAISERROR ('Winner must be either Team 1 or Team 2.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;



--6
CREATE TRIGGER trg_PerformanceConstraint
ON performance
AFTER INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM inserted i
        JOIN player p ON i.pid = p.pid
        JOIN match m ON i.mid = m.mid
        WHERE p.tid != m.team1_id AND p.tid != m.team2_id
    )
    BEGIN
        RAISERROR ('Player team did not participate in this match.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;



--7 
CREATE TRIGGER trg_AggregateEnforcement
ON performance
AFTER UPDATE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted WHERE runs = 0 AND wickets = 0)
    BEGIN
        RAISERROR ('Runs and wickets cannot both be zero.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;



--8
CREATE TRIGGER trg_TournamentIntegrity
ON tournament
AFTER DELETE
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM match 
        WHERE tour_id IN (SELECT tour_id FROM deleted)
    )
    BEGIN
        RAISERROR ('Cannot delete tournament because matches exist.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;



--9
CREATE TRIGGER trg_MatchPlayerCount
ON match
AFTER INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM inserted i
        WHERE (SELECT COUNT(*) FROM player WHERE tid = i.team1_id) < 11
        OR (SELECT COUNT(*) FROM player WHERE tid = i.team2_id) < 11
    )
    BEGIN
        RAISERROR ('Both teams must have at least 11 players.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;



--10 
CREATE TRIGGER trg_SalaryConstraint
ON player
AFTER UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM inserted i
        WHERE i.salary > (SELECT AVG(salary) * 3 FROM player WHERE tid = i.tid)
    )
    BEGIN
        RAISERROR ('Salary exceeds thrice the team average.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
