USE Hospital;

SELECT * FROM Ecommerce;

EXEC sp_help Ecommerce;


/*Analyze Seasonal Order Behaviour Across Years : 
Question – 1 : 
- As an E-Commerce analytics expert, you are tasked with understanding customer 
Purchasing behaviour over time, Your goal is to determine in which quarters (Q1 –
Q4) customers places the most orders and how that trend has evolved from 2022 to 
2024. This insights will help stakeholders to plan marketing and inventory strategies 
around high-demand periods. Construct a feature to identify the quarter from the 
order date and aggregate the total number of orders per quarter, per year*/

-- Add computed column for Order Year

ALTER TABLE Ecommerce
ADD Order_Year AS YEAR(OrderDate);

-- Add computed column for Order Quarter

ALTER TABLE Ecommerce
ADD Order_Quarter AS 
    CASE 
        WHEN MONTH(OrderDate) BETWEEN 1 AND 3 THEN 'Q1'
        WHEN MONTH(OrderDate) BETWEEN 4 AND 6 THEN 'Q2'
        WHEN MONTH(OrderDate) BETWEEN 7 AND 9 THEN 'Q3'
        WHEN MONTH(OrderDate) BETWEEN 10 AND 12 THEN 'Q4'
    END;


SELECT Order_Year,Order_Quarter,COUNT(*) AS Total_Orders
FROM Ecommerce
WHERE Order_Year BETWEEN 2022 AND 2024
GROUP BY Order_Year, Order_Quarter
ORDER BY Order_Year, Order_Quarter;



/*Calculate Seller-Wise Average Product Rating for Performance BenchMarking:
Question – 2: 
- The Quality of Service and Product Satisfaction is essential for long-term customer 
retention in an eCommerce business. As a Data Analyst, you need to provide sellerlevel performance insights to the marketplace operations team. Calculate the 
average customer rating received by each seller, along with the total number of 
products sold by that seller. This will help identify high-performing sellers and those 
who may need support or training interventions.*/

SELECT SellerID,ROUND(AVG(Rating),2) AS 'Avg_rating'
FROM Ecommerce
GROUP BY SellerID;


/*Identify Product Categories with the Highest Return and Cancellation Rates
Question – 3 :
- Returns and cancellations significantly impact logistics costs and customer 
satisfaction. To improve the supply chain and reduce losses, identify which product 
categories have the highest percentage of returned or cancelled orders. This metric 
should be normalized based on the total number of orders in each category to 
account for volume differences. Your output should include the total number of 
orders, return/cancel counts, and return/cancel rate per category*/

SELECT ProductCategory,DeliveryStatus,COUNT(DeliveryStatus) AS 'No_of_Status'
FROM Ecommerce
WHERE DeliveryStatus IN ('Returned', 'Cancelled');


/*Analyze Top 10 High-Revenue Products with Adjusted Revenue Considering Discounts
Question – 4:
- Revenue insights are vital for identifying product success. As a revenue analyst, your 
task is to determine the top 10 products that generate the most revenue after 
discounts are applied. The metric should use a calculated TotalPrice that adjusts for 
discounts, not just the MRP. This will help product and pricing teams understand 
which products are driving real monetary value*/

SELECT TOP 10 ProductID,ProductName,
       SUM(PricePerUnit * Quantity * (1 - Discount)) AS 'Adjusted_Revenue'
FROM Ecommerce
GROUP BY ProductID, ProductName
ORDER BY Adjusted_Revenue DESC;


/*Evaluate Regional Order Distribution and Total Revenue for Strategic Expansion
Question – 5:
- Understanding geographic trends is essential for regional marketing and logistics 
planning. As part of a regional strategy evaluation, calculate the total number of 
orders and the total revenue generated from each region (CustomerLocation). This 
will support decisions regarding warehouse expansion, delivery optimization, and 
targeted marketing campaigns*/

SELECT CustomerLocation,ROUND(SUM(TotalPrice),2) AS 'Total_Revenue'
FROM Ecommerce
GROUP BY CustomerLocation;


/*Determine Average Delivery Time by Product Category to Identify Supply Chain 
Bottlenecks
Question – 6:
- In eCommerce logistics, average delivery time is a crucial KPI that reflects supply 
chain efficiency. Management wants to understand which product categories are 
taking longer to deliver than others. Your goal is to compute the average delivery 
time in days per product category. This will help logistics teams identify bottlenecks 
and improve delivery SLAs.*/

