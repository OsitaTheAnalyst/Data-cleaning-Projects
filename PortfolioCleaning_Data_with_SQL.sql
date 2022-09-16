/*
Cleaning data in Sql queries
*/
select *
from PortfolioProject.dbo.NashvilleHousing

/*
Standardizing the date to sql format
*/
select SaleDate,convert(Date,SaleDate)
from NashvilleHousing

alter table NashvilleHousing
add SaleDateConverted Date

update NashvilleHousing
set SaleDateConverted = convert(Date,SaleDate)

/*
 Populate Property Address date
*/
select * from NashvilleHousing
where PropertyAddress is null

select a.ParcelID, a.PropertyAddress,b.ParcelID,b.PropertyAddress,isnull(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null

select *
from NashvilleHousing

/*
Breaking out the PropertyAddress into columns(Address,city and state) because we can see they are still all clustered 
*/
select 
SUBSTRING(PropertyAddress,1,charindex(',',PropertyAddress) -1) as Address
,SUBSTRING(PropertyAddress,charindex(',', PropertyAddress) +1, LEN(PropertyAddress)) as City

from NashvilleHousing

alter table NashvilleHousing
add Address varchar(50)

update NashvilleHousing
set Address = SUBSTRING(PropertyAddress,1,charindex(',',PropertyAddress) -1)

alter table NashvilleHousing
add City varchar(20)

update NashvilleHousing
set City = SUBSTRING(PropertyAddress,charindex(',', PropertyAddress) +1, LEN(PropertyAddress))

/*
Breaking out the OwnersAddress into columns(Address,city and state) because we can see they are still all clustered 
*/
select OwnerAddress
from NashvilleHousing

select
PARSENAME(REPLACE(OwnerAddress,',','.'), 3)
,PARSENAME(REPLACE(OwnerAddress,',','.'), 2)
,PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
from NashvilleHousing

alter table NashvilleHousing
add OwnerSplitAddress varchar(100)

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

alter table NashvilleHousing
add OwnerSplitCity varchar(100)

update NashvilleHousing
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

alter table NashvilleHousing
add OwnerSplitState varchar(100)

update NashvilleHousing
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)

select *
from NashvilleHousing

/* change Y and N to yes and no in the soldAsVacant column*/

select distinct(SoldAsVacant),count(SoldAsVacant)
from NashvilleHousing 
group by SoldAsVacant
order by 2

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end
from NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end

--Remove duplicate rows

with RowNumCTE as(
select *,
      ROW_NUMBER() over(
	  partition by ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference
	  order by UniqueID
	  ) row_num
from NashvilleHousing
)
--select *
delete
from RowNumCTE
where row_num > 1

--Remove unused columns

alter table NashvilleHousing
drop column PropertyAddress,SaleDate,OwnerAddress

select *
from NashvilleHousing