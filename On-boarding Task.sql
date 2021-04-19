--1. Write queries to return the following: 
--a. Display a list of all property names and their property id’s for Owner Id: 1426. 
SELECT op.OwnerId, p.Name AS PropertyName, p.Id AS PropertyId
FROM OwnerProperty op
LEFT JOIN Property p 
	on op.PropertyId = p.Id
WHERE op.OwnerId = '1426'


--b. Display the current home value for each property in question a). 
SELECT op.OwnerId, p.Name AS PropertyName, p.Id AS PropertyId, pf.CurrentHomeValue 
FROM OwnerProperty op
LEFT JOIN Property p 
	ON op.PropertyId = p.Id
LEFT JOIN PropertyFinance pf
	ON p.Id = pf.PropertyId
WHERE op.OwnerId = '1426'

--SELECT op.OwnerId, p.Name AS PropertyName, p.Id AS PropertyId, hv.Value AS CurrentHomeValue 
--FROM OwnerProperty op
--LEFT JOIN Property p 
--	ON op.PropertyId = p.Id
--LEFT JOIN PropertyHomeValue hv 
--	ON p.Id = hv.PropertyId
--LEFT JOIN PropertyHomeValueType vt 
--	ON hv.HomeValueTypeId = vt.Id
--WHERE op.OwnerId = '1426' AND vt.HomeValueType = 'Current' AND hv.IsActive = '1'



--c. For each property in question a), return the following:                                                                      
--i.Using rental payment amount, rental payment frequency, tenant start date and tenant end date to write a query that returns the sum of all payments from start date to end date. 

SELECT op.OwnerId, p.Id AS PropertyId, p.Name AS PropertyName, tp.StartDate AS TenantStartDate, tp.EndDate AS TenantEndDate, 
pf.Name AS PaymentFrequencies, tp.PaymentAmount, 
CAST(CASE 
	WHEN pf.Name = 'Weekly' THEN DATEDIFF(WEEK, tp.StartDate, tp.EndDate)*tp.PaymentAmount
	WHEN pf.Name = 'Fortnightly' THEN DATEDIFF(WEEK, tp.StartDate, tp.EndDate)*tp.PaymentAmount/2
	WHEN pf.Name = 'Monthly' THEN (DATEDIFF(MONTH, tp.StartDate, tp.EndDate)+1)*tp.PaymentAmount
END AS NUMERIC(36,2)) AS TotalAmount
FROM OwnerProperty op
LEFT JOIN Property p
	ON op.PropertyId = p.Id
LEFT JOIN TenantProperty tp
	ON tp.PropertyId = op.PropertyId
LEFT JOIN TenantPaymentFrequencies AS pf 
	ON tp.PaymentFrequencyId = pf.Id
WHERE op.OwnerId = '1426'


--SELECT op.OwnerId, p.Id AS PropertyId, p.Name AS PropertyName, tp.StartDate AS TenantStartDate, tp.EndDate AS TenantEndDate, pf.Name AS PaymentFrequencies,
--DATEDIFF(DAY, tp.StartDate, tp.EndDate)/pf.PaymentFrequency AS NumberOfPayment, tp.PaymentAmount, 
--CAST(tp.PaymentAmount*ROUND(DATEDIFF(DAY, tp.StartDate, tp.EndDate)/pf.PaymentFrequency,0) AS NUMERIC(36,2)) AS TotalAmount
--FROM OwnerProperty op
--LEFT JOIN Property p
--	ON op.PropertyId = p.Id
--LEFT JOIN TenantProperty tp
--	ON tp.PropertyId = op.PropertyId
--LEFT JOIN 
--	( SELECT Id, Name, CASE
--					WHEN Name = 'Weekly' THEN 7
--					WHEN Name = 'Fortnightly' THEN 14
--					WHEN Name = 'Monthly' THEN 30
--					ELSE 1
--				END AS PaymentFrequency
--		FROM TenantPaymentFrequencies) AS pf 
--	ON tp.PaymentFrequencyId = pf.Id
--WHERE op.OwnerId = '1426'

--SELECT 
--CASE 
--			WHEN pf.Name = 'Weekly' THEN DATEDIFF(WEEK, tp.StartDate, tp.EndDate)
--			WHEN pf.Name = 'Fortnightly' THEN DATEDIFF(WEEK, tp.StartDate, tp.EndDate)/2
--			WHEN pf.Name = 'Monthly' THEN DATEDIFF(MONTH, tp.StartDate, tp.EndDate)
--		END as NumberOfPayment, *
--FROM TenantProperty tp
--LEFT JOIN TenantPaymentFrequencies pf ON tp.PaymentFrequencyId = pf.Id
--WHERE PropertyId IN ('5597', '5637', '5638')

