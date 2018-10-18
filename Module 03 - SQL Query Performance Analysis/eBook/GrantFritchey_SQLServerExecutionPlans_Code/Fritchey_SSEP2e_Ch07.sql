/*Listing 7.1*/
SELECT  p.FirstName ,
        p.LastName ,
        e.Gender ,
        a.AddressLine1 ,
        a.AddressLine2 ,
        a.City ,
        a.StateProvinceID ,
        a.PostalCode
FROM    Person.Person p
        INNER JOIN HumanResources.Employee e ON p.BusinessEntityID = e.BusinessEntityID
        INNER JOIN Person.BusinessEntityAddress AS bea ON e.BusinessEntityID = bea.BusinessEntityID
        INNER JOIN Person.Address a ON bea.AddressID = a.AddressID
FOR     XML AUTO;

/*Listing 7.2*/
SELECT  s.Name AS StoreName ,
        bec.PersonID ,
        bec.ContactTypeID
FROM    Sales.Store s
        JOIN Person.BusinessEntityContact AS bec ON s.BusinessEntityID = bec.BusinessEntityID
ORDER BY s.Name
FOR     XML AUTO;

/*Listing 7.4*/
SELECT  1 AS Tag ,
        NULL AS Parent ,
        s.Name AS [Store!1!StoreName] ,
        NULL AS [BECContact!2!PersonID] ,
        NULL AS [BECContact!2!ContactTypeID]
FROM    Sales.Store s
        JOIN Person.BusinessEntityContact AS bec ON s.BusinessEntityID = bec.BusinessEntityID
UNION ALL
SELECT  2 AS Tag ,
        1 AS Parent ,
        s.Name AS StoreName ,
        bec.PersonID ,
        bec.ContactTypeID
FROM    Sales.Store s
        JOIN Person.BusinessEntityContact AS bec ON s.BusinessEntityID = bec.BusinessEntityID
ORDER BY [Store!1!StoreName] ,
        [BECContact!2!PersonID]
FOR     XML EXPLICIT;

/*Listing 7.6*/
SELECT  s.Name AS StoreName ,
        ( SELECT    bec.BusinessEntityID ,
                    bec.ContactTypeID
          FROM      Person.BusinessEntityContact bec
          WHERE     bec.BusinessEntityID = s.BusinessEntityID
        FOR
          XML AUTO ,
              TYPE ,
              ELEMENTS
        )
FROM    Sales.Store s
ORDER BY s.Name
FOR     XML AUTO ,
            TYPE;

/*Listing 7.8*/
SELECT  s.Name AS "@StoreName" ,
        bec.PersonID AS "BECContact/@PersonId" ,
        bec.ContactTypeID AS "BECContact/@ContactTypeID"
FROM    Sales.Store s
        JOIN Person.BusinessEntityContact AS bec ON s.BusinessEntityID = bec.BusinessEntityID
ORDER BY s.Name
FOR     XML PATH;

/*Listing 7.11*/
BEGIN TRAN
DECLARE @iDoc AS INTEGER
DECLARE @Xml AS NVARCHAR(MAX)

SET @Xml = '<ROOT>
<Currency CurrencyCode="UTE" CurrencyName="Universal
  Transactional Exchange">
   <CurrencyRate FromCurrencyCode="USD" ToCurrencyCode="UTE"
     CurrencyRateDate="1/1/2007" AverageRate=".553"
     EndOfDayRate= ".558" />
   <CurrencyRate FromCurrencyCode="USD" ToCurrencyCode="UTE"
     CurrencyRateDate="6/1/2007" AverageRate=".928"
     EndOfDayRate= "1.057" />
</Currency>
</ROOT>'

EXEC sp_xml_preparedocument @iDoc OUTPUT, @Xml

INSERT  INTO Sales.Currency
        ( CurrencyCode ,
          Name ,
          ModifiedDate
        )
        SELECT  CurrencyCode ,
                CurrencyName ,
                GETDATE()
        FROM    OPENXML (@iDoc, 'ROOT/Currency',1)
           WITH ( CurrencyCode NCHAR(3), CurrencyName NVARCHAR(50) )

