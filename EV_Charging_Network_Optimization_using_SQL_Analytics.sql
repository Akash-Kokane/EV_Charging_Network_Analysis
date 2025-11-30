CREATE DATABASE my_ev;
USE my_ev;


-- Task 1: Understanding Data
SELECT * FROM customer_usage;
SELECT * FROM charging_sessions;
SELECT * FROM ev_stations;

-- Q1. Display the total number of EV stations available in the dataset.
SELECT 
    DISTINCT COUNT(*) AS TotalEvStations 
FROM ev_stations;

/* OUTCOME: 
The dataset contains 50 EV charging stations, indicating the size of the charging network being analyzed.
*/

-- Q2. Find how many customers are registered per city.
SELECT 
    City, 
    COUNT(*) AS TotalCustomers
FROM customer_usage
GROUP BY City;

/* Outcome: 
Delhi has the highest number of EV users (37), indicating strong EV adoption.
Pune, Mumbai, and Bangalore show similar customer bases (30–32 range).
Hyderabad has the smallest user base (21), suggesting lower adoption or fewer stations.
*/

-- Q3. Get the number of charging sessions recorded overall.
SELECT 
    COUNT(*) AS TotalSessions
FROM charging_sessions;

/* Outcome: 
The dataset contains 1000 charging sessions, giving a substantial amount of user behavior and energy usage data to analyze.
*/

-- Q4. Find the earliest and latest installation dates of EV stations.
SELECT 
    MIN(installation_date) AS EarliestsStation,
    MAX(installation_date) AS LatestStation
FROM ev_stations;

/* Outcome: 
The first EV charging station in the dataset was installed on 3 April 2018.
The most recent installation occurred on 26 August 2024.
This shows a 6+ year development period, indicating continuous growth of the EV charging network.
*/

-- Q5. Calculate the total energy consumed per city.
SELECT
    cu.City,
    SUM(cs.energy_kWh) AS TotalEnergy
FROM customer_usage AS cu
INNER JOIN charging_sessions AS cs
ON cu.user_id = cs.vehicle_id
GROUP BY City;

/* Outcome: 
Delhi has the `highest EV charging demand`.
Pune & Mumbai show very similar and strong energy usage.
Hyderabad has the `lowest`, indicating fewer sessions or fewer EVs.
*/

-- Q6. Find the average energy per session for each vehicle type.
SELECT 
    cu.vehicle_type,
    ROUND(AVG(cs.energy_kWh), 2) AS AvgEnergy
FROM charging_sessions AS cs
INNER JOIN customer_usage AS cu
ON cu.user_id = cs.vehicle_id
GROUP BY vehicle_type;

/* Outcome: 
All vehicle types consume around 42–44 kWh on average, indicating balanced charging needs.
4W vehicles consume the most energy per session (43.64 kWh), consistent with larger battery requirements.
Buses consume the least (42.21 kWh), likely due to more frequent smaller charges.
Energy consumption is fairly consistent across vehicle types, but 4-wheelers slightly lead due to higher battery capacity.
*/

-- Q7. Display top 5 cities by total revenue from charging sessions.
SELECT
    cu.city,
    ROUND(SUM(cs.cost_inr),2) AS TotalRevenue
FROM customer_usage AS cu
INNER JOIN charging_sessions AS cs
ON cu.user_id = cs.vehicle_id
GROUP BY cu.city
ORDER BY TotalRevenue DESC
LIMIT 5;

/* Outcome: 
Delhi leads with the highest revenue — indicates dense EV adoption.
Pune & Mumbai perform strongly due to significant EV penetration.
Bangalore contributes moderately—likely driven by tech workforce.
Hyderabad ranks 5th, showing potential for further EV expansion.
*/

-- Q8. Find average cost per kWh for each membership level.
SELECT 
    cu.membership_status,
    ROUND(AVG(cs.cost_inr/cs.energy_kWh),2) AS AvgCost
FROM customer_usage AS cu
INNER JOIN charging_sessions AS cs
ON cu.user_id = cs.vehicle_id
GROUP BY cu.membership_status;

/* Outcome: 
Platinum members pay the highest avg cost per kWh (₹11.52)
→ This is unusual unless Platinum offers non-monetary perks (priority access, fast-charging lanes).
Basic users pay the lowest (₹11.25)
Indicates basic pricing is subsidized or discounts apply on membership upgrades.
*/

-- Q9. Determine total revenue generated per vehicle type.
SELECT
    cu.vehicle_type,
    ROUND(SUM(cs.cost_inr),2) AS total_revenue
FROM customer_usage AS cu
INNER JOIN charging_sessions AS cs
GROUP BY cu.vehicle_type;

/* Outcome: 
3Ws generate the highest revenue, indicating frequent usage or higher per-session cost.
Buses also contribute significantly despite fewer units.
4Ws and 2Ws have equal revenue, suggesting similar usage patterns.
Focus on 3Ws and Buses could further optimize revenue through targeted strategies.
*/


