# EV_Charging_Network_Analysis

## 1. Introduction

Electric Vehicle (EV) adoption is rapidly increasing, and EV charging infrastructure plays a crucial role in supporting this transition. This SQL project analyzes a fictional EV charging network database named my_ev, containing real-world–style datasets on customers, charging sessions, and charging stations.

The goal of this project is to derive meaningful business insights, optimize infrastructure planning, and understand customer behavior using SQL queries.

---
## 2. Project Objectives
1. This project focuses on answering important business questions:
2. Business Goals
3. Understand EV station distribution and infrastructure growth
4. Analyze customer base, usage behavior, and geographic distribution
5. Study energy consumption patterns
6. Identify revenue-generating segments (city, vehicle type, membership)
7. Discover operational metrics such as session duration and charging demand

---
## 3. Database & Tables

The project uses 3 main tables:

### 1. customer_usage
* user_id
* city
* vehicle_type
* membership_status

### 2. charging_sessions
* session_id
* vehicle_id
* start_time
* energy_kWh
* duration_min
* cost_inr

### 3. ev_stations
* station_id
* city
* installation_date
* location
* capacity_kW

---
##  4. SQL Tasks & Analysis
Below is a detailed explanation of insights generated from each query.

---
## Task 1: Understanding Data
Basic exploration of all three tables helps in understanding structure, row count, and column details.
```sql
SELECT * FROM customer_usage;
SELECT * FROM charging_sessions;
SELECT * FROM ev_stations;
```
---
## **Q1. Display the total number of EV stations available in the dataset.**

```sql
SELECT 
    COUNT(*) AS total_ev_stations
FROM ev_stations;
```
**Insight:** 
* The dataset contains `50 EV charging stations`, indicating the size of the charging network being analyzed.

## **Q2. Find how many customers are registered per city.**

```sql
SELECT 
    city,
    COUNT(*) AS total_customers
FROM customer_usage
GROUP BY city;
```
**Insight:**
* `Delhi` has the highest number of EV users (37), indicating strong EV adoption.
* `Pune, Mumbai`, and Bangalore show similar customer bases (30–32 range).
* `Hyderabad` has the smallest user base (21), suggesting lower adoption or fewer stations.

---
## **Q3. Get the number of charging sessions recorded overall.**

```sql
SELECT 
    COUNT(*) AS total_sessions
FROM charging_sessions;
```
**Insight:**
* The dataset contains `1000 charging sessions`, giving a substantial amount of user behavior and energy usage data to analyze.

---
## **Q4. Find the earliest and latest installation dates of EV stations.**

```sql
SELECT 
    MIN(installation_date) AS earliest_station,
    MAX(installation_date) AS latest_station
FROM ev_stations;
```
**Insight:**
* The `first EV charging station` in the dataset was installed on `3 April 2018`.
* The `most recent installation` occurred on `26 August 2024`.
* This shows a `6+ year development period`, indicating continuous growth of the EV charging network.

## **Q5. Calculate the total energy consumed per city.**

```sql
SELECT
    cu.city,
    SUM(cs.energy_kWh) AS total_energy
FROM customer_usage cu
JOIN charging_sessions cs
    ON cu.user_id = cs.vehicle_id
GROUP BY cu.city;
```
**Insight:**
* Delhi has the `highest EV charging demand`.
* Pune & Mumbai show very similar and strong energy usage.
* Hyderabad has the `lowest`, indicating fewer sessions or fewer EVs.

---

## **Q6. Find the average energy per session for each vehicle type.**

```sql
SELECT 
    cu.vehicle_type,
    ROUND(AVG(cs.energy_kWh), 2) AS avg_energy
FROM charging_sessions cs
JOIN customer_usage cu
    ON cu.user_id = cs.vehicle_id
GROUP BY cu.vehicle_type;
```
**Insight:**
* All vehicle types consume `around 42–44 kWh on average`, indicating balanced charging needs.
* `4W vehicles consume the most energy` per session (43.64 kWh), consistent with larger battery requirements.
* `Buses consume the least` (42.21 kWh), likely due to more frequent smaller charges.
* Energy consumption is fairly consistent across vehicle types, but 4-wheelers slightly lead due to higher battery capacity.

