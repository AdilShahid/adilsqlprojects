SELECT * FROM "housing";


-- standardising the date format 
ALTER TABLE "housing" ADD SaleDate1 date

update housing
SET SaleDate1 = CONVERT(Date,saleDate) 

select "SaleDate1" FROM housing;


--populating property adress (attempt1) 

SELECT ParcelId, a.propertyAddress, b.propertyAddress, ISNULL(a.propertyAddress,b.propertyAddress).
FROM [project 3 cleaning]..housing a
join [project 3 cleaning]..housing b
 on a.ParcelID =b.ParcelID
 and a.[UniqueID ]<>b.[UniqueID ]
 WHERE a.PropertyAddress is null

 -- working attempt 
	SELECT
    a.ParcelId,
    a.propertyAddress,
    b.propertyAddress,
    ISNULL(a.propertyAddress, b.propertyAddress) AS MergedAddress
FROM
    [project 3 cleaning]..housing a
JOIN
    [project 3 cleaning]..housing b ON a.ParcelID = b.ParcelID
    AND a.[UniqueID] <> b.[UniqueID]
WHERE
    a.PropertyAddress IS NULL;

update a 
set propertyAddress = ISNULL(a.propertyAddress, b.propertyAddress) 
FROM [project 3 cleaning]..housing a
join [project 3 cleaning]..housing b
 on a.ParcelID =b.ParcelID
 and a.[UniqueID ]<>b.[UniqueID ]
 WHERE a.PropertyAddress is null

 -- now there are no null adresses as seen in the following query 
 select * from [project 3 cleaning]..housing 
 where propertyaddress is null ;
 -- breaking out adress
 SELECT 
 SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1) as address 
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(propertyAddress)) as address_city  
 FROM [project 3 cleaning]..housing ;

 ALTER TABLE housing ADD Address_split nvarchar(255);
update housing
SET Address_split = SUBSTRING("PropertyAddress",1, CHARINDEX(',',PropertyAddress)-1)

 ALTER TABLE "housing" ADD Address_city nvarchar(255);
update housing
SET Address_city = SUBSTRING("PropertyAddress", CHARINDEX(',',"PropertyAddress")+1,LEN(propertyAddress))

 SELECT * FROM [project 3 cleaning]..housing;


 SELECT 
 PARSENAME(REPLACE("OwnerAddress",',','.'),3),
  PARSENAME(REPLACE(OwnerAddress,',','.'),2),
  PARSENAME(REPLACE(OwnerAddress,',','.'),1)
 FROM [project 3 cleaning]..housing ;

ALTER TABLE housing ADD ownerAddress_split nvarchar(255);
update housing
SET ownerAddress_split =PARSENAME(REPLACE("OwnerAddress",',','.'),3)

 ALTER TABLE "housing" ADD ownerAddress_city nvarchar(255);
update housing
SET ownerAddress_city =PARSENAME(REPLACE(OwnerAddress,',','.'),2)

 ALTER TABLE "housing" ADD Address_state nvarchar(255);
update housing
SET Address_state =PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT * FROM [project 3 cleaning]..housing;

-- changing y and n to yeas and no 
SELECT SoldasVacant,
CASE WHEN SoldasVacant ='y' THEN 'yes'
     WHEN SoldasVacant ='N' THEN 'no'
	 ELSE SoldasVacant
	 END
 FROM [project 3 cleaning]..housing;
 
 UPDATE housing
 SET SoldAsVacant = 
 CASE WHEN SoldasVacant ='y' THEN 'yes'
     WHEN SoldasVacant ='N' THEN 'no'
	 ELSE SoldasVacant
	 END
 FROM [project 3 cleaning]..housing;

 SELECT DISTINCT(SoldasVacant), COUNT (SoldasVacant)
  FROM [project 3 cleaning]..housing
  GROUP BY SoldasVacant
  ORDER BY 2;

-- remove duplicates 
WITH RowNumCTE AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY Parcelid,
                         PropertyAddress,
                         Saleprice,
                         Legalreference
            ORDER BY UNIQUEID
        ) AS row_num
    FROM [project 3 cleaning]..housing
	--order by ParcelID
)
SELECT *FROM ROWNUMCTE
WHERE row_num > 1
ORDER BY PropertyAddress;

-- deleting unused columns 

ALTER TABLE [project 3 cleaning]..housing
	DROP COLUMN "TaxDistrict", "propertyaddress","saledate";
