                     -- ============================================================
                                -- STEEL PLANT PRODUCTION DATA ANALYSIS
                                     -- Analysis Period: 2024 - 2025
                                            -- Database: steelplant
                                       -- Tables: steel_plant2024, steel_plant2025
                                             -- Tool:  SSMS
                      -- ============================================================



-- ============================================================
-- 1. SELECT THE DATABASE
-- ============================================================

use SteelPlant;


-- ============================================================
-- 2. VERIFY SOURCE TABLES
-- ============================================================
SELECT TOP 10 *
FROM steel_plant2024;

SELECT TOP 10 *
FROM steel_plant2025;

-- ============================================================
-- 3. CHECK RECORD COUNT
-- ============================================================
-- Determine the number of production records available
-- for each year.

SELECT COUNT(*) AS Total_Records_2024
FROM steel_plant2024;

SELECT COUNT(*) AS Total_Records_2025
FROM steel_plant2025;


-- ============================================================
-- 4. CHECK TABLE STRUCTURE
-- ============================================================
-- Verify column names and data types before combining
-- the two yearly datasets.


EXEC sp_help 'steel_plant2024';

EXEC sp_help 'steel_plant2025';




-- ============================================================
-- 5. COMBINE 2024 AND 2025 DATA
-- ============================================================
-- Purpose:
-- Combine both yearly production tables into a single table
-- because both datasets have the same column structure.
--
-- UNION ALL is used because we want to retain every record
-- from both years.


SELECT *
INTO steel_plant_combineddata
FROM steel_plant2024

UNION ALL

SELECT *
FROM steel_plant2025;


-- ============================================================
-- 6. VERIFY COMBINED DATA
-- ============================================================
-- Purpose:
-- Check the total number of records after combining
-- the 2024 and 2025 datasets.

SELECT COUNT(*) AS Total_Combined_Records
FROM steel_plant_combineddata;

-- ============================================================
-- 7. VERIFY YEAR-WISE RECORDS
-- ============================================================
-- Purpose:
-- Confirm that records from both 2024 and 2025 are
-- correctly present in the combined table.

SELECT
    YEAR(Production_Date) AS Production_Year,
    COUNT(*) AS Total_Records
FROM steel_plant_combineddata
GROUP BY YEAR(Production_Date)
ORDER BY Production_Year;


-- ============================================================
-- 8. CHECK DUPLICATE PRODUCTION IDs
-- ============================================================
-- Identify duplicate Production_ID values that may
-- represent repeated production records.


SELECT
    Production_ID,
    COUNT(*) AS Duplicate_Count
FROM steel_plant_combineddata
GROUP BY Production_ID
HAVING COUNT(*) > 1;


-- ============================================================
-- 9. CHECK MISSING VALUES
-- ============================================================
-- Purpose:
-- Identify NULL values in important production,
-- machine, operator, quality and operational columns.


SELECT
    SUM(CASE WHEN Production_ID IS NULL THEN 1 ELSE 0 END) AS Production_ID_NULL,
    SUM(CASE WHEN Production_Date IS NULL THEN 1 ELSE 0 END) AS Production_Date_NULL,
    SUM(CASE WHEN Department_Name IS NULL THEN 1 ELSE 0 END) AS Department_NULL,
    SUM(CASE WHEN Shift_Name IS NULL THEN 1 ELSE 0 END) AS Shift_NULL,
    SUM(CASE WHEN Machine_ID IS NULL THEN 1 ELSE 0 END) AS Machine_ID_NULL,
    SUM(CASE WHEN Operator_ID IS NULL THEN 1 ELSE 0 END) AS Operator_ID_NULL,
    SUM(CASE WHEN Product_Name IS NULL THEN 1 ELSE 0 END) AS Product_NULL,
    SUM(CASE WHEN Production_Quantity_Tons IS NULL THEN 1 ELSE 0 END) AS Production_NULL,
    SUM(CASE WHEN Energy_Consumption_MWh IS NULL THEN 1 ELSE 0 END) AS Energy_NULL,
    SUM(CASE WHEN Quality_Status IS NULL THEN 1 ELSE 0 END) AS Quality_NULL,
    SUM(CASE WHEN Defect_Quantity_Tons IS NULL THEN 1 ELSE 0 END) AS Defect_NULL,
    SUM(CASE WHEN Downtime_Minutes IS NULL THEN 1 ELSE 0 END) AS Downtime_NULL,
    SUM(CASE WHEN Downtime_Reason IS NULL THEN 1 ELSE 0 END) AS Downtime_Reason_NULL
