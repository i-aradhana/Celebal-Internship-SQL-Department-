
CREATE FUNCTION DateFor(@DOB DATETIME)
RETURNS NVARCHAR(10) 
AS
BEGIN
    DECLARE @FormattedDate NVARCHAR(10);
    SET @FormattedDate = CONVERT(NVARCHAR(10), @DOB, 102);
    RETURN @FormattedDate;
END;
GO

-- Use the function
SELECT dbo.DateFor('2023-06-14 00:00:00') AS FormattedDate;