---

## **Q7. Display top 5 cities by total revenue from charging sessions.**

```sql
SELECT
    cu.city,
    ROUND(SUM(cs.cost_inr), 2) AS total_revenue
FROM customer_usage cu
JOIN charging_sessions cs
    ON cu.user_id = cs.vehicle_id
GROUP BY cu.city
ORDER BY total_revenue DESC
LIMIT 5;
```
**Insight:**
1. `Delhi` leads with the highest revenue — indicates dense EV adoption.
2. `Pune & Mumbai` perform strongly due to significant EV penetration.
3. `Bangalore` contributes moderately—likely driven by tech workforce.
4. `Hyderabad` ranks 5th, showing potential for further EV expansion.

---

## **Q8. Find average cost per kWh for each membership level.**

```sql
SELECT 
    cu.membership_status,
    ROUND(AVG(cs.cost_inr / cs.energy_kWh), 2) AS avg_cost_per_kwh
FROM customer_usage cu
JOIN charging_sessions cs
    ON cu.user_id = cs.vehicle_id
GROUP BY cu.membership_status;
```
**Insight:**
* `Platinum members pay the highest avg cost per kWh (₹11.52)`
* → This is unusual unless Platinum offers non-monetary perks (priority access, fast-charging lanes).
* `Basic users pay the lowest (₹11.25)`
* → Indicates basic pricing is subsidized or discounts apply on membership upgrades.

---

## **Q9. Determine total revenue generated per vehicle type.**

```sql
SELECT
    cu.vehicle_type,
    ROUND(SUM(cs.cost_inr), 2) AS total_revenue
FROM customer_usage cu
JOIN charging_sessions cs
    ON cu.user_id = cs.vehicle_id
GROUP BY cu.vehicle_type;
```
**Insight:**
* `3Ws` generate the highest revenue, indicating frequent usage or higher per-session cost.
* `Buses` also contribute significantly despite fewer units.
* `4Ws and 2Ws` have equal revenue, suggesting similar usage patterns.
* `Focus on 3Ws and Buses` could further optimize revenue through targeted strategies.

---

## **Q10. Find total charging sessions & average duration per city.**

```sql
SELECT
    cu.city,
    COUNT(cs.session_id) AS total_sessions,
    ROUND(AVG(cs.duration_min), 2) AS avg_duration
FROM charging_sessions cs
JOIN customer_usage cu
    ON cu.user_id = cs.vehicle_id
GROUP BY cu.city;
```
**Insight:**
* Delhi has the most charging sessions, while Pune records the longest average charging duration; Hyderabad has the shortest, with Mumbai and Bangalore showing moderate usage.

---

## **Q11. Rank cities by total energy consumption (Window Function).**

```sql
SELECT
    cu.city,
    ROUND(SUM(cs.energy_kWh), 2) AS total_energy,
    RANK() OVER (ORDER BY SUM(cs.energy_kWh) DESC) AS energy_rank
FROM customer_usage cu
JOIN charging_sessions cs
    ON cu.user_id = cs.vehicle_id
GROUP BY cu.city;
```
**Insight:**
* Delhi leads in total energy consumption, followed by Pune and Mumbai, while Hyderabad has the lowest usage among the cities.

---

## **Q12. Identify stations with capacity greater than 75 kW.**

```sql
SELECT 
    city,
    location,
    capacity_kW
FROM ev_stations
WHERE capacity_kW > 75
ORDER BY capacity_kW DESC;
```
**Insight:**
* Most high-capacity stations (≥100 kW) are concentrated in major cities like Mumbai, Delhi, Pune, Bangalore, and Hyderabad, with peak capacities of 150 kW at key locations.