FROM steel_plant_combineddata;


-- ============================================================
-- 10. CHECK INVALID PRODUCTION VALUES
-- ============================================================
-- Identify records where production quantity is negative,
-- which is not logically valid for production data.

select * from steel_plant_combineddata
where Production_Quantity_Tons <0;

-- ============================================================
-- 11. CHECK INVALID DEFECT VALUES
-- ============================================================
-- Purpose:
-- Identify negative defect quantities.

SELECT *
FROM steel_plant_combineddata
WHERE Defect_Quantity_Tons < 0;

-- ============================================================
-- 13. VALIDATE DEFECT QUANTITY
-- ============================================================
-- Purpose:
-- Check whether defect quantity is greater than
-- total production quantity.

SELECT *
FROM steel_plant_combineddata
WHERE Defect_Quantity_Tons > Production_Quantity_Tons;


-- ============================================================
-- 14. CHECK DEPARTMENT VALUES
-- ============================================================
-- Purpose:
-- Identify all unique departments available in the dataset
-- and check for unexpected category values.

SELECT DISTINCT
    Department_Name
FROM steel_plant_combineddata
ORDER BY Department_Name;


-- ============================================================
-- 15. CHECK SHIFT VALUES
-- ============================================================
-- Purpose:
-- Identify all unique shift categories.

SELECT DISTINCT
    Shift_Name
FROM steel_plant_combineddata
ORDER BY Shift_Name;


-- ============================================================
-- 16. CHECK PRODUCT VALUES
-- ============================================================
-- Purpose:
-- Identify all unique products available for production
-- analysis.

SELECT DISTINCT
    Product_Name
FROM steel_plant_combineddata
ORDER BY Product_Name;


-- ============================================================
-- 17. QUALITY STATUS DISTRIBUTION
-- ============================================================
-- Purpose:
-- Understand the distribution of different quality statuses.

SELECT
    Quality_Status,
    COUNT(*) AS Total_Records
FROM steel_plant_combineddata
GROUP BY Quality_Status
ORDER BY Total_Records DESC;


-- ============================================================
-- 18. TOTAL PRODUCTION
-- ============================================================
-- Purpose:
-- Calculate the total production quantity across
-- the complete 2024-2025 period.

SELECT
    Cast(sum(Production_Quantity_Tons) as decimal(18,2)) AS Total_Production_Tons
FROM steel_plant_combineddata;


-- ============================================================
-- 19. YEAR-WISE PRODUCTION COMPARISON
-- ============================================================
-- Purpose:
-- Compare total production between 2024 and 2025.

SELECT
    YEAR(Production_Date) AS Production_Year,
    SUM(Production_Quantity_Tons) AS Total_Production_Tons
FROM steel_plant_combineddata
GROUP BY YEAR(Production_Date)
ORDER BY Production_Year;


-- ============================================================
-- 20. YEAR-OVER-YEAR PRODUCTION CHANGE
-- ============================================================
-- Compare each year's production with the previous year
-- and calculate the production change.

WITH YearlyProduction AS
(
    SELECT
        YEAR(Production_Date) AS Production_Year,
        SUM(Production_Quantity_Tons) AS Total_Production
    FROM steel_plant_combineddata
    GROUP BY YEAR(Production_Date)
)
SELECT
    Production_Year,
    Total_Production,
    LAG(Total_Production) OVER (
        ORDER BY Production_Year
    ) AS Previous_Year_Production,
    Total_Production -
    LAG(Total_Production) OVER (
        ORDER BY Production_Year
    ) AS Production_Change
