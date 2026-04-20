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

alter table player
add wickets int default 0;

alter table player
add catches int default 0;
/*
go
create trigger player_insertion
on player
after insert
as 
begin 
print('Player inserted!')
end
go

insert into player values('Shadab Khan', 109, 26, 'All-Rounder', 80000, 3, NULL)


go
create trigger team_deletion
on team 
after delete
as 
begin
select tname
from deleted
end 
go

delete from team
where tname='Lahore Lions'


go 
create trigger update_salary
on player
after update
as
begin
print('Player salary updated')
end
go
*/

-- prevent insertion of player if age less than 16 
/*
go
create trigger prevent_player
on player
instead of insert
as
begin
if exists (select 1
    from inserted
    where age<16)
begin
print('Under Age Player')
end
else 
begin
insert into player values(select * from inserted)
end
end
go


go
create trigger insert_performance
on performance
after insert
as 
begin
update player
set player.runs=player.runs+inserted.runs,
set player.wickets=player.wickets+inserted.wickets
where player.pid=inserted.pid
end
go


go
create trigger delete_team_players
on team
after delete
as 
begin
delete from player
where player.tid=deleted.tid
end
go


go
create trigger update_match
on match
after update 
as 
begin
if update(winner_id)
begin
if exists(select 1
          from deleted d join inserted i
          where d.winner_id!=i.winner_id)
begin
print('Winning team changed')
end
end
end
go


go
create trigger delete_player 
on player
instead of delete
as 
begin
if exists(select 1
          from deleted d join performance p on d.pid=p.pid)
begin
print('Player has performance record')
end
else 
begin
delete from player p
where p.pid in (select pid from deleted)
end
end
go
*/


