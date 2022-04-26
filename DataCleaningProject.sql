Select *
From PortfolioProject.dbo.Nashville

--Converting Saledate to actual date without the time
Select Saledate, CONVERT(Date, Saledate) as Date
From PortfolioProject.dbo.Nashville

--Now we update it after checking
Update Nashville
Set Saledate = CONVERT(Date, Saledate)
Select Saledate
From PortfolioProject.dbo.Nashville

--Hmm which seems to be not working, we can try altering table
Alter Table Nashville
Alter Column Saledate Date;
Select *
From PortfolioProject.dbo.Nashville
--Now we successfuly changed the saledate to actual date format.

Select PropertyAddress
From PortfolioProject.dbo.Nashville
Where PropertyAddress is NULL
--There exist some null values for random reason.  Around 29 of those
Select *
From PortfolioProject.dbo.Nashville
Order by ParcelID
--Some parcelID have the same address


Select a.ParcelID, a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.Nashville a 
Join PortfolioProject.dbo.Nashville b
	On a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is NULL

--Theres around 35 null values where ParcelID is the same, Unique ID is different
--and PropertyAddress is NULL
--We use ISNULL to update the data where copy b property address to a property address
Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.Nashville a 
Join PortfolioProject.dbo.Nashville b
	On a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is NULL

--Checking for changes 

Select a.ParcelID, a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.Nashville a 
Join PortfolioProject.dbo.Nashville b
	On a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is NULL
-- And its good to go as no values is found. 

Select PropertyAddress
From PortfolioProject.dbo.Nashville
Where PropertyAddress is NULL

--Double checking to making sure. 

Select *
From PortfolioProject.dbo.Nashville

--Breaking out address into individual columns(address, city, state)

Select PropertyAddress
From PortfolioProject.dbo.Nashville

--using substring and character index to seperate the data.
Select
SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) as Address
From PortfolioProject.dbo.Nashville

--Using substring method to get the Address and get rid of the comma by searching for value index 
-- and with that index we use -1 to get rid of the comma
--Using substring to find the first comma and use that index to +1 and rest is length of propertAddress

--SPlit address and city into two new columns 
Alter Table Nashville
Add PropertySplitAddress NVARCHAR(255);

Update Nashville
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress) -1)

Alter Table Nashville
Add PropertySplitCity NVARCHAR(255);

Update Nashville
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))

-- Updated those two new columns 
Select OwnerAddress
From PortfolioProject.dbo.Nashville

--Need to seperate Address, city, states with a different method

Select 
Parsename(REPLACE(OwnerAddress, ',','.'),3),
Parsename(REPLACE(OwnerAddress, ',','.'),2),
Parsename(REPLACE(OwnerAddress, ',','.'),1)
From PortfolioProject.dbo.Nashville

--We replaced the ',' with '.' so we can call the parsename function and return the strings
--Now create the columns in the table and we should be good

Alter table Nashville
Add OwnerSplitAddress NVARCHAR(255);
Alter table Nashville
Add OwnerSplitCity NVARCHAR(255);
Alter table Nashville
Add OwnerSplitState NVARCHAR(255);

Update Nashville
SET OwnerSplitAddress = Parsename(REPLACE(OwnerAddress, ',','.'),3)

Update Nashville
SET OwnerSplitCity = Parsename(REPLACE(OwnerAddress, ',','.'),2)

Update Nashville
SET OwnerSplitState = Parsename(REPLACE(OwnerAddress, ',','.'),1)

--We updated the data successfuly 
Select *
From PortfolioProject.dbo.Nashville

--Checking again. 

Select SoldAsVacant, count(SoldAsVacant) as Variable
From PortfolioProject.dbo.Nashville
group by SoldAsVacant

--Knows theres is 4 distinct value want to change N to No and Y to Yes and Rest remains the same
Select SoldAsVacant,

Case
	When SoldAsVacant = 'N' Then  'No'
	When SoldAsVacant = 'Y' Then  'Yes'
	Else SoldAsVacant 
End
From PortfolioProject.dbo.Nashville

Update Nashville
Set SoldAsVacant = Case
	When SoldAsVacant = 'N' Then  'No'
	When SoldAsVacant = 'Y' Then  'Yes'
	Else SoldAsVacant 
End
From PortfolioProject.dbo.Nashville
--We successfully updated the data

Select SoldAsVacant, count(SoldAsVacant) as okay
From PortfolioProject.dbo.Nashville
group by SoldAsVacant

--Great, now all the column is fixed for SoldAsVacant

With RowNumCTE AS (
Select *,
	ROW_NUMBER() OVER(
	Partition by ParcelID, 
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				Order by 
					UniqueID
					) row_num
From PortfolioProject.dbo.Nashville
--Order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress

--Removing duplicates

--Delete unused columns

Alter table PortfolioProject.dbo.Nashville
Drop column OwnerAddress, TaxDistrict, PropertyAddress

--Dropping unused or useless column to make our data looks better.
Select *
From PortfolioProject.dbo.Nashville