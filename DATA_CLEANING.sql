/* 
Cleaning Data in SQL Queries
*/
SELECT * 
FROM portfolio_.test1

-- -----------------------------------------------------------------------------------------

-- Standardize Date Format

SELECT SalesDateconverted, STR_TO_DATE(SaleDate,'%M %d,%Y')
FROM portfolio_.test1

ALTER TABLE test1
ADD SalesDateConverted Date

UPDATE test1
SET SalesDateConverted = STR_TO_DATE(SaleDate,'%M %d,%Y')

-- ---------------------------------------------------------------------------------------

-- Populate Property Address Data

SELECT * FROM portfolio_.test1
WHERE PropertyAddress is NULL

SELECT a.ParcelID, a.PropertyAddress,b.ParcelID, b.PropertyAddress,COALESCE(a.PropertyAddress,b.PropertyAddress) 
FROM portfolio_.test1 a
JOIN portfolio_.test1 b
     ON a.ParcelID = b.ParcelID
     AND a.UniqueID != b.UniqueID
WHERE a.PropertyAddress is NULL

UPDATE portfolio_.test1 a
JOIN portfolio_.test1 b
     ON a.ParcelID = b.ParcelID
     AND a.UniqueID != b.UniqueID
SET a.PropertyAddress = COALESCE(a.PropertyAddress,b.PropertyAddress) 
WHERE a.PropertyAddress is NULL

-- -----------------------------------------------------------------------------------------
-- Breaking out Address Into Individual columns

SELECT PropertyAddress
FROM portfolio_.test1
-- ORDER BY ParcelID

SELECT 
SUBSTRING(PropertyAddress,1, LOCATE(',',PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress,LOCATE(',',PropertyAddress)+1, CHAR_LENGTH(PropertyAddress)) AS Address
FROM portfolio_.test1

ALTER TABLE test1
ADD PropertySplitAddress NVARCHAR(255)

UPDATE test1
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1, LOCATE(',',PropertyAddress)-1)

ALTER TABLE test1
ADD PropertySplitCity NVARCHAR(255)

UPDATE test1
SET PropertySplitCity = SUBSTRING(PropertyAddress,LOCATE(',',PropertyAddress)+1, CHAR_LENGTH(PropertyAddress)) 

SELECT * FROM portfolio_.test1

SELECT OwnerAddress
FROM portfolio_.test1

SELECT
    SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', -3), '.', 1) ,
    SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', -2), '.', 1) ,
    SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', -1), '.', 1)
FROM portfolio_.test1

ALTER TABLE test1
ADD OwnerSplitAddress NVARCHAR(255)

UPDATE test1
SET OwnerSplitAddress = SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', -3), '.', 1) 

ALTER TABLE test1
ADD OwnerSplitCity NVARCHAR(255)

UPDATE test1
SET OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', -2), '.', 1)

ALTER TABLE test1
ADD OwnerSplitState NVARCHAR(255)

UPDATE test1
SET OwnerSplitState = SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', -1), '.', 1)

-- ------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes AND No In "Sold as Vacant" field
SELECT DISTINCT(SoldAsVacant) , COUNT(SoldAsVacant)
FROM portfolio_.test1
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant 
, CASE When SoldAsVacant = "Y" THEN "Yes"
	   When SoldAsVacant = "N" THEN "No"
       ELSE SoldAsVacant
  END 
FROM portfolio_.test1

UPDATE portfolio_.test1
SET SoldAsVacant = CASE When SoldAsVacant = "Y" THEN "Yes"
	   When SoldAsVacant = "N" THEN "No"
       ELSE SoldAsVacant
       END 
       
-- --------------------------------------------------------------------------------------------

-- Remove Duplicates
-- Created a temporary table with row numbers

CREATE TEMPORARY TABLE TempTable AS
SELECT UniqueID
FROM (
    SELECT UniqueID, 
           ROW_NUMBER() OVER (
               PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
               ORDER BY UniqueID
           ) AS row_num
    FROM portfolio_.test1
) AS SubQuery
WHERE row_num > 1

DELETE FROM portfolio_.test1
WHERE UniqueID IN (SELECT UniqueID FROM TempTable)

DROP TEMPORARY TABLE TempTable

-- -----------------------------------------------------------------------------------------------

-- Delete Unused Columns

SELECT *
FROM portfolio_.test1

ALTER TABLE portfolio_.test1 
DROP COLUMN OwnerAddress,
DROP COLUMN TaxDistrict,
DROP COLUMN PropertyAddress

ALTER TABLE portfolio_.test1 
DROP COLUMN SaleDate