FROM YearlyProduction
ORDER BY Production_Year;


-- ============================================================
-- 21. MONTHLY PRODUCTION TREND
-- ============================================================
-- Purpose:
-- Analyze production month by month for both years
-- to identify production trends.

SELECT
    YEAR(Production_Date) AS Production_Year,
    MONTH(Production_Date) AS Month_Number,
    DATENAME(MONTH, Production_Date) AS Month_Name,
    SUM(Production_Quantity_Tons) AS Total_Production_Tons
FROM steel_plant_combineddata
GROUP BY
    YEAR(Production_Date),
    MONTH(Production_Date),
    DATENAME(MONTH, Production_Date)
ORDER BY
    Production_Year,
    Month_Number;


-- ============================================================
-- 22. DEPARTMENT-WISE PRODUCTION
-- ============================================================
-- Purpose:
-- Compare production performance across departments.

SELECT
    Department_Name,
    Cast(SUM(Production_Quantity_Tons)as decimal(18,2)) AS Total_Production_Tons
FROM steel_plant_combineddata
GROUP BY Department_Name
ORDER BY Total_Production_Tons DESC;



-- ============================================================
-- 23. YEAR-WISE DEPARTMENT PRODUCTION
-- ============================================================
-- Purpose:
-- Compare department production between 2024 and 2025.

SELECT
    YEAR(Production_Date) AS Production_Year,
    Department_Name,
    SUM(Production_Quantity_Tons) AS Total_Production_Tons
FROM steel_plant_combineddata
GROUP BY
    YEAR(Production_Date),
    Department_Name
ORDER BY
    Production_Year,
    Total_Production_Tons DESC;


-- ============================================================
-- 24. SHIFT-WISE PRODUCTION
-- ============================================================
-- Purpose:
-- Analyze production performance across different shifts.

SELECT
    Shift_Name,
    SUM(Production_Quantity_Tons) AS Total_Production_Tons
FROM steel_plant_combineddata
GROUP BY Shift_Name
ORDER BY Total_Production_Tons DESC;


-- ============================================================
-- 25. PRODUCT-WISE PRODUCTION
-- ============================================================
-- Purpose:
-- Identify production contribution by product type.

SELECT
    Product_Name,
    Cast(SUM(Production_Quantity_Tons)as decimal(18,2)) AS Total_Production_Tons
FROM steel_plant_combineddata
GROUP BY Product_Name
ORDER BY Total_Production_Tons DESC;



-- ============================================================
-- 26. MACHINE-WISE PRODUCTION Defect
-- ============================================================
-- Purpose:
-- Compare production output across machines.

SELECT
    Machine_ID,
   cast( SUM(Production_Quantity_Tons)as Decimal(18,2)) AS Total_Production_Tons,
    Cast (SUM(Defect_Quantity_Tons)as Decimal(18,2)) AS Total_Defects_Tons
FROM steel_plant_combineddata
GROUP BY Machine_ID
ORDER BY Total_Production_Tons DESC;


-- ============================================================
-- 27. MACHINE DOWNTIME ANALYSIS
-- ============================================================
-- Purpose:
-- Identify machines with higher total downtime.

SELECT
    Machine_ID,
    SUM(Downtime_Minutes) AS Total_Downtime_Minutes
FROM steel_plant_combineddata
GROUP BY Machine_ID
ORDER BY Total_Downtime_Minutes DESC;


-- ============================================================
-- 28. ENERGY CONSUMPTION ANALYSIS
-- ============================================================

-- Compare total energy consumption between 2024 and 2025.

SELECT
    YEAR(Production_Date) AS Production_Year,
    Cast(SUM(Energy_Consumption_MWh)as decimal(18,2)) AS Total_Energy_MWh
FROM steel_plant_combineddata
GROUP BY YEAR(Production_Date)
ORDER BY Production_Year;


-- ============================================================
-- 29. ENERGY CONSUMPTION PER TON
-- ============================================================
-- Purpose:
-- Calculate the amount of energy consumed for each ton
-- of production.

