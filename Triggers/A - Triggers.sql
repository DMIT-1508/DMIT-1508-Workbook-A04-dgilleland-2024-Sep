-- Triggers Samples
/* Notes:
    Triggers are a special kind of stored procedure. These triggers run only in
    response to a DML statement (INSERT | UPDATE | DELETE).
    The purpose of triggers is to act as a last-moment opportunity to do something
    before the DML statement is finalized. Typically we use triggers to accomplish
    some complex types of validation of the changes to the data in our database.

    Triggers are not called directly from "outside" the database server (like regular
    stored prodedures are). Rather, they are called internally by the database server
    at the end of its doing the DML statement.

    Inside of the trigger, it's important to know that the code is executing within
    the context of that "mini" Transaction that the database server started when it
    began the DML statement. That means, in our validation we might want to do, we
    have an opportunity to ROLLBACK TRANSACTION and undo the changes.

    How does the database server know what changes to "undo"? It knows because during
    the DML statement, it sets up two additional tables - called "inserted" and "deleted"
    - where it stored the "old" information ("deleted" table) and the "new" information
    ("inserted" table). These two tables will have the exact same schema (column names
    and data types) as the table they are "attached" to.
*/
USE [A04-School]
GO
SELECT DB_NAME() AS 'Active Database'
GO
/*
DROP TRIGGER IF EXISTS Table_TriggerType
GO

CREATE TRIGGER Table_TriggerType
ON TableName
FOR Insert, Update, Delete -- Choose only the DML statement(s) that apply
AS
    -- Body of Trigger
RETURN
GO
*/
-- Making a diagnostic trigger for the first example
DROP TRIGGER IF EXISTS Activity_DML_Diagnostic
GO

CREATE TRIGGER Activity_DML_Diagnostic
ON Activity -- Part of the Activity table
FOR Insert, Update, Delete -- Show diagnostics of the Activity/inserted/deleted tables
AS
    -- Body of Trigger - Echo back the trigger context
    SELECT 'Activity Table:', StudentID, ClubId FROM Activity ORDER BY StudentID
    SELECT 'Inserted Table:', StudentID, ClubId FROM inserted ORDER BY StudentID
    SELECT 'Deleted Table:', StudentID, ClubId FROM deleted ORDER BY StudentID
