Select *
From [Portfolio Projects]..Nashville$

--Standardize Date format
Select SaleDateConverted
From [Portfolio Projects]..Nashville$

Update Nashville$
Set SaleDate = CONVERT(Date, SaleDate)

Alter Table Nashville$
Add SaleDateConverted Date;

Update Nashville$
Set SaleDateConverted = CONVERT(Date, SaleDate)

---Populate Property Address data
Select * 
From [Portfolio Projects]..Nashville$
--where propertyaddress is null
order by parcelid


Select a.parcelid,a.propertyaddress, b.parcelid, b.propertyaddress,ISNULL(a.propertyaddress,b.propertyaddress)
From [Portfolio Projects]..Nashville$ a
Join [Portfolio Projects]..Nashville$ b
On a.parcelid = b.parcelid
and a.uniqueid <> b.uniqueid
where a.propertyaddress is null


Update a
Set PropertyAddress = ISNULL(a.propertyaddress,b.propertyaddress) 
From [Portfolio Projects]..Nashville$ a
Join [Portfolio Projects]..Nashville$ b
On a.parcelid = b.parcelid
and a.uniqueid <> b.uniqueid
where a.propertyaddress is null

----------------------------------------------------------------------------------------------------------------

--Breakking Out Address Into Individual(Address, City, State)]


Select * 
From [Portfolio Projects]..Nashville$
--where propertyaddress is null
--order by parcelid

Select 
SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))as Address
From [Portfolio Projects]..Nashville$

Alter Table Nashville$
Add PropertySplitAddress Nvarchar(255);

Update Nashville$
Set PropertySplitAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1)


Alter Table Nashville$
Add PropertySplitCity Nvarchar(255);

Update Nashville$
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

Select *
From [Portfolio Projects]..Nashville$




Select OwnerAddress
From [Portfolio Projects]..Nashville$

Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
From [Portfolio Projects]..Nashville$

Alter Table Nashville$
Add OwnerSplitAddress Nvarchar(255);

Update Nashville$
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)


Alter Table Nashville$
Add OwnerSplitCity Nvarchar(255);

Update Nashville$
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)


Alter Table Nashville$
Add OwnerSplitState Nvarchar(255);

Update Nashville$
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)



----------------------------------------------------------------------------------------------------------------------------
--Change Y and N to Yes and No in " Sold as Vacant " Field

Select Distinct(Soldasvacant), COUNT(SOLDASVACANT)
From [Portfolio Projects]..Nashville$
GROUP BY SOLDASVACANT
ORDER BY 2

Select SOLDASVACANT
, CASE When SOLDASVACANT = 'Y' THEN 'Yes'
	   When SOLDASVACANT = 'N' THEN 'No'
	   Else SOLDASVACANT
	   END
From [Portfolio Projects]..Nashville$

Update Nashville$
Set SOLDASVACANT = CASE When SOLDASVACANT = 'Y' THEN 'Yes'
	   When SOLDASVACANT = 'N' THEN 'No'
	   Else SOLDASVACANT
	   END

----------------------------------------------------------------------------------------------------------------------------------

--Removing Duplicates

--Using Cte
With RowNumCTE As(
Select *,
 Row_Number() Over(
Partition BY ParcelId,
			 PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 Order BY UniqueID ) row_num

From [Portfolio Projects]..Nashville$
--order by parcelid
)
Select *
From RowNumCTE
where row_num > 1
--order by PropertyAddress


-------------------------------------------------------------------------------------------------------------------------------
--Delete Unused Columns
Select *
From [Portfolio Projects]..Nashville$

Alter Table Nashville$
Drop column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table Nashville$
Drop column SaleDate