SELECT
    YEAR(Production_Date) AS Production_Year,
    SUM(Energy_Consumption_MWh) AS Total_Energy_MWh,
    SUM(Production_Quantity_Tons) AS Total_Production_Tons,
    SUM(Energy_Consumption_MWh)
        / NULLIF(SUM(Production_Quantity_Tons), 0)
        AS Energy_Per_Ton
FROM steel_plant_combineddata
GROUP BY YEAR(Production_Date)
ORDER BY Production_Year;


-- ============================================================
-- 30. QUALITY ANALYSIS
-- ============================================================
-- Purpose:
-- Analyze quality status across 2024 and 2025.

SELECT
    YEAR(Production_Date) AS Production_Year,
    Quality_Status,
    COUNT(*) AS Total_Records,
    SUM(Production_Quantity_Tons) AS Total_Production_Tons
FROM steel_plant_combineddata
GROUP BY
    YEAR(Production_Date),
    Quality_Status
ORDER BY
    Production_Year,
    Total_Records DESC;


-- ============================================================
-- 31. DEFECT ANALYSIS
-- ============================================================
-- Purpose:
-- Compare total defect quantity between 2024 and 2025.

SELECT
    Department_Name,

    CAST(SUM(Production_Quantity_Tons) AS DECIMAL(18,2)) 
        AS Total_Production_Tons,
    CAST(SUM(Defect_Quantity_Tons) AS DECIMAL(18,2)) 
        AS Total_Defects_Tons,
    CAST(
        SUM(Defect_Quantity_Tons) * 100.0 /
        NULLIF(SUM(Production_Quantity_Tons), 0)
        AS DECIMAL(18,2)
    ) AS Defect_Rate_Percent

FROM steel_plant_combineddata
GROUP BY Department_Name
ORDER BY Defect_Rate_Percent DESC;

-- ============================================================
-- 32. DEFECT RATE
-- ============================================================
-- Purpose:
-- Calculate defect quantity as a percentage of
-- total production.

SELECT
    YEAR(Production_Date) AS Production_Year,
    SUM(Production_Quantity_Tons) AS Total_Production_Tons,
    SUM(Defect_Quantity_Tons) AS Total_Defect_Tons,
    CAST(
        SUM(Defect_Quantity_Tons) * 100.0
        / NULLIF(SUM(Production_Quantity_Tons), 0)
        AS DECIMAL(10,2)
    ) AS Defect_Rate_Percent
FROM steel_plant_combineddata
GROUP BY YEAR(Production_Date)
ORDER BY Production_Year;


-- ============================================================
-- 33. DOWNTIME ANALYSIS
-- ============================================================
-- Purpose:
-- Compare total downtime between 2024 and 2025.

SELECT
    YEAR(Production_Date) AS Production_Year,
    SUM(Downtime_Minutes) AS Total_Downtime_Minutes
FROM steel_plant_combineddata
GROUP BY YEAR(Production_Date)
ORDER BY Production_Year;


-- ============================================================
-- 34. DOWNTIME REASON ANALYSIS
-- ============================================================
-- Purpose:
-- Identify the major reasons contributing to downtime.

SELECT
    Downtime_Reason,
    SUM(Downtime_Minutes) AS Total_Downtime_Minutes
FROM steel_plant_combineddata
GROUP BY Downtime_Reason
ORDER BY Total_Downtime_Minutes DESC;


-- ============================================================
-- 35. TOP 5 MACHINES BY PRODUCTION
-- ============================================================
-- Purpose:
-- Identify the five machines with the highest
-- production output.

SELECT TOP 5
    Machine_ID,
    SUM(Production_Quantity_Tons) AS Total_Production_Tons
FROM steel_plant_combineddata
GROUP BY Machine_ID
ORDER BY Total_Production_Tons DESC;


-- ============================================================
-- 36. MACHINE PRODUCTION RANKING
-- ============================================================
-- Purpose:
-- Rank machines based on their total production output.