RETURN
GO
-- Demonstrate the diagnostic trigger
SELECT * FROM Activity ORDER BY ClubId
SELECT * FROM Club
-- Note to self: make sure you have the CIPS club from the INSERT demo
-- I need someone to add to the CIPS club
-- SELECT * FROM Student WHERE StudentID = 200494476
INSERT INTO Activity(StudentID, ClubId) VALUES (200494476, 'CIPS')
-- (note: generally, it's not a good idea to change a primary key, even part of one)
UPDATE Activity SET ClubId = 'NASA1' WHERE StudentID = 200494476
DELETE FROM Activity WHERE StudentID = 200494476

-- 1. In order to be fair to all students, a student can only belong to a maximum of 3 clubs. Create a trigger to enforce this rule.
GO
DROP TRIGGER IF EXISTS Activity_InsertUpdate
GO

CREATE TRIGGER Activity_InsertUpdate
ON Activity
FOR Insert, Update -- Choose only the DML statement(s) that apply
AS
    -- Body of Trigger
    IF @@ROWCOUNT > 0 -- It's a good idea to see if any rows were affected first
       AND -- the next statement is our business rule
       EXISTS (SELECT A.StudentID FROM Activity AS A
               -- The next line ensures we are only dealing with students
               -- affected by the INSERT/UPDATE
               INNER JOIN inserted AS i ON A.StudentID = i.StudentID
               GROUP BY A.StudentID HAVING COUNT(A.StudentID) > 3)
    BEGIN
        -- State why I'm going to abort the changes
        RAISERROR('Max of 3 clubs that a student can belong to', 16, 1)
        -- "Undo" the changes
        ROLLBACK TRANSACTION
    END
RETURN
GO

/*  The following will list all the triggers in my database
SELECT  t.name AS TableName,
        tr.name AS TriggerName  
FROM sys.triggers AS tr
    INNER JOIN sys.tables AS t
        ON t.object_id = tr.parent_id
*/

-- Before doing my tests, examine the data in the table
-- to see what I could use for testing purposes
SELECT * FROM Activity ORDER BY StudentID
-- Then I picked student 200495500
SELECT StudentID, FirstName, LastName FROM Student WHERE StudentID = 200495500 -- This is Robert Smith

-- The following test should result in a rollback.
INSERT INTO Activity(StudentID, ClubId)
VALUES (200495500, 'CIPS') -- Robert Smith

-- The following should succeed
INSERT INTO Activity(StudentID, ClubId)
VALUES (200312345, 'CIPS') -- Mary Jane

INSERT INTO Activity(StudentID, ClubId)
VALUES (200122100, 'CIPS'), -- Peter Codd   -- New to the Activity table
       (200494476, 'CIPS'), -- Joe Cool     -- New to the Activity table
       (200522220, 'CIPS'), -- Joe Petroni  -- New to the Activity table
       (200978400, 'CIPS'), -- Peter Pan    -- New to the Activity table
       (200688700, 'CIPS')  -- Robbie Chan  -- New to the Activity table
      ,(200495500, 'CIPS')  -- Robert Smith -- This would be his 4th club!
-- SELECT * FROM Activity ORDER BY StudentID

-- 2. The Education Board is concerned with rising course costs! Create a trigger to ensure that a course cost does not get increased by more than 20% at any one time.
-- Our first question is, What table should the trigger belong to?
-- Our next question is, What DML statement(s) should launch the trigger?
GO
DROP TRIGGER IF EXISTS Course_Update_CourseCostLimit
GO

CREATE TRIGGER Course_Update_CourseCostLimit
ON Course  -- The table our trigger belongs to
FOR Update -- The DML statement that applies to this problem
AS
    -- Body of Trigger
    IF @@ROWCOUNT > 0 AND
       EXISTS(SELECT * FROM inserted AS I
              INNER JOIN deleted AS D ON I.CourseId = D.CourseId
              WHERE I.CourseCost > D.CourseCost * 1.20) -- 20% higher
              --    \ new cost / > \ max 20% increase/
    BEGIN
        RAISERROR('Students can''t afford that much of an increase!', 16, 1)
        ROLLBACK TRANSACTION
    END
RETURN
GO
-- Write the code that will test this stored procedure.
SELECT * FROM Course
UPDATE Course SET CourseCost = 1000 -- This should fail
UPDATE Course SET CourseCost = CourseCost * 1.21
UPDATE Course SET CourseCost = CourseCost * 1.195

-- 3. Too many students owe us money and keep registering for more courses! Create a trigger to ensure that a student cannot register for any more courses if they have a balance owing of more than $2800.
-- Q) What table should the trigger belong to?
-- Q) What DML statement(s) should launch the trigger?
GO
DROP TRIGGER IF EXISTS Registration_Insert_BalanceOwing
GO

CREATE TRIGGER Registration_Insert_BalanceOwing
ON Registration  -- this trigger is tied to the Registration table
                 -- thus, the inserted and deleted tables for this
                 -- trigger will mirror the structure of the Registration
                 -- table.
FOR INSERT       -- this will run on an INSERT INTO Registration(...)
AS
    -- Body of Trigger
    IF @@ROWCOUNT > 0 AND
       -- Our complex business logic involves a table OTHER THAN Registration
       -- We are effectively joining our inserted (Registration) table
       -- with the Student table to see the balance for the new students
       EXISTS(SELECT S.StudentID FROM inserted AS I -- the new data in the Registration table
              INNER JOIN Student AS S ON I.StudentID = S.StudentID
              WHERE S.BalanceOwing > 2800)
    BEGIN
        RAISERROR('Student owes too much money - cannot register student in course', 16, 1)
        ROLLBACK TRANSACTION
    END
RETURN
GO

-- BTW, you can list the triggers that exist in the database with
-- a simple query of the sys.triggers and sys.tables.
SELECT  t.name AS 'TableName',
        tr.name AS 'TriggerName'
FROM    sys.triggers AS tr
    INNER JOIN sys.tables AS t
        ON t.object_id = tr.parent_id


