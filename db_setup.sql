DROP DATABASE IF EXISTS coursework;

CREATE DATABASE coursework;

USE coursework;

-- definition of department table. A department can be deleted if there are no lecturers in the specified department
DROP TABLE IF EXISTS Department;
CREATE TABLE Department (
    Dep_ID INT UNSIGNED NOT NULL,
    Dep_Name VARCHAR(255) NOT NULL,
	PRIMARY KEY (Dep_ID)
);

-- insertion of details into department
INSERT INTO Department VALUES
(1, 'Faculty of Engineering and Physical Sciences'),
(2, 'Faculty of Arts and Social Sciences'),
(3, 'Faculty of Health and Medical Sciences');

-- the creation of this table is essential to keep all data in the tables atomic. The office and fax must not be stored in the same column and row.
-- They have been linked using the primary key of the department to the departments they're from.
DROP TABLE IF EXISTS DepartmentPhone;
CREATE TABLE DepartmentPhone (
    Dep_ID INT UNSIGNED NOT NULL,
    Phone_Number VARCHAR(15) NOT NULL,
    Phone_Type ENUM('Office', 'Fax') NOT NULL,
    PRIMARY KEY (Dep_ID, Phone_Number),
    FOREIGN KEY (Dep_ID) REFERENCES Department(Dep_ID)
    ON DELETE CASCADE
);

INSERT INTO DepartmentPhone VALUES
(1, '01483233445', 'Office'),
(1, '01484551234', 'Fax'),
(2, '01482345678', 'Office'),
(2, '01489998765', 'Fax'),
(3, '01487654321', 'Office'),
(3, '01489996666', 'Fax');

-- Lecturer table definition. Deletion of the lecturer's department is restricted if the lecturer is in that department.
DROP TABLE IF EXISTS Lecturer;
CREATE TABLE Lecturer (
    Lec_ID INT UNSIGNED NOT NULL,
    Dep_ID INT UNSIGNED NOT NULL,
    Lec_FName VARCHAR(255) NOT NULL,
    Lec_LName VARCHAR(255) NOT NULL,
    PRIMARY KEY (Lec_ID),
    FOREIGN KEY (Dep_ID) REFERENCES Department(Dep_ID)
    ON DELETE RESTRICT);

-- inserts lecturer details into table
INSERT INTO Lecturer VALUES
(4, 1, 'Emily', 'Williams'),
(5, 2, 'Michael', 'Davis'),
(6, 3, 'Sophia', 'Brown'),
(7, 1, 'Daniel', 'Miller'),
(8, 2, 'Olivia', 'Jones');

-- course table definition
DROP TABLE IF EXISTS Course;
CREATE TABLE Course (
Crs_Code INT UNSIGNED NOT NULL,
Lec_ID INT UNSIGNED NOT NULL,
Crs_Title VARCHAR(255) NOT NULL,
Crs_Enrollment INT UNSIGNED,
PRIMARY KEY (Crs_code),
FOREIGN KEY (Lec_ID) REFERENCES Lecturer(Lec_ID)
ON DELETE RESTRICT);

-- insertion of data into course
INSERT INTO Course VALUES 
(100, 8,'BSc Computer Science', 150),
(101, 8,'BSc Computer Information Technology', 20),
(200, 4,'MSc Data Science', 100),
(201, 7,'MSc Security', 30),
(210, 5,'MSc Electrical Engineering', 70),
(211, 6,'BSc Physics', 100);


-- This is the student table definition

DROP TABLE IF EXISTS Student;
CREATE TABLE Student (
URN INT UNSIGNED NOT NULL,
Stu_FName 	VARCHAR(255) NOT NULL,
Stu_LName 	VARCHAR(255) NOT NULL,
Stu_DOB 	DATE,
Stu_Phone 	VARCHAR(12),
Stu_Course	INT UNSIGNED NOT NULL,
Stu_Type 	ENUM('UG', 'PG'),
PRIMARY KEY (URN),
FOREIGN KEY (Stu_Course) REFERENCES Course (Crs_Code)
ON DELETE RESTRICT);