SELECT
    Machine_ID,
    SUM(Production_Quantity_Tons) AS Total_Production_Tons,
    RANK() OVER (
        ORDER BY SUM(Production_Quantity_Tons) DESC
    ) AS Production_Rank
FROM steel_plant_combineddata
GROUP BY Machine_ID;


-- ============================================================
-- 37. DEPARTMENT ANALYSIS USING CTE
-- ============================================================
-- Purpose:
-- Use a Common Table Expression to calculate
-- department-level production before further analysis.

WITH DepartmentProduction AS
(
    SELECT
        Department_Name,
        SUM(Production_Quantity_Tons) AS Total_Production_Tons
    FROM steel_plant_combineddata
    GROUP BY Department_Name
)
SELECT
    Department_Name,
    Total_Production_Tons
FROM DepartmentProduction
ORDER BY Total_Production_Tons DESC;


-- ============================================================
-- 38. FINAL YEAR-WISE PERFORMANCE SUMMARY
-- ============================================================
-- Purpose:
-- Create a consolidated summary of major production,
-- energy, quality, defect and downtime KPIs.

SELECT
    YEAR(Production_Date) AS Production_Year,
    COUNT(*) AS Total_Records,
    SUM(Production_Quantity_Tons) AS Total_Production_Tons,
    SUM(Energy_Consumption_MWh) AS Total_Energy_MWh,
    SUM(Defect_Quantity_Tons) AS Total_Defect_Tons,
    SUM(Downtime_Minutes) AS Total_Downtime_Minutes
FROM steel_plant_combineddata
GROUP BY YEAR(Production_Date)
ORDER BY Production_Year;


-- ============================================================
-- 39. MONTHLY PRODUCTION COMPARISON
-- ============================================================

-- Analyze monthly production performance and compare each
-- month with the previous month.

SELECT
    YEAR(Production_Date) AS Production_Year,
    MONTH(Production_Date) AS Month_Number,
    DATENAME(MONTH, Production_Date) AS Month_Name,
    SUM(Production_Quantity_Tons) AS Monthly_Production_Tons,
    LAG(SUM(Production_Quantity_Tons)) OVER (
        PARTITION BY YEAR(Production_Date)
        ORDER BY MONTH(Production_Date)
    ) AS Previous_Month_Production
FROM steel_plant_combineddata
GROUP BY
    YEAR(Production_Date),
    MONTH(Production_Date),
    DATENAME(MONTH, Production_Date)
ORDER BY
    Production_Year,
    Month_Number;


-- ============================================================
-- 40. DEPARTMENT AND SHIFT PRODUCTION ANALYSIS
-- ============================================================
-- Purpose:
-- Evaluate production performance across different
-- departments and shifts.

SELECT
    Department_Name,
    Shift_Name,
    SUM(Production_Quantity_Tons) AS Total_Production_Tons,
    SUM(Downtime_Minutes) AS Total_Downtime_Minutes
FROM steel_plant_combineddata
GROUP BY
    Department_Name,
    Shift_Name
ORDER BY
    Total_Production_Tons DESC;


-- ============================================================
-- 41. SHIFT-WISE QUALITY ANALYSIS
-- ============================================================
-- Purpose:
-- Analyze quality performance across different
-- production shifts.

SELECT
    Shift_Name,
    Quality_Status,
    COUNT(*) AS Total_Records,
    cast(SUM(Production_Quantity_Tons)as decimal(18,2)) AS Total_Production_Tons,
    cast(SUM(Defect_Quantity_Tons)as decimal(18,2) )AS Total_Defect_Tons
FROM steel_plant_combineddata
GROUP BY
    Shift_Name,
    Quality_Status
ORDER BY
    Shift_Name,
    Total_Production_Tons DESC;


-- ============================================================
-- 42. DEPARTMENT-WISE DEFECT RATE
-- ============================================================
-- Purpose:
-- Calculate the defect rate for each department
-- based on total production.

SELECT
    Department_Name,
    SUM(Production_Quantity_Tons) AS Total_Production_Tons,
    SUM(Defect_Quantity_Tons) AS Total_Defect_Tons,
    CAST(
        SUM(Defect_Quantity_Tons) * 100.0
        / NULLIF(SUM(Production_Quantity_Tons), 0)
        AS DECIMAL(10,2)
    ) AS Defect_Rate_Percent