-- 3.b. Write code to test this trigger by creating a stored procedure called RegisterStudent that a) puts a student in a course and then b) increases the balance owing by the cost of the course.
--      Then, you will be testing the trigger by calling RegisterStudent repeatedly
--      to add a particular student to a whole bunch of courses (one at a time).
-- sp_help Registration
SELECT * FROM Student WHERE BalanceOwing > 0
GO
-- TODO: Student Answer Here...

-- 4. The Activity table uses a composite primary key. In order to ensure that parts of this key cannot be changed, write a trigger called Activity_PreventUpdate that will prevent changes to the primary key columns.
GO
DROP TRIGGER IF EXISTS Activity_PreventUpdate
GO

CREATE TRIGGER Activity_PreventUpdate
ON Activity
FOR UPDATE
AS
    IF @@ROWCOUNT > 0 -- No need to check anything else because the only columns
                      -- are the composite key columns in the table.
                      -- If there were other columns beside the composite PK,
                      -- then I could isolate my IF check by adding the following:
                        AND (Update(StudentID) OR Update(ClubId))
    BEGIN
        RAISERROR('Modifications to the composite primary key of Activity are not allowed', 16, 1)
        ROLLBACK TRANSACTION
    END
RETURN
GO
/* Testing
   SELECT * FROM Activity ORDER BY ClubID
    UPDATE Activity
    SET     ClubId = 'NASA1'
    WHERE   ClubId = 'CHESS' AND StudentID = 200495500
*/

-- 5. The school has placed a temporary hold on the creation of any more clubs. (Existing clubs can be renamed or removed, but no additional clubs can be created.) Put a trigger on the Clubs table to prevent any new clubs from being created.
-- TODO: Student Answer Here
CREATE OR ALTER TRIGGER Clubs_StopInserts
ON Club
FOR INSERT
AS
    IF @@ROWCOUNT > 0
    BEGIN
        RAISERROR('Adding new clubs is temporarily disabled', 16, 1)
        ROLLBACK TRANSACTION
    END
GO
INSERT INTO Club(ClubName, ClubId)
VALUES ('Better Results in Basic Education', 'BRIBE')
INSERT INTO Club(ClubName, ClubId)
VALUES ('Knitting for Programmers', 'KFP')
GO
-- 6. Our school DBA has suddenly disabled some Foreign Key constraints to deal with performance issues! Create a trigger on the Registration table to ensure that only valid CourseIDs, StudentIDs and StaffIDs are used for grade records. (You can use sp_help tablename to find the name of the foreign key constraints you need to disable to test your trigger.) Have the trigger raise an error for each foreign key that is not valid. If you have trouble with this question create the trigger so it just checks for a valid student ID.
-- sp_help Registration -- then disable the foreign key constraints....
ALTER TABLE Registration NOCHECK CONSTRAINT FK_GRD_CRS_CseID
ALTER TABLE Registration NOCHECK CONSTRAINT FK_GRD_STF_StaID
ALTER TABLE Registration NOCHECK CONSTRAINT FK_GRD_STU_StuID
GO
DROP TRIGGER IF EXISTS Registration_InsertUpdate_EnforceForeignKeyValues
GO

CREATE TRIGGER Registration_InsertUpdate_EnforceForeignKeyValues
ON Registration
FOR INSERT, UPDATE -- Choose only the DML statement(s) that apply
AS
	-- Body of Trigger
    IF @@ROWCOUNT > 0
    BEGIN
        -- UPDATE(columnName) is a function call that checks to see if information between the 
        -- deleted and inserted tables for that column are different (i.e.: data in that column
        -- has changed).
        DECLARE @LocalError bit = 0

        IF  UPDATE(StudentID) AND
            EXISTS (SELECT * FROM inserted AS I 
                    LEFT OUTER JOIN Student AS S ON I.StudentID = S.StudentID
                    WHERE S.StudentID IS NULL)
        BEGIN
            RAISERROR('That is not a valid StudentID', 16, 1)
            SET @LocalError = 1
        END

        IF  UPDATE(CourseID) AND
            EXISTS (SELECT * FROM inserted AS I 
                    LEFT OUTER JOIN Course AS C ON I.CourseId = C.CourseId
                    WHERE C.CourseId IS NULL)
        BEGIN
            RAISERROR('That is not a valid CourseID', 16, 1)
            SET @LocalError = 1
        END

        IF  UPDATE(StaffID) AND
            EXISTS (SELECT * FROM inserted AS I
                    LEFT OUTER JOIN Staff AS S ON I.StaffID = S.StaffID
                    WHERE S.StaffID IS NULL)
        BEGIN
            RAISERROR('That is not a valid StaffID', 16, 1)
            SET @LocalError = 1
        END

        IF @LocalError = 1
        BEGIN
            ROLLBACK TRANSACTION
        END
    END