-- Q10. Find total charging sessions and average duration per city.
SELECT
    cu.city,
    COUNT(session_id) AS total_sessions,
    ROUND(AVG(duration_min),2) AS avg_duration
FROM charging_sessions AS cs
INNER JOIN customer_usage AS cu
ON cu.user_id = cs.vehicle_id
GROUP BY cu.city;

/* Outcome: 
Delhi has the most charging sessions, while Pune records the longest average charging duration; 
Hyderabad has the shortest, with Mumbai and Bangalore showing moderate usage.
*/

-- Q11. Rank cities by total energy consumption using window function.    
SELECT
    cu.city,
    ROUND(SUM(cs.energy_kWh),2) AS total_energy,
    RANK() OVER(ORDER BY ROUND(SUM(cs.energy_kWh),2) DESC) AS energy_rank
FROM customer_usage AS cu
INNER JOIN charging_sessions AS cs
ON user_id = vehicle_id
GROUP BY cu.city;

/* Outcome: 
Delhi leads in total energy consumption, followed by Pune and Mumbai, while Hyderabad has the lowest usage among the cities.
*/

-- Q12. Identify stations with capacity greater than 75 kW.
SELECT 
    city, 
    location, capacity_kW 
FROM ev_stations
WHERE capacity_kW > 75
ORDER BY capacity_kW DESC;

/* Outcome: 
Most high-capacity stations (≥100 kW) are concentrated in major cities like Mumbai, Delhi, Pune, Bangalore, and Hyderabad, 
with peak capacities of 150 kW at key locations.
*/

-- Q13. Find customers with more than 10 sessions (frequent users).
SELECT
    cu.user_id,
    cu.city,
    COUNT(cs.session_id) AS total_sessions
FROM charging_sessions AS cs
INNER JOIN customer_usage AS cu
ON user_id = vehicle_id
GROUP BY cu.user_id, cu.city
HAVING total_sessions > 10
ORDER BY total_sessions DESC;

/* Outcome: 
Delhi users are the most frequent, with the highest number of sessions (16), followed by 
Pune, Hyderabad, and Mumbai, indicating strong EV adoption and repeat usage in these cities.
*/

-- Q14. Find city-wise average revenue per customer.
SELECT
     cu.city,
     ROUND(SUM(cs.cost_inr) / COUNT(DISTINCT cu.user_id)) AS avg_revenue_per_cust
FROM charging_sessions AS cs
JOIN customer_usage AS cu
ON cu.user_id = cs.vehicle_id
GROUP BY cu.city
ORDER BY avg_revenue_per_cust DESC;

/* Outcome: 
Mumbai and Hyderabad generate the highest average revenue per customer, 
while Delhi has the lowest, indicating stronger per-customer spending in Mumbai and Hyderabad EV markets.
*/

-- Q15. Find the most common membership type across users.
SELECT 
    membership_status,
    COUNT(*) AS common_type
FROM customer_usage
GROUP BY membership_status
ORDER BY common_type DESC;

/* Outcome: 
Gold is the most common membership among users, followed closely by Platinum and Basic, 
indicating a preference for mid-to-premium membership tiers.
*/

-- Q16. Compute total revenue per membership tier.
SELECT
    cu.membership_status,
    ROUND(SUM(cs.cost_inr),2) AS total_revenue
FROM charging_sessions AS cs
JOIN customer_usage AS cu
ON cu.user_id = cs.vehicle_id
GROUP BY cu.membership_status
ORDER BY total_revenue DESC;

/* Outcome:
Platinum members generate the highest total revenue, followed by Gold and Basic, while Silver contributes 
the least, showing that premium memberships drive more revenue despite fewer users.
*/

-- Q17. Find the top 3 most expensive sessions per city.
SELECT 
    *
FROM (
        SELECT 
            cu.city, 
            cs.session_id, 
            cs.cost_inr,
            RANK() OVER(PARTITION BY cu.city ORDER BY cs.cost_inr DESC) AS cost_rank
        FROM charging_sessions AS cs
        JOIN customer_usage AS cu
        ON cu.user_id = cs.vehicle_id
        )t
WHERE cost_rank <=3;

/* Outcome: 
 Pune has the highest-cost sessions, with the top session at ₹1,184.41, while other cities like Delhi, Hyderabad, Mumbai, and Bangalore 
 have sessions slightly above ₹1,000, indicating occasional high-value charging activity across all major cities.
*/

-- Q18. Identify the longest charging session per vehicle type.
SELECT
    cu.vehicle_type,
    MAX(duration_min) AS longest_duration
FROM customer_usage AS cu
JOIN charging_sessions AS cs
ON cu.user_id = cs.vehicle_id
GROUP BY cu.vehicle_type
ORDER BY longest_duration DESC;

/* Outcome: 
The longest charging sessions are around `180 minutes` for Buses, 2Ws, and 3Ws, with 4Ws slightly lower at 179 minutes, 
showing similar maximum charging times across vehicle types.
*/