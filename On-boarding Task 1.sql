--1. Write queries to return the following: 
--a. Display a list of all property names and their property id’s for Owner Id: 1426. 
SELECT op.OwnerId, p.Name AS PropertyName, p.Id AS PropertyId
FROM OwnerProperty op
LEFT JOIN Property p 
	ON op.PropertyId = p.Id
WHERE op.OwnerId = '1426'


--b. Display the current home value for each property in question a). 
SELECT op.OwnerId, p.Name AS PropertyName, p.Id AS PropertyId, pf.CurrentHomeValue 
FROM OwnerProperty op
LEFT JOIN Property p 
	ON op.PropertyId = p.Id
LEFT JOIN PropertyFinance pf
	ON p.Id = pf.PropertyId
WHERE op.OwnerId = '1426'


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


--ii. Display the yield
SELECT op.OwnerId, p.Id AS PropertyId, p.Name AS PropertyName, pfi.PurchasePrice, pfi.CurrentHomeValue, pfi.Yield
FROM OwnerProperty op
LEFT JOIN Property p
	ON op.PropertyId = p.Id
LEFT JOIN PropertyFinance pfi ON op.PropertyId = pfi.PropertyId
WHERE op.OwnerId = '1426'


--d. Display all the jobs available
SELECT DISTINCT j.Id AS JobId, j.ProviderId, j.PropertyId, j.OwnerId, j.JobStartDate, j.JobEndDate, j.JobStatusId, jm.IsActive
FROM Job j
LEFT JOIN JobMedia jm 
	ON J.Id = jm.JobId
WHERE jm.IsActive = '1'
ORDER BY j.Id


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