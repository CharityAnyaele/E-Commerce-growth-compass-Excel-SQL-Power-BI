SELECT * FROM e_commerce.reviews;
USE e_commerce;
SELECT
    T1.Source,
    -- Calculate Average Order Value (AOV)
    AVG(CAST(REPLACE(T1.Total, '$', '') AS DECIMAL(10, 2))) AS Average_Order_Value,
    -- Calculate the percentage of orders that had a discount
    CAST(SUM(CASE WHEN CAST(REPLACE(T1.Discount, '$', '') AS DECIMAL(10, 2)) > 0 THEN 1 ELSE 0 END) AS DECIMAL(10, 2)) * 100.0 / COUNT(T1.Order_id) AS Discount_Rate_Percentage
FROM
    orders T1
GROUP BY
    T1.Source
ORDER BY
    Average_Order_Value DESC;
    
SELECT
    T1.Name,
    T1.Country,
    T1.Age,
    SUM(CAST(REPLACE(T2.Total, '$', '') AS DECIMAL(10, 2))) AS Total_Spending,
    COUNT(DISTINCT T4.Category) AS Unique_Categories_Reviewed_Count
FROM
    customers T1
JOIN
    orders T2 ON T1.customer_id = T2.Customer_id
JOIN
    reviews T3 ON T2.Order_id = T3.Order_Id
JOIN
    products T4 ON T3.Product_Id = T4.Product_Id
GROUP BY
    T1.customer_id, T1.Name, T1.Country, T1.Age
ORDER BY
    Total_Spending DESC
LIMIT 5;

SELECT
    T1.Category,
    -- Calculate Total Estimated Profit = SUM((Price - Cost))
    SUM(
        CAST(REPLACE(T1.Price, '$', '') AS DECIMAL(10, 2)) - CAST(REPLACE(T1.Cost, '$', '') AS DECIMAL(10, 2))
    ) AS Total_Estimated_Profit
FROM
    products T1
WHERE
    T1.Product_Id IN (
        SELECT
            Product_Id
        FROM
            reviews
        GROUP BY
            Product_Id
        HAVING
            AVG(Rating) >= 4.0
    )
GROUP BY
    T1.Category
ORDER BY
    Total_Estimated_Profit DESC;

SELECT
    T1.Name,
    T1.Category,
    CAST(REPLACE(T1.Price, '$', '') AS DECIMAL(10, 2)) AS Price
FROM
    products T1
LEFT JOIN
    reviews T2 ON T1.Product_Id = T2.Product_Id AND T2.Year = 2024
WHERE
    CAST(REPLACE(T1.Price, '$', '') AS DECIMAL(10, 2)) > 100
GROUP BY
    T1.Product_Id, T1.Name, T1.Category, T1.Price
HAVING
    COUNT(T2.Review_Id) < 5
ORDER BY
    Price DESC;
    
SELECT
    T1.Country,
    T2.marketing_opt_in,
    -- Calculate Average Order Value (AOV)
    AVG(CAST(REPLACE(T1.Total, '$', '') AS DECIMAL(10, 2))) AS Average_Order_Value
FROM
    orders T1
JOIN
    customers T2 ON T1.Customer_id = T2.customer_id
GROUP BY
    T1.Country, T2.marketing_opt_in
ORDER BY
    T1.Country, T2.marketing_opt_in DESC;
    
SELECT
    T1.Name,
    T1.Category,
    CAST(REPLACE(T1.Margin, '$', '') AS DECIMAL(10, 2)) AS Calculated_Margin,
    AVG(T2.Rating) AS Average_Rating,
    -- Using the count of reviews as a proxy for sales quantity
    COUNT(T2.Order_Id) AS Sales_or_Review_Count_Proxy
FROM
    products T1
JOIN
    reviews T2 ON T1.Product_Id = T2.Product_Id
GROUP BY
    T1.Product_Id, T1.Name, T1.Category, T1.Margin
HAVING
    AVG(T2.Rating) < 3.0
ORDER BY
    Sales_or_Review_Count_Proxy DESC;
    
SELECT
    -- Create Age Buckets
    CASE
        WHEN T1.Age < 25 THEN 'Under 25'
        WHEN T1.Age BETWEEN 25 AND 40 THEN '25-40'
        ELSE 'Over 40'
    END AS Age_Bracket,
    -- Calculate Average Total Spending per Bracket
    AVG(CAST(REPLACE(T2.Total, '$', '') AS DECIMAL(10, 2))) AS Average_Total_Spending,
    -- Calculate Mobile Usage Rate
    CAST(SUM(CASE WHEN T2.Device = 'Mobile' THEN 1 ELSE 0 END) AS DECIMAL(10, 2)) * 100.0 / COUNT(T2.Order_id) AS Mobile_Order_Rate_Percentage
FROM
    customers T1
JOIN
    orders T2 ON T1.customer_id = T2.Customer_id
GROUP BY
    Age_Bracket
ORDER BY
    Average_Total_Spending DESC;
    
SELECT
    -- Create Discount Brackets (Assuming Discount is a monetary value, needs calculation)
    CASE
        WHEN CAST(REPLACE(T1.Discount, '$', '') AS DECIMAL(10, 2)) = 0 THEN 'A. No Discount'
        WHEN CAST(REPLACE(T1.Discount, '$', '') AS DECIMAL(10, 2)) <= 10 THEN 'B. Low Discount (1-10)'
        ELSE 'C. High Discount (>10)'
    END AS Discount_Bracket,
    -- Calculate Average Rating for products in these orders
    AVG(T2.Rating) AS Average_Product_Rating,
    COUNT(T1.Order_id) AS Total_Orders_in_Bracket
FROM
    orders T1
JOIN
    reviews T2 ON T1.Order_id = T2.Order_Id
GROUP BY
    Discount_Bracket
ORDER BY
    Discount_Bracket;
    