SELECT ProductCategory,AVG(DeliveryTimeDays) AS 'Avg_Delivery_Time'
FROM Ecommerce
GROUP BY ProductCategory;



/*Identify Customer Segments Based on Purchase Volume for Loyalty Program Targeting
Question – 7:
- To design an effective loyalty or rewards program, it's essential to classify customers 
based on their total order volume. Segment the customers into three tiers—Low, 
Medium, and High—based on the number of orders they've placed. This will help the 
marketing team focus their campaigns on loyal, high-value customers while also reengaging low-activity ones.*/

-- Add a columnn'Loyality'
ALTER TABLE Ecommerce ADD Loyality TEXT;

--Add the data into column 'Loyality'
UPDATE Ecommerce
SET Loyality = CASE
    WHEN Quantity <= 3 THEN 'Low'
    WHEN Quantity >= 4 AND Quantity <= 7 THEN 'Medium'
    ELSE 'High'
END;

/*Calculate Net Effective Discount Percentage Offered Across Categories
Question – 8 :
- Discounts are a key part of eCommerce pricing strategies. However, stakeholders 
want a realistic picture of the average net effective discount given in each product 
category, not just the highest advertised rate. Your task is to calculate the average 
discount percentage offered across each category and determine which categories 
are operating at higher markdowns. This analysis aids pricing teams in managing 
margin leakage*/

SELECT 
    ProductCategory,
    ROUND(AVG(Discount) * 100.0, 2) AS Avg_Discount_Percentage
FROM Ecommerce
GROUP BY ProductCategory
ORDER BY Avg_Discount_Percentage DESC;



/*Identify Top 5 Cities (Regions) with Highest Average Order Value (AOV)
Question – 9 :
- Marketing and regional operations teams need clarity on customer purchasing power 
across regions. One of the best indicators of this is Average Order Value (AOV)—the 
average revenue generated per order. Your goal is to compute AOV for each customer 
region and return the top 5 regions. This will help teams target affluent markets with 
premium products and personalized campaigns.*/

SELECT TOP 5 CustomerLocation,ROUND(AVG(TotalPrice),2) AS 'Avg_Total_Revenue'
FROM Ecommerce
GROUP BY CustomerLocation
ORDER BY Avg_Total_Revenue DESC;



/*Engineer a Feature to Identify Repeat Customers and Analyze Their Contribution to 
Revenue
Question – 10 :
- Repeat customers are the backbone of a successful eCommerce business. To help the 
customer success team evaluate loyalty, create a new feature that identifies repeat 
customers—those who have placed more than one order. Then, compute how much 
of the total revenue comes from these repeat customers compared to first-time 
buyers. This insight will validate the ROI of retention strategies and justify loyalty 
program investments*/


-- Tag customers as Repeat or First-Time

SELECT 
    CASE 
        WHEN COUNT(*) > 1 THEN 'Repeat'
        ELSE 'First-Time'
    END AS Customer_Type,
    COUNT(*) AS Total_Orders,
    SUM(TotalPrice) AS 'Total_Revenue'
FROM Ecommerce
GROUP BY CustomerID;


/*Identify Top 5 Sellers by Revenue and Analyze Their Average Product Ratings
Question – 11 :
- Revenue is critical, but coupling it with customer satisfaction gives a complete picture 
of seller performance. Your goal is to identify the top 5 sellers in terms of total 
revenue, and then evaluate their average product ratings. This will help the 
marketplace team reward high-value sellers who maintain quality, and investigate 
those who may be sacrificing customer experience for volume*/

SELECT TOP 5 SellerID, ROUND(Avg(Rating),2) AS 'Avg_Ratings'
FROM Ecommerce
GROUP BY SellerID
ORDER BY Avg_Ratings DESC;



/*Analyze Impact of Payment Methods on Average Order Value and Return Rates
Question – 12 :
- Finance and operations teams want to assess how different payment methods affect 
purchasing behavior and return patterns. Your task is to calculate two key metrics for 
each payment method: Average Order Value (AOV) and Return/Cancel Rate. This will 
inform strategic decisions such as incentivizing certain payment methods or 
identifying friction points in others.*/

SELECT PaymentMethod,AVG(Quantity) AS 'Avg_Order_Value'
FROM Ecommerce
GROUP BY PaymentMethod
ORDER BY Avg_Order_Value DESC;