FROM steel_plant_combineddata
GROUP BY
    Department_Name
ORDER BY
    Defect_Rate_Percent DESC;


-- ============================================================
-- 43. MACHINE-WISE DEFECT RATE
-- ============================================================
-- Purpose:
-- Identify machines with higher defect rates
-- relative to their production output.

SELECT
    Machine_ID,
    SUM(Production_Quantity_Tons) AS Total_Production_Tons,
    SUM(Defect_Quantity_Tons) AS Total_Defect_Tons,
    CAST(
        SUM(Defect_Quantity_Tons) * 100.0
        / NULLIF(SUM(Production_Quantity_Tons), 0)
        AS DECIMAL(10,2)
    ) AS Defect_Rate_Percent
FROM steel_plant_combineddata
GROUP BY
    Machine_ID
ORDER BY
    Defect_Rate_Percent DESC;


-- ============================================================
-- 44. MACHINE PRODUCTION EFFICIENCY
-- ============================================================
-- Purpose:
-- Measure machine productivity in relation
-- to recorded downtime.

SELECT
    Machine_ID,
    SUM(Production_Quantity_Tons) AS Total_Production_Tons,
    SUM(Downtime_Minutes) AS Total_Downtime_Minutes,
    CAST(
        SUM(Production_Quantity_Tons)
        / NULLIF(SUM(Downtime_Minutes), 0)
        AS DECIMAL(10,2)
    ) AS Production_Per_Downtime_Minute
FROM steel_plant_combineddata
GROUP BY
    Machine_ID
ORDER BY
    Production_Per_Downtime_Minute DESC;


-- ============================================================
-- 45. DOWNTIME REASON BY DEPARTMENT
-- ============================================================
-- Analyze the major downtime reasons affecting
-- each department.

SELECT
    Department_Name,
    Downtime_Reason,
    SUM(Downtime_Minutes) AS Total_Downtime_Minutes
FROM steel_plant_combineddata
GROUP BY
    Department_Name,
    Downtime_Reason
ORDER BY
    Department_Name,
    Total_Downtime_Minutes DESC;


-- ============================================================
-- 46. DOWNTIME REASON BY MACHINE
-- ============================================================
-- Identify the primary downtime reasons associated
-- with individual machines.

SELECT
    Machine_ID,
    Downtime_Reason,
    SUM(Downtime_Minutes) AS Total_Downtime_Minutes
FROM steel_plant_combineddata
GROUP BY
    Machine_ID,
    Downtime_Reason
ORDER BY
    Total_Downtime_Minutes DESC;


-- ============================================================
-- 47. TOP 10 MACHINES BY DEFECT QUANTITY
-- ============================================================
-- Identify the ten machines generating
-- the highest defect quantities.

SELECT TOP 10
    Machine_ID,
    SUM(Defect_Quantity_Tons) AS Total_Defect_Tons
FROM steel_plant_combineddata
GROUP BY
    Machine_ID
ORDER BY
    Total_Defect_Tons DESC;


-- ============================================================
-- 48. OPERATOR-WISE PRODUCTION ANALYSIS
-- ============================================================

-- Evaluate production output, defects, and downtime
-- associated with each operator.

SELECT top 10
    Operator_ID,
    COUNT(*) AS Total_Production_Records,
    SUM(Production_Quantity_Tons) AS Total_Production_Tons,
    SUM(Defect_Quantity_Tons) AS Total_Defect_Tons,
    SUM(Downtime_Minutes) AS Total_Downtime_Minutes
FROM steel_plant_combineddata
GROUP BY
    Operator_ID
ORDER BY
    Total_Production_Tons DESC ;


-- ============================================================
-- 49. OPERATOR QUALITY PERFORMANCE
-- ============================================================
-- Purpose:
-- Measure operator-level defect rates
-- relative to production output.