RETURN
GO

-- How would you test the trigger?
-- TODO: Student Answer Here...
SELECT StudentID, CourseID, StaffID, Semester FROM Registration
-- Test for Bad data
INSERT INTO Registration(StudentID, CourseId, StaffID, Semester)
VALUES (199899200, 'PROG123', 300, '2025J')


GO

-- 7. Our network security officer suspects our system has a virus that is allowing students to alter their balance owing records! In order to track down what is happening we want to create a logging table that will log any changes to the balance owing in the Student table. You must create the logging table and the trigger to populate it when the balance owing is modified.
-- Step 1) Make the logging table
GO
DROP TABLE IF EXISTS BalanceOwingLog
GO
CREATE TABLE BalanceOwingLog
(
    LogID           int  IDENTITY (1,1) NOT NULL CONSTRAINT PK_BalanceOwingLog PRIMARY KEY,
    StudentID       int                 NOT NULL, -- No FK constraint
    ChangeDateTime  datetime            NOT NULL, -- When the change occurred
    OldBalance      money               NOT NULL, -- Old value
    NewBalance      money               NOT NULL  -- New value
)
GO

DROP TRIGGER IF EXISTS Student_Update_AuditBalanceOwing
GO

CREATE TRIGGER Student_Update_AuditBalanceOwing
ON Student
FOR UPDATE -- Inserting does not CHANGE, it CREATES data; Deleting does not CHANGE, it removes data
AS
    -- Body of Trigger
    IF @@ROWCOUNT > 0 AND UPDATE(BalanceOwing)
    --                    \ Function         /
    --                     \  Returns true if that column's data changed
	BEGIN
	    INSERT INTO BalanceOwingLog (StudentID, ChangedateTime, OldBalance, NewBalance)
	    SELECT I.StudentID, GETDATE(), d.BalanceOwing, i.BalanceOwing
        FROM deleted AS d 
            INNER JOIN inserted AS i on d.StudentID = i.StudentID
	    IF @@ERROR <> 0 
	    BEGIN
		    RAISERROR('Insert into BalanceOwingLog Failed',16,1)
            ROLLBACK TRANSACTION
        END    
    END
RETURN
GO

-- time to test the changes

SELECT * FROM BalanceOwingLog -- To see what's in there before an update
-- Hacker statements happening offline....
UPDATE Student SET BalanceOwing = BalanceOwing - 100 -- Hacker failed, but not disuaded
UPDATE Student SET BalanceOwing = BalanceOwing - 100 WHERE BalanceOwing > 100
SELECT * FROM BalanceOwingLog -- To see what's in there after a hack attempt
UPDATE Student SET BalanceOwing = 10000 -- He's graduated, and doesn't want competition
SELECT * FROM BalanceOwingLog -- To see what's in there after a hack attempt

-- 8. The Registration table has a composite primary key. In order to ensure that parts of this key cannot be changed, write a trigger called Registration_ProtectPrimaryKey that will prevent changes to the primary key columns.
-- TODO: Student Answer Here

-- 9. Create a trigger to ensure that an instructor does not teach more than 3 courses in a given semester.
-- TODO: Student Answer Here

-- 10. Create a trigger to ensure that students cannot be added to a course if the course is already full.
-- TODO: Student Answer Here

-- 11. Change the Registration_ClassSizeLimit trigger so students will be added to a wait list if the course is already full; make sure the student is not added to Registration, and include a message that the student has been added to a waitlist. You should design a WaitList table to accommodate the changes needed for adding a student to the course once space is freed up for the course. Students should be added on a first-come-first-served basis (i.e. - include a timestamp in your WaitList table)
-- TODO: Student Answer Here

-- 12. (Advanced) Create a trigger called Registration_AutomaticEnrollment that will add students from the wait list of a course whenever another student withdraws from that course. Pull your students from the WaitList table on a first-come-first-served basis.
-- TODO: Student Answer Here
