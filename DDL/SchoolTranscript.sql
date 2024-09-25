/* **********************************************
 * Simple Table Creation - Columns and Primary Keys
 *
 * School Transcript
 *  Version 1.0.0
 *
 * Author: Dan Gilleland
 ********************************************** */
-- Create the database
IF NOT EXISTS (SELECT name FROM master.sys.databases WHERE name = N'SchoolTranscript')
BEGIN
    CREATE DATABASE [SchoolTranscript]
END
GO

-- Switch execution context to the database
USE [SchoolTranscript] -- remaining SQL statements will run against the SchoolTranscript database
GO

-- Create Tables...
-- 1) Drop tables that already exist
--    Drop the table in the reverse order
--    that they were created
DROP TABLE IF EXISTS Courses
DROP TABLE IF EXISTS Students

-- 2) Create the tables in the right order
--    Parent tables before child tables
CREATE TABLE Students
(
    StudentID       int,
    GivenName       varchar(50),
    Surname         varchar(50),
    DateOfBirth     datetime,
    Enrolled        bit
)

CREATE TABLE Courses
(
    Number          varchar(10),
    Name            varchar(50),
    Credits         decimal(3,1),
    Hours           tinyint,
    Active          bit,
    Cost            money
)