INSERT  INTO Sales.CurrencyRate
        ( CurrencyRateDate ,
          FromCurrencyCode ,
          ToCurrencyCode ,
          AverageRate ,
          EndOfDayRate ,
          ModifiedDate
        )
        SELECT  CurrencyRateDate ,
                FromCurrencyCode ,
                ToCurrencyCode ,
                AverageRate ,
                EndOfDayRate ,
                GETDATE()
        FROM    OPENXML(@iDoc , 'ROOT/Currency/CurrencyRate',2)
          WITH ( CurrencyRateDate DATETIME '@CurrencyRateDate',
                 FromCurrencyCode NCHAR(3) '@FromCurrencyCode',
                 ToCurrencyCode NCHAR(3) '@ToCurrencyCode', 
                 AverageRate MONEY '@AverageRate', 
                 EndOfDayRate MONEY '@EndOfDayRate' )

EXEC sp_xml_removedocument @iDoc
ROLLBACK TRAN

/*Listing 7.12*/
SELECT  p.LastName ,
        p.FirstName ,
        e.HireDate ,
        e.JobTitle
FROM    Person.Person p
        INNER JOIN HumanResources.Employee e ON p.BusinessEntityID = e.BusinessEntityID
        INNER JOIN HumanResources.JobCandidate jc ON e.BusinessEntityID = jc.BusinessEntityID
                                                     AND jc.Resume.exist(' declare namespace
        res="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/Resume";
        /res:Resume/res:Employment/res:Emp.JobTitle[contains
             (.,"Sales Manager")]') = 1;

/*Listing 7.13*/
SELECT  s.Demographics.query('
   declare namespace ss="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/StoreSurvey";
   for $s in /ss:StoreSurvey
   where ss:StoreSurvey/ss:SquareFeet > 20000
   return $s
') AS Demographics
FROM    Sales.Store s
WHERE   s.SalesPersonID = 279;

/*Listing 7.14*/
DECLARE @ManagerId HIERARCHYID;
DECLARE @BEId INT;

SET @BEId = 2;

SELECT  @ManagerID = e.OrganizationNode
FROM    HumanResources.Employee AS e
WHERE   e.BusinessEntityID = @BEId;

SELECT  e.BusinessEntityID ,
        p.LastName
FROM    HumanResources.Employee AS e
        JOIN Person.Person AS p ON e.BusinessEntityId = p.BusinessEntityId
WHERE   e.OrganizationNode.IsDescendantOf(@ManagerId) = 1

/*Listing 7.15*/
DECLARE @MyLocation GEOGRAPHY = GEOGRAPHY::STPointFromText('POINT(-122.33383 47.61066 )',
                                                           4326)
SELECT  p.LastName + ', ' + p.FirstName ,
        a.AddressLine1 ,
        a.City ,
        a.PostalCode ,
        sp.Name AS StateName ,
        a.SpatialLocation
FROM    Person.Address AS a
        JOIN Person.BusinessEntityAddress AS bea ON a.AddressID = bea.AddressID
        JOIN Person.Person AS p ON bea.BusinessEntityID = p.BusinessEntityID
        JOIN Person.StateProvince AS sp ON a.StateProvinceID = sp.StateProvinceID
WHERE   @MyLocation.STDistance(a.spatiallocation) < 1000

/*Listing 7.16*/
CREATE SPATIAL INDEX [ix_Spatial] ON [Person].[Address] 
(
[SpatialLocation]
)USING  GEOGRAPHY_GRID 
WITH (
GRIDS =(LEVEL_1 = MEDIUM,LEVEL_2 = MEDIUM,LEVEL_3 = MEDIUM,
LEVEL_4 = MEDIUM), 
CELLS_PER_OBJECT = 16, 
PAD_INDEX  = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF,
ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON
)
ON [PRIMARY]

