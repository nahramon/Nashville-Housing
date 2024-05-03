/*
Cleaning Data in SQL Queries
*/


Select *
From HOUSINGProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

Select SaleDateConverted, CONVERT( Date, SaleDate)
From HOUSINGProject.dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)
 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

--- Check where there are NULL in PropertyAdress and Replace them by the PropertyAdrees on the same ParcelID
Select Table1.ParcelID, Table1.PropertyAddress, Table2.ParcelID, Table2.PropertyAddress, ISNULL(Table1.PropertyAddress, Table2.PropertyAddress)
From HOUSINGProject.dbo.NashvilleHousing as Table1
JOIN HOUSINGProject.dbo.NashvilleHousing as Table2
	on Table1.ParcelID = Table2.ParcelID
	AND Table1.[UniqueID ] <> Table2.[UniqueID ] 
Where Table1.PropertyAddress is null

--- Update the table with the previous modification
UPDATE Table1
SET PropertyAddress = ISNULL(Table1.PropertyAddress, Table2.PropertyAddress)
From HOUSINGProject.dbo.NashvilleHousing as Table1
JOIN HOUSINGProject.dbo.NashvilleHousing as Table2
	on Table1.ParcelID = Table2.ParcelID
	AND Table1.[UniqueID ] <> Table2.[UniqueID ] 
Where Table1.PropertyAddress is null
--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From HOUSINGProject.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

SELECT
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
From HOUSINGProject.dbo.NashvilleHousing

--- Create Address column into the table
ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

--- Create City column into the table
ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

--- Create State column into the table (It's not exctrictly necessary since the DataBase is from Nashville)
ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)

--------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From HOUSINGProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant 
	 END
From HOUSINGProject.dbo.NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant 
	 END

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates with CTE

WITH RowNumCTE AS (
Select * ,
	ROW_NUMBER() OVER (
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID) as row_num

From HOUSINGProject.dbo.NashvilleHousing
--Order by ParcelID
)

DELETE
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress
---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select *
From HOUSINGProject.dbo.NashvilleHousing

ALTER TABLE HOUSINGProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE HOUSINGProject.dbo.NashvilleHousing
DROP COLUMN SaleDate


/*
POSSIBLE INSIGHTS

- How many sales doessn't have TotalValue, OwnerName, YearBuilt, etc compared to total sales?
- Average price per acreage in each city
- Top 10 Most Sales by owner
- Aggregation by LandUse to see the distribution of sales
- Sales by month, to see if there's seasonality 

*/

-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------