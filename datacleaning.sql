--data cleaning
select * from sheet1$

--formatting date
--select saledate,convert(date,saledate)
--from PortfolioProject..sheet1$

--update sheet1$
--set saledate=convert(date,saledate)


select saledateconverted,convert(date,saledate)
from PortfolioProject..sheet1$
alter table sheet1$
add saledateconverted date;
update sheet1$
set saledateconverted=convert(date,saledate)

--populate address
select*from PortfolioProject..sheet1$
order by parcelid

select a.parcelid,a.propertyaddress,b.parcelid,b.propertyaddress,isnull(a.propertyaddress,b.propertyaddress)
from PortfolioProject..sheet1$ a
join PortfolioProject..sheet1$ b
on a.parcelid=b.parcelid
and a.uniqueid<>b.uniqueid
where a.propertyaddress is null

update a
set propertyaddress=isnull(a.propertyaddress,b.propertyaddress)
from PortfolioProject..sheet1$ a
join PortfolioProject..sheet1$ b
on a.parcelid=b.parcelid
and a.uniqueid<>b.uniqueid
where a.propertyaddress is null

-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From PortfolioProject.dbo.sheet1$
--Where PropertyAddress is null
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
From PortfolioProject.dbo.sheet1$


ALTER TABLE sheet1$
Add PropertySplitAddress Nvarchar(255);

Update sheet1$
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE sheet1$
Add PropertySplitCity Nvarchar(255);

Update sheet1$
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


select*from PortfolioProject..sheet1$

--owneraddrwss


Select OwnerAddress
From PortfolioProject.dbo.sheet1$


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProject.dbo.sheet1$



ALTER TABLE sheet1$
Add OwnerSplitAddress Nvarchar(255);

Update sheet1$
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE sheet1$
Add OwnerSplitCity Nvarchar(255);

Update sheet1$
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE sheet1$
Add OwnerSplitState Nvarchar(255);

Update sheet1$
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From PortfolioProject.dbo.sheet1$

--convert y to yes and n to no
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.sheet1$
Group by SoldAsVacant
order by 2




Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProject.dbo.sheet1$


Update sheet1$
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


	   --remove duplicate rows
	   WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject.dbo.sheet1$
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



Select *
From PortfolioProject.dbo.sheet1$


-- Delete Unused Columns



Select *
From PortfolioProject.dbo.sheet1$


ALTER TABLE PortfolioProject.dbo.sheet1$
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