-- inserting student names and details
INSERT INTO Student VALUES
(612345, 'Sara', 'Khan', '2002-06-20', '01483112233', 100, 'UG'),
(612346, 'Pierre', 'Gervais', '2002-03-12', '01483223344', 100, 'UG'),
(612347, 'Patrick', 'O-Hara', '2001-05-03', '01483334455', 100, 'UG'),
(612348, 'Iyabo', 'Ogunsola', '2002-04-21', '01483445566', 100, 'UG'),
(612349, 'Omar', 'Sharif', '2001-12-29', '01483778899', 100, 'UG'),
(612350, 'Yunli', 'Guo', '2002-06-07', '01483123456', 100, 'UG'),
(612351, 'Costas', 'Spiliotis', '2002-07-02', '01483234567', 100, 'UG'),
(612352, 'Tom', 'Jones', '2001-10-24',  '01483456789', 101, 'UG'),
(612353, 'Simon', 'Larson', '2002-08-23', '01483998877', 101, 'UG'),
(612354, 'Sue', 'Smith', '2002-05-16', '01483776655', 101, 'UG');

-- Undergraduate and Postgraduates are 2 subtypes of student. If a student is deleted, 
-- that student's row in whichever of the two's table it is in will also be removed due to 'cascade'

DROP TABLE IF EXISTS Undergraduate;
CREATE TABLE Undergraduate (
UG_URN 	INT UNSIGNED NOT NULL,
UG_Credits   INT NOT NULL,
CHECK (60 <= UG_Credits <= 150),
PRIMARY KEY (UG_URN),
FOREIGN KEY (UG_URN) REFERENCES Student(URN)
ON DELETE CASCADE);

INSERT INTO Undergraduate VALUES
(612345, 120),
(612346, 90),
(612347, 150),
(612348, 120),
(612349, 120),
(612350, 60),
(612351, 60),
(612352, 90),
(612353, 120),
(612354, 90);

DROP TABLE IF EXISTS Postgraduate;

CREATE TABLE Postgraduate (
PG_URN 	INT UNSIGNED NOT NULL,
Thesis  VARCHAR(512) NOT NULL,
PRIMARY KEY (PG_URN),
FOREIGN KEY (PG_URN) REFERENCES Student(URN)
ON DELETE CASCADE);

-- hobby table definition
DROP TABLE IF EXISTS Hobby;
CREATE TABLE Hobby (
    Hob_ID INT UNSIGNED NOT NULL,
    Hob_Name VARCHAR(50),
    PRIMARY KEY (Hob_ID)
);

-- inserting hobby ID and values
INSERT INTO Hobby VALUES
(1, 'Reading'),
(2, 'Hiking'),
(3, 'Chess'),
(4, 'Taichi'),
(5, 'Ballroom Dancing'),
(6, 'Football'),
(7, 'Tennis'),
(8, 'Rugby'),
(9, 'Climbing'),
(10, 'Rowing'),
(11, 'Cooking');

-- society table definition
DROP TABLE IF EXISTS Society;
CREATE TABLE Society (
    Soc_ID INT UNSIGNED NOT NULL,
    Soc_Name VARCHAR(50) NOT NULL,
    Soc_Desc VARCHAR(255),
    PRIMARY KEY (Soc_ID)
);	