--ii. Display the yield
--SELECT op.OwnerId, p.Id AS PropertyId, p.Name AS PropertyName, pfi.PurchasePrice, pfi.CurrentHomeValue, pfi.Yield
--FROM OwnerProperty op
--LEFT JOIN Property p
--	ON op.PropertyId = p.Id
--LEFT JOIN PropertyFinance pfi ON op.PropertyId = pfi.PropertyId
--WHERE op.OwnerId = '1426'

--GrossRentalYield
SELECT op.OwnerId, p.Id AS PropertyId, p.Name AS PropertyName, tp.PaymentAmount, pf.Name AS PaymentFrequencies, tp.PaymentAmount * pf.NumberOfPayment AS AnnualRentalIncome, 
pfi.PurchasePrice, FORMAT(tp.PaymentAmount * pf.NumberOfPayment/NULLIF(pfi.PurchasePrice,0), 'P') AS GrossRentalYield
FROM OwnerProperty op
LEFT JOIN Property p
	ON op.PropertyId = p.Id
LEFT JOIN TenantProperty tp
	ON tp.PropertyId = op.PropertyId
LEFT JOIN ( SELECT Id, Name, CASE
					WHEN Name = 'Weekly' THEN 52
					WHEN Name = 'Fortnightly' THEN 26
					WHEN Name = 'Monthly' THEN 12
					ELSE 1
				END AS NumberOfPayment
		FROM TenantPaymentFrequencies) AS pf 
	ON tp.PaymentFrequencyId = pf.Id
LEFT JOIN PropertyFinance pfi ON op.PropertyId = pfi.PropertyId
WHERE op.OwnerId = '1426'


--d. Display all the jobs available
--SELECT * FROM JOB j
--LEFT JOIN JobStatus js ON j.JobStatusId = js.Id
--WHERE js.Status = 'Open'

SELECT DISTINCT j.Id AS JobId, j.ProviderId, j.PropertyId, j.OwnerId, j.JobDescription, j.JobStartDate, j.JobEndDate, j.JobStatusId, jm.IsActive--, js.Status
FROM Job j
LEFT JOIN JobMedia jm 
	ON J.Id = jm.JobId
--LEFT  JOIN JobStatus js
--	ON j.JobStatusId = js.Id
WHERE jm.IsActive = '1'
ORDER BY j.Id
--ORDER BY js.Status

--SELECT j.Id AS JobId
--FROM Job j
--LEFT JOIN JobMedia jm 
--	ON J.Id = jm.JobId
--WHERE jm.IsActive = '1'
--GROUP BY j.Id


--e. Display all property names, current tenants first and last names and rental payments per week/ fortnight/month for the properties in question a). 
SELECT pp.Name AS PropertyName, p.FirstName AS TenantFirstName, p.LastName AS TenantLastName, tp.PaymentAmount AS Rental, 
		pf.Name AS PaymentFrequency
FROM Property pp
RIGHT JOIN OwnerProperty op
	ON pp.Id = op.PropertyId
LEFT JOIN TenantProperty tp
	ON tp.PropertyId = pp.Id
LEFT JOIN Tenant t
	ON t.Id = tp.TenantId
LEFT JOIN Person p
	ON t.Id = p.Id
LEFT JOIN TenantPaymentFrequencies pf
	ON pf.Id = tp.PaymentFrequencyId
WHERE op.OwnerId = '1426'


--Task 2 SSRS
SELECT p.Name AS PropertyName, p.Bedroom AS NumberOfBedroom, p.Bathroom AS NumberOfBathroom, a.Number AS StreetNumber, a.Street, 
a.Suburb, pe.FirstName AS OwnerName, tp.PaymentAmount, 
CASE 
	WHEN pf.Name = 'Weekly' THEN 'per week'
	WHEN pf.Name = 'Fortnightly' THEN 'per fortnight'
	WHEN pf.Name = 'Monthly' THEN 'per month'
END AS PaymentFrequency,
pex.Amount AS ExpenseAmount, pex.Date AS ExpenseDate, pex.Description AS ExpenseDescription
FROM Property AS p
LEFT JOIN Address AS a
	ON a.AddressId = p.AddressId
LEFT JOIN OwnerProperty AS op
	ON op.PropertyId = p.Id
LEFT JOIN Person AS pe
	ON OP.OwnerId = pe.Id
LEFT JOIN TenantProperty AS tp
	ON tp.PropertyId = p.Id
LEFT JOIN TenantPaymentFrequencies pf
	ON tp.PaymentFrequencyId = pf.Id
LEFT JOIN PropertyExpense pex
	ON pex.PropertyId = p.Id
WHERE p.name = 'Property A'

select p.Name, a.Number, a.Street, a.Suburb, a.City FROM Property AS p
LEFT JOIN Address AS a
	ON a.AddressId = p.AddressId
	where p.name = 'Property A'

select p.Name, tp.PaymentAmount FROM Property AS p
LEFT JOIN TenantProperty AS tp
	ON tp.PropertyId = p.Id
	where p.name = 'Property A'