/*Engineer a Flag for High-Value Orders and Analyze Their Distribution Across Categories
Question – 13 :
- Product and marketing teams are interested in identifying "high-value" transactions 
to offer premium customer experiences (e.g., free shipping, early access). You need 
to engineer a new feature that flags high-value orders—defined as those with a total 
price greater than the 90th percentile of all orders. Then, analyze how these orders 
are distributed across product categories*/

SELECT ProductCategory,MAX(Quantity) AS 'High_value'
FROM Ecommerce
GROUP BY ProductCategory
ORDER BY High_value DESC;


/*Calculate Average Rating by Product Category and Identify Underperforming Segments
Question – 14 :
- Customer reviews are critical indicators of product satisfaction. As part of a quality 
assurance initiative, you are asked to calculate the average rating for each product 
category. The goal is to flag categories where the average rating falls below 3.5, 
indicating potential customer dissatisfaction. This will help product teams prioritize 
improvements or reconsider inventory from specific suppliers.*/

SELECT ProductCategory,ROUND(AVG(Rating),2) AS 'Avg_Rating'
FROM Ecommerce
GROUP BY ProductCategory
ORDER BY Avg_Rating DESC;



/*Engineer Product Profitability Metric and Identify Most and Least Profitable Categories
Question – 15 :
- While revenue is important, profitability is what ultimately matters to the finance 
team. For better decision-making, you are tasked with engineering a new feature: 
Estimated Profit per order. Assume a flat product cost = 70% of the PricePerUnit 
(excluding discount). Using this, calculate estimated profit for each order and then 
aggregate the total profit by product category. Identify the top 3 most profitable and 
least profitable categories*/

SELECT ProductCategory,
       ROUND(SUM((PricePerUnit * Quantity * (1 - Discount)) - (PricePerUnit * Quantity * 0.70)),2) AS 'Total_Profit'
FROM Ecommerce
GROUP BY ProductCategory
ORDER BY Total_Profit DESC;



/*Engineer Order Completion Flag and Analyze Seller Fulfillment Efficiency
Question – 16 :
- To assess seller reliability, operations teams want a metric that reflects the fulfillment 
efficiency of each seller. Begin by engineering a new feature: an Order Completion 
Flag which is True only if the delivery status is “Delivered”. Then, calculate the Order 
Completion Rate (%) for each seller by dividing completed orders by total orders. Sort 
the sellers from best to worst based on this fulfillment metric*/

--  Add Order Completion Flag
ALTER TABLE Ecommerce ADD Order_Completion_Flag INT;

UPDATE Ecommerce
SET Order_Completion_Flag=
    CASE 
        WHEN DeliveryStatus = 'Delivered' THEN 1 
        ELSE 0 
    END;


SELECT 
    SellerID,
    COUNT(*) AS Total_Orders,
    SUM(Order_Completion_Flag) AS 'Completed_Orders',
    ROUND(100.0 * SUM(Order_Completion_Flag) / COUNT(*), 2) AS Completion_Rate_Percent
FROM 
    Ecommerce
GROUP BY 
    SellerID
ORDER BY 
    Completion_Rate_Percent DESC;




/*Determine Category-Wise Revenue Growth Year Over Year
Question – 17 :
- Understanding growth trends across product categories helps in strategic investment 
decisions. The executive team is interested in knowing which product categories are 
showing positive or negative revenue growth year over year. Calculate the total 
revenue per category for each year, and then derive a feature for Year-over-Year (YoY) 
Growth (%) to highlight accelerating or declining segments*/

--Compute total revenue per category per year
WITH RevenueByYear AS (
    SELECT 
        ProductCategory,
        YEAR(OrderDate) AS Order_Year,
        SUM(TotalPrice) AS Total_Revenue
    FROM 
        Ecommerce
    GROUP BY 
        ProductCategory, YEAR(OrderDate)
),

--Use LAG to get previous year's revenue
YoYGrowth AS (
    SELECT 
        ProductCategory,
        Order_Year,
        Total_Revenue,
        LAG(Total_Revenue) OVER (PARTITION BY ProductCategory ORDER BY Order_Year) AS Previous_Year_Revenue
    FROM 
        RevenueByYear
)

--Calculate YoY growth %
SELECT 
    ProductCategory,
    Order_Year,
    Total_Revenue,
    Previous_Year_Revenue,
    ROUND(
        CASE 
            WHEN Previous_Year_Revenue IS NULL OR Previous_Year_Revenue = 0 THEN NULL
            ELSE 100.0 * (Total_Revenue - Previous_Year_Revenue) / Previous_Year_Revenue
        END, 2
    ) AS 'YoY_Growth_Percent'
