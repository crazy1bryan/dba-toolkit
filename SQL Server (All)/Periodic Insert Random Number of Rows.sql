DECLARE
	@MaxNumberOfRows	INT,
	@NumberOfRows		INT,
	@Start				INT;

SET @Start				= 1;
SET @MaxNumberOfRows	= 500;

WHILE (1 = 1)
BEGIN

SET @NumberOfRows = RAND() * @MaxNumberOfRows;

WITH AllNumbers (Number) AS
		(
			SELECT @Start AS Number
			UNION ALL
			SELECT Number + 1
			FROM AllNumbers
			WHERE Number < @NumberOfRows
		)

		INSERT INTO [dbo].[MyTable]
		(
			[Row1]
		)
		SELECT
			'SomeData'
		FROM AllNumbers OPTION (MAXRECURSION 32767);

		WAITFOR DELAY '00:01:00';
END;