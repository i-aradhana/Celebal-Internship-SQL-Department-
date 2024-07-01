
CREATE FUNCTION DateFormat(@DOB DATETIME)
RETURNS NVARCHAR(10) 
AS
BEGIN
    DECLARE @FormattedDate NVARCHAR(10);
    SET @FormattedDate = CONVERT(NVARCHAR(10), @DOB, 103);
    RETURN @FormattedDate;
END;
GO


SELECT dbo.DateFormat('2023-06-14 00:00:00') AS FormattedDate;




