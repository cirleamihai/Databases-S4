use FirstBank;

select * from CreditCards;
select * from CustomerAccount;
select * from Purchases;
select * from CustomerCreditCards;
select * from BankAccounts;

drop table CreditCards;
drop table CustomerAccount;
drop table Purchases;
drop table CustomerCreditCards;
drop table BankAccounts;

create table CreditCards(
	id int identity primary key,
	number varchar(24),
	expMo int,
	expYr int,
	cvv int,

	check (cvv < 1000),
	check (expMo > 0 and expMo < 13),
);

create table Purchases (
	id int identity primary key,
	merchant varchar(255),
	totalValue int,
	cardId int foreign key references CreditCards(id)
)

create table CustomerAccount(
	id int identity primary key,
	name varchar(100),
	age int,
	dateOpened date
);

INSERT INTO CreditCards (number, expMo, expYr, cvv) VALUES
('1234 5678 9012 3456', 12, 2025, 123),
('9876 5432 1098 7654', 6, 2023, 456),
('4567 8901 2345 6789', 9, 2024, 789),
('6543 2109 8765 4321', 3, 2026, 012),
('5678 1234 5678 1234', 11, 2022, 345);

INSERT INTO Purchases (merchant, totalValue, cardId) VALUES
('Amazon', 100, 1),
('Walmart', 50, 2),
('Apple Store', 200, 3),
('Starbucks', 15, 1),
('Best Buy', 300, 4),
('Target', 75, 5),
('Nike', 150, 3),
('Uber', 25, 2),
('eBay', 60, 5),
('KFC', 20, 1);

insert into CustomerAccount values ('Cirlea Mihai Alexandru', 20, '2020-09-25')
insert into CustomerAccount values ('Cirlea Tudor Gabriel', 14, '2024-01-19')

create table CustomerCreditCards(
	custId int foreign key references CustomerAccount(id),
	cardId int foreign key references CreditCards(id)
)

insert into CustomerCreditCards values (1, 1), (1, 2), (1, 3), (2, 4), (1, 5)

create table BankAccounts(
	IBAN varchar(15) primary key,
	custId int foreign key references CustomerAccount(id)
)



insert into BankAccounts values ('RO42 BTRL 1111', 1), ('REVL RONL 1923', 1), ('SW11 SWIS 1922', 2)

CREATE PROCEDURE InsertCustomerCreditCards
    @CustomerName VARCHAR(100),
    @CustomerAge INT,
    @DateOpened DATE,
    @CardNumber VARCHAR(24),
    @ExpMo INT,
    @ExpYr INT,
    @Cvv INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        
        DECLARE @CustomerId INT, @CardId INT;

        -- Insert into CustomerAccount
        INSERT INTO CustomerAccount (name, age, dateOpened)
        VALUES (@CustomerName, @CustomerAge, @DateOpened);

        SET @CustomerId = SCOPE_IDENTITY();

        -- Insert into CreditCards
        INSERT INTO CreditCards (number, expMo, expYr, cvv)
        VALUES (@CardNumber, @ExpMo, @ExpYr, @Cvv);

        SET @CardId = SCOPE_IDENTITY();

        -- Insert into CustomerCreditCards
        INSERT INTO CustomerCreditCards (custId, cardId)
        VALUES (@CustomerId, @CardId);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;

CREATE OR ALTER PROCEDURE InsertCustomerCreditCardsPartial
    @CustomerName VARCHAR(100),
    @CustomerAge INT,
    @DateOpened DATE,
    @CardNumber VARCHAR(24),
    @ExpMo INT,
    @ExpYr INT,
    @Cvv INT
