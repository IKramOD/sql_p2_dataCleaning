DROP TABLE IF EXISTS NashvilleHousing;
CREATE TABLE NashvilleHousing (
    UniqueID        INT,
    ParcelID        VARCHAR(20),
    LandUse         VARCHAR(50),
    PropertyAddress VARCHAR(100),
    SaleDate        VARCHAR(100),
    SalePrice      	VARCHAR(30),
    LegalReference  VARCHAR(20),
    SoldAsVacant    VARCHAR(5),
    OwnerName       VARCHAR(100),
    OwnerAddress    VARCHAR(100),
    Acreage         VARCHAR(30),
    TaxDistrict     VARCHAR(50),
    LandValue       VARCHAR(30),
    BuildingValue   VARCHAR(30),
    TotalValue      VARCHAR(30),
    YearBuilt       VARCHAR(30),
    Bedrooms        VARCHAR(30),
    FullBath        VARCHAR(30),
    HalfBath        VARCHAR(30)
);

SET GLOBAL LOCAL_INFILE=ON;
LOAD DATA LOCAL INFILE 'C:/Users/ikram/Downloads/Nashville Housing Data for Data Cleaning(Sheet1) (1).csv'
INTO TABLE NashvilleHousing
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;


-- Cleaning Data
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT * FROM nashvillehousing;
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Standardize the Date format  
SET SQL_SAFE_UPDATES = 0;

SELECT SaleDate, str_to_date(SaleDate,'%M %d, %Y')
FROM nashvillehousing;

ALTER TABLE nashvillehousing
ADD SaleDateConverted DATE;

UPDATE nashvillehousing
SET SaleDateConverted = str_to_date(SaleDate,'%M %d, %Y');

ALTER TABLE nashvillehousing
DROP COLUMN SaleDate;

-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Populate property address format
SELECT * FROM nashvillehousing 
WHERE PropertyAddress IS NULL;

SELECT PropertyAddress , substring(PropertyAddress, LOCATE(',', PropertyAddress)+2)
FROM nashvillehousing;

ALTER TABLE nashvillehousing
ADD Address VARCHAR(100);

ALTER TABLE nashvillehousing
ADD City VARCHAR(50);

UPDATE nashvillehousing
SET City = substring(PropertyAddress, LOCATE(',', PropertyAddress)+2);

UPDATE nashvillehousing
SET Address = substring(PropertyAddress,1, LOCATE(',', PropertyAddress)-1);

ALTER TABLE nashvillehousing
DROP COLUMN PropertyAddress;

SELECT * FROM nashvillehousing 
WHERE OwnerAddress IS NULL;

SELECT OwnerAddress , substring(OwnerAddress, LOCATE(',', OwnerAddress)+2)
FROM nashvillehousing;

ALTER TABLE nashvillehousing
ADD OwnerAddressUpdated VARCHAR(100);

ALTER TABLE nashvillehousing
ADD OwnerCity VARCHAR(100);

ALTER TABLE nashvillehousing
ADD OwnerState VARCHAR(100);

UPDATE nashvillehousing
SET OwnerAddressUpdated = substring(OwnerAddress,1, LOCATE(',', OwnerAddress)-1);

SELECT OwnerAddress , substring(OwnerAddress, LOCATE(',', OwnerAddress)+2)
FROM nashvillehousing;

UPDATE nashvillehousing
SET OwnerCity = substring(OwnerAddress,LOCATE(',', OwnerAddress)+2);

UPDATE nashvillehousing
SET OwnerState = substring(OwnerCity,LOCATE(',', OwnerAddress)+2);

UPDATE nashvillehousing
SET OwnerCity = substring(OwnerCity,1,LOCATE(',', OwnerCity)-1);

ALTER TABLE nashvillehousing
DROP COLUMN OwnerAddress;

-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Change 'Y' and 'N' to 'Yes' and 'No' in SoldAsVacant column
SELECT DISTINCT SoldAsVacant
FROM nashvillehousing;

UPDATE nashvillehousing
SET SoldAsVacant = 'No'
WHERE SoldAsVacant='N';

UPDATE nashvillehousing
SET SoldAsVacant = 'Yes'
WHERE SoldAsVacant='Y';
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Remove Duplicates
WITH CTE AS(
SELECT *, ROW_NUMBER() OVER (PARTITION BY 
    ParcelID, LandUse, SalePrice, LegalReference,
    SoldAsVacant, OwnerName, Acreage, TaxDistrict,
    LandValue, BuildingValue, TotalValue, YearBuilt, Bedrooms,
    FullBath, HalfBath, SaleDateConverted, Address, City,
    OwnerAddressUpdated, OwnerCity, OwnerState) AS row_num
FROM nashvillehousing)
SELECT * FROM CTE WHERE row_num > 1;
;

DELETE t1
FROM nashvillehousing t1
JOIN (
    SELECT UniqueID,
           ROW_NUMBER() OVER (
               PARTITION BY ParcelID, LandUse, SalePrice,
               LegalReference, SoldAsVacant, OwnerName,
               Acreage, TaxDistrict, LandValue,
               BuildingValue, TotalValue, YearBuilt,
               Bedrooms, FullBath, HalfBath,
               SaleDateConverted, Address, City,
               OwnerAddressUpdated, OwnerCity, OwnerState
               ORDER BY UniqueID
           ) AS row_num
    FROM nashvillehousing
) t2
ON t1.UniqueID = t2.UniqueID
WHERE t2.row_num > 1;
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Delete unused columns
ALTER TABLE nashvillehousing
DROP TaxDistrict;





