SELECT
    Operator_ID,
    SUM(Production_Quantity_Tons) AS Total_Production_Tons,
    SUM(Defect_Quantity_Tons) AS Total_Defect_Tons,
    CAST(
        SUM(Defect_Quantity_Tons) * 100.0
        / NULLIF(SUM(Production_Quantity_Tons), 0)
        AS DECIMAL(10,2)
    ) AS Defect_Rate_Percent
FROM steel_plant_combineddata
GROUP BY
    Operator_ID
ORDER BY
    Defect_Rate_Percent DESC;


-- ============================================================
-- 50. PRODUCT-WISE ENERGY EFFICIENCY
-- ============================================================
-- Compare energy consumption per ton
-- across different products.

SELECT
    Product_Name,
    SUM(Production_Quantity_Tons) AS Total_Production_Tons,
    SUM(Energy_Consumption_MWh) AS Total_Energy_MWh,
    CAST(
        SUM(Energy_Consumption_MWh)
        / NULLIF(SUM(Production_Quantity_Tons), 0)
        AS DECIMAL(10,4)
    ) AS Energy_Per_Ton
FROM steel_plant_combineddata
GROUP BY
    Product_Name
ORDER BY
    Energy_Per_Ton;



-- ============================================================
-- 51. QUALITY STATUS DISTRIBUTION PERCENTAGE
-- ============================================================
-- Purpose:
-- Determine the percentage contribution of each
-- quality status across total production records.

SELECT
    Quality_Status,
    COUNT(*) AS Total_Records,
    CAST(
        COUNT(*) * 100.0
        / SUM(COUNT(*)) OVER ()
        AS DECIMAL(10,2)
    ) AS Quality_Percentage
FROM steel_plant_combineddata
GROUP BY
    Quality_Status
ORDER BY
    Quality_Percentage DESC;


-- ============================================================
-- 52. DEPARTMENT PRODUCTION CONTRIBUTION
-- ============================================================
-- Purpose:
-- Measure each department's contribution
-- to total plant production.

SELECT
    Department_Name,
    SUM(Production_Quantity_Tons) AS Department_Production_Tons,
    CAST(
        SUM(Production_Quantity_Tons) * 100.0
        / SUM(SUM(Production_Quantity_Tons)) OVER ()
        AS DECIMAL(10,2)
    ) AS Production_Contribution_Percent
FROM steel_plant_combineddata
GROUP BY
    Department_Name
ORDER BY
    Production_Contribution_Percent DESC;



-- ============================================================
-- 52. MACHINE DOWNTIME AND DEFECT ANALYSIS
-- ============================================================
-- Purpose:
-- Identify machines with significant downtime
-- and defect quantities for operational review.

SELECT
    Machine_ID,
    Cast(SUM(Production_Quantity_Tons)as decimal(18,2)) AS Total_Production_Tons,
    SUM(Downtime_Minutes) AS Total_Downtime_Minutes,
    cast(SUM(Defect_Quantity_Tons)as decimal(18,2)) AS Total_Defect_Tons,
    CAST(
        SUM(Defect_Quantity_Tons) * 100.0
        / NULLIF(SUM(Production_Quantity_Tons), 0)
        AS DECIMAL(10,2)
    ) AS Defect_Rate_Percent
FROM steel_plant_combineddata
GROUP BY
    Machine_ID
HAVING
    SUM(Downtime_Minutes) > 0
    AND SUM(Defect_Quantity_Tons) > 0
ORDER BY
Defect_Rate_Percent,
    Total_Downtime_Minutes DESC;
    
	SELECT
    Shift_Name,
    SUM(Production_Quantity_Tons) AS Total_Production_Tons,
    SUM(Defect_Quantity_Tons) AS Total_Defects_Tons,
    CAST(
        SUM(Defect_Quantity_Tons) * 100.0 /
        NULLIF(SUM(Production_Quantity_Tons), 0)
        AS DECIMAL(18,2)
    ) AS Defect_Rate_Percent
FROM steel_plant_combineddata
GROUP BY Shift_Name
ORDER BY Defect_Rate_Percent DESC;