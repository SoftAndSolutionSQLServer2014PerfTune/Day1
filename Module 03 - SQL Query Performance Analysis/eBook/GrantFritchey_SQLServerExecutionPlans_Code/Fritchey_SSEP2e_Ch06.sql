/*Listing 6.1*/
DECLARE CurrencyList CURSOR
FOR
    SELECT  CurrencyCode
    FROM    Sales.Currency
    WHERE   Name LIKE '%Dollar%'

OPEN CurrencyList

FETCH NEXT FROM CurrencyList

WHILE @@FETCH_STATUS = 0 
    BEGIN

 -- Normally there would be operations here using data from cursor

        FETCH NEXT FROM CurrencyList
    END

CLOSE CurrencyList
DEALLOCATE CurrencyList
GO

/*Listing 6.2*/
DECLARE CurrencyList CURSOR
FOR
    SELECT  CurrencyCode
    FROM    Sales.Currency
    WHERE   Name LIKE '%Dollar%'

/*Listing 6.3*/
OPEN CurrencyList

FETCH NEXT FROM CurrencyList

/*Listing 6.4*/
WHILE @@FETCH_STATUS = 0 
    BEGIN
   --Normally there would be operations here using data from cursor
        FETCH NEXT FROM CurrencyList
    END

/*Listing 6.5*/
CLOSE CurrencyList
DEALLOCATE CurrencyList
 
/*Listing 6.6*/
DECLARE CurrencyList CURSOR STATIC FOR

/*Listing 6.7*/
DECLARE CurrencyList CURSOR KEYSET FOR

/*Listing 6.8*/
DECLARE CurrencyList CURSOR READ_ONLY FOR

/*Listing 6.9*/
DECLARE @WorkTable TABLE
    (
      DateOrderNumber INT IDENTITY(1, 1) ,
      Name VARCHAR(50) ,
      OrderDate DATETIME ,
      TotalDue MONEY ,
      SaleType VARCHAR(50)
    )

DECLARE @DateOrderNumber INT ,
    @TotalDue MONEY

INSERT  INTO @WorkTable
        ( Name ,
          OrderDate ,
          TotalDue
        )
        SELECT  s.Name ,
                soh.OrderDate ,
                soh.TotalDue
        FROM    Sales.SalesOrderHeader AS soh
                JOIN Sales.Store AS s ON soh.SalesPersonID = s.SalesPersonID
        WHERE   soh.CustomerID = 29731
        ORDER BY soh.OrderDate

DECLARE ChangeData CURSOR
FOR
    SELECT  DateOrderNumber ,
            TotalDue
    FROM    @WorkTable 

OPEN ChangeData

FETCH NEXT FROM ChangeData INTO @DateOrderNumber, @TotalDue

WHILE @@FETCH_STATUS = 0 
    BEGIN
   -- Normally there would be operations here using data from cursor
        IF @TotalDue < 1000 
            UPDATE  @WorkTable
            SET     SaleType = 'Poor'
            WHERE   DateOrderNumber = @DateOrderNumber
        ELSE 
            IF @TotalDue > 1000
                AND @TotalDue < 10000 
                UPDATE  @WorkTable
                SET     SaleType = 'OK'
                WHERE   DateOrderNumber = @DateOrderNumber
            ELSE 
                IF @TotalDue > 10000
                    AND @TotalDue < 30000 
                    UPDATE  @WorkTable
                    SET     SaleType = 'Good'
                    WHERE   DateOrderNumber = @DateOrderNumber
                ELSE 
                    UPDATE  @WorkTable
                    SET     SaleType = 'Great'
                    WHERE   DateOrderNumber = @DateOrderNumber
        FETCH NEXT FROM ChangeData INTO @DateOrderNumber, @TotalDue
    END

CLOSE ChangeData
DEALLOCATE ChangeData

SELECT  *
FROM    @WorkTable

/*Listing 6.10*/
DECLARE ChangeData CURSOR STATIC

/*Listing 6.11*/
DECLARE ChangeData CURSOR KEYSET  

/*Listing 6.12*/
DECLARE ChangeData CURSOR READ_ONLY

/*Listing 6.13*/
DECLARE ChangeData CURSOR FAST_FORWARD  

/*Listing 6.14*/
DECLARE ChangeData CURSOR FORWARD_ONLY KEYSET  

/*Listing 6.15*/
SELECT  ROW_NUMBER() OVER ( ORDER BY soh.OrderDate ) ,
        s.Name ,
        soh.OrderDate ,
        soh.TotalDue ,
        CASE WHEN soh.TotalDue < 1000 THEN 'Poor'
             WHEN soh.TotalDue BETWEEN 1000 AND 10000 THEN 'OK'
             WHEN soh.TotalDue BETWEEN 10000 AND 30000 THEN 'Good'
             ELSE 'Great'
        END AS SaleType
FROM    Sales.SalesOrderHeader AS soh
        JOIN Sales.Store AS s ON soh.SalesPersonID = s.SalesPersonID
WHERE   soh.CustomerID = 29731
ORDER BY soh.OrderDate

