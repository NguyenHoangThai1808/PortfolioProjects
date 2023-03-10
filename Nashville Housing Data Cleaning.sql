/* Standardize Date Format*/

SELECT *
FROM Housing

SELECT SaleDateConverted, CONVERT(Date,SaleDate) 
FROM Housing

UPDATE Housing
SET SaleDate = CONVERT(date,SaleDate)

ALTER TABLE Housing
ADD SaleDateConverted1 DATE

UPDATE Housing
SET SaleDateConverted1 = CONVERT(date,SaleDate)



/* Populate Porperty Address Data */

SELECT a. ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Housing a
JOIN Housing b 
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL

UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Housing a
JOIN Housing b 
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL

SELECT *
FROM Housing
WHERE PropertyAddress is NULL



/*Break out Address into individual columns (Address, City, State)*/

SELECT PropertyAddress, 
    SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address, 
    SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as City
FROM Housing

ALTER TABLE Housing
ADD PropertySplitAddress NVARCHAR(255)

UPDATE Housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE Housing
ADD PropertySplitCity NVARCHAR(255)

UPDATE Housing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

SELECT 
    PARSENAME(REPLACE(OwnerAddress,',','.'),3) as OwnerSplitAddress,
    PARSENAME(REPLACE(OwnerAddress,',','.'),2) as OwnerSplitAddress,
    PARSENAME(REPLACE(OwnerAddress,',','.'),1) as OwnerSplitAddress
FROM Housing

ALTER TABLE Housing
ADD OwnerSplitAddress NVARCHAR(255)

UPDATE Housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE Housing
ADD OwnerSplitCity NVARCHAR(255)

UPDATE Housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE Housing
ADD OwnerSplitState NVARCHAR(255)

UPDATE Housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)


/* Change Y and N to Yes and No in column 'SoldAsVacant' */

SELECT DISTINCT (SoldAsVacant), COUNT(SoldAsVacant)
FROM Housing
GROUP BY SoldAsVacant

SELECT SoldAsVacant,
    CASE WHEN SoldAsVacant = 'N' THEN 'No'
        WHEN SoldAsVacant = 'Y' THEN 'Yes'
        ELSE SoldAsVacant
        END as new
FROM Housing

UPDATE Housing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'N' THEN 'No'
        WHEN SoldAsVacant = 'Y' THEN 'Yes'
        ELSE SoldAsVacant
        END 


/*Remove Duplicates*/

WITH t1 AS
(SELECT *, 
    ROW_NUMBER() OVER(
        PARTITION BY ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference
        ORDER BY UniqueID
    ) AS row_n

FROM Housing)

--DELETE--
SELECT *
FROM t1 
WHERE row_n >1