FROM 
    YoYGrowth
ORDER BY 
    ProductCategory, Order_Year;


/*Use List Comprehension to Classify Products Based on Price Ranges for Marketing 
Segmentation
Question – 18 :
- To drive targeted pricing campaigns, the marketing team wants products categorized 
based on their unit price. Create a new column that classifies each product into Low, 
Mid, or High price segments using list comprehension. Then, analyze how much total 
revenue each segment contributes to the business. This helps in targeting different 
customer segments effectively.
Low: PricePerUnit < ₹100
Mid: ₹100 ≤ PricePerUnit ≤ ₹300
High: PricePerUnit > ₹300*/

--Add a computed column for Price Segment
ALTER TABLE Ecommerce
ADD Price_Segment AS (
    CASE 
        WHEN PricePerUnit < 100 THEN 'Low'
        WHEN PricePerUnit BETWEEN 100 AND 300 THEN 'Mid'
        ELSE 'High'
    END
);

--Analyze total revenue by price segment
SELECT 
    Price_Segment,
    COUNT(*) AS 'Total_Orders',
    SUM(TotalPrice) AS 'Total_Revenue'
FROM 
    Ecommerce
GROUP BY 
    Price_Segment
ORDER BY 
    CASE 
        WHEN Price_Segment = 'Low' THEN 1
        WHEN Price_Segment = 'Mid' THEN 2
        WHEN Price_Segment = 'High' THEN 3
    END;



/*Identify the Return Rate of High-Value Orders Compared to Low-Value Orders
Question – 19 :
- Customer behavior can vary significantly based on the value of a transaction. The 
operations and fraud detection teams want to compare the return/cancel rate of 
high-value orders (orders above the 75th percentile) with that of low-value orders 
(orders below the 25th percentile). This can help uncover patterns such as abuse of 
returns or product dissatisfaction in expensive or cheap items*/

--Calculate 25th and 75th percentiles
WITH Percentiles AS (
    SELECT 
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY TotalPrice) OVER () AS P25,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY TotalPrice) OVER () AS P75
    FROM Ecommerce
),

--Tag each order as Low, Mid, or High based on TotalPrice
SegmentedOrders AS (
    SELECT 
        E.*,
        CASE 
            WHEN E.TotalPrice < P.P25 THEN 'Low'
            WHEN E.TotalPrice > P.P75 THEN 'High'
            ELSE 'Mid'
        END AS 'Value_Segment'
    FROM 
        Ecommerce E
    CROSS JOIN Percentiles P
),

-- Calculate return/cancel rate for each segment
ReturnRates AS (
    SELECT 
        Value_Segment,
        COUNT(*) AS 'Total_Orders',
        SUM(CASE 
                WHEN DeliveryStatus IN ('Returned', 'Cancelled') THEN 1 
                ELSE 0 
            END) AS 'Returned_Orders'
    FROM 
        SegmentedOrders
    WHERE 
        Value_Segment IN ('Low', 'High') 
    GROUP BY 
        Value_Segment
)

--Return with return rate %
SELECT 
    Value_Segment,
    Total_Orders,
    Returned_Orders,
    ROUND(100.0 * Returned_Orders / Total_Orders, 2) AS 'Return_Rate_Percent'
FROM 
    ReturnRates
ORDER BY 
    Value_Segment;




/*Engineer Delivery Performance Bands and Analyze Their Impact on Customer Ratings
Question – 20 :
- To improve last-mile delivery and customer satisfaction, the logistics team wants to 
understand how delivery time impacts customer ratings. Your task is to engineer a 
new feature called DeliveryPerformanceBand that classifies delivery speed as Fast 
(≤3 days), Moderate (4–7 days), or Slow (>7 days). Then analyze the average 
customer rating within each delivery band*/

--Add a computed column for DeliveryPerformanceBand
ALTER TABLE Ecommerce
ADD DeliveryPerformanceBand AS (
    CASE 
        WHEN DeliveryTimeDays <= 3 THEN 'Fast'
        WHEN DeliveryTimeDays BETWEEN 4 AND 7 THEN 'Moderate'
        ELSE 'Slow'
    END
);

--Analyze average rating by delivery performance
SELECT 
    DeliveryPerformanceBand,
    COUNT(*) AS Total_Orders,
    ROUND(AVG(Rating), 2) AS 'Avg_Customer_Rating'
FROM 
    Ecommerce
GROUP BY 
    DeliveryPerformanceBand
