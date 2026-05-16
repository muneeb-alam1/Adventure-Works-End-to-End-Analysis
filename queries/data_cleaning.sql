SELECT CustomerKey, COUNT(*) as cnt FROM customer_lookup
GROUP BY CustomerKey
HAVING cnt > 1;

SHOW COLUMNS FROM sales_data;


ALTER TABLE customer_lookup
MODIFY COLUMN CustomerKey INT,
MODIFY COLUMN BirthDate DATE,
MODIFY COLUMN AnnualIncome INT,
MODIFY COLUMN TotalChildren INT;

SELECT CustomerKey
FROM customer_lookup
WHERE CustomerKey NOT REGEXP '^[0-9]+$';


DELETE FROM customer_lookup
WHERE CustomerKey NOT REGEXP '^[0-9]+$';


UPDATE customer_lookup SET
FirstName = CONCAT(UPPER(LEFT(FirstName,1)), LOWER(SUBSTRING(FirstName,2))),
LastName = CONCAT(UPPER(LEFT(LastName,1)), LOWER(SUBSTRING(LastName,2)));
	
    
UPDATE customer_lookup
SET Prefix = CASE 
WHEN UPPER(TRIM(Prefix)) = 'MR.' THEN 'Mr.'
WHEN UPPER(TRIM(Prefix)) = 'MRS.' THEN 'Mrs.'
WHEN UPPER(TRIM(Prefix)) = 'MS.' THEN 'Ms.'
ELSE Prefix
END;


SELECT
CONCAT(Prefix, ' ', FirstName, ' ', LastName) AS FullName
FROM customer_lookup;

    
ALTER TABLE customer_lookup
ADD COLUMN FullName VARCHAR(255);    

    
UPDATE customer_lookup
SET FullName = CONCAT_WS(' ', Prefix, FirstName, LastName);


UPDATE customer_lookup
SET HomeOwner = CASE 
WHEN HomeOwner = 'Y' THEN 'Yes'
ELSE "No"
END;


ALTER TABLE sales_data
MODIFY COLUMN OrderDate DATE,
MODIFY COLUMN StockDate DATE;


UPDATE sales_data
SET OrderDate = STR_TO_DATE(OrderDate, '%c/%e/%Y'),
StockDate = STR_TO_DATE(StockDate, '%c/%e/%Y');

    
ALTER TABLE returns_data
MODIFY COLUMN ReturnDate DATE;