-- inserting all societies and their keys and descriptions which were mentioned in business rules.
INSERT INTO Society VALUES
(1, 'LiteratureSoc', 'Discover the joy of reading and join fellow book enthusiasts and explore literature through book discussions, events, and writing workshops.'),
(2, 'WalkingSoc', 'Embark on exciting journeys through nature while connecting with others who share a passion for hiking.'),
(3, 'ChessSoc', 'Bringing together chess enthusiasts for friendly competition and strategy discussions.'),
(4, 'TaichiSoc', 'Experience the art of Taichi, enhancing your well-being through gentle movements with like-minded induviduals.'),
(5, 'DanceSoc', 'Learn new dance moves, connect with partners, and enjoy learning how to dance'),
(6, 'FootballSoc', 'Unleash your passion for football by playing exciting matches and developing skills.'),
(7, 'TenniSoc', 'Play your heart out in tennis whether you are a seasoned player or a beginner level'),
(8, 'RugbySoc', 'Join fellow rugby enthusiasts for training sessions and exciting matches.'),
(9, 'ClimbingSoc', 'Scale new heights and conquer climbing challenges with other climbers'),
(10, 'RowingSoc', 'Join the rowing club to enjoy learning how to row efficiently on harsh waters.'),
(11, 'BakingSoc', 'If you share love for baking, join to bake with other baking enthusiasts and join our special events.'),
(12, 'BasketballSoc', 'Uniting basketball enthusiasts for games, events, and skill development.'),
(13, 'MusicSoc', 'Here we share our love for music through carrying out performances and events'),
(14, 'ArtSoc', 'Fostering creativity through having art sessions where you can paint and design your heart out.'),
(15, 'PhotographySoc', 'Practice your photography skills and master the art of capturing the moment.'),
(16, 'Science Fiction Society', 'Diving into the world of science fiction through discussions of ideas and events.'),
(17, 'CompSoc', 'Exploring and holding discussions about new advancements in computer science.');

-- associative entity, briding between student and society table
DROP TABLE IF EXISTS StudentSociety;
CREATE TABLE StudentSociety (
    URN INT UNSIGNED NOT NULL,
    Soc_ID INT UNSIGNED NOT NULL,
    PRIMARY KEY (URN, Soc_ID),
    FOREIGN KEY (URN) REFERENCES Student(URN),
    FOREIGN KEY (Soc_ID) REFERENCES Society(Soc_ID)
);

INSERT INTO StudentSociety (URN, Soc_ID) VALUES
(612345, 2), -- Sara is a member of WalkingSoc
(612350, 5), -- Yunli is a member of DanceSoc
(612351, 6), -- Costas is a member of FootballSoc
(612351, 10), -- Costas is a member of RowingSoc
(612352, 11), -- Tom is a member of BakingSoc
(612352, 13), -- Tom is a member of MusicSoc
(612348, 1), -- Iyabo is a member of LiteratureSoc
(612353, 8), -- Simon is a member of RugbySoc
(612354, 9), -- Sue is a member of ClimbingSoc
(612354, 15); -- Sue is a member of PhotographySoc

-- societyleader table which uses society as FK. The leader of the corresponding society will be deleted if the society is deleted.
DROP TABLE IF EXISTS SocietyLeader;
CREATE TABLE SocietyLeader (
    SocL_ID INT UNSIGNED NOT NULL,
    Soc_ID INT UNSIGNED NOT  NULL,
	SocL_FName VARCHAR(255) NOT NULL,
    SocL_LName VARCHAR(255) NOT NULL,
    Start_Date DATE,
    PRIMARY KEY (SocL_ID),
    FOREIGN KEY (Soc_ID) REFERENCES Society(Soc_ID)
    ON DELETE CASCADE);

-- associative entity, briding between student and hobby leader table
DROP TABLE IF EXISTS StudentHobby;
CREATE TABLE StudentHobby (
    URN INT UNSIGNED NOT NULL,
    Hob_ID INT UNSIGNED NOT NULL,
    PRIMARY KEY (URN, Hob_ID),
    FOREIGN KEY (URN) REFERENCES Student(URN),
    FOREIGN KEY (Hob_ID) REFERENCES Hobby(Hob_ID)
);

INSERT INTO StudentHobby (URN, Hob_ID) VALUES
(612350, 4),  -- Yunli likes Taichi
(612350, 10), -- Yunli likes rowing
(612351, 5),  -- Costas likes ballroom dDancing
(612352, 6),  -- Tom likes football
(612353, 1),  -- Simon likes reading
(612353, 8),  -- Simon likes rugby
(612354, 3),  -- Sue likes chess
(612354, 6),  -- Sue likes football
(612345, 6),  -- Sara likes football
(612347, 7);  -- Sara likes tennis

