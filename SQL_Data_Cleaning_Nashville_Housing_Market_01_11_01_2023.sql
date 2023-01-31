/* 

Data Cleaning Phase 

*/

SELECT *
FROM PortfolioProject.dbo.Nashvillehousing

---------------------------------------------------------------------
--STANDARDIZE DATA FORMAT COLUMN SaleData

ALTER TABLE PortfolioProject.DBO.Nashvillehousing
ADD SaleDateConverted DATE;

UPDATE PortfolioProject.DBO.Nashvillehousing
SET SaleDateConverted = CONVERT(DATE,SALEDATE)



----------------------------------------------------------------------
--POPULATE PROPERTY ADDRESS DATA

SELECT * 
FROM PortfolioProject.DBO.Nashvillehousing
WHERE PropertyAddress IS NULL


SELECT * 
FROM PortfolioProject.DBO.Nashvillehousing
ORDER BY ParcelID

SELECT * 
FROM PortfolioProject.DBO.Nashvillehousing A
JOIN PortfolioProject.DBO.Nashvillehousing B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ] 

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM PortfolioProject.DBO.Nashvillehousing A
JOIN PortfolioProject.DBO.Nashvillehousing B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ] 
WHERE A.PropertyAddress IS NULL

UPDATE A
SET A.PropertyAddress = ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM PortfolioProject.DBO.Nashvillehousing A
JOIN PortfolioProject.DBO.Nashvillehousing B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ] 
WHERE A.PropertyAddress IS NULL

------------------------------------------------------------------------------

--BREAKING OUT PROPERTY ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY)

SELECT PropertyAddress
FROM PortfolioProject.DBO.Nashvillehousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS City
FROM PortfolioProject.DBO.Nashvillehousing


ALTER TABLE PortfolioProject.DBO.Nashvillehousing
ADD PropertySplitedAddress NVARCHAR(260);

UPDATE PortfolioProject.DBO.Nashvillehousing
SET PropertySplitedAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)


ALTER TABLE PortfolioProject.DBO.Nashvillehousing
ADD PropertySplitedCity NVARCHAR(260);

UPDATE PortfolioProject.DBO.Nashvillehousing
SET PropertySplitedCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

-----------------------------------------------------------------------------------------------------
--BREAKING OUT OWNER ADDRESS INTO INDIVIDUAL ADDRESSES

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
FROM PortfolioProject.DBO.Nashvillehousing

ALTER TABLE PortfolioProject.DBO.Nashvillehousing
ADD OwnerSplitedAddress NVARCHAR(260);

UPDATE PortfolioProject.DBO.Nashvillehousing
SET OwnerSplitedAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

ALTER TABLE PortfolioProject.DBO.Nashvillehousing
ADD OwnerSplitedCity NVARCHAR(260);

UPDATE PortfolioProject.DBO.Nashvillehousing
SET OwnerSplitedCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

ALTER TABLE PortfolioProject.DBO.Nashvillehousing
ADD OwnerSplitedCityCode NVARCHAR(260);

UPDATE PortfolioProject.DBO.Nashvillehousing
SET OwnerSplitedCityCode = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)


-------------------------------------------------------------------------
--CHANGING Y AND N TO YES AND NO IN SOLDASVACANT COLUMN

SELECT SoldAsVacant
FROM PortfolioProject.dbo.Nashvillehousing

SELECT DISTINCT SoldAsVacant
FROM PortfolioProject.dbo.Nashvillehousing

SELECT DISTINCT SoldAsVacant , COUNT( SoldAsVacant) AS NumberOfCases
FROM PortfolioProject.dbo.Nashvillehousing
GROUP BY SoldAsVacant
ORDER BY NumberOfCases

SELECT SoldAsVacant,
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM PortfolioProject.dbo.Nashvillehousing

UPDATE PortfolioProject.dbo.Nashvillehousing
SET SoldAsVacant = CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END



--------------------------------------------------------
--REMOVE DUPLICATE

SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				PropertyAddress,
				SaleDate,
				SalePrice,
				LegalReference
				ORDER BY
					UniqueID
					) row_num
FROM PortfolioProject.dbo.Nashvillehousing


WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				PropertyAddress,
				SaleDate,
				SalePrice,
				LegalReference
				ORDER BY
					UniqueID
					) row_num
FROM PortfolioProject.dbo.Nashvillehousing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1


WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				PropertyAddress,
				SaleDate,
				SalePrice,
				LegalReference
				ORDER BY
					UniqueID
					) row_num
FROM PortfolioProject.dbo.Nashvillehousing
)
DELETE 
FROM RowNumCTE
WHERE row_num > 1

------------------------------------------------------------------------
--DELETE UNUSED COLUMNS

SELECT *
FROM PortfolioProject.dbo.Nashvillehousing

ALTER TABLE PortfolioProject.dbo.Nashvillehousing
DROP COLUMN SaleDate, PropertyAddress, OwnerAddress, TaxDistrict