ORDER BY 
    CASE 
        WHEN DeliveryPerformanceBand = 'Fast' THEN 1
        WHEN DeliveryPerformanceBand = 'Moderate' THEN 2
        WHEN DeliveryPerformanceBand = 'Slow' THEN 3
    END;




/*Engineer a Feature to Flag Peak Season Orders and Compare Revenue Contribution
Question – 21 :
- The sales team suspects that a large chunk of revenue is concentrated during the 
peak seasons like festive quarters (Q4) or year-end sales. Your job is to engineer a 
new feature called IsPeakSeason based on the order quarter, where Q4 is considered 
peak. Then calculate the total revenue and number of orders from peak vs. non-peak 
periods to validate the hypothesis*/

--Add a computed column to flag Peak Season (Q4 = months 10, 11, 12)
ALTER TABLE Ecommerce
ADD IsPeakSeason AS (
    CASE 
        WHEN DATEPART(QUARTER, OrderDate) = 4 THEN 'Yes'
        ELSE 'No'
    END
);

--Compare revenue and order count by peak vs. non-peak
SELECT 
    IsPeakSeason,
    COUNT(*) AS 'Total_Orders',
    SUM(TotalPrice) AS 'Total_Revenue'
FROM 
    Ecommerce
GROUP BY 
    IsPeakSeason
ORDER BY 
    IsPeakSeason DESC;





/*Perform Multi-Metric Performance Analysis of Each Product Category
Question – 22 :
- The executive dashboard needs a composite view of each product category's 
business performance. You are required to compile a table showing the following for 
each category:
Total Revenue
Total Quantity Sold
Average Rating
Return/Cancel Rate
- This multi-metric view will help the leadership team identify not just top-selling 
categories, but also the ones that balance revenue, satisfaction, and operational 
efficiency*/

SELECT 
    ProductCategory,
    
    -- Total revenue per category
    SUM(TotalPrice) AS 'Total_Revenue',
    
    -- Total quantity sold
    SUM(Quantity) AS 'Total_Quantity_Sold',
    
    -- Average customer rating
    ROUND(AVG(Rating), 2) AS 'Avg_Customer_Rating',
    
    -- Return/Cancel Rate = Returned or Cancelled orders / Total orders
    ROUND(
        100.0 * SUM(
            CASE 
                WHEN DeliveryStatus IN ('Returned', 'Cancelled') THEN 1 
                ELSE 0 
            END
        ) / COUNT(*), 2
    ) AS 'Return_Cancel_Rate_Percent'

FROM 
    Ecommerce
GROUP BY 
    ProductCategory
ORDER BY 
    Total_Revenue DESC;



/*Segment Sellers by Revenue Tiers and Analyze Their Average Completion Rate
Question – 23 :
To design tiered incentive programs for marketplace sellers, the business team needs to 
segment sellers into Low, Mid, and High Revenue groups. Then, calculate the average order 
completion rate within each revenue tier. This analysis will reveal whether top sellers are 
also the most reliable, or if mid/low-tier sellers outperform them in fulfillment quality*/

--Calculate 25th and 75th percentiles of Seller Revenue
WITH SellerRevenue AS (
    SELECT 
        SellerID,
        SUM(TotalPrice) AS 'Total_Seller_Revenue'
    FROM 
        Ecommerce
    GROUP BY 
        SellerID
),

Percentiles AS (
    SELECT 
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Total_Seller_Revenue) OVER () AS P25,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Total_Seller_Revenue) OVER () AS P75
    FROM SellerRevenue
),

--Segment Sellers into Revenue Tiers
SegmentedSellers AS (
    SELECT 
        SR.SellerID,
        SR.Total_Seller_Revenue,
        CASE 
            WHEN SR.Total_Seller_Revenue < P.P25 THEN 'Low'
            WHEN SR.Total_Seller_Revenue > P.P75 THEN 'High'
            ELSE 'Mid'
        END AS Revenue_Tier
    FROM 
        SellerRevenue SR
    CROSS JOIN Percentiles P
),

--Join Ecommerce data with Revenue Tiers and compute completion rates
SellerPerformance AS (
    SELECT 
        SS.Revenue_Tier,
        E.SellerID,
        COUNT(*) AS 'Total_Orders',
        SUM(CASE WHEN E.DeliveryStatus = 'Delivered' THEN 1 ELSE 0 END) AS 'Completed_Orders'
    FROM 
        Ecommerce E
    JOIN 
        SegmentedSellers SS ON E.SellerID = SS.SellerID
    GROUP BY 
        SS.Revenue_Tier, E.SellerID
)

