# Product Data Analysis Case Study Assignment

## About the Case
This case study has the objective of evaluating data analytics skills across SQL, A/B testing, and forecasting. Bonus questions are not mandatory but could improve the final evaluation score.

## About the Company
The case study is set in the context of an application that connects Padel clubs and Padel players. The platform offers two main products:

1. **Online Court Bookings**: Users can reserve a padel court for a chosen timeslot and pay in advance. They can share the booking link with colleagues to join the game, or keep it blank and organize the match independently outside the app.

2. **Open Matches**: Community-created games where users can participate without needing to find additional players to complete the match.

## Data Description

### Users Table
Contains information about registered users in the application.

| USER_ID | CREATED_AT | USER_COUNTRY | USER_LEVEL |
|---------|------------|--------------|------------|
| 123456789 | 2022-05-17 | Spain | 2.5 |
| 234567890 | 2022-08-06 | Spain | 3.0 |
| 345678901 | 2023-03-25 | Spain | 2.0 |
| 456789012 | 2023-08-11 | Spain | 3.5 |

### Online Court Bookings Table
Contains data about the online court bookings product. Note that some rows have NULL user_id which means that information about player 2, 3, or 4 are not filled.

| BOOKING_ID | OWNER_ID | USER_ID | CREATED_AT | PLAYED_AT | CLUB_ID | CLUB_COUNTRY | PAYMENT_AMOUNT | B2C_COMMISSION_AMOUNT |
|------------|----------|---------|------------|-----------|---------|--------------|----------------|------------------------|
| 15274734 | 123456789 | 123456789 | 2024-01-17 | 2024-01-23 | 5555555 | Spain | 25 | 1 |
| 15274734 | 123456789 | 234567890 | 2024-01-17 | 2024-01-23 | 5555555 | Spain | 0 | 0 |
| 15274734 | 123456789 | NULL | NULL | 2024-01-23 | 5555555 | Spain | 0 | 0 |
| 15274734 | 123456789 | NULL | NULL | 2024-01-23 | 5555555 | Spain | 0 | 0 |
| 55234774 | 123456789 | 123456789 | 2024-05-06 | 2024-05-14 | 6666666 | Spain | 7 | 0.5 |
| 55234774 | 123456789 | 234567890 | 2024-05-07 | 2024-05-14 | 6666666 | Spain | 7 | 0.5 |
| 55234774 | 123456789 | 745378931 | 2024-05-07 | 2024-05-14 | 6666666 | Spain | 7 | 0.5 |
| 55234774 | 123456789 | 656383722 | 2024-05-08 | 2024-05-14 | 6666666 | Spain | 7 | 0.5 |

### Open Matches Table
Similar to the court_bookings table. An open match is ready to play when it has all required players.

| MATCH_ID / BOOKING_ID | OWNER_ID | USER_ID | CREATED_AT | PLAYED_AT | CLUB_ID | CLUB_COUNTRY | PAYMENT_AMOUNT | B2C_COMMISSION_AMOUNT |
|-----------------------|----------|---------|------------|-----------|---------|--------------|----------------|------------------------|
| 15274734 | NULL | 345678901 | 2023-11-20 | 2023-11-23 | 5555555 | Spain | 7 | 0.5 |
| 15274734 | NULL | NULL | 2023-11-20 | 2023-11-23 | 5555555 | Spain | 7 | 0.5 |
| 15274734 | NULL | NULL | 2023-11-20 | 2023-11-23 | 5555555 | Spain | 7 | 0.5 |
| 15274734 | NULL | NULL | 2023-11-20 | 2023-11-23 | 5555555 | Spain | 7 | 0.5 |
| 55234774 | NULL | 456789012 | 2024-03-23 | 2024-04-01 | 6666666 | Spain | 8 | 0.65 |
| 55234774 | NULL | 521236334 | 2024-03-23 | 2024-04-01 | 6666666 | Spain | 8 | 0.65 |
| 55234774 | NULL | 736345353 | 2024-03-23 | 2024-04-01 | 6666666 | Spain | 8 | 0.65 |
| 55234774 | NULL | 264573453 | 2024-03-23 | 2024-04-01 | 6666666 | Spain | 8 | 0.65 |

## Part 1: SQL Tasks

1. Write SQL queries to calculate:
   - The number of users and the average user level breakdown by user creation date.
   - The number of users who have played at least 1 open match and 1 online court booking match.
   - For online court bookings: The number of bookings, the total payment amount, the total b2c commission, and the margin/take rate —breakdown by user country.
   - For open matches: Create a rank based on the created_at date per match_id.
   
   Example of rank output:
   
   | match_id | user_id | created_at | rank |
   |----------|---------|------------|------|
   | 1 | A | 2023-01-03 17:00:00 | 2 |
   | 1 | B | 2023-01-03 10:00:00 | 1 |
   | 2 | C | 2022-01-04 12:00:00 | 1 |
   | 2 | D | 2022-01-04 15:00:00 | 2 |

2. Write a SQL query for a funnel analysis: Show per user creation year, the conversion from user creation to an open match.

   Expected output format:
   
   | creation_year | count_users | converted_users | conversion_rate |
   |---------------|-------------|-----------------|-----------------|
   | 2023 | 10,000 | 5,000 | 50% |
   | 2022 | 8,000 | 3,500 | 43.75% |
   | 2021 | 7,000 | 2,000 | 28.57% |

   Extra points: Performance optimization.

## Part 2: A/B Testing & Product Analytics

### Case Overview
You are a data analyst in a marketplace specialized in connecting Padel players with clubs and other players. The company recently implemented a new feature on its application to improve the open matches conversion rate by adding a carousel of recommended open matches in the online court booking flow. An A/B test was conducted to assess the effectiveness of this feature.

### Questions
1. How would you answer the PM (product manager) question about how much time we have to run the experiment?
2. Which roll-out strategy would you recommend as a data analyst if the product team worries about the impact?
3. Which is the primary metric of the experiment? Do you suggest another primary metric?
4. Imagine that you don't want to harm a specific metric (guardrail metric). Which metric would you choose and why?
5. What do you expect to see in the control group, and what do you expect to happen in the treatment group if the hypothesis is valid and the experiment is successful?

### Bonus Questions
- What do you think about adding the retention rate as a guardrail metric?
- Imagine that your PM wants to see the data per country, what are the risks you will take in doing that analysis?
- Repeat exercises 3, 4, and 5 imagining that now the new feature is a pricing test, and the team decided to reduce the commission by 10%.

## Part 3: Forecasting

Using the provided dataset (which can be downloaded and imported as a CSV), forecast the 2024 MAU (Monthly Active Users) because you have signed a contract with a third-party tool that charges by MAU.

### Current Contract Terms
- 1,000,000 MAU per year (1M)
- Fixed cost of 5k dollars per year
- If you surpass 1M MAU, you will be charged $0.006 per additional MAU

### Tasks
1. Share the technique used to forecast the MAUs during 2024 (python code if applied)
2. What would happen in 2024 with the contract? Will we surpass the fixed MAUs?

### Bonus
Imagine the future. Make 3 business scenarios for the following 3-5 years assuming:
- BAU growth (Business as usual)
- The company enters the US market
- The company enters the China and India markets