AS
BEGIN
    DECLARE @CustomerId INT, @CardId INT;

    BEGIN TRY
        -- Start a new transaction for the CustomerAccount insertion
        BEGIN TRANSACTION;

        -- Insert into CustomerAccount
        INSERT INTO CustomerAccount (name, age, dateOpened)
        VALUES (@CustomerName, @CustomerAge, @DateOpened);

        SET @CustomerId = SCOPE_IDENTITY();

        -- Commit the transaction for CustomerAccount insertion
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- Log the error
        PRINT 'Error inserting into CustomerAccount: ' + ERROR_MESSAGE();

        -- Return if failed
        RETURN;
    END CATCH

    BEGIN TRY
        -- Validate inputs before starting transactions
        IF @ExpMo < 1 OR @ExpMo > 12
        BEGIN
            THROW 50000, 'Invalid expiration month', 1;
        END

        -- Start a new transaction for the CreditCards insertion
        BEGIN TRANSACTION;

        -- Insert into CreditCards
        INSERT INTO CreditCards (number, expMo, expYr, cvv)
        VALUES (@CardNumber, @ExpMo, @ExpYr, @Cvv);

        SET @CardId = SCOPE_IDENTITY();

        -- Commit the transaction for CreditCards insertion
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- Log the error
        PRINT 'Error inserting into CreditCards: ' + ERROR_MESSAGE();

        -- Return if failed
        RETURN;
    END CATCH

    BEGIN TRY
        -- Start a new transaction for the CustomerCreditCards insertion
        BEGIN TRANSACTION;

        -- Insert into CustomerCreditCards
        INSERT INTO CustomerCreditCards (custId, cardId)
        VALUES (@CustomerId, @CardId);

        -- Commit the transaction for CustomerCreditCards insertion
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- Log the error
        PRINT 'Error inserting into CustomerCreditCards: ' + ERROR_MESSAGE();

        -- Return if failed
        RETURN;
    END CATCH
END;


-- Test InsertCustomerCreditCardsPartial Procedure - Failure Case in CreditCards
BEGIN TRY
    EXEC InsertCustomerCreditCardsPartial
        @CustomerName = 'Joe MANsdadas', 
        @CustomerAge = 40, 
        @DateOpened = '2024-01-01', 
        @CardNumber = '2321 3132 2321 2333',  
        @ExpMo = 11, 
        @ExpYr = 2026, 
        @Cvv = 3261;
END TRY
BEGIN CATCH
    PRINT 'Caught an error during the execution.';
END CATCH;

-- Verify the insertion into CustomerAccount
SELECT * FROM CustomerAccount WHERE name = 'John Doe';
-- Verify that nothing is inserted into CreditCards
SELECT * FROM CreditCards




-- Test InsertCustomerCreditCards Procedure - Success Case
EXEC InsertCustomerCreditCards 
    @CustomerName = 'Alice Smith', 
    @CustomerAge = 30, 
    @DateOpened = '2024-01-01', 
    @CardNumber = '1234567890123456', 
    @ExpMo = 12, 
    @ExpYr = 2025, 
    @Cvv = 123;

-- Verify the insertion
SELECT * FROM CustomerAccount WHERE name = 'Alice Smith';
SELECT * FROM CreditCards WHERE number = '1234567890123456';
SELECT * FROM CustomerCreditCards WHERE cardId = (SELECT id FROM CreditCards WHERE number = '1234567890123456');

-- Test InsertCustomerCreditCards Procedure - Failure Case
-- Trying to insert with a duplicate primary key value (assuming '1' already exists)
BEGIN TRY
    EXEC InsertCustomerCreditCards 
        @CustomerName = 'John Doe', 
        @CustomerAge = 'sdasdad', 
        @DateOpened = '2024-01-01', 
        @CardNumber = '1111222233334444', 
        @ExpMo = 12, 
        @ExpYr = 2026, 
        @Cvv = 321;
END TRY
BEGIN CATCH
    PRINT 'An error occurred during the execution.';
END CATCH;

-- Verify no partial insertion
SELECT * FROM CustomerAccount WHERE name = 'John Doe';
SELECT * FROM CreditCards WHERE number = '1111222233334444';
SELECT * FROM CustomerCreditCards WHERE cardId = (SELECT id FROM CreditCards WHERE number = '1111222233334444');




---------------- EXERCISE 3 (GRADE 9)