--Compute average completion rate by revenue tier
SELECT 
    Revenue_Tier,
    COUNT(*) AS 'Total_Sellers',
    ROUND(AVG(100.0 * Completed_Orders * 1.0 / NULLIF(Total_Orders, 0)), 2) AS 'Avg_Completion_Rate_Percent'
FROM 
    SellerPerformance
GROUP BY 
    Revenue_Tier
ORDER BY 
    CASE 
        WHEN Revenue_Tier = 'Low' THEN 1
        WHEN Revenue_Tier = 'Mid' THEN 2
        WHEN Revenue_Tier = 'High' THEN 3
    END;


/*Engineer a Customer Frequency Band and Analyze Their Contribution to Revenue
Question – 24 :
- Customer frequency is a core driver of lifetime value. You are asked to engineer a 
new feature called CustomerFrequencyBand, categorizing customers based on the 
number of orders they’ve placed:
Rare (1 order)
Occasional (2–4 orders)
Frequent (5+ orders)
- Then, analyze how much revenue each customer band contributes. This insight will 
help the CRM team design personalized loyalty campaigns and better manage 
customer retention efforts.*/

-- Step 1: Count orders per customer
WITH CustomerOrderCounts AS (
    SELECT 
        CustomerID,
        COUNT(*) AS 'OrderCount',
        SUM(TotalPrice) AS 'CustomerRevenue'
    FROM 
        Ecommerce
    GROUP BY 
        CustomerID
),

-- Step 2: Assign frequency band
CustomerBands AS (
    SELECT 
        CustomerID,
        OrderCount,
        CustomerRevenue,
        CASE 
            WHEN OrderCount = 1 THEN 'Rare'
            WHEN OrderCount BETWEEN 2 AND 4 THEN 'Occasional'
            ELSE 'Frequent'
        END AS CustomerFrequencyBand
    FROM 
        CustomerOrderCounts
),

--Aggregate revenue by frequency band
RevenueByBand AS (
    SELECT 
        CustomerFrequencyBand,
        COUNT(*) AS 'Total_Customers',
        SUM(OrderCount) AS 'Total_Orders',
        SUM(CustomerRevenue) AS 'Total_Revenue'
    FROM 
        CustomerBands
    GROUP BY 
        CustomerFrequencyBand
)

-- Final Output
SELECT 
    CustomerFrequencyBand,
    Total_Customers,
    Total_Orders,
    Total_Revenue,
    ROUND(100.0 * Total_Revenue / SUM(Total_Revenue) OVER (), 2) AS Revenue_Contribution_Percent
FROM 
    RevenueByBand
ORDER BY 
    CASE 
        WHEN CustomerFrequencyBand = 'Rare' THEN 1
        WHEN CustomerFrequencyBand = 'Occasional' THEN 2
        WHEN CustomerFrequencyBand = 'Frequent' THEN 3
    END;




/*Evaluate Seller-Level Discounting Behavior and Its Correlation with Revenue
Question – 25 :
- Discounting is often used as a lever to boost sales—but excessive discounting may 
eat into profits. The finance team wants to assess whether sellers offering higher 
average discounts are generating proportionately higher revenue. Calculate average 
discount percentage and total revenue for each seller, and rank them to identify 
outliers—sellers with high discounts but low revenue (or vice versa)*/

-- Calculate average discount % and total revenue per seller
WITH SellerStats AS (
    SELECT 
        SellerID,
        ROUND(AVG(Discount), 2) AS 'Avg_Discount_Percent',
        SUM(TotalPrice) AS 'Total_Revenue'
    FROM 
        Ecommerce
    GROUP BY 
        SellerID
),

--Rank sellers by discount and revenue
RankedSellers AS (
    SELECT 
        SellerID,
        Avg_Discount_Percent,
        Total_Revenue,
        RANK() OVER (ORDER BY Avg_Discount_Percent DESC) AS Discount_Rank,
        RANK() OVER (ORDER BY Total_Revenue DESC) AS Revenue_Rank
    FROM 
        SellerStats
)

--List all seller stats with ranks
SELECT 
    SellerID,
    Avg_Discount_Percent,
    Total_Revenue,
    Discount_Rank,
    Revenue_Rank,
    (Discount_Rank - Revenue_Rank) AS 'Rank_Difference' 
FROM 
    RankedSellers
ORDER BY 
    Rank_Difference DESC; 