---

## **Q13. Find customers with more than 10 sessions (frequent users).**

```sql
SELECT
    cu.user_id,
    cu.city,
    COUNT(cs.session_id) AS total_sessions
FROM charging_sessions cs
JOIN customer_usage cu
    ON cu.user_id = cs.vehicle_id
GROUP BY cu.user_id, cu.city
HAVING COUNT(cs.session_id) > 10
ORDER BY total_sessions DESC;
```
**Insight:**
* Delhi users are the most frequent, with the highest number of sessions (16), followed by Pune, Hyderabad, and Mumbai, indicating strong EV adoption and repeat usage in these cities.

---

## **Q14. City-wise average revenue per customer.**

```sql
SELECT
    cu.city,
    ROUND(SUM(cs.cost_inr) / COUNT(DISTINCT cu.user_id), 2) AS avg_revenue_per_customer
FROM charging_sessions cs
JOIN customer_usage cu
    ON cu.user_id = cs.vehicle_id
GROUP BY cu.city
ORDER BY avg_revenue_per_customer DESC;
```
**Insight:**
* Mumbai and Hyderabad generate the highest average revenue per customer, while Delhi has the lowest, indicating stronger per-customer spending in Mumbai and Hyderabad EV markets.

---

## **Q15. Most common membership type across users.**

```sql
SELECT 
    membership_status,
    COUNT(*) AS membership_count
FROM customer_usage
GROUP BY membership_status
ORDER BY membership_count DESC;
```
**Insight:**
* Gold is the most common membership among users, followed closely by Platinum and Basic, indicating a preference for mid-to-premium membership tiers.

---

## **Q16. Compute total revenue per membership tier.**

```sql
SELECT
    cu.membership_status,
    ROUND(SUM(cs.cost_inr), 2) AS total_revenue
FROM charging_sessions cs
JOIN customer_usage cu
    ON cu.user_id = cs.vehicle_id
GROUP BY cu.membership_status
ORDER BY total_revenue DESC;
```
**Insight:**
* `Platinum members` generate the highest total revenue, followed by Gold and Basic, while Silver contributes the least, showing that premium memberships drive more revenue despite fewer users.

---

## **Q17. Top 3 most expensive sessions per city.**

```sql
SELECT 
    city,
    session_id,
    cost_inr,
    cost_rank
FROM (
    SELECT 
        cu.city,
        cs.session_id,
        cs.cost_inr,
        RANK() OVER (PARTITION BY cu.city ORDER BY cs.cost_inr DESC) AS cost_rank
    FROM charging_sessions cs
    JOIN customer_usage cu
        ON cu.user_id = cs.vehicle_id
) AS ranked_sessions
WHERE cost_rank <= 3;
```
**Insight:**
* Pune has the highest-cost sessions, with the top session at ₹1,184.41, while other cities like Delhi, Hyderabad, Mumbai, and Bangalore have sessions slightly above ₹1,000, indicating occasional high-value charging activity across all major cities.

---

## **Q18. Longest charging session per vehicle type.**

```sql
SELECT
    cu.vehicle_type,
    MAX(cs.duration_min) AS longest_duration
FROM customer_usage cu
JOIN charging_sessions cs
    ON cu.user_id = cs.vehicle_id
GROUP BY cu.vehicle_type
ORDER BY longest_duration DESC;
```
**Insight:**
* The longest charging sessions are around `180 minutes` for Buses, 2Ws, and 3Ws, with 4Ws slightly lower at 179 minutes, showing similar maximum charging times across vehicle types.

---

## 5. Conclusion

This SQL project provides a comprehensive analysis of an EV charging network. By leveraging SQL joins, aggregations, window functions, and filtering, we uncover insights across customer behavior, charging patterns, revenue distribution, and station performance.

The results can help stakeholders optimize:

* Infrastructure planning
* Pricing strategy
* Membership offerings
* City-level expansion
* EV customer retention