-- DIRTY READ
-- solution: Use READ COMMITTED or higher isolation level.
-- SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
-- SELECT * FROM CustomerAccount WHERE id = 1;
-- Transaction 1
BEGIN TRANSACTION;
UPDATE CustomerAccount SET name = 'Dirty Read' WHERE id = 1;
-- No commit yet


-- Transaction 2 (Dirty Read)
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SELECT * FROM CustomerAccount WHERE id = 1;    -- reads dirty read

rollback
SELECT * FROM CustomerAccount WHERE id = 1;    -- reads initial data


-- NON REPEATABLE READ
-- solution: Use REPEATABLE READ isolation level
-- SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
-- BEGIN TRANSACTION;
-- SELECT * FROM CustomerAccount WHERE id = 1;
-- Transaction 1
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
BEGIN TRANSACTION;
SELECT * FROM CustomerAccount WHERE id = 2;
-- No commit yet

-- Transaction 2 (Non-repeatable read)
UPDATE CustomerAccount SET name = 'Non Repeatable Read' WHERE id = 2;
COMMIT;

-- Transaction 1
SELECT * FROM CustomerAccount WHERE id = 2;



-- PHANTOM READ
-- solution
-- SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
-- BEGIN TRANSACTION;
-- SELECT * FROM CustomerAccount WHERE age > 30;
-- Transaction 1
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
BEGIN TRANSACTION;
SELECT * FROM CustomerAccount WHERE age > 30;
-- No commit yet

-- Transaction 2 (Phantom Read)
INSERT INTO CustomerAccount (name, age, dateOpened) VALUES ('PHANTOM READ', 35, GETDATE());
COMMIT;

-- Transaction 1
SELECT * FROM CustomerAccount WHERE age > 30;




-- DEADLOCK
-- Solution: Ensure consistent ordering of operations or use deadlock retry logic.
-- Transaction 1
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN TRANSACTION;
UPDATE CustomerAccount SET name = 'John Doe' WHERE id = 1;
-- No commit yet

-- Transaction 1
UPDATE CustomerAccount SET name = 'John Doe' WHERE id = 2; -- Waiting for Transaction 2


-- CREATE ANOTHER SQL INSTANCE TO RUN THIS
-- Transaction 2
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN TRANSACTION;
UPDATE CustomerAccount SET name = 'Jane Doe' WHERE id = 2;
-- No commit yet

-- Transaction 2
UPDATE CustomerAccount SET name = 'Jane Doe' WHERE id = 1; -- Deadlock

select * from CustomerAccount







------------4.  Update Conflict under Optimistic Isolation Level (Grade 10)

-- Transaction 1
BEGIN TRANSACTION;
SELECT * FROM CustomerAccount WHERE id = 1;
-- No commit yet

-- Transaction 2
BEGIN TRANSACTION;
UPDATE CustomerAccount SET name = 'Jane Doe' WHERE id = 1;
COMMIT;

-- Transaction 1
UPDATE CustomerAccount SET name = 'John Doe' WHERE id = 1;
COMMIT;


--- Solution: Implement optimistic concurrency control using timestamps or row versions.
-- Add a Timestamp column to the table
ALTER TABLE CustomerAccount ADD RowVersion ROWVERSION;

-- Session 1
DECLARE @OriginalRowVersion binary(8);

BEGIN TRANSACTION;

SELECT @OriginalRowVersion = RowVersion FROM CustomerAccount WHERE id = 1;
SELECT id, name, age, dateOpened, RowVersion FROM CustomerAccount WHERE id = 1;
-- Save the RowVersion value (e.g., @OriginalRowVersion = RowVersion)
-- No commit yet

-- Session 2
BEGIN TRANSACTION;
UPDATE CustomerAccount SET name = 'Jane Doe' WHERE id = 1;
COMMIT;

-- Back to Session 1
UPDATE CustomerAccount SET name = 'John Doe' WHERE id = 1 AND RowVersion = @OriginalRowVersion;
-- If RowVersion has changed, the update will not affect any rows
COMMIT;

