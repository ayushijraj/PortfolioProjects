/* DATA CLEANING WALKTHROUGH

Dataset: Nashville Housing Data */

Select *
from ProjectPortfolio..NashvilleHousing

-- Step 1: Standardize Date Format
Select SaleDateConverted, CONVERT(Date, SaleDate) 
from ProjectPortfolio..NashvilleHousing

Update NashvilleHousing
Set SaleDate = CONVERT(Date, SaleDate)

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = CONVERT(Date, SaleDate)


-- Step 2: Populate Property Address Data

Select PropertyAddress
from ProjectPortfolio..NashvilleHousing

Select *
from ProjectPortfolio..NashvilleHousing
where PropertyAddress is null

Select * 
from ProjectPortfolio..NashvilleHousing
-- where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from ProjectPortfolio..NashvilleHousing a
JOIN ProjectPortfolio..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from ProjectPortfolio..NashvilleHousing a
JOIN ProjectPortfolio..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from ProjectPortfolio..NashvilleHousing a
JOIN ProjectPortfolio..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- Step 3: Breaking out Address into Individual Columns (Address, City, State)
Select PropertyAddress
from ProjectPortfolio..NashvilleHousing
-- where PropertyAddress is null
--order by ParcelID

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress) -1) as Address,
CHARINDEX(',' , PropertyAddress) 
from ProjectPortfolio..NashvilleHousing


Select
    SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address,
    SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City
From ProjectPortfolio..NashvilleHousing

Alter Table ProjectPortfolio..NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update ProjectPortfolio..NashvilleHousing
Set PropertySplitAddress = Convert(Date, SaleDate)

Alter Table ProjectPortfolio..NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update ProjectPortfolio..NashvilleHousing
Set PropertySplitCity = Convert(Date, SaleDate)

Select *
from ProjectPortfolio..NashvilleHousing

Select OwnerName
From ProjectPortfolio..NashvilleHousing
where OwnerName is null

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
from ProjectPortfolio..NashvilleHousing
/* Explanation:
OwnerAddress has values like:
"123 Main St, Nashville, TN"
REPLACE(OwnerAddress, ',', '.')
Changes it to: "123 Main St. Nashville. TN"
→ PARSENAME() only works with dots, not commas.
PARSENAME(..., 3) → picks first part = "123 Main St"
PARSENAME(..., 2) → picks second part = "Nashville"
PARSENAME(..., 1) → picks third part = "TN"
 In short:
This splits the OwnerAddress into Address, City, and State using SQL’s PARSENAME() trick. */

Alter Table ProjectPortfolio..NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update ProjectPortfolio..NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

Alter Table ProjectPortfolio..NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update ProjectPortfolio..NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

Alter Table ProjectPortfolio..NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update ProjectPortfolio..NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

Select * 
from ProjectPortfolio..NashvilleHousing


-- Step 4: Change Y and N and No in "Sold as Vacant" field
Select DISTINCT(SoldAsVacant), Count(SoldAsVacant)
From ProjectPortfolio..NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant, 
CASE
When SoldAsVacant = 'Y' Then 'Yes'
When SoldAsVacant = 'N' Then 'No'
ELSE SoldAsVacant
END
From ProjectPortfolio..NashvilleHousing

Update ProjectPortfolio..NashvilleHousing
SET SoldAsVacant =
CASE
When SoldAsVacant = 'Y' Then 'Yes'
When SoldAsVacant = 'N' Then 'No'
ELSE SoldAsVacant
END
From ProjectPortfolio..NashvilleHousing

Select * 
from ProjectPortfolio..NashvilleHousing


-- Step 5: Remove Duplicates
 With RowNumCTE As(
 Select *,
    Row_Number() Over(
	PARTITION BY ParcelID, 
				   PropertyAddress,
				   SalePrice,
				   SaleDate,
				   LegalReference
				   Order by UniqueID
				   ) Row_num
From Projectportfolio..NashvilleHousing
-- Order by ParcelID
)
Select * 
from RowNumCTE
where row_num >1
--Order by PropertyAddress

/* This CTE (Common Table Expression) assigns a row number to duplicate records in the NashvilleHousing table based on a group of columns.
PARTITION BY: Groups rows that have the same ParcelID, PropertyAddress, SalePrice, SaleDate, and LegalReference.

ROW_NUMBER(): Gives a unique number to each row within that group.

Duplicates get row numbers 1, 2, 3...

Why use it?
To find and remove duplicate rows by keeping only the first one (Row_num = 1). */

-- Duplicates Removed
 With RowNumCTE As(
 Select *,
    Row_Number() Over(
	PARTITION BY ParcelID, 
				   PropertyAddress,
				   SalePrice,
				   SaleDate,
				   LegalReference
				   Order by UniqueID
				   ) Row_num
From Projectportfolio..NashvilleHousing
-- Order by ParcelID
)
Delete
from RowNumCTE
where row_num >1
--Order by PropertyAddress

-- Step 6: Drop Unnecessary Columns
  Select * 
  From ProjectPortfolio..NashvilleHousing

  Alter Table ProjectPortfolio..NashvilleHousing
  Drop Column OwnerAddress, TaxDistrict, PropertyAddress

  Alter Table ProjectPortfolio..NashvilleHousing
  Drop Column SaleDate

